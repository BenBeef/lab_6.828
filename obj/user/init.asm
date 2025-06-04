
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6f 03 00 00       	call   8003a0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 60 26 80 00       	push   $0x802660
  800072:	e8 64 04 00 00       	call   8004db <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	0f 84 99 00 00 00    	je     800130 <umain+0xd2>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	68 9e 98 0f 00       	push   $0xf989e
  80009f:	50                   	push   %eax
  8000a0:	68 28 27 80 00       	push   $0x802728
  8000a5:	e8 31 04 00 00       	call   8004db <cprintf>
  8000aa:	83 c4 10             	add    $0x10,%esp
			x, want);
	else
		cprintf("init: data seems okay\n");
	if ((x = sum(bss, sizeof bss)) != 0)
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	68 70 17 00 00       	push   $0x1770
  8000b5:	68 20 50 80 00       	push   $0x805020
  8000ba:	e8 74 ff ff ff       	call   800033 <sum>
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	74 7f                	je     800145 <umain+0xe7>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	50                   	push   %eax
  8000ca:	68 64 27 80 00       	push   $0x802764
  8000cf:	e8 07 04 00 00       	call   8004db <cprintf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 9c 26 80 00       	push   $0x80269c
  8000df:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 2f 0a 00 00       	call   800b1a <strcat>
	for (i = 0; i < argc; i++) {
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  8000f3:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  8000f9:	39 fb                	cmp    %edi,%ebx
  8000fb:	7d 5a                	jge    800157 <umain+0xf9>
		strcat(args, " '");
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	68 a8 26 80 00       	push   $0x8026a8
  800105:	56                   	push   %esi
  800106:	e8 0f 0a 00 00       	call   800b1a <strcat>
		strcat(args, argv[i]);
  80010b:	83 c4 08             	add    $0x8,%esp
  80010e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800111:	ff 34 98             	pushl  (%eax,%ebx,4)
  800114:	56                   	push   %esi
  800115:	e8 00 0a 00 00       	call   800b1a <strcat>
		strcat(args, "'");
  80011a:	83 c4 08             	add    $0x8,%esp
  80011d:	68 a9 26 80 00       	push   $0x8026a9
  800122:	56                   	push   %esi
  800123:	e8 f2 09 00 00       	call   800b1a <strcat>
	for (i = 0; i < argc; i++) {
  800128:	83 c3 01             	add    $0x1,%ebx
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	eb c9                	jmp    8000f9 <umain+0x9b>
		cprintf("init: data seems okay\n");
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	68 6f 26 80 00       	push   $0x80266f
  800138:	e8 9e 03 00 00       	call   8004db <cprintf>
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	e9 68 ff ff ff       	jmp    8000ad <umain+0x4f>
		cprintf("init: bss seems okay\n");
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	68 86 26 80 00       	push   $0x802686
  80014d:	e8 89 03 00 00       	call   8004db <cprintf>
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	eb 80                	jmp    8000d7 <umain+0x79>
	}
	cprintf("%s\n", args);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800160:	50                   	push   %eax
  800161:	68 ab 26 80 00       	push   $0x8026ab
  800166:	e8 70 03 00 00       	call   8004db <cprintf>

	cprintf("init: running sh\n");
  80016b:	c7 04 24 af 26 80 00 	movl   $0x8026af,(%esp)
  800172:	e8 64 03 00 00       	call   8004db <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017e:	e8 0c 11 00 00       	call   80128f <close>
	if ((r = opencons()) < 0)
  800183:	e8 c6 01 00 00       	call   80034e <opencons>
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 16                	js     8001a5 <umain+0x147>
		panic("opencons: %e", r);
	if (r != 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	74 24                	je     8001b7 <umain+0x159>
		panic("first opencons used fd %d", r);
  800193:	50                   	push   %eax
  800194:	68 da 26 80 00       	push   $0x8026da
  800199:	6a 39                	push   $0x39
  80019b:	68 ce 26 80 00       	push   $0x8026ce
  8001a0:	e8 5b 02 00 00       	call   800400 <_panic>
		panic("opencons: %e", r);
  8001a5:	50                   	push   %eax
  8001a6:	68 c1 26 80 00       	push   $0x8026c1
  8001ab:	6a 37                	push   $0x37
  8001ad:	68 ce 26 80 00       	push   $0x8026ce
  8001b2:	e8 49 02 00 00       	call   800400 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	6a 01                	push   $0x1
  8001bc:	6a 00                	push   $0x0
  8001be:	e8 1c 11 00 00       	call   8012df <dup>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	79 23                	jns    8001ed <umain+0x18f>
		panic("dup: %e", r);
  8001ca:	50                   	push   %eax
  8001cb:	68 f4 26 80 00       	push   $0x8026f4
  8001d0:	6a 3b                	push   $0x3b
  8001d2:	68 ce 26 80 00       	push   $0x8026ce
  8001d7:	e8 24 02 00 00       	call   800400 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	50                   	push   %eax
  8001e0:	68 13 27 80 00       	push   $0x802713
  8001e5:	e8 f1 02 00 00       	call   8004db <cprintf>
			continue;
  8001ea:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	68 fc 26 80 00       	push   $0x8026fc
  8001f5:	e8 e1 02 00 00       	call   8004db <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001fa:	83 c4 0c             	add    $0xc,%esp
  8001fd:	6a 00                	push   $0x0
  8001ff:	68 10 27 80 00       	push   $0x802710
  800204:	68 0f 27 80 00       	push   $0x80270f
  800209:	e8 86 1c 00 00       	call   801e94 <spawnl>
		if (r < 0) {
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	85 c0                	test   %eax,%eax
  800213:	78 c7                	js     8001dc <umain+0x17e>
		}
		wait(r);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	e8 89 20 00 00       	call   8022a7 <wait>
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	eb ca                	jmp    8001ed <umain+0x18f>

00800223 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800226:	b8 00 00 00 00       	mov    $0x0,%eax
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800233:	68 93 27 80 00       	push   $0x802793
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	e8 ba 08 00 00       	call   800afa <strcpy>
	return 0;
}
  800240:	b8 00 00 00 00       	mov    $0x0,%eax
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <devcons_write>:
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800253:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800258:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80025e:	eb 2f                	jmp    80028f <devcons_write+0x48>
		m = n - tot;
  800260:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800263:	29 f3                	sub    %esi,%ebx
  800265:	83 fb 7f             	cmp    $0x7f,%ebx
  800268:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80026d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800270:	83 ec 04             	sub    $0x4,%esp
  800273:	53                   	push   %ebx
  800274:	89 f0                	mov    %esi,%eax
  800276:	03 45 0c             	add    0xc(%ebp),%eax
  800279:	50                   	push   %eax
  80027a:	57                   	push   %edi
  80027b:	e8 08 0a 00 00       	call   800c88 <memmove>
		sys_cputs(buf, m);
  800280:	83 c4 08             	add    $0x8,%esp
  800283:	53                   	push   %ebx
  800284:	57                   	push   %edi
  800285:	e8 ad 0b 00 00       	call   800e37 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80028a:	01 de                	add    %ebx,%esi
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800292:	72 cc                	jb     800260 <devcons_write+0x19>
}
  800294:	89 f0                	mov    %esi,%eax
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <devcons_read>:
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8002a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002ad:	75 07                	jne    8002b6 <devcons_read+0x18>
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    
		sys_yield();
  8002b1:	e8 1e 0c 00 00       	call   800ed4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8002b6:	e8 9a 0b 00 00       	call   800e55 <sys_cgetc>
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	74 f2                	je     8002b1 <devcons_read+0x13>
	if (c < 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	78 ec                	js     8002af <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8002c3:	83 f8 04             	cmp    $0x4,%eax
  8002c6:	74 0c                	je     8002d4 <devcons_read+0x36>
	*(char*)vbuf = c;
  8002c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cb:	88 02                	mov    %al,(%edx)
	return 1;
  8002cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8002d2:	eb db                	jmp    8002af <devcons_read+0x11>
		return 0;
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	eb d4                	jmp    8002af <devcons_read+0x11>

008002db <cputchar>:
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8002e7:	6a 01                	push   $0x1
  8002e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	e8 45 0b 00 00       	call   800e37 <sys_cputs>
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <getchar>:
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8002fd:	6a 01                	push   $0x1
  8002ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800302:	50                   	push   %eax
  800303:	6a 00                	push   $0x0
  800305:	e8 c1 10 00 00       	call   8013cb <read>
	if (r < 0)
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	78 08                	js     800319 <getchar+0x22>
	if (r < 1)
  800311:	85 c0                	test   %eax,%eax
  800313:	7e 06                	jle    80031b <getchar+0x24>
	return c;
  800315:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    
		return -E_EOF;
  80031b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800320:	eb f7                	jmp    800319 <getchar+0x22>

00800322 <iscons>:
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80032b:	50                   	push   %eax
  80032c:	ff 75 08             	pushl  0x8(%ebp)
  80032f:	e8 26 0e 00 00       	call   80115a <fd_lookup>
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	85 c0                	test   %eax,%eax
  800339:	78 11                	js     80034c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80033b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80033e:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800344:	39 10                	cmp    %edx,(%eax)
  800346:	0f 94 c0             	sete   %al
  800349:	0f b6 c0             	movzbl %al,%eax
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <opencons>:
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 ae 0d 00 00       	call   80110b <fd_alloc>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	78 3a                	js     80039e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800364:	83 ec 04             	sub    $0x4,%esp
  800367:	68 07 04 00 00       	push   $0x407
  80036c:	ff 75 f4             	pushl  -0xc(%ebp)
  80036f:	6a 00                	push   $0x0
  800371:	e8 7d 0b 00 00       	call   800ef3 <sys_page_alloc>
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 21                	js     80039e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800386:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80038b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800392:	83 ec 0c             	sub    $0xc,%esp
  800395:	50                   	push   %eax
  800396:	e8 49 0d 00 00       	call   8010e4 <fd2num>
  80039b:	83 c4 10             	add    $0x10,%esp
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8003ab:	e8 05 0b 00 00       	call   800eb5 <sys_getenvid>
  8003b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bd:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c2:	85 db                	test   %ebx,%ebx
  8003c4:	7e 07                	jle    8003cd <libmain+0x2d>
		binaryname = argv[0];
  8003c6:	8b 06                	mov    (%esi),%eax
  8003c8:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	e8 87 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d7:	e8 0a 00 00 00       	call   8003e6 <exit>
}
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003ec:	e8 c9 0e 00 00       	call   8012ba <close_all>
	sys_env_destroy(0);
  8003f1:	83 ec 0c             	sub    $0xc,%esp
  8003f4:	6a 00                	push   $0x0
  8003f6:	e8 79 0a 00 00       	call   800e74 <sys_env_destroy>
}
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800405:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800408:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040e:	e8 a2 0a 00 00       	call   800eb5 <sys_getenvid>
  800413:	83 ec 0c             	sub    $0xc,%esp
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	56                   	push   %esi
  80041d:	50                   	push   %eax
  80041e:	68 ac 27 80 00       	push   $0x8027ac
  800423:	e8 b3 00 00 00       	call   8004db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800428:	83 c4 18             	add    $0x18,%esp
  80042b:	53                   	push   %ebx
  80042c:	ff 75 10             	pushl  0x10(%ebp)
  80042f:	e8 56 00 00 00       	call   80048a <vcprintf>
	cprintf("\n");
  800434:	c7 04 24 2c 2d 80 00 	movl   $0x802d2c,(%esp)
  80043b:	e8 9b 00 00 00       	call   8004db <cprintf>
  800440:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800443:	cc                   	int3   
  800444:	eb fd                	jmp    800443 <_panic+0x43>

00800446 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	53                   	push   %ebx
  80044a:	83 ec 04             	sub    $0x4,%esp
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800450:	8b 13                	mov    (%ebx),%edx
  800452:	8d 42 01             	lea    0x1(%edx),%eax
  800455:	89 03                	mov    %eax,(%ebx)
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800463:	74 09                	je     80046e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800465:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	68 ff 00 00 00       	push   $0xff
  800476:	8d 43 08             	lea    0x8(%ebx),%eax
  800479:	50                   	push   %eax
  80047a:	e8 b8 09 00 00       	call   800e37 <sys_cputs>
		b->idx = 0;
  80047f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb db                	jmp    800465 <putch+0x1f>

0080048a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800493:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80049a:	00 00 00 
	b.cnt = 0;
  80049d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a7:	ff 75 0c             	pushl  0xc(%ebp)
  8004aa:	ff 75 08             	pushl  0x8(%ebp)
  8004ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b3:	50                   	push   %eax
  8004b4:	68 46 04 80 00       	push   $0x800446
  8004b9:	e8 1a 01 00 00       	call   8005d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004be:	83 c4 08             	add    $0x8,%esp
  8004c1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004cd:	50                   	push   %eax
  8004ce:	e8 64 09 00 00       	call   800e37 <sys_cputs>

	return b.cnt;
}
  8004d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e4:	50                   	push   %eax
  8004e5:	ff 75 08             	pushl  0x8(%ebp)
  8004e8:	e8 9d ff ff ff       	call   80048a <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	57                   	push   %edi
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 1c             	sub    $0x1c,%esp
  8004f8:	89 c7                	mov    %eax,%edi
  8004fa:	89 d6                	mov    %edx,%esi
  8004fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800505:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800508:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80050b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800510:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800513:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800516:	39 d3                	cmp    %edx,%ebx
  800518:	72 05                	jb     80051f <printnum+0x30>
  80051a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051d:	77 7a                	ja     800599 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	ff 75 18             	pushl  0x18(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80052b:	53                   	push   %ebx
  80052c:	ff 75 10             	pushl  0x10(%ebp)
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 e4             	pushl  -0x1c(%ebp)
  800535:	ff 75 e0             	pushl  -0x20(%ebp)
  800538:	ff 75 dc             	pushl  -0x24(%ebp)
  80053b:	ff 75 d8             	pushl  -0x28(%ebp)
  80053e:	e8 dd 1e 00 00       	call   802420 <__udivdi3>
  800543:	83 c4 18             	add    $0x18,%esp
  800546:	52                   	push   %edx
  800547:	50                   	push   %eax
  800548:	89 f2                	mov    %esi,%edx
  80054a:	89 f8                	mov    %edi,%eax
  80054c:	e8 9e ff ff ff       	call   8004ef <printnum>
  800551:	83 c4 20             	add    $0x20,%esp
  800554:	eb 13                	jmp    800569 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	ff 75 18             	pushl  0x18(%ebp)
  80055d:	ff d7                	call   *%edi
  80055f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800562:	83 eb 01             	sub    $0x1,%ebx
  800565:	85 db                	test   %ebx,%ebx
  800567:	7f ed                	jg     800556 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	56                   	push   %esi
  80056d:	83 ec 04             	sub    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	ff 75 e0             	pushl  -0x20(%ebp)
  800576:	ff 75 dc             	pushl  -0x24(%ebp)
  800579:	ff 75 d8             	pushl  -0x28(%ebp)
  80057c:	e8 bf 1f 00 00       	call   802540 <__umoddi3>
  800581:	83 c4 14             	add    $0x14,%esp
  800584:	0f be 80 cf 27 80 00 	movsbl 0x8027cf(%eax),%eax
  80058b:	50                   	push   %eax
  80058c:	ff d7                	call   *%edi
}
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800594:	5b                   	pop    %ebx
  800595:	5e                   	pop    %esi
  800596:	5f                   	pop    %edi
  800597:	5d                   	pop    %ebp
  800598:	c3                   	ret    
  800599:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059c:	eb c4                	jmp    800562 <printnum+0x73>

0080059e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ad:	73 0a                	jae    8005b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b2:	89 08                	mov    %ecx,(%eax)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	88 02                	mov    %al,(%edx)
}
  8005b9:	5d                   	pop    %ebp
  8005ba:	c3                   	ret    

008005bb <printfmt>:
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c4:	50                   	push   %eax
  8005c5:	ff 75 10             	pushl  0x10(%ebp)
  8005c8:	ff 75 0c             	pushl  0xc(%ebp)
  8005cb:	ff 75 08             	pushl  0x8(%ebp)
  8005ce:	e8 05 00 00 00       	call   8005d8 <vprintfmt>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	c9                   	leave  
  8005d7:	c3                   	ret    

008005d8 <vprintfmt>:
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	57                   	push   %edi
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
  8005de:	83 ec 2c             	sub    $0x2c,%esp
  8005e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005ea:	e9 c1 03 00 00       	jmp    8009b0 <vprintfmt+0x3d8>
		padc = ' ';
  8005ef:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8005f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8005fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800601:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8d 47 01             	lea    0x1(%edi),%eax
  800610:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800613:	0f b6 17             	movzbl (%edi),%edx
  800616:	8d 42 dd             	lea    -0x23(%edx),%eax
  800619:	3c 55                	cmp    $0x55,%al
  80061b:	0f 87 12 04 00 00    	ja     800a33 <vprintfmt+0x45b>
  800621:	0f b6 c0             	movzbl %al,%eax
  800624:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80062e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800632:	eb d9                	jmp    80060d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800637:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80063b:	eb d0                	jmp    80060d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	0f b6 d2             	movzbl %dl,%edx
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800643:	b8 00 00 00 00       	mov    $0x0,%eax
  800648:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80064b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80064e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800652:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800655:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800658:	83 f9 09             	cmp    $0x9,%ecx
  80065b:	77 55                	ja     8006b2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80065d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800660:	eb e9                	jmp    80064b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 00                	mov    (%eax),%eax
  800667:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800676:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067a:	79 91                	jns    80060d <vprintfmt+0x35>
				width = precision, precision = -1;
  80067c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800682:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800689:	eb 82                	jmp    80060d <vprintfmt+0x35>
  80068b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068e:	85 c0                	test   %eax,%eax
  800690:	ba 00 00 00 00       	mov    $0x0,%edx
  800695:	0f 49 d0             	cmovns %eax,%edx
  800698:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 6a ff ff ff       	jmp    80060d <vprintfmt+0x35>
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006ad:	e9 5b ff ff ff       	jmp    80060d <vprintfmt+0x35>
  8006b2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b8:	eb bc                	jmp    800676 <vprintfmt+0x9e>
			lflag++;
  8006ba:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006c0:	e9 48 ff ff ff       	jmp    80060d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 78 04             	lea    0x4(%eax),%edi
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	ff 30                	pushl  (%eax)
  8006d1:	ff d6                	call   *%esi
			break;
  8006d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006d6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006d9:	e9 cf 02 00 00       	jmp    8009ad <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 78 04             	lea    0x4(%eax),%edi
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	99                   	cltd   
  8006e7:	31 d0                	xor    %edx,%eax
  8006e9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006eb:	83 f8 0f             	cmp    $0xf,%eax
  8006ee:	7f 23                	jg     800713 <vprintfmt+0x13b>
  8006f0:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	74 18                	je     800713 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8006fb:	52                   	push   %edx
  8006fc:	68 b1 2b 80 00       	push   $0x802bb1
  800701:	53                   	push   %ebx
  800702:	56                   	push   %esi
  800703:	e8 b3 fe ff ff       	call   8005bb <printfmt>
  800708:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80070b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80070e:	e9 9a 02 00 00       	jmp    8009ad <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800713:	50                   	push   %eax
  800714:	68 e7 27 80 00       	push   $0x8027e7
  800719:	53                   	push   %ebx
  80071a:	56                   	push   %esi
  80071b:	e8 9b fe ff ff       	call   8005bb <printfmt>
  800720:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800723:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800726:	e9 82 02 00 00       	jmp    8009ad <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	83 c0 04             	add    $0x4,%eax
  800731:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800739:	85 ff                	test   %edi,%edi
  80073b:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  800740:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800743:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800747:	0f 8e bd 00 00 00    	jle    80080a <vprintfmt+0x232>
  80074d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800751:	75 0e                	jne    800761 <vprintfmt+0x189>
  800753:	89 75 08             	mov    %esi,0x8(%ebp)
  800756:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800759:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075f:	eb 6d                	jmp    8007ce <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	ff 75 d0             	pushl  -0x30(%ebp)
  800767:	57                   	push   %edi
  800768:	e8 6e 03 00 00       	call   800adb <strnlen>
  80076d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800770:	29 c1                	sub    %eax,%ecx
  800772:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800775:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800778:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80077c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800782:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800784:	eb 0f                	jmp    800795 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	ff 75 e0             	pushl  -0x20(%ebp)
  80078d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80078f:	83 ef 01             	sub    $0x1,%edi
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	85 ff                	test   %edi,%edi
  800797:	7f ed                	jg     800786 <vprintfmt+0x1ae>
  800799:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80079c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	0f 49 c1             	cmovns %ecx,%eax
  8007a9:	29 c1                	sub    %eax,%ecx
  8007ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b4:	89 cb                	mov    %ecx,%ebx
  8007b6:	eb 16                	jmp    8007ce <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8007b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007bc:	75 31                	jne    8007ef <vprintfmt+0x217>
					putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	50                   	push   %eax
  8007c5:	ff 55 08             	call   *0x8(%ebp)
  8007c8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cb:	83 eb 01             	sub    $0x1,%ebx
  8007ce:	83 c7 01             	add    $0x1,%edi
  8007d1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007d5:	0f be c2             	movsbl %dl,%eax
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	74 59                	je     800835 <vprintfmt+0x25d>
  8007dc:	85 f6                	test   %esi,%esi
  8007de:	78 d8                	js     8007b8 <vprintfmt+0x1e0>
  8007e0:	83 ee 01             	sub    $0x1,%esi
  8007e3:	79 d3                	jns    8007b8 <vprintfmt+0x1e0>
  8007e5:	89 df                	mov    %ebx,%edi
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ed:	eb 37                	jmp    800826 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007ef:	0f be d2             	movsbl %dl,%edx
  8007f2:	83 ea 20             	sub    $0x20,%edx
  8007f5:	83 fa 5e             	cmp    $0x5e,%edx
  8007f8:	76 c4                	jbe    8007be <vprintfmt+0x1e6>
					putch('?', putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	6a 3f                	push   $0x3f
  800802:	ff 55 08             	call   *0x8(%ebp)
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	eb c1                	jmp    8007cb <vprintfmt+0x1f3>
  80080a:	89 75 08             	mov    %esi,0x8(%ebp)
  80080d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800810:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800813:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800816:	eb b6                	jmp    8007ce <vprintfmt+0x1f6>
				putch(' ', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 20                	push   $0x20
  80081e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800820:	83 ef 01             	sub    $0x1,%edi
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 ff                	test   %edi,%edi
  800828:	7f ee                	jg     800818 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80082a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
  800830:	e9 78 01 00 00       	jmp    8009ad <vprintfmt+0x3d5>
  800835:	89 df                	mov    %ebx,%edi
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083d:	eb e7                	jmp    800826 <vprintfmt+0x24e>
	if (lflag >= 2)
  80083f:	83 f9 01             	cmp    $0x1,%ecx
  800842:	7e 3f                	jle    800883 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8b 50 04             	mov    0x4(%eax),%edx
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8d 40 08             	lea    0x8(%eax),%eax
  800858:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80085b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085f:	79 5c                	jns    8008bd <vprintfmt+0x2e5>
				putch('-', putdat);
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	53                   	push   %ebx
  800865:	6a 2d                	push   $0x2d
  800867:	ff d6                	call   *%esi
				num = -(long long) num;
  800869:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80086c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80086f:	f7 da                	neg    %edx
  800871:	83 d1 00             	adc    $0x0,%ecx
  800874:	f7 d9                	neg    %ecx
  800876:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800879:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087e:	e9 10 01 00 00       	jmp    800993 <vprintfmt+0x3bb>
	else if (lflag)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	75 1b                	jne    8008a2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 c1                	mov    %eax,%ecx
  800891:	c1 f9 1f             	sar    $0x1f,%ecx
  800894:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8d 40 04             	lea    0x4(%eax),%eax
  80089d:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a0:	eb b9                	jmp    80085b <vprintfmt+0x283>
		return va_arg(*ap, long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008aa:	89 c1                	mov    %eax,%ecx
  8008ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8008af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 40 04             	lea    0x4(%eax),%eax
  8008b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bb:	eb 9e                	jmp    80085b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8008bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8008c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c8:	e9 c6 00 00 00       	jmp    800993 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8008cd:	83 f9 01             	cmp    $0x1,%ecx
  8008d0:	7e 18                	jle    8008ea <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 10                	mov    (%eax),%edx
  8008d7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008da:	8d 40 08             	lea    0x8(%eax),%eax
  8008dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e5:	e9 a9 00 00 00       	jmp    800993 <vprintfmt+0x3bb>
	else if (lflag)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	75 1a                	jne    800908 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8b 10                	mov    (%eax),%edx
  8008f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f8:	8d 40 04             	lea    0x4(%eax),%eax
  8008fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800903:	e9 8b 00 00 00       	jmp    800993 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8b 10                	mov    (%eax),%edx
  80090d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800912:	8d 40 04             	lea    0x4(%eax),%eax
  800915:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800918:	b8 0a 00 00 00       	mov    $0xa,%eax
  80091d:	eb 74                	jmp    800993 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80091f:	83 f9 01             	cmp    $0x1,%ecx
  800922:	7e 15                	jle    800939 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800924:	8b 45 14             	mov    0x14(%ebp),%eax
  800927:	8b 10                	mov    (%eax),%edx
  800929:	8b 48 04             	mov    0x4(%eax),%ecx
  80092c:	8d 40 08             	lea    0x8(%eax),%eax
  80092f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800932:	b8 08 00 00 00       	mov    $0x8,%eax
  800937:	eb 5a                	jmp    800993 <vprintfmt+0x3bb>
	else if (lflag)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	75 17                	jne    800954 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8b 10                	mov    (%eax),%edx
  800942:	b9 00 00 00 00       	mov    $0x0,%ecx
  800947:	8d 40 04             	lea    0x4(%eax),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80094d:	b8 08 00 00 00       	mov    $0x8,%eax
  800952:	eb 3f                	jmp    800993 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800954:	8b 45 14             	mov    0x14(%ebp),%eax
  800957:	8b 10                	mov    (%eax),%edx
  800959:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095e:	8d 40 04             	lea    0x4(%eax),%eax
  800961:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800964:	b8 08 00 00 00       	mov    $0x8,%eax
  800969:	eb 28                	jmp    800993 <vprintfmt+0x3bb>
			putch('0', putdat);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	53                   	push   %ebx
  80096f:	6a 30                	push   $0x30
  800971:	ff d6                	call   *%esi
			putch('x', putdat);
  800973:	83 c4 08             	add    $0x8,%esp
  800976:	53                   	push   %ebx
  800977:	6a 78                	push   $0x78
  800979:	ff d6                	call   *%esi
			num = (unsigned long long)
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8b 10                	mov    (%eax),%edx
  800980:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800985:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800988:	8d 40 04             	lea    0x4(%eax),%eax
  80098b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80098e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800993:	83 ec 0c             	sub    $0xc,%esp
  800996:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80099a:	57                   	push   %edi
  80099b:	ff 75 e0             	pushl  -0x20(%ebp)
  80099e:	50                   	push   %eax
  80099f:	51                   	push   %ecx
  8009a0:	52                   	push   %edx
  8009a1:	89 da                	mov    %ebx,%edx
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	e8 45 fb ff ff       	call   8004ef <printnum>
			break;
  8009aa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009b0:	83 c7 01             	add    $0x1,%edi
  8009b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009b7:	83 f8 25             	cmp    $0x25,%eax
  8009ba:	0f 84 2f fc ff ff    	je     8005ef <vprintfmt+0x17>
			if (ch == '\0')
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	0f 84 8b 00 00 00    	je     800a53 <vprintfmt+0x47b>
			putch(ch, putdat);
  8009c8:	83 ec 08             	sub    $0x8,%esp
  8009cb:	53                   	push   %ebx
  8009cc:	50                   	push   %eax
  8009cd:	ff d6                	call   *%esi
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	eb dc                	jmp    8009b0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8009d4:	83 f9 01             	cmp    $0x1,%ecx
  8009d7:	7e 15                	jle    8009ee <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	8b 10                	mov    (%eax),%edx
  8009de:	8b 48 04             	mov    0x4(%eax),%ecx
  8009e1:	8d 40 08             	lea    0x8(%eax),%eax
  8009e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009e7:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ec:	eb a5                	jmp    800993 <vprintfmt+0x3bb>
	else if (lflag)
  8009ee:	85 c9                	test   %ecx,%ecx
  8009f0:	75 17                	jne    800a09 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8009f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f5:	8b 10                	mov    (%eax),%edx
  8009f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fc:	8d 40 04             	lea    0x4(%eax),%eax
  8009ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a02:	b8 10 00 00 00       	mov    $0x10,%eax
  800a07:	eb 8a                	jmp    800993 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800a09:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0c:	8b 10                	mov    (%eax),%edx
  800a0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a13:	8d 40 04             	lea    0x4(%eax),%eax
  800a16:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a19:	b8 10 00 00 00       	mov    $0x10,%eax
  800a1e:	e9 70 ff ff ff       	jmp    800993 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	53                   	push   %ebx
  800a27:	6a 25                	push   $0x25
  800a29:	ff d6                	call   *%esi
			break;
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	e9 7a ff ff ff       	jmp    8009ad <vprintfmt+0x3d5>
			putch('%', putdat);
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	53                   	push   %ebx
  800a37:	6a 25                	push   $0x25
  800a39:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	89 f8                	mov    %edi,%eax
  800a40:	eb 03                	jmp    800a45 <vprintfmt+0x46d>
  800a42:	83 e8 01             	sub    $0x1,%eax
  800a45:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a49:	75 f7                	jne    800a42 <vprintfmt+0x46a>
  800a4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a4e:	e9 5a ff ff ff       	jmp    8009ad <vprintfmt+0x3d5>
}
  800a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 18             	sub    $0x18,%esp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a6a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a6e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	74 26                	je     800aa2 <vsnprintf+0x47>
  800a7c:	85 d2                	test   %edx,%edx
  800a7e:	7e 22                	jle    800aa2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a80:	ff 75 14             	pushl  0x14(%ebp)
  800a83:	ff 75 10             	pushl  0x10(%ebp)
  800a86:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 9e 05 80 00       	push   $0x80059e
  800a8f:	e8 44 fb ff ff       	call   8005d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a97:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a9d:	83 c4 10             	add    $0x10,%esp
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    
		return -E_INVAL;
  800aa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa7:	eb f7                	jmp    800aa0 <vsnprintf+0x45>

00800aa9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aaf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ab2:	50                   	push   %eax
  800ab3:	ff 75 10             	pushl  0x10(%ebp)
  800ab6:	ff 75 0c             	pushl  0xc(%ebp)
  800ab9:	ff 75 08             	pushl  0x8(%ebp)
  800abc:	e8 9a ff ff ff       	call   800a5b <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	eb 03                	jmp    800ad3 <strlen+0x10>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0xd>
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	eb 03                	jmp    800aee <strnlen+0x13>
		n++;
  800aeb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aee:	39 d0                	cmp    %edx,%eax
  800af0:	74 06                	je     800af8 <strnlen+0x1d>
  800af2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af6:	75 f3                	jne    800aeb <strnlen+0x10>
	return n;
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	83 c2 01             	add    $0x1,%edx
  800b0c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b10:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b13:	84 db                	test   %bl,%bl
  800b15:	75 ef                	jne    800b06 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b17:	5b                   	pop    %ebx
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b21:	53                   	push   %ebx
  800b22:	e8 9c ff ff ff       	call   800ac3 <strlen>
  800b27:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b2a:	ff 75 0c             	pushl  0xc(%ebp)
  800b2d:	01 d8                	add    %ebx,%eax
  800b2f:	50                   	push   %eax
  800b30:	e8 c5 ff ff ff       	call   800afa <strcpy>
	return dst;
}
  800b35:	89 d8                	mov    %ebx,%eax
  800b37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	8b 75 08             	mov    0x8(%ebp),%esi
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	89 f3                	mov    %esi,%ebx
  800b49:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b4c:	89 f2                	mov    %esi,%edx
  800b4e:	eb 0f                	jmp    800b5f <strncpy+0x23>
		*dst++ = *src;
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	0f b6 01             	movzbl (%ecx),%eax
  800b56:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b59:	80 39 01             	cmpb   $0x1,(%ecx)
  800b5c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b5f:	39 da                	cmp    %ebx,%edx
  800b61:	75 ed                	jne    800b50 <strncpy+0x14>
	}
	return ret;
}
  800b63:	89 f0                	mov    %esi,%eax
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b77:	89 f0                	mov    %esi,%eax
  800b79:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	75 0b                	jne    800b8c <strlcpy+0x23>
  800b81:	eb 17                	jmp    800b9a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b8c:	39 d8                	cmp    %ebx,%eax
  800b8e:	74 07                	je     800b97 <strlcpy+0x2e>
  800b90:	0f b6 0a             	movzbl (%edx),%ecx
  800b93:	84 c9                	test   %cl,%cl
  800b95:	75 ec                	jne    800b83 <strlcpy+0x1a>
		*dst = '\0';
  800b97:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b9a:	29 f0                	sub    %esi,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba9:	eb 06                	jmp    800bb1 <strcmp+0x11>
		p++, q++;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bb1:	0f b6 01             	movzbl (%ecx),%eax
  800bb4:	84 c0                	test   %al,%al
  800bb6:	74 04                	je     800bbc <strcmp+0x1c>
  800bb8:	3a 02                	cmp    (%edx),%al
  800bba:	74 ef                	je     800bab <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bbc:	0f b6 c0             	movzbl %al,%eax
  800bbf:	0f b6 12             	movzbl (%edx),%edx
  800bc2:	29 d0                	sub    %edx,%eax
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	53                   	push   %ebx
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bd5:	eb 06                	jmp    800bdd <strncmp+0x17>
		n--, p++, q++;
  800bd7:	83 c0 01             	add    $0x1,%eax
  800bda:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bdd:	39 d8                	cmp    %ebx,%eax
  800bdf:	74 16                	je     800bf7 <strncmp+0x31>
  800be1:	0f b6 08             	movzbl (%eax),%ecx
  800be4:	84 c9                	test   %cl,%cl
  800be6:	74 04                	je     800bec <strncmp+0x26>
  800be8:	3a 0a                	cmp    (%edx),%cl
  800bea:	74 eb                	je     800bd7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bec:	0f b6 00             	movzbl (%eax),%eax
  800bef:	0f b6 12             	movzbl (%edx),%edx
  800bf2:	29 d0                	sub    %edx,%eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    
		return 0;
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	eb f6                	jmp    800bf4 <strncmp+0x2e>

00800bfe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c08:	0f b6 10             	movzbl (%eax),%edx
  800c0b:	84 d2                	test   %dl,%dl
  800c0d:	74 09                	je     800c18 <strchr+0x1a>
		if (*s == c)
  800c0f:	38 ca                	cmp    %cl,%dl
  800c11:	74 0a                	je     800c1d <strchr+0x1f>
	for (; *s; s++)
  800c13:	83 c0 01             	add    $0x1,%eax
  800c16:	eb f0                	jmp    800c08 <strchr+0xa>
			return (char *) s;
	return 0;
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c29:	eb 03                	jmp    800c2e <strfind+0xf>
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c31:	38 ca                	cmp    %cl,%dl
  800c33:	74 04                	je     800c39 <strfind+0x1a>
  800c35:	84 d2                	test   %dl,%dl
  800c37:	75 f2                	jne    800c2b <strfind+0xc>
			break;
	return (char *) s;
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c47:	85 c9                	test   %ecx,%ecx
  800c49:	74 13                	je     800c5e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c51:	75 05                	jne    800c58 <memset+0x1d>
  800c53:	f6 c1 03             	test   $0x3,%cl
  800c56:	74 0d                	je     800c65 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5b:	fc                   	cld    
  800c5c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c5e:	89 f8                	mov    %edi,%eax
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
		c &= 0xFF;
  800c65:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	c1 e3 08             	shl    $0x8,%ebx
  800c6e:	89 d0                	mov    %edx,%eax
  800c70:	c1 e0 18             	shl    $0x18,%eax
  800c73:	89 d6                	mov    %edx,%esi
  800c75:	c1 e6 10             	shl    $0x10,%esi
  800c78:	09 f0                	or     %esi,%eax
  800c7a:	09 c2                	or     %eax,%edx
  800c7c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800c7e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c81:	89 d0                	mov    %edx,%eax
  800c83:	fc                   	cld    
  800c84:	f3 ab                	rep stos %eax,%es:(%edi)
  800c86:	eb d6                	jmp    800c5e <memset+0x23>

00800c88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c96:	39 c6                	cmp    %eax,%esi
  800c98:	73 35                	jae    800ccf <memmove+0x47>
  800c9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c9d:	39 c2                	cmp    %eax,%edx
  800c9f:	76 2e                	jbe    800ccf <memmove+0x47>
		s += n;
		d += n;
  800ca1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	09 fe                	or     %edi,%esi
  800ca8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cae:	74 0c                	je     800cbc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cb0:	83 ef 01             	sub    $0x1,%edi
  800cb3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cb6:	fd                   	std    
  800cb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb9:	fc                   	cld    
  800cba:	eb 21                	jmp    800cdd <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 ef                	jne    800cb0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc1:	83 ef 04             	sub    $0x4,%edi
  800cc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cca:	fd                   	std    
  800ccb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccd:	eb ea                	jmp    800cb9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ccf:	89 f2                	mov    %esi,%edx
  800cd1:	09 c2                	or     %eax,%edx
  800cd3:	f6 c2 03             	test   $0x3,%dl
  800cd6:	74 09                	je     800ce1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd8:	89 c7                	mov    %eax,%edi
  800cda:	fc                   	cld    
  800cdb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce1:	f6 c1 03             	test   $0x3,%cl
  800ce4:	75 f2                	jne    800cd8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ce6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ce9:	89 c7                	mov    %eax,%edi
  800ceb:	fc                   	cld    
  800cec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cee:	eb ed                	jmp    800cdd <memmove+0x55>

00800cf0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	e8 87 ff ff ff       	call   800c88 <memmove>
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0e:	89 c6                	mov    %eax,%esi
  800d10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d13:	39 f0                	cmp    %esi,%eax
  800d15:	74 1c                	je     800d33 <memcmp+0x30>
		if (*s1 != *s2)
  800d17:	0f b6 08             	movzbl (%eax),%ecx
  800d1a:	0f b6 1a             	movzbl (%edx),%ebx
  800d1d:	38 d9                	cmp    %bl,%cl
  800d1f:	75 08                	jne    800d29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d21:	83 c0 01             	add    $0x1,%eax
  800d24:	83 c2 01             	add    $0x1,%edx
  800d27:	eb ea                	jmp    800d13 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d29:	0f b6 c1             	movzbl %cl,%eax
  800d2c:	0f b6 db             	movzbl %bl,%ebx
  800d2f:	29 d8                	sub    %ebx,%eax
  800d31:	eb 05                	jmp    800d38 <memcmp+0x35>
	}

	return 0;
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	73 09                	jae    800d57 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 05                	je     800d57 <memfind+0x1b>
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	eb f3                	jmp    800d4a <memfind+0xe>
			break;
	return (void *) s;
}
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d65:	eb 03                	jmp    800d6a <strtol+0x11>
		s++;
  800d67:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d6a:	0f b6 01             	movzbl (%ecx),%eax
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 f6                	je     800d67 <strtol+0xe>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	74 f2                	je     800d67 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d75:	3c 2b                	cmp    $0x2b,%al
  800d77:	74 2e                	je     800da7 <strtol+0x4e>
	int neg = 0;
  800d79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d7e:	3c 2d                	cmp    $0x2d,%al
  800d80:	74 2f                	je     800db1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d88:	75 05                	jne    800d8f <strtol+0x36>
  800d8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d8d:	74 2c                	je     800dbb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8f:	85 db                	test   %ebx,%ebx
  800d91:	75 0a                	jne    800d9d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d93:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800d98:	80 39 30             	cmpb   $0x30,(%ecx)
  800d9b:	74 28                	je     800dc5 <strtol+0x6c>
		base = 10;
  800d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800da2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800da5:	eb 50                	jmp    800df7 <strtol+0x9e>
		s++;
  800da7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800daa:	bf 00 00 00 00       	mov    $0x0,%edi
  800daf:	eb d1                	jmp    800d82 <strtol+0x29>
		s++, neg = 1;
  800db1:	83 c1 01             	add    $0x1,%ecx
  800db4:	bf 01 00 00 00       	mov    $0x1,%edi
  800db9:	eb c7                	jmp    800d82 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dbb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dbf:	74 0e                	je     800dcf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800dc1:	85 db                	test   %ebx,%ebx
  800dc3:	75 d8                	jne    800d9d <strtol+0x44>
		s++, base = 8;
  800dc5:	83 c1 01             	add    $0x1,%ecx
  800dc8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800dcd:	eb ce                	jmp    800d9d <strtol+0x44>
		s += 2, base = 16;
  800dcf:	83 c1 02             	add    $0x2,%ecx
  800dd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd7:	eb c4                	jmp    800d9d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800dd9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ddc:	89 f3                	mov    %esi,%ebx
  800dde:	80 fb 19             	cmp    $0x19,%bl
  800de1:	77 29                	ja     800e0c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800de3:	0f be d2             	movsbl %dl,%edx
  800de6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800de9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dec:	7d 30                	jge    800e1e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dee:	83 c1 01             	add    $0x1,%ecx
  800df1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800df7:	0f b6 11             	movzbl (%ecx),%edx
  800dfa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dfd:	89 f3                	mov    %esi,%ebx
  800dff:	80 fb 09             	cmp    $0x9,%bl
  800e02:	77 d5                	ja     800dd9 <strtol+0x80>
			dig = *s - '0';
  800e04:	0f be d2             	movsbl %dl,%edx
  800e07:	83 ea 30             	sub    $0x30,%edx
  800e0a:	eb dd                	jmp    800de9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e0c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e0f:	89 f3                	mov    %esi,%ebx
  800e11:	80 fb 19             	cmp    $0x19,%bl
  800e14:	77 08                	ja     800e1e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e16:	0f be d2             	movsbl %dl,%edx
  800e19:	83 ea 37             	sub    $0x37,%edx
  800e1c:	eb cb                	jmp    800de9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e22:	74 05                	je     800e29 <strtol+0xd0>
		*endptr = (char *) s;
  800e24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e27:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	f7 da                	neg    %edx
  800e2d:	85 ff                	test   %edi,%edi
  800e2f:	0f 45 c2             	cmovne %edx,%eax
}
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	89 c3                	mov    %eax,%ebx
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	89 c6                	mov    %eax,%esi
  800e4e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	b8 01 00 00 00       	mov    $0x1,%eax
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	89 d7                	mov    %edx,%edi
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8a:	89 cb                	mov    %ecx,%ebx
  800e8c:	89 cf                	mov    %ecx,%edi
  800e8e:	89 ce                	mov    %ecx,%esi
  800e90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	7f 08                	jg     800e9e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	50                   	push   %eax
  800ea2:	6a 03                	push   $0x3
  800ea4:	68 df 2a 80 00       	push   $0x802adf
  800ea9:	6a 23                	push   $0x23
  800eab:	68 fc 2a 80 00       	push   $0x802afc
  800eb0:	e8 4b f5 ff ff       	call   800400 <_panic>

00800eb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_yield>:

void
sys_yield(void)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eda:	ba 00 00 00 00       	mov    $0x0,%edx
  800edf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee4:	89 d1                	mov    %edx,%ecx
  800ee6:	89 d3                	mov    %edx,%ebx
  800ee8:	89 d7                	mov    %edx,%edi
  800eea:	89 d6                	mov    %edx,%esi
  800eec:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	b8 04 00 00 00       	mov    $0x4,%eax
  800f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0f:	89 f7                	mov    %esi,%edi
  800f11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7f 08                	jg     800f1f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	50                   	push   %eax
  800f23:	6a 04                	push   $0x4
  800f25:	68 df 2a 80 00       	push   $0x802adf
  800f2a:	6a 23                	push   $0x23
  800f2c:	68 fc 2a 80 00       	push   $0x802afc
  800f31:	e8 ca f4 ff ff       	call   800400 <_panic>

00800f36 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
  800f3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f50:	8b 75 18             	mov    0x18(%ebp),%esi
  800f53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7f 08                	jg     800f61 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	50                   	push   %eax
  800f65:	6a 05                	push   $0x5
  800f67:	68 df 2a 80 00       	push   $0x802adf
  800f6c:	6a 23                	push   $0x23
  800f6e:	68 fc 2a 80 00       	push   $0x802afc
  800f73:	e8 88 f4 ff ff       	call   800400 <_panic>

00800f78 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f91:	89 df                	mov    %ebx,%edi
  800f93:	89 de                	mov    %ebx,%esi
  800f95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	7f 08                	jg     800fa3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	50                   	push   %eax
  800fa7:	6a 06                	push   $0x6
  800fa9:	68 df 2a 80 00       	push   $0x802adf
  800fae:	6a 23                	push   $0x23
  800fb0:	68 fc 2a 80 00       	push   $0x802afc
  800fb5:	e8 46 f4 ff ff       	call   800400 <_panic>

00800fba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fce:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd3:	89 df                	mov    %ebx,%edi
  800fd5:	89 de                	mov    %ebx,%esi
  800fd7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	7f 08                	jg     800fe5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	50                   	push   %eax
  800fe9:	6a 08                	push   $0x8
  800feb:	68 df 2a 80 00       	push   $0x802adf
  800ff0:	6a 23                	push   $0x23
  800ff2:	68 fc 2a 80 00       	push   $0x802afc
  800ff7:	e8 04 f4 ff ff       	call   800400 <_panic>

00800ffc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801005:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801010:	b8 09 00 00 00       	mov    $0x9,%eax
  801015:	89 df                	mov    %ebx,%edi
  801017:	89 de                	mov    %ebx,%esi
  801019:	cd 30                	int    $0x30
	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7f 08                	jg     801027 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80101f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	6a 09                	push   $0x9
  80102d:	68 df 2a 80 00       	push   $0x802adf
  801032:	6a 23                	push   $0x23
  801034:	68 fc 2a 80 00       	push   $0x802afc
  801039:	e8 c2 f3 ff ff       	call   800400 <_panic>

0080103e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801047:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104c:	8b 55 08             	mov    0x8(%ebp),%edx
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	b8 0a 00 00 00       	mov    $0xa,%eax
  801057:	89 df                	mov    %ebx,%edi
  801059:	89 de                	mov    %ebx,%esi
  80105b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	7f 08                	jg     801069 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	50                   	push   %eax
  80106d:	6a 0a                	push   $0xa
  80106f:	68 df 2a 80 00       	push   $0x802adf
  801074:	6a 23                	push   $0x23
  801076:	68 fc 2a 80 00       	push   $0x802afc
  80107b:	e8 80 f3 ff ff       	call   800400 <_panic>

00801080 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
	asm volatile("int %1\n"
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801091:	be 00 00 00 00       	mov    $0x0,%esi
  801096:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801099:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7f 08                	jg     8010cd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	50                   	push   %eax
  8010d1:	6a 0d                	push   $0xd
  8010d3:	68 df 2a 80 00       	push   $0x802adf
  8010d8:	6a 23                	push   $0x23
  8010da:	68 fc 2a 80 00       	push   $0x802afc
  8010df:	e8 1c f3 ff ff       	call   800400 <_panic>

008010e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801104:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801111:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801116:	89 c2                	mov    %eax,%edx
  801118:	c1 ea 16             	shr    $0x16,%edx
  80111b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801122:	f6 c2 01             	test   $0x1,%dl
  801125:	74 2a                	je     801151 <fd_alloc+0x46>
  801127:	89 c2                	mov    %eax,%edx
  801129:	c1 ea 0c             	shr    $0xc,%edx
  80112c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801133:	f6 c2 01             	test   $0x1,%dl
  801136:	74 19                	je     801151 <fd_alloc+0x46>
  801138:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80113d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801142:	75 d2                	jne    801116 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801144:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80114a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80114f:	eb 07                	jmp    801158 <fd_alloc+0x4d>
			*fd_store = fd;
  801151:	89 01                	mov    %eax,(%ecx)
			return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801160:	83 f8 1f             	cmp    $0x1f,%eax
  801163:	77 36                	ja     80119b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801165:	c1 e0 0c             	shl    $0xc,%eax
  801168:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80116d:	89 c2                	mov    %eax,%edx
  80116f:	c1 ea 16             	shr    $0x16,%edx
  801172:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 24                	je     8011a2 <fd_lookup+0x48>
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 0c             	shr    $0xc,%edx
  801183:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 1a                	je     8011a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80118f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801192:	89 02                	mov    %eax,(%edx)
	return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
		return -E_INVAL;
  80119b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a0:	eb f7                	jmp    801199 <fd_lookup+0x3f>
		return -E_INVAL;
  8011a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a7:	eb f0                	jmp    801199 <fd_lookup+0x3f>
  8011a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ae:	eb e9                	jmp    801199 <fd_lookup+0x3f>

008011b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011be:	b8 90 47 80 00       	mov    $0x804790,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011c3:	39 08                	cmp    %ecx,(%eax)
  8011c5:	74 33                	je     8011fa <dev_lookup+0x4a>
  8011c7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011ca:	8b 02                	mov    (%edx),%eax
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	75 f3                	jne    8011c3 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011d0:	a1 90 67 80 00       	mov    0x806790,%eax
  8011d5:	8b 40 48             	mov    0x48(%eax),%eax
  8011d8:	83 ec 04             	sub    $0x4,%esp
  8011db:	51                   	push   %ecx
  8011dc:	50                   	push   %eax
  8011dd:	68 0c 2b 80 00       	push   $0x802b0c
  8011e2:	e8 f4 f2 ff ff       	call   8004db <cprintf>
	*dev = 0;
  8011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    
			*dev = devtab[i];
  8011fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb f2                	jmp    8011f8 <dev_lookup+0x48>

00801206 <fd_close>:
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 1c             	sub    $0x1c,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801215:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801218:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801219:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801222:	50                   	push   %eax
  801223:	e8 32 ff ff ff       	call   80115a <fd_lookup>
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 05                	js     801236 <fd_close+0x30>
	    || fd != fd2)
  801231:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801234:	74 16                	je     80124c <fd_close+0x46>
		return (must_exist ? r : 0);
  801236:	89 f8                	mov    %edi,%eax
  801238:	84 c0                	test   %al,%al
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	0f 44 d8             	cmove  %eax,%ebx
}
  801242:	89 d8                	mov    %ebx,%eax
  801244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 36                	pushl  (%esi)
  801255:	e8 56 ff ff ff       	call   8011b0 <dev_lookup>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 15                	js     801278 <fd_close+0x72>
		if (dev->dev_close)
  801263:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801266:	8b 40 10             	mov    0x10(%eax),%eax
  801269:	85 c0                	test   %eax,%eax
  80126b:	74 1b                	je     801288 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80126d:	83 ec 0c             	sub    $0xc,%esp
  801270:	56                   	push   %esi
  801271:	ff d0                	call   *%eax
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	56                   	push   %esi
  80127c:	6a 00                	push   $0x0
  80127e:	e8 f5 fc ff ff       	call   800f78 <sys_page_unmap>
	return r;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb ba                	jmp    801242 <fd_close+0x3c>
			r = 0;
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128d:	eb e9                	jmp    801278 <fd_close+0x72>

0080128f <close>:

int
close(int fdnum)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 b9 fe ff ff       	call   80115a <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 10                	js     8012b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	6a 01                	push   $0x1
  8012ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b0:	e8 51 ff ff ff       	call   801206 <fd_close>
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <close_all>:

void
close_all(void)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	e8 c0 ff ff ff       	call   80128f <close>
	for (i = 0; i < MAXFD; i++)
  8012cf:	83 c3 01             	add    $0x1,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	83 fb 20             	cmp    $0x20,%ebx
  8012d8:	75 ec                	jne    8012c6 <close_all+0xc>
}
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	pushl  0x8(%ebp)
  8012ef:	e8 66 fe ff ff       	call   80115a <fd_lookup>
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	83 c4 08             	add    $0x8,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	0f 88 81 00 00 00    	js     801382 <dup+0xa3>
		return r;
	close(newfdnum);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	ff 75 0c             	pushl  0xc(%ebp)
  801307:	e8 83 ff ff ff       	call   80128f <close>

	newfd = INDEX2FD(newfdnum);
  80130c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80130f:	c1 e6 0c             	shl    $0xc,%esi
  801312:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801318:	83 c4 04             	add    $0x4,%esp
  80131b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131e:	e8 d1 fd ff ff       	call   8010f4 <fd2data>
  801323:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801325:	89 34 24             	mov    %esi,(%esp)
  801328:	e8 c7 fd ff ff       	call   8010f4 <fd2data>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801332:	89 d8                	mov    %ebx,%eax
  801334:	c1 e8 16             	shr    $0x16,%eax
  801337:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133e:	a8 01                	test   $0x1,%al
  801340:	74 11                	je     801353 <dup+0x74>
  801342:	89 d8                	mov    %ebx,%eax
  801344:	c1 e8 0c             	shr    $0xc,%eax
  801347:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	75 39                	jne    80138c <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801353:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801356:	89 d0                	mov    %edx,%eax
  801358:	c1 e8 0c             	shr    $0xc,%eax
  80135b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	25 07 0e 00 00       	and    $0xe07,%eax
  80136a:	50                   	push   %eax
  80136b:	56                   	push   %esi
  80136c:	6a 00                	push   $0x0
  80136e:	52                   	push   %edx
  80136f:	6a 00                	push   $0x0
  801371:	e8 c0 fb ff ff       	call   800f36 <sys_page_map>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 20             	add    $0x20,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 31                	js     8013b0 <dup+0xd1>
		goto err;

	return newfdnum;
  80137f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801382:	89 d8                	mov    %ebx,%eax
  801384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801387:	5b                   	pop    %ebx
  801388:	5e                   	pop    %esi
  801389:	5f                   	pop    %edi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80138c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	25 07 0e 00 00       	and    $0xe07,%eax
  80139b:	50                   	push   %eax
  80139c:	57                   	push   %edi
  80139d:	6a 00                	push   $0x0
  80139f:	53                   	push   %ebx
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 8f fb ff ff       	call   800f36 <sys_page_map>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	83 c4 20             	add    $0x20,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	79 a3                	jns    801353 <dup+0x74>
	sys_page_unmap(0, newfd);
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	56                   	push   %esi
  8013b4:	6a 00                	push   $0x0
  8013b6:	e8 bd fb ff ff       	call   800f78 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013bb:	83 c4 08             	add    $0x8,%esp
  8013be:	57                   	push   %edi
  8013bf:	6a 00                	push   $0x0
  8013c1:	e8 b2 fb ff ff       	call   800f78 <sys_page_unmap>
	return r;
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	eb b7                	jmp    801382 <dup+0xa3>

008013cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 14             	sub    $0x14,%esp
  8013d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	53                   	push   %ebx
  8013da:	e8 7b fd ff ff       	call   80115a <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 3f                	js     801425 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f0:	ff 30                	pushl  (%eax)
  8013f2:	e8 b9 fd ff ff       	call   8011b0 <dev_lookup>
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 27                	js     801425 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801401:	8b 42 08             	mov    0x8(%edx),%eax
  801404:	83 e0 03             	and    $0x3,%eax
  801407:	83 f8 01             	cmp    $0x1,%eax
  80140a:	74 1e                	je     80142a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80140c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140f:	8b 40 08             	mov    0x8(%eax),%eax
  801412:	85 c0                	test   %eax,%eax
  801414:	74 35                	je     80144b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801416:	83 ec 04             	sub    $0x4,%esp
  801419:	ff 75 10             	pushl  0x10(%ebp)
  80141c:	ff 75 0c             	pushl  0xc(%ebp)
  80141f:	52                   	push   %edx
  801420:	ff d0                	call   *%eax
  801422:	83 c4 10             	add    $0x10,%esp
}
  801425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801428:	c9                   	leave  
  801429:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80142a:	a1 90 67 80 00       	mov    0x806790,%eax
  80142f:	8b 40 48             	mov    0x48(%eax),%eax
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	53                   	push   %ebx
  801436:	50                   	push   %eax
  801437:	68 4d 2b 80 00       	push   $0x802b4d
  80143c:	e8 9a f0 ff ff       	call   8004db <cprintf>
		return -E_INVAL;
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801449:	eb da                	jmp    801425 <read+0x5a>
		return -E_NOT_SUPP;
  80144b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801450:	eb d3                	jmp    801425 <read+0x5a>

00801452 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	57                   	push   %edi
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	83 ec 0c             	sub    $0xc,%esp
  80145b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801461:	bb 00 00 00 00       	mov    $0x0,%ebx
  801466:	39 f3                	cmp    %esi,%ebx
  801468:	73 25                	jae    80148f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146a:	83 ec 04             	sub    $0x4,%esp
  80146d:	89 f0                	mov    %esi,%eax
  80146f:	29 d8                	sub    %ebx,%eax
  801471:	50                   	push   %eax
  801472:	89 d8                	mov    %ebx,%eax
  801474:	03 45 0c             	add    0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	57                   	push   %edi
  801479:	e8 4d ff ff ff       	call   8013cb <read>
		if (m < 0)
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	78 08                	js     80148d <readn+0x3b>
			return m;
		if (m == 0)
  801485:	85 c0                	test   %eax,%eax
  801487:	74 06                	je     80148f <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801489:	01 c3                	add    %eax,%ebx
  80148b:	eb d9                	jmp    801466 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80148f:	89 d8                	mov    %ebx,%eax
  801491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 14             	sub    $0x14,%esp
  8014a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	53                   	push   %ebx
  8014a8:	e8 ad fc ff ff       	call   80115a <fd_lookup>
  8014ad:	83 c4 08             	add    $0x8,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 3a                	js     8014ee <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	ff 30                	pushl  (%eax)
  8014c0:	e8 eb fc ff ff       	call   8011b0 <dev_lookup>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 22                	js     8014ee <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d3:	74 1e                	je     8014f3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 35                	je     801514 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	ff 75 10             	pushl  0x10(%ebp)
  8014e5:	ff 75 0c             	pushl  0xc(%ebp)
  8014e8:	50                   	push   %eax
  8014e9:	ff d2                	call   *%edx
  8014eb:	83 c4 10             	add    $0x10,%esp
}
  8014ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 90 67 80 00       	mov    0x806790,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 69 2b 80 00       	push   $0x802b69
  801505:	e8 d1 ef ff ff       	call   8004db <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801512:	eb da                	jmp    8014ee <write+0x55>
		return -E_NOT_SUPP;
  801514:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801519:	eb d3                	jmp    8014ee <write+0x55>

0080151b <seek>:

int
seek(int fdnum, off_t offset)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801521:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 2d fc ff ff       	call   80115a <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 0e                	js     801542 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801534:	8b 55 0c             	mov    0xc(%ebp),%edx
  801537:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80153a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	53                   	push   %ebx
  801553:	e8 02 fc ff ff       	call   80115a <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 37                	js     801596 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	ff 30                	pushl  (%eax)
  80156b:	e8 40 fc ff ff       	call   8011b0 <dev_lookup>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 1f                	js     801596 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157e:	74 1b                	je     80159b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801580:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801583:	8b 52 18             	mov    0x18(%edx),%edx
  801586:	85 d2                	test   %edx,%edx
  801588:	74 32                	je     8015bc <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	50                   	push   %eax
  801591:	ff d2                	call   *%edx
  801593:	83 c4 10             	add    $0x10,%esp
}
  801596:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801599:	c9                   	leave  
  80159a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80159b:	a1 90 67 80 00       	mov    0x806790,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a0:	8b 40 48             	mov    0x48(%eax),%eax
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	50                   	push   %eax
  8015a8:	68 2c 2b 80 00       	push   $0x802b2c
  8015ad:	e8 29 ef ff ff       	call   8004db <cprintf>
		return -E_INVAL;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ba:	eb da                	jmp    801596 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8015bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c1:	eb d3                	jmp    801596 <ftruncate+0x52>

008015c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 14             	sub    $0x14,%esp
  8015ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 81 fb ff ff       	call   80115a <fd_lookup>
  8015d9:	83 c4 08             	add    $0x8,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 4b                	js     80162b <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 bf fb ff ff       	call   8011b0 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 33                	js     80162b <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ff:	74 2f                	je     801630 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801601:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801604:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160b:	00 00 00 
	stat->st_isdir = 0;
  80160e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801615:	00 00 00 
	stat->st_dev = dev;
  801618:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	ff 75 f0             	pushl  -0x10(%ebp)
  801625:	ff 50 14             	call   *0x14(%eax)
  801628:	83 c4 10             	add    $0x10,%esp
}
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    
		return -E_NOT_SUPP;
  801630:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801635:	eb f4                	jmp    80162b <fstat+0x68>

00801637 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	6a 00                	push   $0x0
  801641:	ff 75 08             	pushl  0x8(%ebp)
  801644:	e8 e7 01 00 00       	call   801830 <open>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 1b                	js     80166d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	50                   	push   %eax
  801659:	e8 65 ff ff ff       	call   8015c3 <fstat>
  80165e:	89 c6                	mov    %eax,%esi
	close(fd);
  801660:	89 1c 24             	mov    %ebx,(%esp)
  801663:	e8 27 fc ff ff       	call   80128f <close>
	return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 f3                	mov    %esi,%ebx
}
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	89 c6                	mov    %eax,%esi
  80167d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801686:	74 27                	je     8016af <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801688:	6a 07                	push   $0x7
  80168a:	68 00 70 80 00       	push   $0x807000
  80168f:	56                   	push   %esi
  801690:	ff 35 00 50 80 00    	pushl  0x805000
  801696:	e8 bc 0c 00 00       	call   802357 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169b:	83 c4 0c             	add    $0xc,%esp
  80169e:	6a 00                	push   $0x0
  8016a0:	53                   	push   %ebx
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 4e 0c 00 00       	call   8022f6 <ipc_recv>
}
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016af:	83 ec 0c             	sub    $0xc,%esp
  8016b2:	6a 01                	push   $0x1
  8016b4:	e8 eb 0c 00 00       	call   8023a4 <ipc_find_env>
  8016b9:	a3 00 50 80 00       	mov    %eax,0x805000
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb c5                	jmp    801688 <fsipc+0x12>

008016c3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8016d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d7:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e6:	e8 8b ff ff ff       	call   801676 <fsipc>
}
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <devfile_flush>:
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 06 00 00 00       	mov    $0x6,%eax
  801708:	e8 69 ff ff ff       	call   801676 <fsipc>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_stat>:
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 05 00 00 00       	mov    $0x5,%eax
  80172e:	e8 43 ff ff ff       	call   801676 <fsipc>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 2c                	js     801763 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	68 00 70 80 00       	push   $0x807000
  80173f:	53                   	push   %ebx
  801740:	e8 b5 f3 ff ff       	call   800afa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801745:	a1 80 70 80 00       	mov    0x807080,%eax
  80174a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801750:	a1 84 70 80 00       	mov    0x807084,%eax
  801755:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_write>:
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 0c             	sub    $0xc,%esp
  80176e:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801771:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801776:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80177b:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177e:	8b 55 08             	mov    0x8(%ebp),%edx
  801781:	8b 52 0c             	mov    0xc(%edx),%edx
  801784:	89 15 00 70 80 00    	mov    %edx,0x807000
    fsipcbuf.write.req_n = n;
  80178a:	a3 04 70 80 00       	mov    %eax,0x807004
    memmove(fsipcbuf.write.req_buf, buf, n);
  80178f:	50                   	push   %eax
  801790:	ff 75 0c             	pushl  0xc(%ebp)
  801793:	68 08 70 80 00       	push   $0x807008
  801798:	e8 eb f4 ff ff       	call   800c88 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a7:	e8 ca fe ff ff       	call   801676 <fsipc>
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <devfile_read>:
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bc:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8017c1:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d1:	e8 a0 fe ff ff       	call   801676 <fsipc>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 1f                	js     8017fb <devfile_read+0x4d>
	assert(r <= n);
  8017dc:	39 f0                	cmp    %esi,%eax
  8017de:	77 24                	ja     801804 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e5:	7f 33                	jg     80181a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	50                   	push   %eax
  8017eb:	68 00 70 80 00       	push   $0x807000
  8017f0:	ff 75 0c             	pushl  0xc(%ebp)
  8017f3:	e8 90 f4 ff ff       	call   800c88 <memmove>
	return r;
  8017f8:	83 c4 10             	add    $0x10,%esp
}
  8017fb:	89 d8                	mov    %ebx,%eax
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    
	assert(r <= n);
  801804:	68 98 2b 80 00       	push   $0x802b98
  801809:	68 9f 2b 80 00       	push   $0x802b9f
  80180e:	6a 7d                	push   $0x7d
  801810:	68 b4 2b 80 00       	push   $0x802bb4
  801815:	e8 e6 eb ff ff       	call   800400 <_panic>
	assert(r <= PGSIZE);
  80181a:	68 bf 2b 80 00       	push   $0x802bbf
  80181f:	68 9f 2b 80 00       	push   $0x802b9f
  801824:	6a 7e                	push   $0x7e
  801826:	68 b4 2b 80 00       	push   $0x802bb4
  80182b:	e8 d0 eb ff ff       	call   800400 <_panic>

00801830 <open>:
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	83 ec 1c             	sub    $0x1c,%esp
  801838:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80183b:	56                   	push   %esi
  80183c:	e8 82 f2 ff ff       	call   800ac3 <strlen>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801849:	0f 8f 96 00 00 00    	jg     8018e5 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	e8 b0 f8 ff ff       	call   80110b <fd_alloc>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	78 66                	js     8018ca <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	56                   	push   %esi
  801868:	68 00 70 80 00       	push   $0x807000
  80186d:	e8 88 f2 ff ff       	call   800afa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187d:	b8 01 00 00 00       	mov    $0x1,%eax
  801882:	e8 ef fd ff ff       	call   801676 <fsipc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 43                	js     8018d3 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 49 f8 ff ff       	call   8010e4 <fd2num>
  80189b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189e:	8b 0d 90 67 80 00    	mov    0x806790,%ecx
  8018a4:	8b 49 48             	mov    0x48(%ecx),%ecx
  8018a7:	83 c4 08             	add    $0x8,%esp
  8018aa:	50                   	push   %eax
  8018ab:	52                   	push   %edx
  8018ac:	ff 32                	pushl  (%edx)
  8018ae:	56                   	push   %esi
  8018af:	51                   	push   %ecx
  8018b0:	68 cc 2b 80 00       	push   $0x802bcc
  8018b5:	e8 21 ec ff ff       	call   8004db <cprintf>
	return fd2num(fd);
  8018ba:	83 c4 14             	add    $0x14,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 1f f8 ff ff       	call   8010e4 <fd2num>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	83 c4 10             	add    $0x10,%esp
}
  8018ca:	89 d8                	mov    %ebx,%eax
  8018cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5e                   	pop    %esi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    
		fd_close(fd, 0);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	6a 00                	push   $0x0
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 26 f9 ff ff       	call   801206 <fd_close>
		return r;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	eb e5                	jmp    8018ca <open+0x9a>
		return -E_BAD_PATH;
  8018e5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018ea:	eb de                	jmp    8018ca <open+0x9a>

008018ec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8018fc:	e8 75 fd ff ff       	call   801676 <fsipc>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	57                   	push   %edi
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80190f:	6a 00                	push   $0x0
  801911:	ff 75 08             	pushl  0x8(%ebp)
  801914:	e8 17 ff ff ff       	call   801830 <open>
  801919:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	0f 88 40 03 00 00    	js     801c6a <spawn+0x367>
  80192a:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80192c:	83 ec 04             	sub    $0x4,%esp
  80192f:	68 00 02 00 00       	push   $0x200
  801934:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80193a:	50                   	push   %eax
  80193b:	51                   	push   %ecx
  80193c:	e8 11 fb ff ff       	call   801452 <readn>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	3d 00 02 00 00       	cmp    $0x200,%eax
  801949:	75 5d                	jne    8019a8 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  80194b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801952:	45 4c 46 
  801955:	75 51                	jne    8019a8 <spawn+0xa5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801957:	b8 07 00 00 00       	mov    $0x7,%eax
  80195c:	cd 30                	int    $0x30
  80195e:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801964:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80196a:	85 c0                	test   %eax,%eax
  80196c:	0f 88 79 04 00 00    	js     801deb <spawn+0x4e8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801972:	25 ff 03 00 00       	and    $0x3ff,%eax
  801977:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80197a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801980:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801986:	b9 11 00 00 00       	mov    $0x11,%ecx
  80198b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80198d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801993:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801999:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80199e:	be 00 00 00 00       	mov    $0x0,%esi
  8019a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019a6:	eb 4b                	jmp    8019f3 <spawn+0xf0>
		close(fd);
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8019b1:	e8 d9 f8 ff ff       	call   80128f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019b6:	83 c4 0c             	add    $0xc,%esp
  8019b9:	68 7f 45 4c 46       	push   $0x464c457f
  8019be:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019c4:	68 0b 2c 80 00       	push   $0x802c0b
  8019c9:	e8 0d eb ff ff       	call   8004db <cprintf>
		return -E_NOT_EXEC;
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  8019d8:	ff ff ff 
  8019db:	e9 8a 02 00 00       	jmp    801c6a <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	50                   	push   %eax
  8019e4:	e8 da f0 ff ff       	call   800ac3 <strlen>
  8019e9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019ed:	83 c3 01             	add    $0x1,%ebx
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019fa:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	75 df                	jne    8019e0 <spawn+0xdd>
  801a01:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a07:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a0d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a12:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a14:	89 fa                	mov    %edi,%edx
  801a16:	83 e2 fc             	and    $0xfffffffc,%edx
  801a19:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a20:	29 c2                	sub    %eax,%edx
  801a22:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a28:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a2b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a30:	0f 86 c6 03 00 00    	jbe    801dfc <spawn+0x4f9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	6a 07                	push   $0x7
  801a3b:	68 00 00 40 00       	push   $0x400000
  801a40:	6a 00                	push   $0x0
  801a42:	e8 ac f4 ff ff       	call   800ef3 <sys_page_alloc>
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	0f 88 af 03 00 00    	js     801e01 <spawn+0x4fe>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a52:	be 00 00 00 00       	mov    $0x0,%esi
  801a57:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a60:	eb 30                	jmp    801a92 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801a62:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a68:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a6e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a77:	57                   	push   %edi
  801a78:	e8 7d f0 ff ff       	call   800afa <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a7d:	83 c4 04             	add    $0x4,%esp
  801a80:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a83:	e8 3b f0 ff ff       	call   800ac3 <strlen>
  801a88:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801a8c:	83 c6 01             	add    $0x1,%esi
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801a98:	7f c8                	jg     801a62 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801a9a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa0:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801aa6:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aad:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ab3:	0f 85 8c 00 00 00    	jne    801b45 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ab9:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801abf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ac5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	8b 8d 88 fd ff ff    	mov    -0x278(%ebp),%ecx
  801ad0:	89 4f f8             	mov    %ecx,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ad3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ad8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	6a 07                	push   $0x7
  801ae3:	68 00 d0 bf ee       	push   $0xeebfd000
  801ae8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aee:	68 00 00 40 00       	push   $0x400000
  801af3:	6a 00                	push   $0x0
  801af5:	e8 3c f4 ff ff       	call   800f36 <sys_page_map>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 20             	add    $0x20,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	0f 88 70 03 00 00    	js     801e77 <spawn+0x574>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b07:	83 ec 08             	sub    $0x8,%esp
  801b0a:	68 00 00 40 00       	push   $0x400000
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 62 f4 ff ff       	call   800f78 <sys_page_unmap>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 54 03 00 00    	js     801e77 <spawn+0x574>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b23:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b29:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b30:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b36:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b3d:	00 00 00 
  801b40:	e9 56 01 00 00       	jmp    801c9b <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b45:	68 98 2c 80 00       	push   $0x802c98
  801b4a:	68 9f 2b 80 00       	push   $0x802b9f
  801b4f:	68 f6 00 00 00       	push   $0xf6
  801b54:	68 25 2c 80 00       	push   $0x802c25
  801b59:	e8 a2 e8 ff ff       	call   800400 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b5e:	83 ec 04             	sub    $0x4,%esp
  801b61:	6a 07                	push   $0x7
  801b63:	68 00 00 40 00       	push   $0x400000
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 84 f3 ff ff       	call   800ef3 <sys_page_alloc>
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 92 02 00 00    	js     801e0c <spawn+0x509>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b83:	01 f0                	add    %esi,%eax
  801b85:	50                   	push   %eax
  801b86:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b8c:	e8 8a f9 ff ff       	call   80151b <seek>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 88 77 02 00 00    	js     801e13 <spawn+0x510>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b9c:	83 ec 04             	sub    $0x4,%esp
  801b9f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ba5:	29 f0                	sub    %esi,%eax
  801ba7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bac:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801bb1:	0f 47 c1             	cmova  %ecx,%eax
  801bb4:	50                   	push   %eax
  801bb5:	68 00 00 40 00       	push   $0x400000
  801bba:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801bc0:	e8 8d f8 ff ff       	call   801452 <readn>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 4a 02 00 00    	js     801e1a <spawn+0x517>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	57                   	push   %edi
  801bd4:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801bda:	56                   	push   %esi
  801bdb:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801be1:	68 00 00 40 00       	push   $0x400000
  801be6:	6a 00                	push   $0x0
  801be8:	e8 49 f3 ff ff       	call   800f36 <sys_page_map>
  801bed:	83 c4 20             	add    $0x20,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 80 00 00 00    	js     801c78 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	68 00 00 40 00       	push   $0x400000
  801c00:	6a 00                	push   $0x0
  801c02:	e8 71 f3 ff ff       	call   800f78 <sys_page_unmap>
  801c07:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801c0a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c10:	89 de                	mov    %ebx,%esi
  801c12:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801c18:	76 73                	jbe    801c8d <spawn+0x38a>
		if (i >= filesz) {
  801c1a:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801c20:	0f 87 38 ff ff ff    	ja     801b5e <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	57                   	push   %edi
  801c2a:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801c30:	56                   	push   %esi
  801c31:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c37:	e8 b7 f2 ff ff       	call   800ef3 <sys_page_alloc>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	79 c7                	jns    801c0a <spawn+0x307>
  801c43:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c4e:	e8 21 f2 ff ff       	call   800e74 <sys_env_destroy>
	close(fd);
  801c53:	83 c4 04             	add    $0x4,%esp
  801c56:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c5c:	e8 2e f6 ff ff       	call   80128f <close>
	return r;
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  801c6a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801c78:	50                   	push   %eax
  801c79:	68 31 2c 80 00       	push   $0x802c31
  801c7e:	68 29 01 00 00       	push   $0x129
  801c83:	68 25 2c 80 00       	push   $0x802c25
  801c88:	e8 73 e7 ff ff       	call   800400 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c8d:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801c94:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801c9b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ca2:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801ca8:	7e 71                	jle    801d1b <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801caa:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801cb0:	83 3a 01             	cmpl   $0x1,(%edx)
  801cb3:	75 d8                	jne    801c8d <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801cb5:	8b 42 18             	mov    0x18(%edx),%eax
  801cb8:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801cbb:	83 f8 01             	cmp    $0x1,%eax
  801cbe:	19 ff                	sbb    %edi,%edi
  801cc0:	83 e7 fe             	and    $0xfffffffe,%edi
  801cc3:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801cc6:	8b 72 04             	mov    0x4(%edx),%esi
  801cc9:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801ccf:	8b 5a 10             	mov    0x10(%edx),%ebx
  801cd2:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cd8:	8b 42 14             	mov    0x14(%edx),%eax
  801cdb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ce1:	8b 4a 08             	mov    0x8(%edx),%ecx
  801ce4:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801cea:	89 c8                	mov    %ecx,%eax
  801cec:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cf1:	74 1e                	je     801d11 <spawn+0x40e>
		va -= i;
  801cf3:	29 c1                	sub    %eax,%ecx
  801cf5:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
		memsz += i;
  801cfb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801d01:	01 c3                	add    %eax,%ebx
  801d03:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  801d09:	29 c6                	sub    %eax,%esi
  801d0b:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d16:	e9 f5 fe ff ff       	jmp    801c10 <spawn+0x30d>
	close(fd);
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d24:	e8 66 f5 ff ff       	call   80128f <close>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d31:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801d37:	eb 12                	jmp    801d4b <spawn+0x448>
  801d39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// LAB 5: Your code here.
    uint32_t *va;
    pte_t pte;
    int perm, r;
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801d3f:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801d45:	0f 84 d6 00 00 00    	je     801e21 <spawn+0x51e>
        va = (void *)(i*PGSIZE);
        if (!(uvpd[PDX(va)] & PTE_P) || !(uvpt[PGNUM(va)] & PTE_P))
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	c1 e8 16             	shr    $0x16,%eax
  801d50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d57:	a8 01                	test   $0x1,%al
  801d59:	74 de                	je     801d39 <spawn+0x436>
  801d5b:	89 d8                	mov    %ebx,%eax
  801d5d:	c1 e8 0c             	shr    $0xc,%eax
  801d60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d67:	f6 c2 01             	test   $0x1,%dl
  801d6a:	74 cd                	je     801d39 <spawn+0x436>
            continue;
        pte = (pte_t)uvpt[PGNUM(va)];
  801d6c:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
        if (!(pte & PTE_SHARE))
  801d73:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801d79:	74 be                	je     801d39 <spawn+0x436>
            continue;
        cprintf("[%08x] -------- shared --------- va=%x \n", thisenv->env_id, va);
  801d7b:	a1 90 67 80 00       	mov    0x806790,%eax
  801d80:	8b 40 48             	mov    0x48(%eax),%eax
  801d83:	83 ec 04             	sub    $0x4,%esp
  801d86:	53                   	push   %ebx
  801d87:	50                   	push   %eax
  801d88:	68 c0 2c 80 00       	push   $0x802cc0
  801d8d:	e8 49 e7 ff ff       	call   8004db <cprintf>
        perm = pte & PTE_SYSCALL;
  801d92:	81 e7 07 0e 00 00    	and    $0xe07,%edi
        if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  801d98:	89 3c 24             	mov    %edi,(%esp)
  801d9b:	53                   	push   %ebx
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 91 f1 ff ff       	call   800f36 <sys_page_map>
  801da5:	83 c4 20             	add    $0x20,%esp
  801da8:	85 c0                	test   %eax,%eax
  801daa:	79 8d                	jns    801d39 <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  801dac:	50                   	push   %eax
  801dad:	68 7f 2c 80 00       	push   $0x802c7f
  801db2:	68 82 00 00 00       	push   $0x82
  801db7:	68 25 2c 80 00       	push   $0x802c25
  801dbc:	e8 3f e6 ff ff       	call   800400 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801dc1:	50                   	push   %eax
  801dc2:	68 4e 2c 80 00       	push   $0x802c4e
  801dc7:	68 86 00 00 00       	push   $0x86
  801dcc:	68 25 2c 80 00       	push   $0x802c25
  801dd1:	e8 2a e6 ff ff       	call   800400 <_panic>
		panic("sys_env_set_status: %e", r);
  801dd6:	50                   	push   %eax
  801dd7:	68 68 2c 80 00       	push   $0x802c68
  801ddc:	68 89 00 00 00       	push   $0x89
  801de1:	68 25 2c 80 00       	push   $0x802c25
  801de6:	e8 15 e6 ff ff       	call   800400 <_panic>
		return r;
  801deb:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801df1:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801df7:	e9 6e fe ff ff       	jmp    801c6a <spawn+0x367>
		return -E_NO_MEM;
  801dfc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801e01:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801e07:	e9 5e fe ff ff       	jmp    801c6a <spawn+0x367>
  801e0c:	89 c7                	mov    %eax,%edi
  801e0e:	e9 32 fe ff ff       	jmp    801c45 <spawn+0x342>
  801e13:	89 c7                	mov    %eax,%edi
  801e15:	e9 2b fe ff ff       	jmp    801c45 <spawn+0x342>
  801e1a:	89 c7                	mov    %eax,%edi
  801e1c:	e9 24 fe ff ff       	jmp    801c45 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e21:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e28:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e2b:	83 ec 08             	sub    $0x8,%esp
  801e2e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e3b:	e8 bc f1 ff ff       	call   800ffc <sys_env_set_trapframe>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	0f 88 76 ff ff ff    	js     801dc1 <spawn+0x4be>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	6a 02                	push   $0x2
  801e50:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e56:	e8 5f f1 ff ff       	call   800fba <sys_env_set_status>
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 70 ff ff ff    	js     801dd6 <spawn+0x4d3>
	return child;
  801e66:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e6c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801e72:	e9 f3 fd ff ff       	jmp    801c6a <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	68 00 00 40 00       	push   $0x400000
  801e7f:	6a 00                	push   $0x0
  801e81:	e8 f2 f0 ff ff       	call   800f78 <sys_page_unmap>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e8f:	e9 d6 fd ff ff       	jmp    801c6a <spawn+0x367>

00801e94 <spawnl>:
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	57                   	push   %edi
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	83 ec 1c             	sub    $0x1c,%esp
	va_start(vl, arg0);
  801e9d:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  801ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(va_arg(vl, void *) != NULL)
  801ea5:	eb 05                	jmp    801eac <spawnl+0x18>
		argc++;
  801ea7:	83 c3 01             	add    $0x1,%ebx
	while(va_arg(vl, void *) != NULL)
  801eaa:	89 d0                	mov    %edx,%eax
  801eac:	8d 50 04             	lea    0x4(%eax),%edx
  801eaf:	83 38 00             	cmpl   $0x0,(%eax)
  801eb2:	75 f3                	jne    801ea7 <spawnl+0x13>
	const char *argv[argc+2];
  801eb4:	8d 04 9d 1a 00 00 00 	lea    0x1a(,%ebx,4),%eax
  801ebb:	83 e0 f0             	and    $0xfffffff0,%eax
  801ebe:	29 c4                	sub    %eax,%esp
  801ec0:	8d 44 24 03          	lea    0x3(%esp),%eax
  801ec4:	c1 e8 02             	shr    $0x2,%eax
  801ec7:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801ece:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801ed1:	89 f7                	mov    %esi,%edi
	argv[0] = arg0;
  801ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed6:	89 14 85 00 00 00 00 	mov    %edx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801edd:	c7 44 9e 04 00 00 00 	movl   $0x0,0x4(%esi,%ebx,4)
  801ee4:	00 
	va_start(vl, arg0);
  801ee5:	8d 75 10             	lea    0x10(%ebp),%esi
    cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[0]);
  801ee8:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801eee:	8b 52 48             	mov    0x48(%edx),%edx
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	ff 34 85 00 00 00 00 	pushl  0x0(,%eax,4)
  801efb:	52                   	push   %edx
  801efc:	68 ec 2c 80 00       	push   $0x802cec
  801f01:	e8 d5 e5 ff ff       	call   8004db <cprintf>
  801f06:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<argc;i++) {
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f11:	89 f0                	mov    %esi,%eax
  801f13:	89 fe                	mov    %edi,%esi
  801f15:	eb 28                	jmp    801f3f <spawnl+0xab>
        argv[i+1] = va_arg(vl, const char *);
  801f17:	83 c3 01             	add    $0x1,%ebx
  801f1a:	8d 78 04             	lea    0x4(%eax),%edi
  801f1d:	8b 00                	mov    (%eax),%eax
  801f1f:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
        cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[i+1]);
  801f22:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f28:	8b 52 48             	mov    0x48(%edx),%edx
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	50                   	push   %eax
  801f2f:	52                   	push   %edx
  801f30:	68 ec 2c 80 00       	push   $0x802cec
  801f35:	e8 a1 e5 ff ff       	call   8004db <cprintf>
	for(i=0;i<argc;i++) {
  801f3a:	83 c4 10             	add    $0x10,%esp
        argv[i+1] = va_arg(vl, const char *);
  801f3d:	89 f8                	mov    %edi,%eax
	for(i=0;i<argc;i++) {
  801f3f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  801f42:	75 d3                	jne    801f17 <spawnl+0x83>
	return spawn(prog, argv);
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4a:	ff 75 08             	pushl  0x8(%ebp)
  801f4d:	e8 b1 f9 ff ff       	call   801903 <spawn>
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f62:	83 ec 0c             	sub    $0xc,%esp
  801f65:	ff 75 08             	pushl  0x8(%ebp)
  801f68:	e8 87 f1 ff ff       	call   8010f4 <fd2data>
  801f6d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f6f:	83 c4 08             	add    $0x8,%esp
  801f72:	68 14 2d 80 00       	push   $0x802d14
  801f77:	53                   	push   %ebx
  801f78:	e8 7d eb ff ff       	call   800afa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f7d:	8b 46 04             	mov    0x4(%esi),%eax
  801f80:	2b 06                	sub    (%esi),%eax
  801f82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f8f:	00 00 00 
	stat->st_dev = &devpipe;
  801f92:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801f99:	47 80 00 
	return 0;
}
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	53                   	push   %ebx
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fb2:	53                   	push   %ebx
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 be ef ff ff       	call   800f78 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fba:	89 1c 24             	mov    %ebx,(%esp)
  801fbd:	e8 32 f1 ff ff       	call   8010f4 <fd2data>
  801fc2:	83 c4 08             	add    $0x8,%esp
  801fc5:	50                   	push   %eax
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 ab ef ff ff       	call   800f78 <sys_page_unmap>
}
  801fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <_pipeisclosed>:
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	83 ec 1c             	sub    $0x1c,%esp
  801fdb:	89 c7                	mov    %eax,%edi
  801fdd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801fdf:	a1 90 67 80 00       	mov    0x806790,%eax
  801fe4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	57                   	push   %edi
  801feb:	e8 ed 03 00 00       	call   8023dd <pageref>
  801ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ff3:	89 34 24             	mov    %esi,(%esp)
  801ff6:	e8 e2 03 00 00       	call   8023dd <pageref>
		nn = thisenv->env_runs;
  801ffb:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802001:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	39 cb                	cmp    %ecx,%ebx
  802009:	74 1b                	je     802026 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80200b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80200e:	75 cf                	jne    801fdf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802010:	8b 42 58             	mov    0x58(%edx),%eax
  802013:	6a 01                	push   $0x1
  802015:	50                   	push   %eax
  802016:	53                   	push   %ebx
  802017:	68 1b 2d 80 00       	push   $0x802d1b
  80201c:	e8 ba e4 ff ff       	call   8004db <cprintf>
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	eb b9                	jmp    801fdf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802026:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802029:	0f 94 c0             	sete   %al
  80202c:	0f b6 c0             	movzbl %al,%eax
}
  80202f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <devpipe_write>:
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	57                   	push   %edi
  80203b:	56                   	push   %esi
  80203c:	53                   	push   %ebx
  80203d:	83 ec 28             	sub    $0x28,%esp
  802040:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802043:	56                   	push   %esi
  802044:	e8 ab f0 ff ff       	call   8010f4 <fd2data>
  802049:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	bf 00 00 00 00       	mov    $0x0,%edi
  802053:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802056:	74 4f                	je     8020a7 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802058:	8b 43 04             	mov    0x4(%ebx),%eax
  80205b:	8b 0b                	mov    (%ebx),%ecx
  80205d:	8d 51 20             	lea    0x20(%ecx),%edx
  802060:	39 d0                	cmp    %edx,%eax
  802062:	72 14                	jb     802078 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  802064:	89 da                	mov    %ebx,%edx
  802066:	89 f0                	mov    %esi,%eax
  802068:	e8 65 ff ff ff       	call   801fd2 <_pipeisclosed>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	75 3a                	jne    8020ab <devpipe_write+0x74>
			sys_yield();
  802071:	e8 5e ee ff ff       	call   800ed4 <sys_yield>
  802076:	eb e0                	jmp    802058 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80207f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802082:	89 c2                	mov    %eax,%edx
  802084:	c1 fa 1f             	sar    $0x1f,%edx
  802087:	89 d1                	mov    %edx,%ecx
  802089:	c1 e9 1b             	shr    $0x1b,%ecx
  80208c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80208f:	83 e2 1f             	and    $0x1f,%edx
  802092:	29 ca                	sub    %ecx,%edx
  802094:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802098:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80209c:	83 c0 01             	add    $0x1,%eax
  80209f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8020a2:	83 c7 01             	add    $0x1,%edi
  8020a5:	eb ac                	jmp    802053 <devpipe_write+0x1c>
	return i;
  8020a7:	89 f8                	mov    %edi,%eax
  8020a9:	eb 05                	jmp    8020b0 <devpipe_write+0x79>
				return 0;
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <devpipe_read>:
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 18             	sub    $0x18,%esp
  8020c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020c4:	57                   	push   %edi
  8020c5:	e8 2a f0 ff ff       	call   8010f4 <fd2data>
  8020ca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	be 00 00 00 00       	mov    $0x0,%esi
  8020d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020d7:	74 47                	je     802120 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8020d9:	8b 03                	mov    (%ebx),%eax
  8020db:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020de:	75 22                	jne    802102 <devpipe_read+0x4a>
			if (i > 0)
  8020e0:	85 f6                	test   %esi,%esi
  8020e2:	75 14                	jne    8020f8 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8020e4:	89 da                	mov    %ebx,%edx
  8020e6:	89 f8                	mov    %edi,%eax
  8020e8:	e8 e5 fe ff ff       	call   801fd2 <_pipeisclosed>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	75 33                	jne    802124 <devpipe_read+0x6c>
			sys_yield();
  8020f1:	e8 de ed ff ff       	call   800ed4 <sys_yield>
  8020f6:	eb e1                	jmp    8020d9 <devpipe_read+0x21>
				return i;
  8020f8:	89 f0                	mov    %esi,%eax
}
  8020fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802102:	99                   	cltd   
  802103:	c1 ea 1b             	shr    $0x1b,%edx
  802106:	01 d0                	add    %edx,%eax
  802108:	83 e0 1f             	and    $0x1f,%eax
  80210b:	29 d0                	sub    %edx,%eax
  80210d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802115:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802118:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80211b:	83 c6 01             	add    $0x1,%esi
  80211e:	eb b4                	jmp    8020d4 <devpipe_read+0x1c>
	return i;
  802120:	89 f0                	mov    %esi,%eax
  802122:	eb d6                	jmp    8020fa <devpipe_read+0x42>
				return 0;
  802124:	b8 00 00 00 00       	mov    $0x0,%eax
  802129:	eb cf                	jmp    8020fa <devpipe_read+0x42>

0080212b <pipe>:
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	56                   	push   %esi
  80212f:	53                   	push   %ebx
  802130:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802136:	50                   	push   %eax
  802137:	e8 cf ef ff ff       	call   80110b <fd_alloc>
  80213c:	89 c3                	mov    %eax,%ebx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	85 c0                	test   %eax,%eax
  802143:	78 5b                	js     8021a0 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802145:	83 ec 04             	sub    $0x4,%esp
  802148:	68 07 04 00 00       	push   $0x407
  80214d:	ff 75 f4             	pushl  -0xc(%ebp)
  802150:	6a 00                	push   $0x0
  802152:	e8 9c ed ff ff       	call   800ef3 <sys_page_alloc>
  802157:	89 c3                	mov    %eax,%ebx
  802159:	83 c4 10             	add    $0x10,%esp
  80215c:	85 c0                	test   %eax,%eax
  80215e:	78 40                	js     8021a0 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  802160:	83 ec 0c             	sub    $0xc,%esp
  802163:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802166:	50                   	push   %eax
  802167:	e8 9f ef ff ff       	call   80110b <fd_alloc>
  80216c:	89 c3                	mov    %eax,%ebx
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	85 c0                	test   %eax,%eax
  802173:	78 1b                	js     802190 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802175:	83 ec 04             	sub    $0x4,%esp
  802178:	68 07 04 00 00       	push   $0x407
  80217d:	ff 75 f0             	pushl  -0x10(%ebp)
  802180:	6a 00                	push   $0x0
  802182:	e8 6c ed ff ff       	call   800ef3 <sys_page_alloc>
  802187:	89 c3                	mov    %eax,%ebx
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	85 c0                	test   %eax,%eax
  80218e:	79 19                	jns    8021a9 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	ff 75 f4             	pushl  -0xc(%ebp)
  802196:	6a 00                	push   $0x0
  802198:	e8 db ed ff ff       	call   800f78 <sys_page_unmap>
  80219d:	83 c4 10             	add    $0x10,%esp
}
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
	va = fd2data(fd0);
  8021a9:	83 ec 0c             	sub    $0xc,%esp
  8021ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8021af:	e8 40 ef ff ff       	call   8010f4 <fd2data>
  8021b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b6:	83 c4 0c             	add    $0xc,%esp
  8021b9:	68 07 04 00 00       	push   $0x407
  8021be:	50                   	push   %eax
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 2d ed ff ff       	call   800ef3 <sys_page_alloc>
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	0f 88 8c 00 00 00    	js     80225f <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d3:	83 ec 0c             	sub    $0xc,%esp
  8021d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d9:	e8 16 ef ff ff       	call   8010f4 <fd2data>
  8021de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e5:	50                   	push   %eax
  8021e6:	6a 00                	push   $0x0
  8021e8:	56                   	push   %esi
  8021e9:	6a 00                	push   $0x0
  8021eb:	e8 46 ed ff ff       	call   800f36 <sys_page_map>
  8021f0:	89 c3                	mov    %eax,%ebx
  8021f2:	83 c4 20             	add    $0x20,%esp
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	78 58                	js     802251 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802202:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802204:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802207:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80220e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802211:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802217:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80221c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802223:	83 ec 0c             	sub    $0xc,%esp
  802226:	ff 75 f4             	pushl  -0xc(%ebp)
  802229:	e8 b6 ee ff ff       	call   8010e4 <fd2num>
  80222e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802231:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802233:	83 c4 04             	add    $0x4,%esp
  802236:	ff 75 f0             	pushl  -0x10(%ebp)
  802239:	e8 a6 ee ff ff       	call   8010e4 <fd2num>
  80223e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802241:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80224c:	e9 4f ff ff ff       	jmp    8021a0 <pipe+0x75>
	sys_page_unmap(0, va);
  802251:	83 ec 08             	sub    $0x8,%esp
  802254:	56                   	push   %esi
  802255:	6a 00                	push   $0x0
  802257:	e8 1c ed ff ff       	call   800f78 <sys_page_unmap>
  80225c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80225f:	83 ec 08             	sub    $0x8,%esp
  802262:	ff 75 f0             	pushl  -0x10(%ebp)
  802265:	6a 00                	push   $0x0
  802267:	e8 0c ed ff ff       	call   800f78 <sys_page_unmap>
  80226c:	83 c4 10             	add    $0x10,%esp
  80226f:	e9 1c ff ff ff       	jmp    802190 <pipe+0x65>

00802274 <pipeisclosed>:
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80227a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227d:	50                   	push   %eax
  80227e:	ff 75 08             	pushl  0x8(%ebp)
  802281:	e8 d4 ee ff ff       	call   80115a <fd_lookup>
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	85 c0                	test   %eax,%eax
  80228b:	78 18                	js     8022a5 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80228d:	83 ec 0c             	sub    $0xc,%esp
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	e8 5c ee ff ff       	call   8010f4 <fd2data>
	return _pipeisclosed(fd, p);
  802298:	89 c2                	mov    %eax,%edx
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	e8 30 fd ff ff       	call   801fd2 <_pipeisclosed>
  8022a2:	83 c4 10             	add    $0x10,%esp
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	56                   	push   %esi
  8022ab:	53                   	push   %ebx
  8022ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022af:	85 f6                	test   %esi,%esi
  8022b1:	74 13                	je     8022c6 <wait+0x1f>
	e = &envs[ENVX(envid)];
  8022b3:	89 f3                	mov    %esi,%ebx
  8022b5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022bb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022be:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022c4:	eb 1b                	jmp    8022e1 <wait+0x3a>
	assert(envid != 0);
  8022c6:	68 33 2d 80 00       	push   $0x802d33
  8022cb:	68 9f 2b 80 00       	push   $0x802b9f
  8022d0:	6a 09                	push   $0x9
  8022d2:	68 3e 2d 80 00       	push   $0x802d3e
  8022d7:	e8 24 e1 ff ff       	call   800400 <_panic>
		sys_yield();
  8022dc:	e8 f3 eb ff ff       	call   800ed4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022e1:	8b 43 48             	mov    0x48(%ebx),%eax
  8022e4:	39 f0                	cmp    %esi,%eax
  8022e6:	75 07                	jne    8022ef <wait+0x48>
  8022e8:	8b 43 54             	mov    0x54(%ebx),%eax
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	75 ed                	jne    8022dc <wait+0x35>
}
  8022ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f2:	5b                   	pop    %ebx
  8022f3:	5e                   	pop    %esi
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	56                   	push   %esi
  8022fa:	53                   	push   %ebx
  8022fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8022fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802301:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  802304:	85 c0                	test   %eax,%eax
  802306:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80230b:	0f 44 c2             	cmove  %edx,%eax
  80230e:	83 ec 0c             	sub    $0xc,%esp
  802311:	50                   	push   %eax
  802312:	e8 8c ed ff ff       	call   8010a3 <sys_ipc_recv>
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 2b                	js     802349 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  80231e:	85 f6                	test   %esi,%esi
  802320:	74 0a                	je     80232c <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  802322:	a1 90 67 80 00       	mov    0x806790,%eax
  802327:	8b 40 74             	mov    0x74(%eax),%eax
  80232a:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  80232c:	85 db                	test   %ebx,%ebx
  80232e:	74 0a                	je     80233a <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  802330:	a1 90 67 80 00       	mov    0x806790,%eax
  802335:	8b 40 78             	mov    0x78(%eax),%eax
  802338:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  80233a:	a1 90 67 80 00       	mov    0x806790,%eax
  80233f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802342:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802345:	5b                   	pop    %ebx
  802346:	5e                   	pop    %esi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
        *from_env_store = 0;
  802349:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  80234f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802355:	eb eb                	jmp    802342 <ipc_recv+0x4c>

00802357 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	57                   	push   %edi
  80235b:	56                   	push   %esi
  80235c:	53                   	push   %ebx
  80235d:	83 ec 0c             	sub    $0xc,%esp
  802360:	8b 7d 08             	mov    0x8(%ebp),%edi
  802363:	8b 75 0c             	mov    0xc(%ebp),%esi
  802366:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  802369:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80236b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802370:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802373:	ff 75 14             	pushl  0x14(%ebp)
  802376:	53                   	push   %ebx
  802377:	56                   	push   %esi
  802378:	57                   	push   %edi
  802379:	e8 02 ed ff ff       	call   801080 <sys_ipc_try_send>
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	85 c0                	test   %eax,%eax
  802383:	74 17                	je     80239c <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802385:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802388:	74 e9                	je     802373 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  80238a:	50                   	push   %eax
  80238b:	68 49 2d 80 00       	push   $0x802d49
  802390:	6a 3e                	push   $0x3e
  802392:	68 5b 2d 80 00       	push   $0x802d5b
  802397:	e8 64 e0 ff ff       	call   800400 <_panic>
        }
    }
}
  80239c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023af:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023b8:	8b 52 50             	mov    0x50(%edx),%edx
  8023bb:	39 ca                	cmp    %ecx,%edx
  8023bd:	74 11                	je     8023d0 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8023bf:	83 c0 01             	add    $0x1,%eax
  8023c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c7:	75 e6                	jne    8023af <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ce:	eb 0b                	jmp    8023db <ipc_find_env+0x37>
			return envs[i].env_id;
  8023d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023d8:	8b 40 48             	mov    0x48(%eax),%eax
}
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    

008023dd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e3:	89 d0                	mov    %edx,%eax
  8023e5:	c1 e8 16             	shr    $0x16,%eax
  8023e8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8023f4:	f6 c1 01             	test   $0x1,%cl
  8023f7:	74 1d                	je     802416 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8023f9:	c1 ea 0c             	shr    $0xc,%edx
  8023fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802403:	f6 c2 01             	test   $0x1,%dl
  802406:	74 0e                	je     802416 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802408:	c1 ea 0c             	shr    $0xc,%edx
  80240b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802412:	ef 
  802413:	0f b7 c0             	movzwl %ax,%eax
}
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	66 90                	xchg   %ax,%ax
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80242b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80242f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802433:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802437:	85 d2                	test   %edx,%edx
  802439:	75 35                	jne    802470 <__udivdi3+0x50>
  80243b:	39 f3                	cmp    %esi,%ebx
  80243d:	0f 87 bd 00 00 00    	ja     802500 <__udivdi3+0xe0>
  802443:	85 db                	test   %ebx,%ebx
  802445:	89 d9                	mov    %ebx,%ecx
  802447:	75 0b                	jne    802454 <__udivdi3+0x34>
  802449:	b8 01 00 00 00       	mov    $0x1,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f3                	div    %ebx
  802452:	89 c1                	mov    %eax,%ecx
  802454:	31 d2                	xor    %edx,%edx
  802456:	89 f0                	mov    %esi,%eax
  802458:	f7 f1                	div    %ecx
  80245a:	89 c6                	mov    %eax,%esi
  80245c:	89 e8                	mov    %ebp,%eax
  80245e:	89 f7                	mov    %esi,%edi
  802460:	f7 f1                	div    %ecx
  802462:	89 fa                	mov    %edi,%edx
  802464:	83 c4 1c             	add    $0x1c,%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 f2                	cmp    %esi,%edx
  802472:	77 7c                	ja     8024f0 <__udivdi3+0xd0>
  802474:	0f bd fa             	bsr    %edx,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0xf8>
  802480:	89 f9                	mov    %edi,%ecx
  802482:	b8 20 00 00 00       	mov    $0x20,%eax
  802487:	29 f8                	sub    %edi,%eax
  802489:	d3 e2                	shl    %cl,%edx
  80248b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80248f:	89 c1                	mov    %eax,%ecx
  802491:	89 da                	mov    %ebx,%edx
  802493:	d3 ea                	shr    %cl,%edx
  802495:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802499:	09 d1                	or     %edx,%ecx
  80249b:	89 f2                	mov    %esi,%edx
  80249d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e3                	shl    %cl,%ebx
  8024a5:	89 c1                	mov    %eax,%ecx
  8024a7:	d3 ea                	shr    %cl,%edx
  8024a9:	89 f9                	mov    %edi,%ecx
  8024ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024af:	d3 e6                	shl    %cl,%esi
  8024b1:	89 eb                	mov    %ebp,%ebx
  8024b3:	89 c1                	mov    %eax,%ecx
  8024b5:	d3 eb                	shr    %cl,%ebx
  8024b7:	09 de                	or     %ebx,%esi
  8024b9:	89 f0                	mov    %esi,%eax
  8024bb:	f7 74 24 08          	divl   0x8(%esp)
  8024bf:	89 d6                	mov    %edx,%esi
  8024c1:	89 c3                	mov    %eax,%ebx
  8024c3:	f7 64 24 0c          	mull   0xc(%esp)
  8024c7:	39 d6                	cmp    %edx,%esi
  8024c9:	72 0c                	jb     8024d7 <__udivdi3+0xb7>
  8024cb:	89 f9                	mov    %edi,%ecx
  8024cd:	d3 e5                	shl    %cl,%ebp
  8024cf:	39 c5                	cmp    %eax,%ebp
  8024d1:	73 5d                	jae    802530 <__udivdi3+0x110>
  8024d3:	39 d6                	cmp    %edx,%esi
  8024d5:	75 59                	jne    802530 <__udivdi3+0x110>
  8024d7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024da:	31 ff                	xor    %edi,%edi
  8024dc:	89 fa                	mov    %edi,%edx
  8024de:	83 c4 1c             	add    $0x1c,%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    
  8024e6:	8d 76 00             	lea    0x0(%esi),%esi
  8024e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8024f0:	31 ff                	xor    %edi,%edi
  8024f2:	31 c0                	xor    %eax,%eax
  8024f4:	89 fa                	mov    %edi,%edx
  8024f6:	83 c4 1c             	add    $0x1c,%esp
  8024f9:	5b                   	pop    %ebx
  8024fa:	5e                   	pop    %esi
  8024fb:	5f                   	pop    %edi
  8024fc:	5d                   	pop    %ebp
  8024fd:	c3                   	ret    
  8024fe:	66 90                	xchg   %ax,%ax
  802500:	31 ff                	xor    %edi,%edi
  802502:	89 e8                	mov    %ebp,%eax
  802504:	89 f2                	mov    %esi,%edx
  802506:	f7 f3                	div    %ebx
  802508:	89 fa                	mov    %edi,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	39 f2                	cmp    %esi,%edx
  80251a:	72 06                	jb     802522 <__udivdi3+0x102>
  80251c:	31 c0                	xor    %eax,%eax
  80251e:	39 eb                	cmp    %ebp,%ebx
  802520:	77 d2                	ja     8024f4 <__udivdi3+0xd4>
  802522:	b8 01 00 00 00       	mov    $0x1,%eax
  802527:	eb cb                	jmp    8024f4 <__udivdi3+0xd4>
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d8                	mov    %ebx,%eax
  802532:	31 ff                	xor    %edi,%edi
  802534:	eb be                	jmp    8024f4 <__udivdi3+0xd4>
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80254b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80254f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 ed                	test   %ebp,%ebp
  802559:	89 f0                	mov    %esi,%eax
  80255b:	89 da                	mov    %ebx,%edx
  80255d:	75 19                	jne    802578 <__umoddi3+0x38>
  80255f:	39 df                	cmp    %ebx,%edi
  802561:	0f 86 b1 00 00 00    	jbe    802618 <__umoddi3+0xd8>
  802567:	f7 f7                	div    %edi
  802569:	89 d0                	mov    %edx,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	83 c4 1c             	add    $0x1c,%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    
  802575:	8d 76 00             	lea    0x0(%esi),%esi
  802578:	39 dd                	cmp    %ebx,%ebp
  80257a:	77 f1                	ja     80256d <__umoddi3+0x2d>
  80257c:	0f bd cd             	bsr    %ebp,%ecx
  80257f:	83 f1 1f             	xor    $0x1f,%ecx
  802582:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802586:	0f 84 b4 00 00 00    	je     802640 <__umoddi3+0x100>
  80258c:	b8 20 00 00 00       	mov    $0x20,%eax
  802591:	89 c2                	mov    %eax,%edx
  802593:	8b 44 24 04          	mov    0x4(%esp),%eax
  802597:	29 c2                	sub    %eax,%edx
  802599:	89 c1                	mov    %eax,%ecx
  80259b:	89 f8                	mov    %edi,%eax
  80259d:	d3 e5                	shl    %cl,%ebp
  80259f:	89 d1                	mov    %edx,%ecx
  8025a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8025a5:	d3 e8                	shr    %cl,%eax
  8025a7:	09 c5                	or     %eax,%ebp
  8025a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025ad:	89 c1                	mov    %eax,%ecx
  8025af:	d3 e7                	shl    %cl,%edi
  8025b1:	89 d1                	mov    %edx,%ecx
  8025b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8025b7:	89 df                	mov    %ebx,%edi
  8025b9:	d3 ef                	shr    %cl,%edi
  8025bb:	89 c1                	mov    %eax,%ecx
  8025bd:	89 f0                	mov    %esi,%eax
  8025bf:	d3 e3                	shl    %cl,%ebx
  8025c1:	89 d1                	mov    %edx,%ecx
  8025c3:	89 fa                	mov    %edi,%edx
  8025c5:	d3 e8                	shr    %cl,%eax
  8025c7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025cc:	09 d8                	or     %ebx,%eax
  8025ce:	f7 f5                	div    %ebp
  8025d0:	d3 e6                	shl    %cl,%esi
  8025d2:	89 d1                	mov    %edx,%ecx
  8025d4:	f7 64 24 08          	mull   0x8(%esp)
  8025d8:	39 d1                	cmp    %edx,%ecx
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d7                	mov    %edx,%edi
  8025de:	72 06                	jb     8025e6 <__umoddi3+0xa6>
  8025e0:	75 0e                	jne    8025f0 <__umoddi3+0xb0>
  8025e2:	39 c6                	cmp    %eax,%esi
  8025e4:	73 0a                	jae    8025f0 <__umoddi3+0xb0>
  8025e6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8025ea:	19 ea                	sbb    %ebp,%edx
  8025ec:	89 d7                	mov    %edx,%edi
  8025ee:	89 c3                	mov    %eax,%ebx
  8025f0:	89 ca                	mov    %ecx,%edx
  8025f2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025f7:	29 de                	sub    %ebx,%esi
  8025f9:	19 fa                	sbb    %edi,%edx
  8025fb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8025ff:	89 d0                	mov    %edx,%eax
  802601:	d3 e0                	shl    %cl,%eax
  802603:	89 d9                	mov    %ebx,%ecx
  802605:	d3 ee                	shr    %cl,%esi
  802607:	d3 ea                	shr    %cl,%edx
  802609:	09 f0                	or     %esi,%eax
  80260b:	83 c4 1c             	add    $0x1c,%esp
  80260e:	5b                   	pop    %ebx
  80260f:	5e                   	pop    %esi
  802610:	5f                   	pop    %edi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	85 ff                	test   %edi,%edi
  80261a:	89 f9                	mov    %edi,%ecx
  80261c:	75 0b                	jne    802629 <__umoddi3+0xe9>
  80261e:	b8 01 00 00 00       	mov    $0x1,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f7                	div    %edi
  802627:	89 c1                	mov    %eax,%ecx
  802629:	89 d8                	mov    %ebx,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f1                	div    %ecx
  80262f:	89 f0                	mov    %esi,%eax
  802631:	f7 f1                	div    %ecx
  802633:	e9 31 ff ff ff       	jmp    802569 <__umoddi3+0x29>
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	39 dd                	cmp    %ebx,%ebp
  802642:	72 08                	jb     80264c <__umoddi3+0x10c>
  802644:	39 f7                	cmp    %esi,%edi
  802646:	0f 87 21 ff ff ff    	ja     80256d <__umoddi3+0x2d>
  80264c:	89 da                	mov    %ebx,%edx
  80264e:	89 f0                	mov    %esi,%eax
  802650:	29 f8                	sub    %edi,%eax
  802652:	19 ea                	sbb    %ebp,%edx
  802654:	e9 14 ff ff ff       	jmp    80256d <__umoddi3+0x2d>
