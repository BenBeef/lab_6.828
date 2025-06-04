
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 33 02 00 00       	call   800264 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 66 0e 00 00       	call   800eaa <sys_yield>
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 12 12 00 00       	call   801265 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	78 16                	js     800075 <umain+0x42>
		panic("opencons: %e", r);
	if (r != 0)
  80005f:	85 c0                	test   %eax,%eax
  800061:	74 24                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800063:	50                   	push   %eax
  800064:	68 bc 20 80 00       	push   $0x8020bc
  800069:	6a 11                	push   $0x11
  80006b:	68 ad 20 80 00       	push   $0x8020ad
  800070:	e8 4f 02 00 00       	call   8002c4 <_panic>
		panic("opencons: %e", r);
  800075:	50                   	push   %eax
  800076:	68 a0 20 80 00       	push   $0x8020a0
  80007b:	6a 0f                	push   $0xf
  80007d:	68 ad 20 80 00       	push   $0x8020ad
  800082:	e8 3d 02 00 00       	call   8002c4 <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 22 12 00 00       	call   8012b5 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 24                	jns    8000be <umain+0x8b>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 d6 20 80 00       	push   $0x8020d6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 ad 20 80 00       	push   $0x8020ad
  8000a7:	e8 18 02 00 00       	call   8002c4 <_panic>

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
		else
			fprintf(1, "(end of file received)\n");
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	68 f0 20 80 00       	push   $0x8020f0
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 06 19 00 00       	call   8019c1 <fprintf>
  8000bb:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	68 de 20 80 00       	push   $0x8020de
  8000c6:	e8 bc 08 00 00       	call   800987 <readline>
		if (buf != NULL)
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	74 da                	je     8000ac <umain+0x79>
			fprintf(1, "%s\n", buf);
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	50                   	push   %eax
  8000d6:	68 ec 20 80 00       	push   $0x8020ec
  8000db:	6a 01                	push   $0x1
  8000dd:	e8 df 18 00 00       	call   8019c1 <fprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb d7                	jmp    8000be <umain+0x8b>

008000e7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f7:	68 08 21 80 00       	push   $0x802108
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	e8 cc 09 00 00       	call   800ad0 <strcpy>
	return 0;
}
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <devcons_write>:
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800117:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80011c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800122:	eb 2f                	jmp    800153 <devcons_write+0x48>
		m = n - tot;
  800124:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800127:	29 f3                	sub    %esi,%ebx
  800129:	83 fb 7f             	cmp    $0x7f,%ebx
  80012c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800131:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	53                   	push   %ebx
  800138:	89 f0                	mov    %esi,%eax
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 1a 0b 00 00       	call   800c5e <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 bf 0c 00 00       	call   800e0d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	3b 75 10             	cmp    0x10(%ebp),%esi
  800156:	72 cc                	jb     800124 <devcons_write+0x19>
}
  800158:	89 f0                	mov    %esi,%eax
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	75 07                	jne    80017a <devcons_read+0x18>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
		sys_yield();
  800175:	e8 30 0d 00 00       	call   800eaa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80017a:	e8 ac 0c 00 00       	call   800e2b <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 ec                	js     800173 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb db                	jmp    800173 <devcons_read+0x11>
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
  80019d:	eb d4                	jmp    800173 <devcons_read+0x11>

0080019f <cputchar>:
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 57 0c 00 00       	call   800e0d <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 d3 11 00 00       	call   8013a1 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 08                	js     8001dd <getchar+0x22>
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8001e4:	eb f7                	jmp    8001dd <getchar+0x22>

008001e6 <iscons>:
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 38 0f 00 00       	call   801130 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 c0 0e 00 00       	call   8010e1 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	85 c0                	test   %eax,%eax
  800226:	78 3a                	js     800262 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	68 07 04 00 00       	push   $0x407
  800230:	ff 75 f4             	pushl  -0xc(%ebp)
  800233:	6a 00                	push   $0x0
  800235:	e8 8f 0c 00 00       	call   800ec9 <sys_page_alloc>
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	85 c0                	test   %eax,%eax
  80023f:	78 21                	js     800262 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800244:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80024c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	e8 5b 0e 00 00       	call   8010ba <fd2num>
  80025f:	83 c4 10             	add    $0x10,%esp
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80026f:	e8 17 0c 00 00       	call   800e8b <sys_getenvid>
  800274:	25 ff 03 00 00       	and    $0x3ff,%eax
  800279:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800281:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800286:	85 db                	test   %ebx,%ebx
  800288:	7e 07                	jle    800291 <libmain+0x2d>
		binaryname = argv[0];
  80028a:	8b 06                	mov    (%esi),%eax
  80028c:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	e8 98 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80029b:	e8 0a 00 00 00       	call   8002aa <exit>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b0:	e8 db 0f 00 00       	call   801290 <close_all>
	sys_env_destroy(0);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	6a 00                	push   $0x0
  8002ba:	e8 8b 0b 00 00       	call   800e4a <sys_env_destroy>
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cc:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002d2:	e8 b4 0b 00 00       	call   800e8b <sys_getenvid>
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	56                   	push   %esi
  8002e1:	50                   	push   %eax
  8002e2:	68 20 21 80 00       	push   $0x802120
  8002e7:	e8 b3 00 00 00       	call   80039f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	53                   	push   %ebx
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	e8 56 00 00 00       	call   80034e <vcprintf>
	cprintf("\n");
  8002f8:	c7 04 24 06 21 80 00 	movl   $0x802106,(%esp)
  8002ff:	e8 9b 00 00 00       	call   80039f <cprintf>
  800304:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800307:	cc                   	int3   
  800308:	eb fd                	jmp    800307 <_panic+0x43>

0080030a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	53                   	push   %ebx
  80030e:	83 ec 04             	sub    $0x4,%esp
  800311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800314:	8b 13                	mov    (%ebx),%edx
  800316:	8d 42 01             	lea    0x1(%edx),%eax
  800319:	89 03                	mov    %eax,(%ebx)
  80031b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800322:	3d ff 00 00 00       	cmp    $0xff,%eax
  800327:	74 09                	je     800332 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800329:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80032d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800330:	c9                   	leave  
  800331:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	68 ff 00 00 00       	push   $0xff
  80033a:	8d 43 08             	lea    0x8(%ebx),%eax
  80033d:	50                   	push   %eax
  80033e:	e8 ca 0a 00 00       	call   800e0d <sys_cputs>
		b->idx = 0;
  800343:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb db                	jmp    800329 <putch+0x1f>

0080034e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800357:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035e:	00 00 00 
	b.cnt = 0;
  800361:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800368:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036b:	ff 75 0c             	pushl  0xc(%ebp)
  80036e:	ff 75 08             	pushl  0x8(%ebp)
  800371:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800377:	50                   	push   %eax
  800378:	68 0a 03 80 00       	push   $0x80030a
  80037d:	e8 1a 01 00 00       	call   80049c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800382:	83 c4 08             	add    $0x8,%esp
  800385:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80038b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800391:	50                   	push   %eax
  800392:	e8 76 0a 00 00       	call   800e0d <sys_cputs>

	return b.cnt;
}
  800397:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a8:	50                   	push   %eax
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	e8 9d ff ff ff       	call   80034e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	56                   	push   %esi
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 1c             	sub    $0x1c,%esp
  8003bc:	89 c7                	mov    %eax,%edi
  8003be:	89 d6                	mov    %edx,%esi
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003da:	39 d3                	cmp    %edx,%ebx
  8003dc:	72 05                	jb     8003e3 <printnum+0x30>
  8003de:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e1:	77 7a                	ja     80045d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e3:	83 ec 0c             	sub    $0xc,%esp
  8003e6:	ff 75 18             	pushl  0x18(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003ef:	53                   	push   %ebx
  8003f0:	ff 75 10             	pushl  0x10(%ebp)
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800402:	e8 59 1a 00 00       	call   801e60 <__udivdi3>
  800407:	83 c4 18             	add    $0x18,%esp
  80040a:	52                   	push   %edx
  80040b:	50                   	push   %eax
  80040c:	89 f2                	mov    %esi,%edx
  80040e:	89 f8                	mov    %edi,%eax
  800410:	e8 9e ff ff ff       	call   8003b3 <printnum>
  800415:	83 c4 20             	add    $0x20,%esp
  800418:	eb 13                	jmp    80042d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	56                   	push   %esi
  80041e:	ff 75 18             	pushl  0x18(%ebp)
  800421:	ff d7                	call   *%edi
  800423:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800426:	83 eb 01             	sub    $0x1,%ebx
  800429:	85 db                	test   %ebx,%ebx
  80042b:	7f ed                	jg     80041a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	56                   	push   %esi
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	ff 75 e4             	pushl  -0x1c(%ebp)
  800437:	ff 75 e0             	pushl  -0x20(%ebp)
  80043a:	ff 75 dc             	pushl  -0x24(%ebp)
  80043d:	ff 75 d8             	pushl  -0x28(%ebp)
  800440:	e8 3b 1b 00 00       	call   801f80 <__umoddi3>
  800445:	83 c4 14             	add    $0x14,%esp
  800448:	0f be 80 43 21 80 00 	movsbl 0x802143(%eax),%eax
  80044f:	50                   	push   %eax
  800450:	ff d7                	call   *%edi
}
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5f                   	pop    %edi
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    
  80045d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800460:	eb c4                	jmp    800426 <printnum+0x73>

00800462 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800468:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	3b 50 04             	cmp    0x4(%eax),%edx
  800471:	73 0a                	jae    80047d <sprintputch+0x1b>
		*b->buf++ = ch;
  800473:	8d 4a 01             	lea    0x1(%edx),%ecx
  800476:	89 08                	mov    %ecx,(%eax)
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	88 02                	mov    %al,(%edx)
}
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <printfmt>:
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800485:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800488:	50                   	push   %eax
  800489:	ff 75 10             	pushl  0x10(%ebp)
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	ff 75 08             	pushl  0x8(%ebp)
  800492:	e8 05 00 00 00       	call   80049c <vprintfmt>
}
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	c9                   	leave  
  80049b:	c3                   	ret    

0080049c <vprintfmt>:
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 2c             	sub    $0x2c,%esp
  8004a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ae:	e9 c1 03 00 00       	jmp    800874 <vprintfmt+0x3d8>
		padc = ' ';
  8004b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8004c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8d 47 01             	lea    0x1(%edi),%eax
  8004d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d7:	0f b6 17             	movzbl (%edi),%edx
  8004da:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004dd:	3c 55                	cmp    $0x55,%al
  8004df:	0f 87 12 04 00 00    	ja     8008f7 <vprintfmt+0x45b>
  8004e5:	0f b6 c0             	movzbl %al,%eax
  8004e8:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004f6:	eb d9                	jmp    8004d1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8004fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ff:	eb d0                	jmp    8004d1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800501:	0f b6 d2             	movzbl %dl,%edx
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80050f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800512:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800516:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800519:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80051c:	83 f9 09             	cmp    $0x9,%ecx
  80051f:	77 55                	ja     800576 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800521:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800524:	eb e9                	jmp    80050f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80053a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053e:	79 91                	jns    8004d1 <vprintfmt+0x35>
				width = precision, precision = -1;
  800540:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054d:	eb 82                	jmp    8004d1 <vprintfmt+0x35>
  80054f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800552:	85 c0                	test   %eax,%eax
  800554:	ba 00 00 00 00       	mov    $0x0,%edx
  800559:	0f 49 d0             	cmovns %eax,%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 6a ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80056a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800571:	e9 5b ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
  800576:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800579:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057c:	eb bc                	jmp    80053a <vprintfmt+0x9e>
			lflag++;
  80057e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800584:	e9 48 ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 78 04             	lea    0x4(%eax),%edi
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	ff 30                	pushl  (%eax)
  800595:	ff d6                	call   *%esi
			break;
  800597:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80059a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80059d:	e9 cf 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 78 04             	lea    0x4(%eax),%edi
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	99                   	cltd   
  8005ab:	31 d0                	xor    %edx,%eax
  8005ad:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005af:	83 f8 0f             	cmp    $0xf,%eax
  8005b2:	7f 23                	jg     8005d7 <vprintfmt+0x13b>
  8005b4:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 18                	je     8005d7 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8005bf:	52                   	push   %edx
  8005c0:	68 61 25 80 00       	push   $0x802561
  8005c5:	53                   	push   %ebx
  8005c6:	56                   	push   %esi
  8005c7:	e8 b3 fe ff ff       	call   80047f <printfmt>
  8005cc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005cf:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005d2:	e9 9a 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8005d7:	50                   	push   %eax
  8005d8:	68 5b 21 80 00       	push   $0x80215b
  8005dd:	53                   	push   %ebx
  8005de:	56                   	push   %esi
  8005df:	e8 9b fe ff ff       	call   80047f <printfmt>
  8005e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005e7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005ea:	e9 82 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	83 c0 04             	add    $0x4,%eax
  8005f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	b8 54 21 80 00       	mov    $0x802154,%eax
  800604:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800607:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060b:	0f 8e bd 00 00 00    	jle    8006ce <vprintfmt+0x232>
  800611:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800615:	75 0e                	jne    800625 <vprintfmt+0x189>
  800617:	89 75 08             	mov    %esi,0x8(%ebp)
  80061a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800620:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800623:	eb 6d                	jmp    800692 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	ff 75 d0             	pushl  -0x30(%ebp)
  80062b:	57                   	push   %edi
  80062c:	e8 80 04 00 00       	call   800ab1 <strnlen>
  800631:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800634:	29 c1                	sub    %eax,%ecx
  800636:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80063c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800640:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800643:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800646:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	eb 0f                	jmp    800659 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	ff 75 e0             	pushl  -0x20(%ebp)
  800651:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	85 ff                	test   %edi,%edi
  80065b:	7f ed                	jg     80064a <vprintfmt+0x1ae>
  80065d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800660:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800663:	85 c9                	test   %ecx,%ecx
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
  80066a:	0f 49 c1             	cmovns %ecx,%eax
  80066d:	29 c1                	sub    %eax,%ecx
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	89 cb                	mov    %ecx,%ebx
  80067a:	eb 16                	jmp    800692 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80067c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800680:	75 31                	jne    8006b3 <vprintfmt+0x217>
					putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	ff 75 0c             	pushl  0xc(%ebp)
  800688:	50                   	push   %eax
  800689:	ff 55 08             	call   *0x8(%ebp)
  80068c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068f:	83 eb 01             	sub    $0x1,%ebx
  800692:	83 c7 01             	add    $0x1,%edi
  800695:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800699:	0f be c2             	movsbl %dl,%eax
  80069c:	85 c0                	test   %eax,%eax
  80069e:	74 59                	je     8006f9 <vprintfmt+0x25d>
  8006a0:	85 f6                	test   %esi,%esi
  8006a2:	78 d8                	js     80067c <vprintfmt+0x1e0>
  8006a4:	83 ee 01             	sub    $0x1,%esi
  8006a7:	79 d3                	jns    80067c <vprintfmt+0x1e0>
  8006a9:	89 df                	mov    %ebx,%edi
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b1:	eb 37                	jmp    8006ea <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b3:	0f be d2             	movsbl %dl,%edx
  8006b6:	83 ea 20             	sub    $0x20,%edx
  8006b9:	83 fa 5e             	cmp    $0x5e,%edx
  8006bc:	76 c4                	jbe    800682 <vprintfmt+0x1e6>
					putch('?', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	6a 3f                	push   $0x3f
  8006c6:	ff 55 08             	call   *0x8(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb c1                	jmp    80068f <vprintfmt+0x1f3>
  8006ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006da:	eb b6                	jmp    800692 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	6a 20                	push   $0x20
  8006e2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006e4:	83 ef 01             	sub    $0x1,%edi
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	85 ff                	test   %edi,%edi
  8006ec:	7f ee                	jg     8006dc <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8006ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f4:	e9 78 01 00 00       	jmp    800871 <vprintfmt+0x3d5>
  8006f9:	89 df                	mov    %ebx,%edi
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800701:	eb e7                	jmp    8006ea <vprintfmt+0x24e>
	if (lflag >= 2)
  800703:	83 f9 01             	cmp    $0x1,%ecx
  800706:	7e 3f                	jle    800747 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 50 04             	mov    0x4(%eax),%edx
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800713:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 40 08             	lea    0x8(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80071f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800723:	79 5c                	jns    800781 <vprintfmt+0x2e5>
				putch('-', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 2d                	push   $0x2d
  80072b:	ff d6                	call   *%esi
				num = -(long long) num;
  80072d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800730:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800733:	f7 da                	neg    %edx
  800735:	83 d1 00             	adc    $0x0,%ecx
  800738:	f7 d9                	neg    %ecx
  80073a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	e9 10 01 00 00       	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  800747:	85 c9                	test   %ecx,%ecx
  800749:	75 1b                	jne    800766 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800753:	89 c1                	mov    %eax,%ecx
  800755:	c1 f9 1f             	sar    $0x1f,%ecx
  800758:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
  800764:	eb b9                	jmp    80071f <vprintfmt+0x283>
		return va_arg(*ap, long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 00                	mov    (%eax),%eax
  80076b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076e:	89 c1                	mov    %eax,%ecx
  800770:	c1 f9 1f             	sar    $0x1f,%ecx
  800773:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
  80077f:	eb 9e                	jmp    80071f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800781:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800784:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 c6 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 a9 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	75 1a                	jne    8007cc <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 8b 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	eb 74                	jmp    800857 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007e3:	83 f9 01             	cmp    $0x1,%ecx
  8007e6:	7e 15                	jle    8007fd <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f0:	8d 40 08             	lea    0x8(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8007f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007fb:	eb 5a                	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8007fd:	85 c9                	test   %ecx,%ecx
  8007ff:	75 17                	jne    800818 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800811:	b8 08 00 00 00       	mov    $0x8,%eax
  800816:	eb 3f                	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800828:	b8 08 00 00 00       	mov    $0x8,%eax
  80082d:	eb 28                	jmp    800857 <vprintfmt+0x3bb>
			putch('0', putdat);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	6a 30                	push   $0x30
  800835:	ff d6                	call   *%esi
			putch('x', putdat);
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	53                   	push   %ebx
  80083b:	6a 78                	push   $0x78
  80083d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 10                	mov    (%eax),%edx
  800844:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800849:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800852:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800857:	83 ec 0c             	sub    $0xc,%esp
  80085a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80085e:	57                   	push   %edi
  80085f:	ff 75 e0             	pushl  -0x20(%ebp)
  800862:	50                   	push   %eax
  800863:	51                   	push   %ecx
  800864:	52                   	push   %edx
  800865:	89 da                	mov    %ebx,%edx
  800867:	89 f0                	mov    %esi,%eax
  800869:	e8 45 fb ff ff       	call   8003b3 <printnum>
			break;
  80086e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800871:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800874:	83 c7 01             	add    $0x1,%edi
  800877:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80087b:	83 f8 25             	cmp    $0x25,%eax
  80087e:	0f 84 2f fc ff ff    	je     8004b3 <vprintfmt+0x17>
			if (ch == '\0')
  800884:	85 c0                	test   %eax,%eax
  800886:	0f 84 8b 00 00 00    	je     800917 <vprintfmt+0x47b>
			putch(ch, putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	50                   	push   %eax
  800891:	ff d6                	call   *%esi
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	eb dc                	jmp    800874 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800898:	83 f9 01             	cmp    $0x1,%ecx
  80089b:	7e 15                	jle    8008b2 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a5:	8d 40 08             	lea    0x8(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b0:	eb a5                	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	75 17                	jne    8008cd <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008cb:	eb 8a                	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d7:	8d 40 04             	lea    0x4(%eax),%eax
  8008da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e2:	e9 70 ff ff ff       	jmp    800857 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	6a 25                	push   $0x25
  8008ed:	ff d6                	call   *%esi
			break;
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	e9 7a ff ff ff       	jmp    800871 <vprintfmt+0x3d5>
			putch('%', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	6a 25                	push   $0x25
  8008fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	89 f8                	mov    %edi,%eax
  800904:	eb 03                	jmp    800909 <vprintfmt+0x46d>
  800906:	83 e8 01             	sub    $0x1,%eax
  800909:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80090d:	75 f7                	jne    800906 <vprintfmt+0x46a>
  80090f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800912:	e9 5a ff ff ff       	jmp    800871 <vprintfmt+0x3d5>
}
  800917:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800932:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800935:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	74 26                	je     800966 <vsnprintf+0x47>
  800940:	85 d2                	test   %edx,%edx
  800942:	7e 22                	jle    800966 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800944:	ff 75 14             	pushl  0x14(%ebp)
  800947:	ff 75 10             	pushl  0x10(%ebp)
  80094a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094d:	50                   	push   %eax
  80094e:	68 62 04 80 00       	push   $0x800462
  800953:	e8 44 fb ff ff       	call   80049c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	83 c4 10             	add    $0x10,%esp
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    
		return -E_INVAL;
  800966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096b:	eb f7                	jmp    800964 <vsnprintf+0x45>

0080096d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800976:	50                   	push   %eax
  800977:	ff 75 10             	pushl  0x10(%ebp)
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 9a ff ff ff       	call   80091f <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	83 ec 0c             	sub    $0xc,%esp

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800990:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800994:	74 15                	je     8009ab <readline+0x24>
		fprintf(1, "%s", prompt);
  800996:	83 ec 04             	sub    $0x4,%esp
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	68 61 25 80 00       	push   $0x802561
  8009a1:	6a 01                	push   $0x1
  8009a3:	e8 19 10 00 00       	call   8019c1 <fprintf>
  8009a8:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8009ab:	83 ec 0c             	sub    $0xc,%esp
  8009ae:	6a 00                	push   $0x0
  8009b0:	e8 31 f8 ff ff       	call   8001e6 <iscons>
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	83 c4 10             	add    $0x10,%esp
	i = 0;
  8009ba:	be 00 00 00 00       	mov    $0x0,%esi
  8009bf:	eb 57                	jmp    800a18 <readline+0x91>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8009c1:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009c4:	74 11                	je     8009d7 <readline+0x50>
				cprintf("read error: %e\n", c);
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	50                   	push   %eax
  8009ca:	68 3f 24 80 00       	push   $0x80243f
  8009cf:	e8 cb f9 ff ff       	call   80039f <cprintf>
  8009d4:	83 c4 10             	add    $0x10,%esp
            cprintf("[readline]------------- 1 %s \n", prompt);
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	68 50 24 80 00       	push   $0x802450
  8009e2:	e8 b8 f9 ff ff       	call   80039f <cprintf>
			return NULL;
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
			buf[i] = 0;
            cprintf("[readline]------------- 2 %s \n", buf );
			return buf;
		}
	}
}
  8009ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    
			if (echoing)
  8009f7:	85 ff                	test   %edi,%edi
  8009f9:	75 05                	jne    800a00 <readline+0x79>
			i--;
  8009fb:	83 ee 01             	sub    $0x1,%esi
  8009fe:	eb 18                	jmp    800a18 <readline+0x91>
				cputchar('\b');
  800a00:	83 ec 0c             	sub    $0xc,%esp
  800a03:	6a 08                	push   $0x8
  800a05:	e8 95 f7 ff ff       	call   80019f <cputchar>
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	eb ec                	jmp    8009fb <readline+0x74>
			buf[i++] = c;
  800a0f:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a15:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  800a18:	e8 9e f7 ff ff       	call   8001bb <getchar>
  800a1d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 9e                	js     8009c1 <readline+0x3a>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a23:	83 f8 08             	cmp    $0x8,%eax
  800a26:	0f 94 c2             	sete   %dl
  800a29:	83 f8 7f             	cmp    $0x7f,%eax
  800a2c:	0f 94 c0             	sete   %al
  800a2f:	08 c2                	or     %al,%dl
  800a31:	74 04                	je     800a37 <readline+0xb0>
  800a33:	85 f6                	test   %esi,%esi
  800a35:	7f c0                	jg     8009f7 <readline+0x70>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a37:	83 fb 1f             	cmp    $0x1f,%ebx
  800a3a:	7e 1a                	jle    800a56 <readline+0xcf>
  800a3c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a42:	7f 12                	jg     800a56 <readline+0xcf>
			if (echoing)
  800a44:	85 ff                	test   %edi,%edi
  800a46:	74 c7                	je     800a0f <readline+0x88>
				cputchar(c);
  800a48:	83 ec 0c             	sub    $0xc,%esp
  800a4b:	53                   	push   %ebx
  800a4c:	e8 4e f7 ff ff       	call   80019f <cputchar>
  800a51:	83 c4 10             	add    $0x10,%esp
  800a54:	eb b9                	jmp    800a0f <readline+0x88>
		} else if (c == '\n' || c == '\r') {
  800a56:	83 fb 0a             	cmp    $0xa,%ebx
  800a59:	74 05                	je     800a60 <readline+0xd9>
  800a5b:	83 fb 0d             	cmp    $0xd,%ebx
  800a5e:	75 b8                	jne    800a18 <readline+0x91>
			if (echoing)
  800a60:	85 ff                	test   %edi,%edi
  800a62:	75 26                	jne    800a8a <readline+0x103>
			buf[i] = 0;
  800a64:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
            cprintf("[readline]------------- 2 %s \n", buf );
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	68 00 40 80 00       	push   $0x804000
  800a73:	68 70 24 80 00       	push   $0x802470
  800a78:	e8 22 f9 ff ff       	call   80039f <cprintf>
			return buf;
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a85:	e9 65 ff ff ff       	jmp    8009ef <readline+0x68>
				cputchar('\n');
  800a8a:	83 ec 0c             	sub    $0xc,%esp
  800a8d:	6a 0a                	push   $0xa
  800a8f:	e8 0b f7 ff ff       	call   80019f <cputchar>
  800a94:	83 c4 10             	add    $0x10,%esp
  800a97:	eb cb                	jmp    800a64 <readline+0xdd>

00800a99 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	eb 03                	jmp    800aa9 <strlen+0x10>
		n++;
  800aa6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800aa9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aad:	75 f7                	jne    800aa6 <strlen+0xd>
	return n;
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	eb 03                	jmp    800ac4 <strnlen+0x13>
		n++;
  800ac1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac4:	39 d0                	cmp    %edx,%eax
  800ac6:	74 06                	je     800ace <strnlen+0x1d>
  800ac8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800acc:	75 f3                	jne    800ac1 <strnlen+0x10>
	return n;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	83 c2 01             	add    $0x1,%edx
  800ae2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ae6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae9:	84 db                	test   %bl,%bl
  800aeb:	75 ef                	jne    800adc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800aed:	5b                   	pop    %ebx
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	53                   	push   %ebx
  800af4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af7:	53                   	push   %ebx
  800af8:	e8 9c ff ff ff       	call   800a99 <strlen>
  800afd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	01 d8                	add    %ebx,%eax
  800b05:	50                   	push   %eax
  800b06:	e8 c5 ff ff ff       	call   800ad0 <strcpy>
	return dst;
}
  800b0b:	89 d8                	mov    %ebx,%eax
  800b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	89 f3                	mov    %esi,%ebx
  800b1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b22:	89 f2                	mov    %esi,%edx
  800b24:	eb 0f                	jmp    800b35 <strncpy+0x23>
		*dst++ = *src;
  800b26:	83 c2 01             	add    $0x1,%edx
  800b29:	0f b6 01             	movzbl (%ecx),%eax
  800b2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b32:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b35:	39 da                	cmp    %ebx,%edx
  800b37:	75 ed                	jne    800b26 <strncpy+0x14>
	}
	return ret;
}
  800b39:	89 f0                	mov    %esi,%eax
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 75 08             	mov    0x8(%ebp),%esi
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b53:	85 c9                	test   %ecx,%ecx
  800b55:	75 0b                	jne    800b62 <strlcpy+0x23>
  800b57:	eb 17                	jmp    800b70 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b59:	83 c2 01             	add    $0x1,%edx
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b62:	39 d8                	cmp    %ebx,%eax
  800b64:	74 07                	je     800b6d <strlcpy+0x2e>
  800b66:	0f b6 0a             	movzbl (%edx),%ecx
  800b69:	84 c9                	test   %cl,%cl
  800b6b:	75 ec                	jne    800b59 <strlcpy+0x1a>
		*dst = '\0';
  800b6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b70:	29 f0                	sub    %esi,%eax
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b7f:	eb 06                	jmp    800b87 <strcmp+0x11>
		p++, q++;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b87:	0f b6 01             	movzbl (%ecx),%eax
  800b8a:	84 c0                	test   %al,%al
  800b8c:	74 04                	je     800b92 <strcmp+0x1c>
  800b8e:	3a 02                	cmp    (%edx),%al
  800b90:	74 ef                	je     800b81 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b92:	0f b6 c0             	movzbl %al,%eax
  800b95:	0f b6 12             	movzbl (%edx),%edx
  800b98:	29 d0                	sub    %edx,%eax
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	53                   	push   %ebx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bab:	eb 06                	jmp    800bb3 <strncmp+0x17>
		n--, p++, q++;
  800bad:	83 c0 01             	add    $0x1,%eax
  800bb0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bb3:	39 d8                	cmp    %ebx,%eax
  800bb5:	74 16                	je     800bcd <strncmp+0x31>
  800bb7:	0f b6 08             	movzbl (%eax),%ecx
  800bba:	84 c9                	test   %cl,%cl
  800bbc:	74 04                	je     800bc2 <strncmp+0x26>
  800bbe:	3a 0a                	cmp    (%edx),%cl
  800bc0:	74 eb                	je     800bad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc2:	0f b6 00             	movzbl (%eax),%eax
  800bc5:	0f b6 12             	movzbl (%edx),%edx
  800bc8:	29 d0                	sub    %edx,%eax
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
		return 0;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	eb f6                	jmp    800bca <strncmp+0x2e>

00800bd4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	84 d2                	test   %dl,%dl
  800be3:	74 09                	je     800bee <strchr+0x1a>
		if (*s == c)
  800be5:	38 ca                	cmp    %cl,%dl
  800be7:	74 0a                	je     800bf3 <strchr+0x1f>
	for (; *s; s++)
  800be9:	83 c0 01             	add    $0x1,%eax
  800bec:	eb f0                	jmp    800bde <strchr+0xa>
			return (char *) s;
	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bff:	eb 03                	jmp    800c04 <strfind+0xf>
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c07:	38 ca                	cmp    %cl,%dl
  800c09:	74 04                	je     800c0f <strfind+0x1a>
  800c0b:	84 d2                	test   %dl,%dl
  800c0d:	75 f2                	jne    800c01 <strfind+0xc>
			break;
	return (char *) s;
}
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c1d:	85 c9                	test   %ecx,%ecx
  800c1f:	74 13                	je     800c34 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c27:	75 05                	jne    800c2e <memset+0x1d>
  800c29:	f6 c1 03             	test   $0x3,%cl
  800c2c:	74 0d                	je     800c3b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
		c &= 0xFF;
  800c3b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	c1 e3 08             	shl    $0x8,%ebx
  800c44:	89 d0                	mov    %edx,%eax
  800c46:	c1 e0 18             	shl    $0x18,%eax
  800c49:	89 d6                	mov    %edx,%esi
  800c4b:	c1 e6 10             	shl    $0x10,%esi
  800c4e:	09 f0                	or     %esi,%eax
  800c50:	09 c2                	or     %eax,%edx
  800c52:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800c54:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c57:	89 d0                	mov    %edx,%eax
  800c59:	fc                   	cld    
  800c5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5c:	eb d6                	jmp    800c34 <memset+0x23>

00800c5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c6c:	39 c6                	cmp    %eax,%esi
  800c6e:	73 35                	jae    800ca5 <memmove+0x47>
  800c70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c73:	39 c2                	cmp    %eax,%edx
  800c75:	76 2e                	jbe    800ca5 <memmove+0x47>
		s += n;
		d += n;
  800c77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	09 fe                	or     %edi,%esi
  800c7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c84:	74 0c                	je     800c92 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c86:	83 ef 01             	sub    $0x1,%edi
  800c89:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c8c:	fd                   	std    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8f:	fc                   	cld    
  800c90:	eb 21                	jmp    800cb3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c92:	f6 c1 03             	test   $0x3,%cl
  800c95:	75 ef                	jne    800c86 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c97:	83 ef 04             	sub    $0x4,%edi
  800c9a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c9d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ca0:	fd                   	std    
  800ca1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca3:	eb ea                	jmp    800c8f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca5:	89 f2                	mov    %esi,%edx
  800ca7:	09 c2                	or     %eax,%edx
  800ca9:	f6 c2 03             	test   $0x3,%dl
  800cac:	74 09                	je     800cb7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	fc                   	cld    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb7:	f6 c1 03             	test   $0x3,%cl
  800cba:	75 f2                	jne    800cae <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cbc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cbf:	89 c7                	mov    %eax,%edi
  800cc1:	fc                   	cld    
  800cc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc4:	eb ed                	jmp    800cb3 <memmove+0x55>

00800cc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cc9:	ff 75 10             	pushl  0x10(%ebp)
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	ff 75 08             	pushl  0x8(%ebp)
  800cd2:	e8 87 ff ff ff       	call   800c5e <memmove>
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce4:	89 c6                	mov    %eax,%esi
  800ce6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce9:	39 f0                	cmp    %esi,%eax
  800ceb:	74 1c                	je     800d09 <memcmp+0x30>
		if (*s1 != *s2)
  800ced:	0f b6 08             	movzbl (%eax),%ecx
  800cf0:	0f b6 1a             	movzbl (%edx),%ebx
  800cf3:	38 d9                	cmp    %bl,%cl
  800cf5:	75 08                	jne    800cff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cf7:	83 c0 01             	add    $0x1,%eax
  800cfa:	83 c2 01             	add    $0x1,%edx
  800cfd:	eb ea                	jmp    800ce9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800cff:	0f b6 c1             	movzbl %cl,%eax
  800d02:	0f b6 db             	movzbl %bl,%ebx
  800d05:	29 d8                	sub    %ebx,%eax
  800d07:	eb 05                	jmp    800d0e <memcmp+0x35>
	}

	return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d20:	39 d0                	cmp    %edx,%eax
  800d22:	73 09                	jae    800d2d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d24:	38 08                	cmp    %cl,(%eax)
  800d26:	74 05                	je     800d2d <memfind+0x1b>
	for (; s < ends; s++)
  800d28:	83 c0 01             	add    $0x1,%eax
  800d2b:	eb f3                	jmp    800d20 <memfind+0xe>
			break;
	return (void *) s;
}
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3b:	eb 03                	jmp    800d40 <strtol+0x11>
		s++;
  800d3d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d40:	0f b6 01             	movzbl (%ecx),%eax
  800d43:	3c 20                	cmp    $0x20,%al
  800d45:	74 f6                	je     800d3d <strtol+0xe>
  800d47:	3c 09                	cmp    $0x9,%al
  800d49:	74 f2                	je     800d3d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d4b:	3c 2b                	cmp    $0x2b,%al
  800d4d:	74 2e                	je     800d7d <strtol+0x4e>
	int neg = 0;
  800d4f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d54:	3c 2d                	cmp    $0x2d,%al
  800d56:	74 2f                	je     800d87 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d5e:	75 05                	jne    800d65 <strtol+0x36>
  800d60:	80 39 30             	cmpb   $0x30,(%ecx)
  800d63:	74 2c                	je     800d91 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d65:	85 db                	test   %ebx,%ebx
  800d67:	75 0a                	jne    800d73 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d69:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800d6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d71:	74 28                	je     800d9b <strtol+0x6c>
		base = 10;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d7b:	eb 50                	jmp    800dcd <strtol+0x9e>
		s++;
  800d7d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d80:	bf 00 00 00 00       	mov    $0x0,%edi
  800d85:	eb d1                	jmp    800d58 <strtol+0x29>
		s++, neg = 1;
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800d8f:	eb c7                	jmp    800d58 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d91:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d95:	74 0e                	je     800da5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d97:	85 db                	test   %ebx,%ebx
  800d99:	75 d8                	jne    800d73 <strtol+0x44>
		s++, base = 8;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800da3:	eb ce                	jmp    800d73 <strtol+0x44>
		s += 2, base = 16;
  800da5:	83 c1 02             	add    $0x2,%ecx
  800da8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dad:	eb c4                	jmp    800d73 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800daf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db2:	89 f3                	mov    %esi,%ebx
  800db4:	80 fb 19             	cmp    $0x19,%bl
  800db7:	77 29                	ja     800de2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db9:	0f be d2             	movsbl %dl,%edx
  800dbc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dbf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dc2:	7d 30                	jge    800df4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dc4:	83 c1 01             	add    $0x1,%ecx
  800dc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dcb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dcd:	0f b6 11             	movzbl (%ecx),%edx
  800dd0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dd3:	89 f3                	mov    %esi,%ebx
  800dd5:	80 fb 09             	cmp    $0x9,%bl
  800dd8:	77 d5                	ja     800daf <strtol+0x80>
			dig = *s - '0';
  800dda:	0f be d2             	movsbl %dl,%edx
  800ddd:	83 ea 30             	sub    $0x30,%edx
  800de0:	eb dd                	jmp    800dbf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800de2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800de5:	89 f3                	mov    %esi,%ebx
  800de7:	80 fb 19             	cmp    $0x19,%bl
  800dea:	77 08                	ja     800df4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dec:	0f be d2             	movsbl %dl,%edx
  800def:	83 ea 37             	sub    $0x37,%edx
  800df2:	eb cb                	jmp    800dbf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800df4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df8:	74 05                	je     800dff <strtol+0xd0>
		*endptr = (char *) s;
  800dfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dfd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dff:	89 c2                	mov    %eax,%edx
  800e01:	f7 da                	neg    %edx
  800e03:	85 ff                	test   %edi,%edi
  800e05:	0f 45 c2             	cmovne %edx,%eax
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	89 c3                	mov    %eax,%ebx
  800e20:	89 c7                	mov    %eax,%edi
  800e22:	89 c6                	mov    %eax,%esi
  800e24:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e31:	ba 00 00 00 00       	mov    $0x0,%edx
  800e36:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3b:	89 d1                	mov    %edx,%ecx
  800e3d:	89 d3                	mov    %edx,%ebx
  800e3f:	89 d7                	mov    %edx,%edi
  800e41:	89 d6                	mov    %edx,%esi
  800e43:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e60:	89 cb                	mov    %ecx,%ebx
  800e62:	89 cf                	mov    %ecx,%edi
  800e64:	89 ce                	mov    %ecx,%esi
  800e66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7f 08                	jg     800e74 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	50                   	push   %eax
  800e78:	6a 03                	push   $0x3
  800e7a:	68 8f 24 80 00       	push   $0x80248f
  800e7f:	6a 23                	push   $0x23
  800e81:	68 ac 24 80 00       	push   $0x8024ac
  800e86:	e8 39 f4 ff ff       	call   8002c4 <_panic>

00800e8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 02 00 00 00       	mov    $0x2,%eax
  800e9b:	89 d1                	mov    %edx,%ecx
  800e9d:	89 d3                	mov    %edx,%ebx
  800e9f:	89 d7                	mov    %edx,%edi
  800ea1:	89 d6                	mov    %edx,%esi
  800ea3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_yield>:

void
sys_yield(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eba:	89 d1                	mov    %edx,%ecx
  800ebc:	89 d3                	mov    %edx,%ebx
  800ebe:	89 d7                	mov    %edx,%edi
  800ec0:	89 d6                	mov    %edx,%esi
  800ec2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed2:	be 00 00 00 00       	mov    $0x0,%esi
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee5:	89 f7                	mov    %esi,%edi
  800ee7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7f 08                	jg     800ef5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	50                   	push   %eax
  800ef9:	6a 04                	push   $0x4
  800efb:	68 8f 24 80 00       	push   $0x80248f
  800f00:	6a 23                	push   $0x23
  800f02:	68 ac 24 80 00       	push   $0x8024ac
  800f07:	e8 b8 f3 ff ff       	call   8002c4 <_panic>

00800f0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f15:	8b 55 08             	mov    0x8(%ebp),%edx
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f26:	8b 75 18             	mov    0x18(%ebp),%esi
  800f29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7f 08                	jg     800f37 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	50                   	push   %eax
  800f3b:	6a 05                	push   $0x5
  800f3d:	68 8f 24 80 00       	push   $0x80248f
  800f42:	6a 23                	push   $0x23
  800f44:	68 ac 24 80 00       	push   $0x8024ac
  800f49:	e8 76 f3 ff ff       	call   8002c4 <_panic>

00800f4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	b8 06 00 00 00       	mov    $0x6,%eax
  800f67:	89 df                	mov    %ebx,%edi
  800f69:	89 de                	mov    %ebx,%esi
  800f6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7f 08                	jg     800f79 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	50                   	push   %eax
  800f7d:	6a 06                	push   $0x6
  800f7f:	68 8f 24 80 00       	push   $0x80248f
  800f84:	6a 23                	push   $0x23
  800f86:	68 ac 24 80 00       	push   $0x8024ac
  800f8b:	e8 34 f3 ff ff       	call   8002c4 <_panic>

00800f90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa9:	89 df                	mov    %ebx,%edi
  800fab:	89 de                	mov    %ebx,%esi
  800fad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7f 08                	jg     800fbb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	50                   	push   %eax
  800fbf:	6a 08                	push   $0x8
  800fc1:	68 8f 24 80 00       	push   $0x80248f
  800fc6:	6a 23                	push   $0x23
  800fc8:	68 ac 24 80 00       	push   $0x8024ac
  800fcd:	e8 f2 f2 ff ff       	call   8002c4 <_panic>

00800fd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe6:	b8 09 00 00 00       	mov    $0x9,%eax
  800feb:	89 df                	mov    %ebx,%edi
  800fed:	89 de                	mov    %ebx,%esi
  800fef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7f 08                	jg     800ffd <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	50                   	push   %eax
  801001:	6a 09                	push   $0x9
  801003:	68 8f 24 80 00       	push   $0x80248f
  801008:	6a 23                	push   $0x23
  80100a:	68 ac 24 80 00       	push   $0x8024ac
  80100f:	e8 b0 f2 ff ff       	call   8002c4 <_panic>

00801014 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801028:	b8 0a 00 00 00       	mov    $0xa,%eax
  80102d:	89 df                	mov    %ebx,%edi
  80102f:	89 de                	mov    %ebx,%esi
  801031:	cd 30                	int    $0x30
	if(check && ret > 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	7f 08                	jg     80103f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	50                   	push   %eax
  801043:	6a 0a                	push   $0xa
  801045:	68 8f 24 80 00       	push   $0x80248f
  80104a:	6a 23                	push   $0x23
  80104c:	68 ac 24 80 00       	push   $0x8024ac
  801051:	e8 6e f2 ff ff       	call   8002c4 <_panic>

00801056 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801062:	b8 0c 00 00 00       	mov    $0xc,%eax
  801067:	be 00 00 00 00       	mov    $0x0,%esi
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801072:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	8b 55 08             	mov    0x8(%ebp),%edx
  80108a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108f:	89 cb                	mov    %ecx,%ebx
  801091:	89 cf                	mov    %ecx,%edi
  801093:	89 ce                	mov    %ecx,%esi
  801095:	cd 30                	int    $0x30
	if(check && ret > 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	7f 08                	jg     8010a3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	50                   	push   %eax
  8010a7:	6a 0d                	push   $0xd
  8010a9:	68 8f 24 80 00       	push   $0x80248f
  8010ae:	6a 23                	push   $0x23
  8010b0:	68 ac 24 80 00       	push   $0x8024ac
  8010b5:	e8 0a f2 ff ff       	call   8002c4 <_panic>

008010ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010da:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	c1 ea 16             	shr    $0x16,%edx
  8010f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 2a                	je     801127 <fd_alloc+0x46>
  8010fd:	89 c2                	mov    %eax,%edx
  8010ff:	c1 ea 0c             	shr    $0xc,%edx
  801102:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801109:	f6 c2 01             	test   $0x1,%dl
  80110c:	74 19                	je     801127 <fd_alloc+0x46>
  80110e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801113:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801118:	75 d2                	jne    8010ec <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801120:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801125:	eb 07                	jmp    80112e <fd_alloc+0x4d>
			*fd_store = fd;
  801127:	89 01                	mov    %eax,(%ecx)
			return 0;
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801136:	83 f8 1f             	cmp    $0x1f,%eax
  801139:	77 36                	ja     801171 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113b:	c1 e0 0c             	shl    $0xc,%eax
  80113e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801143:	89 c2                	mov    %eax,%edx
  801145:	c1 ea 16             	shr    $0x16,%edx
  801148:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114f:	f6 c2 01             	test   $0x1,%dl
  801152:	74 24                	je     801178 <fd_lookup+0x48>
  801154:	89 c2                	mov    %eax,%edx
  801156:	c1 ea 0c             	shr    $0xc,%edx
  801159:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801160:	f6 c2 01             	test   $0x1,%dl
  801163:	74 1a                	je     80117f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801165:	8b 55 0c             	mov    0xc(%ebp),%edx
  801168:	89 02                	mov    %eax,(%edx)
	return 0;
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
		return -E_INVAL;
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801176:	eb f7                	jmp    80116f <fd_lookup+0x3f>
		return -E_INVAL;
  801178:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117d:	eb f0                	jmp    80116f <fd_lookup+0x3f>
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801184:	eb e9                	jmp    80116f <fd_lookup+0x3f>

00801186 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118f:	ba 38 25 80 00       	mov    $0x802538,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801194:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801199:	39 08                	cmp    %ecx,(%eax)
  80119b:	74 33                	je     8011d0 <dev_lookup+0x4a>
  80119d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011a0:	8b 02                	mov    (%edx),%eax
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	75 f3                	jne    801199 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a6:	a1 04 44 80 00       	mov    0x804404,%eax
  8011ab:	8b 40 48             	mov    0x48(%eax),%eax
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	51                   	push   %ecx
  8011b2:	50                   	push   %eax
  8011b3:	68 bc 24 80 00       	push   $0x8024bc
  8011b8:	e8 e2 f1 ff ff       	call   80039f <cprintf>
	*dev = 0;
  8011bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    
			*dev = devtab[i];
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011da:	eb f2                	jmp    8011ce <dev_lookup+0x48>

008011dc <fd_close>:
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 1c             	sub    $0x1c,%esp
  8011e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ee:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011f5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f8:	50                   	push   %eax
  8011f9:	e8 32 ff ff ff       	call   801130 <fd_lookup>
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 05                	js     80120c <fd_close+0x30>
	    || fd != fd2)
  801207:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80120a:	74 16                	je     801222 <fd_close+0x46>
		return (must_exist ? r : 0);
  80120c:	89 f8                	mov    %edi,%eax
  80120e:	84 c0                	test   %al,%al
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	0f 44 d8             	cmove  %eax,%ebx
}
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	ff 36                	pushl  (%esi)
  80122b:	e8 56 ff ff ff       	call   801186 <dev_lookup>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 15                	js     80124e <fd_close+0x72>
		if (dev->dev_close)
  801239:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123c:	8b 40 10             	mov    0x10(%eax),%eax
  80123f:	85 c0                	test   %eax,%eax
  801241:	74 1b                	je     80125e <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	56                   	push   %esi
  801247:	ff d0                	call   *%eax
  801249:	89 c3                	mov    %eax,%ebx
  80124b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80124e:	83 ec 08             	sub    $0x8,%esp
  801251:	56                   	push   %esi
  801252:	6a 00                	push   $0x0
  801254:	e8 f5 fc ff ff       	call   800f4e <sys_page_unmap>
	return r;
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	eb ba                	jmp    801218 <fd_close+0x3c>
			r = 0;
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801263:	eb e9                	jmp    80124e <fd_close+0x72>

00801265 <close>:

int
close(int fdnum)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	ff 75 08             	pushl  0x8(%ebp)
  801272:	e8 b9 fe ff ff       	call   801130 <fd_lookup>
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 10                	js     80128e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	6a 01                	push   $0x1
  801283:	ff 75 f4             	pushl  -0xc(%ebp)
  801286:	e8 51 ff ff ff       	call   8011dc <fd_close>
  80128b:	83 c4 10             	add    $0x10,%esp
}
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <close_all>:

void
close_all(void)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801297:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	53                   	push   %ebx
  8012a0:	e8 c0 ff ff ff       	call   801265 <close>
	for (i = 0; i < MAXFD; i++)
  8012a5:	83 c3 01             	add    $0x1,%ebx
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	83 fb 20             	cmp    $0x20,%ebx
  8012ae:	75 ec                	jne    80129c <close_all+0xc>
}
  8012b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	ff 75 08             	pushl  0x8(%ebp)
  8012c5:	e8 66 fe ff ff       	call   801130 <fd_lookup>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 81 00 00 00    	js     801358 <dup+0xa3>
		return r;
	close(newfdnum);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	ff 75 0c             	pushl  0xc(%ebp)
  8012dd:	e8 83 ff ff ff       	call   801265 <close>

	newfd = INDEX2FD(newfdnum);
  8012e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e5:	c1 e6 0c             	shl    $0xc,%esi
  8012e8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012ee:	83 c4 04             	add    $0x4,%esp
  8012f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f4:	e8 d1 fd ff ff       	call   8010ca <fd2data>
  8012f9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012fb:	89 34 24             	mov    %esi,(%esp)
  8012fe:	e8 c7 fd ff ff       	call   8010ca <fd2data>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801308:	89 d8                	mov    %ebx,%eax
  80130a:	c1 e8 16             	shr    $0x16,%eax
  80130d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801314:	a8 01                	test   $0x1,%al
  801316:	74 11                	je     801329 <dup+0x74>
  801318:	89 d8                	mov    %ebx,%eax
  80131a:	c1 e8 0c             	shr    $0xc,%eax
  80131d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801324:	f6 c2 01             	test   $0x1,%dl
  801327:	75 39                	jne    801362 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	c1 e8 0c             	shr    $0xc,%eax
  801331:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	25 07 0e 00 00       	and    $0xe07,%eax
  801340:	50                   	push   %eax
  801341:	56                   	push   %esi
  801342:	6a 00                	push   $0x0
  801344:	52                   	push   %edx
  801345:	6a 00                	push   $0x0
  801347:	e8 c0 fb ff ff       	call   800f0c <sys_page_map>
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	83 c4 20             	add    $0x20,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	78 31                	js     801386 <dup+0xd1>
		goto err;

	return newfdnum;
  801355:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801362:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	25 07 0e 00 00       	and    $0xe07,%eax
  801371:	50                   	push   %eax
  801372:	57                   	push   %edi
  801373:	6a 00                	push   $0x0
  801375:	53                   	push   %ebx
  801376:	6a 00                	push   $0x0
  801378:	e8 8f fb ff ff       	call   800f0c <sys_page_map>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	83 c4 20             	add    $0x20,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	79 a3                	jns    801329 <dup+0x74>
	sys_page_unmap(0, newfd);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	56                   	push   %esi
  80138a:	6a 00                	push   $0x0
  80138c:	e8 bd fb ff ff       	call   800f4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	57                   	push   %edi
  801395:	6a 00                	push   $0x0
  801397:	e8 b2 fb ff ff       	call   800f4e <sys_page_unmap>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	eb b7                	jmp    801358 <dup+0xa3>

008013a1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 14             	sub    $0x14,%esp
  8013a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	53                   	push   %ebx
  8013b0:	e8 7b fd ff ff       	call   801130 <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 3f                	js     8013fb <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	ff 30                	pushl  (%eax)
  8013c8:	e8 b9 fd ff ff       	call   801186 <dev_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 27                	js     8013fb <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d7:	8b 42 08             	mov    0x8(%edx),%eax
  8013da:	83 e0 03             	and    $0x3,%eax
  8013dd:	83 f8 01             	cmp    $0x1,%eax
  8013e0:	74 1e                	je     801400 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	8b 40 08             	mov    0x8(%eax),%eax
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 35                	je     801421 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ec:	83 ec 04             	sub    $0x4,%esp
  8013ef:	ff 75 10             	pushl  0x10(%ebp)
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	52                   	push   %edx
  8013f6:	ff d0                	call   *%eax
  8013f8:	83 c4 10             	add    $0x10,%esp
}
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801400:	a1 04 44 80 00       	mov    0x804404,%eax
  801405:	8b 40 48             	mov    0x48(%eax),%eax
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	53                   	push   %ebx
  80140c:	50                   	push   %eax
  80140d:	68 fd 24 80 00       	push   $0x8024fd
  801412:	e8 88 ef ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141f:	eb da                	jmp    8013fb <read+0x5a>
		return -E_NOT_SUPP;
  801421:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801426:	eb d3                	jmp    8013fb <read+0x5a>

00801428 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	57                   	push   %edi
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	8b 7d 08             	mov    0x8(%ebp),%edi
  801434:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801437:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143c:	39 f3                	cmp    %esi,%ebx
  80143e:	73 25                	jae    801465 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	89 f0                	mov    %esi,%eax
  801445:	29 d8                	sub    %ebx,%eax
  801447:	50                   	push   %eax
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	03 45 0c             	add    0xc(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	57                   	push   %edi
  80144f:	e8 4d ff ff ff       	call   8013a1 <read>
		if (m < 0)
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 08                	js     801463 <readn+0x3b>
			return m;
		if (m == 0)
  80145b:	85 c0                	test   %eax,%eax
  80145d:	74 06                	je     801465 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80145f:	01 c3                	add    %eax,%ebx
  801461:	eb d9                	jmp    80143c <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801463:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801465:	89 d8                	mov    %ebx,%eax
  801467:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801479:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	53                   	push   %ebx
  80147e:	e8 ad fc ff ff       	call   801130 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 3a                	js     8014c4 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801494:	ff 30                	pushl  (%eax)
  801496:	e8 eb fc ff ff       	call   801186 <dev_lookup>
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 22                	js     8014c4 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a9:	74 1e                	je     8014c9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b1:	85 d2                	test   %edx,%edx
  8014b3:	74 35                	je     8014ea <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	ff 75 10             	pushl  0x10(%ebp)
  8014bb:	ff 75 0c             	pushl  0xc(%ebp)
  8014be:	50                   	push   %eax
  8014bf:	ff d2                	call   *%edx
  8014c1:	83 c4 10             	add    $0x10,%esp
}
  8014c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c9:	a1 04 44 80 00       	mov    0x804404,%eax
  8014ce:	8b 40 48             	mov    0x48(%eax),%eax
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	50                   	push   %eax
  8014d6:	68 19 25 80 00       	push   $0x802519
  8014db:	e8 bf ee ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e8:	eb da                	jmp    8014c4 <write+0x55>
		return -E_NOT_SUPP;
  8014ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014ef:	eb d3                	jmp    8014c4 <write+0x55>

008014f1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	ff 75 08             	pushl  0x8(%ebp)
  8014fe:	e8 2d fc ff ff       	call   801130 <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 0e                	js     801518 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801510:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801513:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 14             	sub    $0x14,%esp
  801521:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	53                   	push   %ebx
  801529:	e8 02 fc ff ff       	call   801130 <fd_lookup>
  80152e:	83 c4 08             	add    $0x8,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 37                	js     80156c <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	ff 30                	pushl  (%eax)
  801541:	e8 40 fc ff ff       	call   801186 <dev_lookup>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 1f                	js     80156c <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801550:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801554:	74 1b                	je     801571 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801556:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801559:	8b 52 18             	mov    0x18(%edx),%edx
  80155c:	85 d2                	test   %edx,%edx
  80155e:	74 32                	je     801592 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	50                   	push   %eax
  801567:	ff d2                	call   *%edx
  801569:	83 c4 10             	add    $0x10,%esp
}
  80156c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156f:	c9                   	leave  
  801570:	c3                   	ret    
			thisenv->env_id, fdnum);
  801571:	a1 04 44 80 00       	mov    0x804404,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 dc 24 80 00       	push   $0x8024dc
  801583:	e8 17 ee ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801590:	eb da                	jmp    80156c <ftruncate+0x52>
		return -E_NOT_SUPP;
  801592:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801597:	eb d3                	jmp    80156c <ftruncate+0x52>

00801599 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	83 ec 14             	sub    $0x14,%esp
  8015a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	ff 75 08             	pushl  0x8(%ebp)
  8015aa:	e8 81 fb ff ff       	call   801130 <fd_lookup>
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 4b                	js     801601 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 bf fb ff ff       	call   801186 <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 33                	js     801601 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d5:	74 2f                	je     801606 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015da:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e1:	00 00 00 
	stat->st_isdir = 0;
  8015e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015eb:	00 00 00 
	stat->st_dev = dev;
  8015ee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fb:	ff 50 14             	call   *0x14(%eax)
  8015fe:	83 c4 10             	add    $0x10,%esp
}
  801601:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801604:	c9                   	leave  
  801605:	c3                   	ret    
		return -E_NOT_SUPP;
  801606:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160b:	eb f4                	jmp    801601 <fstat+0x68>

0080160d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	6a 00                	push   $0x0
  801617:	ff 75 08             	pushl  0x8(%ebp)
  80161a:	e8 e7 01 00 00       	call   801806 <open>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 1b                	js     801643 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	e8 65 ff ff ff       	call   801599 <fstat>
  801634:	89 c6                	mov    %eax,%esi
	close(fd);
  801636:	89 1c 24             	mov    %ebx,(%esp)
  801639:	e8 27 fc ff ff       	call   801265 <close>
	return r;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	89 f3                	mov    %esi,%ebx
}
  801643:	89 d8                	mov    %ebx,%eax
  801645:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801648:	5b                   	pop    %ebx
  801649:	5e                   	pop    %esi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	89 c6                	mov    %eax,%esi
  801653:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801655:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80165c:	74 27                	je     801685 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80165e:	6a 07                	push   $0x7
  801660:	68 00 50 80 00       	push   $0x805000
  801665:	56                   	push   %esi
  801666:	ff 35 00 44 80 00    	pushl  0x804400
  80166c:	e8 2b 07 00 00       	call   801d9c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801671:	83 c4 0c             	add    $0xc,%esp
  801674:	6a 00                	push   $0x0
  801676:	53                   	push   %ebx
  801677:	6a 00                	push   $0x0
  801679:	e8 bd 06 00 00       	call   801d3b <ipc_recv>
}
  80167e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	6a 01                	push   $0x1
  80168a:	e8 5a 07 00 00       	call   801de9 <ipc_find_env>
  80168f:	a3 00 44 80 00       	mov    %eax,0x804400
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb c5                	jmp    80165e <fsipc+0x12>

00801699 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ad:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016bc:	e8 8b ff ff ff       	call   80164c <fsipc>
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <devfile_flush>:
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016de:	e8 69 ff ff ff       	call   80164c <fsipc>
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <devfile_stat>:
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 05 00 00 00       	mov    $0x5,%eax
  801704:	e8 43 ff ff ff       	call   80164c <fsipc>
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 2c                	js     801739 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	68 00 50 80 00       	push   $0x805000
  801715:	53                   	push   %ebx
  801716:	e8 b5 f3 ff ff       	call   800ad0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171b:	a1 80 50 80 00       	mov    0x805080,%eax
  801720:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801726:	a1 84 50 80 00       	mov    0x805084,%eax
  80172b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devfile_write>:
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801747:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80174c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801751:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801754:	8b 55 08             	mov    0x8(%ebp),%edx
  801757:	8b 52 0c             	mov    0xc(%edx),%edx
  80175a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801760:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801765:	50                   	push   %eax
  801766:	ff 75 0c             	pushl  0xc(%ebp)
  801769:	68 08 50 80 00       	push   $0x805008
  80176e:	e8 eb f4 ff ff       	call   800c5e <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 04 00 00 00       	mov    $0x4,%eax
  80177d:	e8 ca fe ff ff       	call   80164c <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_read>:
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801797:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a7:	e8 a0 fe ff ff       	call   80164c <fsipc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 1f                	js     8017d1 <devfile_read+0x4d>
	assert(r <= n);
  8017b2:	39 f0                	cmp    %esi,%eax
  8017b4:	77 24                	ja     8017da <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017bb:	7f 33                	jg     8017f0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	50                   	push   %eax
  8017c1:	68 00 50 80 00       	push   $0x805000
  8017c6:	ff 75 0c             	pushl  0xc(%ebp)
  8017c9:	e8 90 f4 ff ff       	call   800c5e <memmove>
	return r;
  8017ce:	83 c4 10             	add    $0x10,%esp
}
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    
	assert(r <= n);
  8017da:	68 48 25 80 00       	push   $0x802548
  8017df:	68 4f 25 80 00       	push   $0x80254f
  8017e4:	6a 7d                	push   $0x7d
  8017e6:	68 64 25 80 00       	push   $0x802564
  8017eb:	e8 d4 ea ff ff       	call   8002c4 <_panic>
	assert(r <= PGSIZE);
  8017f0:	68 6f 25 80 00       	push   $0x80256f
  8017f5:	68 4f 25 80 00       	push   $0x80254f
  8017fa:	6a 7e                	push   $0x7e
  8017fc:	68 64 25 80 00       	push   $0x802564
  801801:	e8 be ea ff ff       	call   8002c4 <_panic>

00801806 <open>:
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	83 ec 1c             	sub    $0x1c,%esp
  80180e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801811:	56                   	push   %esi
  801812:	e8 82 f2 ff ff       	call   800a99 <strlen>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181f:	0f 8f 96 00 00 00    	jg     8018bb <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	e8 b0 f8 ff ff       	call   8010e1 <fd_alloc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	78 66                	js     8018a0 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	56                   	push   %esi
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	e8 88 f2 ff ff       	call   800ad0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	b8 01 00 00 00       	mov    $0x1,%eax
  801858:	e8 ef fd ff ff       	call   80164c <fsipc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 43                	js     8018a9 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	e8 49 f8 ff ff       	call   8010ba <fd2num>
  801871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801874:	8b 0d 04 44 80 00    	mov    0x804404,%ecx
  80187a:	8b 49 48             	mov    0x48(%ecx),%ecx
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	50                   	push   %eax
  801881:	52                   	push   %edx
  801882:	ff 32                	pushl  (%edx)
  801884:	56                   	push   %esi
  801885:	51                   	push   %ecx
  801886:	68 7c 25 80 00       	push   $0x80257c
  80188b:	e8 0f eb ff ff       	call   80039f <cprintf>
	return fd2num(fd);
  801890:	83 c4 14             	add    $0x14,%esp
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 1f f8 ff ff       	call   8010ba <fd2num>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    
		fd_close(fd, 0);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	6a 00                	push   $0x0
  8018ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b1:	e8 26 f9 ff ff       	call   8011dc <fd_close>
		return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	eb e5                	jmp    8018a0 <open+0x9a>
		return -E_BAD_PATH;
  8018bb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018c0:	eb de                	jmp    8018a0 <open+0x9a>

008018c2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d2:	e8 75 fd ff ff       	call   80164c <fsipc>
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018d9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018dd:	7e 38                	jle    801917 <writebuf+0x3e>
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018e8:	ff 70 04             	pushl  0x4(%eax)
  8018eb:	8d 40 10             	lea    0x10(%eax),%eax
  8018ee:	50                   	push   %eax
  8018ef:	ff 33                	pushl  (%ebx)
  8018f1:	e8 79 fb ff ff       	call   80146f <write>
		if (result > 0)
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	7e 03                	jle    801900 <writebuf+0x27>
			b->result += result;
  8018fd:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801900:	39 43 04             	cmp    %eax,0x4(%ebx)
  801903:	74 0d                	je     801912 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801905:	85 c0                	test   %eax,%eax
  801907:	ba 00 00 00 00       	mov    $0x0,%edx
  80190c:	0f 4f c2             	cmovg  %edx,%eax
  80190f:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801915:	c9                   	leave  
  801916:	c3                   	ret    
  801917:	f3 c3                	repz ret 

00801919 <putch>:

static void
putch(int ch, void *thunk)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	53                   	push   %ebx
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801923:	8b 53 04             	mov    0x4(%ebx),%edx
  801926:	8d 42 01             	lea    0x1(%edx),%eax
  801929:	89 43 04             	mov    %eax,0x4(%ebx)
  80192c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192f:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801933:	3d 00 01 00 00       	cmp    $0x100,%eax
  801938:	74 06                	je     801940 <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  80193a:	83 c4 04             	add    $0x4,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    
		writebuf(b);
  801940:	89 d8                	mov    %ebx,%eax
  801942:	e8 92 ff ff ff       	call   8018d9 <writebuf>
		b->idx = 0;
  801947:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80194e:	eb ea                	jmp    80193a <putch+0x21>

00801950 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801962:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801969:	00 00 00 
	b.result = 0;
  80196c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801973:	00 00 00 
	b.error = 1;
  801976:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80197d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801980:	ff 75 10             	pushl  0x10(%ebp)
  801983:	ff 75 0c             	pushl  0xc(%ebp)
  801986:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	68 19 19 80 00       	push   $0x801919
  801992:	e8 05 eb ff ff       	call   80049c <vprintfmt>
	if (b.idx > 0)
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019a1:	7f 11                	jg     8019b4 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8019a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    
		writebuf(&b);
  8019b4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ba:	e8 1a ff ff ff       	call   8018d9 <writebuf>
  8019bf:	eb e2                	jmp    8019a3 <vfprintf+0x53>

008019c1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019c7:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019ca:	50                   	push   %eax
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	ff 75 08             	pushl  0x8(%ebp)
  8019d1:	e8 7a ff ff ff       	call   801950 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <printf>:

int
printf(const char *fmt, ...)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019e1:	50                   	push   %eax
  8019e2:	ff 75 08             	pushl  0x8(%ebp)
  8019e5:	6a 01                	push   $0x1
  8019e7:	e8 64 ff ff ff       	call   801950 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	ff 75 08             	pushl  0x8(%ebp)
  8019fc:	e8 c9 f6 ff ff       	call   8010ca <fd2data>
  801a01:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a03:	83 c4 08             	add    $0x8,%esp
  801a06:	68 bc 25 80 00       	push   $0x8025bc
  801a0b:	53                   	push   %ebx
  801a0c:	e8 bf f0 ff ff       	call   800ad0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a11:	8b 46 04             	mov    0x4(%esi),%eax
  801a14:	2b 06                	sub    (%esi),%eax
  801a16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a1c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a23:	00 00 00 
	stat->st_dev = &devpipe;
  801a26:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a2d:	30 80 00 
	return 0;
}
  801a30:	b8 00 00 00 00       	mov    $0x0,%eax
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a46:	53                   	push   %ebx
  801a47:	6a 00                	push   $0x0
  801a49:	e8 00 f5 ff ff       	call   800f4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4e:	89 1c 24             	mov    %ebx,(%esp)
  801a51:	e8 74 f6 ff ff       	call   8010ca <fd2data>
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	50                   	push   %eax
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 ed f4 ff ff       	call   800f4e <sys_page_unmap>
}
  801a61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <_pipeisclosed>:
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	57                   	push   %edi
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 1c             	sub    $0x1c,%esp
  801a6f:	89 c7                	mov    %eax,%edi
  801a71:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a73:	a1 04 44 80 00       	mov    0x804404,%eax
  801a78:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	57                   	push   %edi
  801a7f:	e8 9e 03 00 00       	call   801e22 <pageref>
  801a84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a87:	89 34 24             	mov    %esi,(%esp)
  801a8a:	e8 93 03 00 00       	call   801e22 <pageref>
		nn = thisenv->env_runs;
  801a8f:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a95:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	39 cb                	cmp    %ecx,%ebx
  801a9d:	74 1b                	je     801aba <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a9f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aa2:	75 cf                	jne    801a73 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aa4:	8b 42 58             	mov    0x58(%edx),%eax
  801aa7:	6a 01                	push   $0x1
  801aa9:	50                   	push   %eax
  801aaa:	53                   	push   %ebx
  801aab:	68 c3 25 80 00       	push   $0x8025c3
  801ab0:	e8 ea e8 ff ff       	call   80039f <cprintf>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	eb b9                	jmp    801a73 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801aba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801abd:	0f 94 c0             	sete   %al
  801ac0:	0f b6 c0             	movzbl %al,%eax
}
  801ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <devpipe_write>:
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	57                   	push   %edi
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 28             	sub    $0x28,%esp
  801ad4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ad7:	56                   	push   %esi
  801ad8:	e8 ed f5 ff ff       	call   8010ca <fd2data>
  801add:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aea:	74 4f                	je     801b3b <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aec:	8b 43 04             	mov    0x4(%ebx),%eax
  801aef:	8b 0b                	mov    (%ebx),%ecx
  801af1:	8d 51 20             	lea    0x20(%ecx),%edx
  801af4:	39 d0                	cmp    %edx,%eax
  801af6:	72 14                	jb     801b0c <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801af8:	89 da                	mov    %ebx,%edx
  801afa:	89 f0                	mov    %esi,%eax
  801afc:	e8 65 ff ff ff       	call   801a66 <_pipeisclosed>
  801b01:	85 c0                	test   %eax,%eax
  801b03:	75 3a                	jne    801b3f <devpipe_write+0x74>
			sys_yield();
  801b05:	e8 a0 f3 ff ff       	call   800eaa <sys_yield>
  801b0a:	eb e0                	jmp    801aec <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 fa 1f             	sar    $0x1f,%edx
  801b1b:	89 d1                	mov    %edx,%ecx
  801b1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b23:	83 e2 1f             	and    $0x1f,%edx
  801b26:	29 ca                	sub    %ecx,%edx
  801b28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b30:	83 c0 01             	add    $0x1,%eax
  801b33:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b36:	83 c7 01             	add    $0x1,%edi
  801b39:	eb ac                	jmp    801ae7 <devpipe_write+0x1c>
	return i;
  801b3b:	89 f8                	mov    %edi,%eax
  801b3d:	eb 05                	jmp    801b44 <devpipe_write+0x79>
				return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <devpipe_read>:
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 18             	sub    $0x18,%esp
  801b55:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b58:	57                   	push   %edi
  801b59:	e8 6c f5 ff ff       	call   8010ca <fd2data>
  801b5e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	be 00 00 00 00       	mov    $0x0,%esi
  801b68:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b6b:	74 47                	je     801bb4 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b6d:	8b 03                	mov    (%ebx),%eax
  801b6f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b72:	75 22                	jne    801b96 <devpipe_read+0x4a>
			if (i > 0)
  801b74:	85 f6                	test   %esi,%esi
  801b76:	75 14                	jne    801b8c <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b78:	89 da                	mov    %ebx,%edx
  801b7a:	89 f8                	mov    %edi,%eax
  801b7c:	e8 e5 fe ff ff       	call   801a66 <_pipeisclosed>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	75 33                	jne    801bb8 <devpipe_read+0x6c>
			sys_yield();
  801b85:	e8 20 f3 ff ff       	call   800eaa <sys_yield>
  801b8a:	eb e1                	jmp    801b6d <devpipe_read+0x21>
				return i;
  801b8c:	89 f0                	mov    %esi,%eax
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b96:	99                   	cltd   
  801b97:	c1 ea 1b             	shr    $0x1b,%edx
  801b9a:	01 d0                	add    %edx,%eax
  801b9c:	83 e0 1f             	and    $0x1f,%eax
  801b9f:	29 d0                	sub    %edx,%eax
  801ba1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bac:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801baf:	83 c6 01             	add    $0x1,%esi
  801bb2:	eb b4                	jmp    801b68 <devpipe_read+0x1c>
	return i;
  801bb4:	89 f0                	mov    %esi,%eax
  801bb6:	eb d6                	jmp    801b8e <devpipe_read+0x42>
				return 0;
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbd:	eb cf                	jmp    801b8e <devpipe_read+0x42>

00801bbf <pipe>:
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	e8 11 f5 ff ff       	call   8010e1 <fd_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 5b                	js     801c34 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	68 07 04 00 00       	push   $0x407
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	6a 00                	push   $0x0
  801be6:	e8 de f2 ff ff       	call   800ec9 <sys_page_alloc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 40                	js     801c34 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 e1 f4 ff ff       	call   8010e1 <fd_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 1b                	js     801c24 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c09:	83 ec 04             	sub    $0x4,%esp
  801c0c:	68 07 04 00 00       	push   $0x407
  801c11:	ff 75 f0             	pushl  -0x10(%ebp)
  801c14:	6a 00                	push   $0x0
  801c16:	e8 ae f2 ff ff       	call   800ec9 <sys_page_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	79 19                	jns    801c3d <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 1d f3 ff ff       	call   800f4e <sys_page_unmap>
  801c31:	83 c4 10             	add    $0x10,%esp
}
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    
	va = fd2data(fd0);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	e8 82 f4 ff ff       	call   8010ca <fd2data>
  801c48:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4a:	83 c4 0c             	add    $0xc,%esp
  801c4d:	68 07 04 00 00       	push   $0x407
  801c52:	50                   	push   %eax
  801c53:	6a 00                	push   $0x0
  801c55:	e8 6f f2 ff ff       	call   800ec9 <sys_page_alloc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 8c 00 00 00    	js     801cf3 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	e8 58 f4 ff ff       	call   8010ca <fd2data>
  801c72:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c79:	50                   	push   %eax
  801c7a:	6a 00                	push   $0x0
  801c7c:	56                   	push   %esi
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 88 f2 ff ff       	call   800f0c <sys_page_map>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 20             	add    $0x20,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 58                	js     801ce5 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c96:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 f8 f3 ff ff       	call   8010ba <fd2num>
  801cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc7:	83 c4 04             	add    $0x4,%esp
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	e8 e8 f3 ff ff       	call   8010ba <fd2num>
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce0:	e9 4f ff ff ff       	jmp    801c34 <pipe+0x75>
	sys_page_unmap(0, va);
  801ce5:	83 ec 08             	sub    $0x8,%esp
  801ce8:	56                   	push   %esi
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 5e f2 ff ff       	call   800f4e <sys_page_unmap>
  801cf0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cf3:	83 ec 08             	sub    $0x8,%esp
  801cf6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 4e f2 ff ff       	call   800f4e <sys_page_unmap>
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	e9 1c ff ff ff       	jmp    801c24 <pipe+0x65>

00801d08 <pipeisclosed>:
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	ff 75 08             	pushl  0x8(%ebp)
  801d15:	e8 16 f4 ff ff       	call   801130 <fd_lookup>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 18                	js     801d39 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d21:	83 ec 0c             	sub    $0xc,%esp
  801d24:	ff 75 f4             	pushl  -0xc(%ebp)
  801d27:	e8 9e f3 ff ff       	call   8010ca <fd2data>
	return _pipeisclosed(fd, p);
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	e8 30 fd ff ff       	call   801a66 <_pipeisclosed>
  801d36:	83 c4 10             	add    $0x10,%esp
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	8b 75 08             	mov    0x8(%ebp),%esi
  801d43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d50:	0f 44 c2             	cmove  %edx,%eax
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	50                   	push   %eax
  801d57:	e8 1d f3 ff ff       	call   801079 <sys_ipc_recv>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	78 2b                	js     801d8e <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801d63:	85 f6                	test   %esi,%esi
  801d65:	74 0a                	je     801d71 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801d67:	a1 04 44 80 00       	mov    0x804404,%eax
  801d6c:	8b 40 74             	mov    0x74(%eax),%eax
  801d6f:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801d71:	85 db                	test   %ebx,%ebx
  801d73:	74 0a                	je     801d7f <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801d75:	a1 04 44 80 00       	mov    0x804404,%eax
  801d7a:	8b 40 78             	mov    0x78(%eax),%eax
  801d7d:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801d7f:	a1 04 44 80 00       	mov    0x804404,%eax
  801d84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    
        *from_env_store = 0;
  801d8e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801d94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801d9a:	eb eb                	jmp    801d87 <ipc_recv+0x4c>

00801d9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801da8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801dae:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801db0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801db5:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801db8:	ff 75 14             	pushl  0x14(%ebp)
  801dbb:	53                   	push   %ebx
  801dbc:	56                   	push   %esi
  801dbd:	57                   	push   %edi
  801dbe:	e8 93 f2 ff ff       	call   801056 <sys_ipc_try_send>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	74 17                	je     801de1 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801dca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dcd:	74 e9                	je     801db8 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801dcf:	50                   	push   %eax
  801dd0:	68 db 25 80 00       	push   $0x8025db
  801dd5:	6a 3e                	push   $0x3e
  801dd7:	68 ed 25 80 00       	push   $0x8025ed
  801ddc:	e8 e3 e4 ff ff       	call   8002c4 <_panic>
        }
    }
}
  801de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801df4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801df7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dfd:	8b 52 50             	mov    0x50(%edx),%edx
  801e00:	39 ca                	cmp    %ecx,%edx
  801e02:	74 11                	je     801e15 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801e04:	83 c0 01             	add    $0x1,%eax
  801e07:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e0c:	75 e6                	jne    801df4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e13:	eb 0b                	jmp    801e20 <ipc_find_env+0x37>
			return envs[i].env_id;
  801e15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e1d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    

00801e22 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e28:	89 d0                	mov    %edx,%eax
  801e2a:	c1 e8 16             	shr    $0x16,%eax
  801e2d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e39:	f6 c1 01             	test   $0x1,%cl
  801e3c:	74 1d                	je     801e5b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e3e:	c1 ea 0c             	shr    $0xc,%edx
  801e41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e48:	f6 c2 01             	test   $0x1,%dl
  801e4b:	74 0e                	je     801e5b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e4d:	c1 ea 0c             	shr    $0xc,%edx
  801e50:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e57:	ef 
  801e58:	0f b7 c0             	movzwl %ax,%eax
}
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801e77:	85 d2                	test   %edx,%edx
  801e79:	75 35                	jne    801eb0 <__udivdi3+0x50>
  801e7b:	39 f3                	cmp    %esi,%ebx
  801e7d:	0f 87 bd 00 00 00    	ja     801f40 <__udivdi3+0xe0>
  801e83:	85 db                	test   %ebx,%ebx
  801e85:	89 d9                	mov    %ebx,%ecx
  801e87:	75 0b                	jne    801e94 <__udivdi3+0x34>
  801e89:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8e:	31 d2                	xor    %edx,%edx
  801e90:	f7 f3                	div    %ebx
  801e92:	89 c1                	mov    %eax,%ecx
  801e94:	31 d2                	xor    %edx,%edx
  801e96:	89 f0                	mov    %esi,%eax
  801e98:	f7 f1                	div    %ecx
  801e9a:	89 c6                	mov    %eax,%esi
  801e9c:	89 e8                	mov    %ebp,%eax
  801e9e:	89 f7                	mov    %esi,%edi
  801ea0:	f7 f1                	div    %ecx
  801ea2:	89 fa                	mov    %edi,%edx
  801ea4:	83 c4 1c             	add    $0x1c,%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	39 f2                	cmp    %esi,%edx
  801eb2:	77 7c                	ja     801f30 <__udivdi3+0xd0>
  801eb4:	0f bd fa             	bsr    %edx,%edi
  801eb7:	83 f7 1f             	xor    $0x1f,%edi
  801eba:	0f 84 98 00 00 00    	je     801f58 <__udivdi3+0xf8>
  801ec0:	89 f9                	mov    %edi,%ecx
  801ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ec7:	29 f8                	sub    %edi,%eax
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ecf:	89 c1                	mov    %eax,%ecx
  801ed1:	89 da                	mov    %ebx,%edx
  801ed3:	d3 ea                	shr    %cl,%edx
  801ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ed9:	09 d1                	or     %edx,%ecx
  801edb:	89 f2                	mov    %esi,%edx
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e3                	shl    %cl,%ebx
  801ee5:	89 c1                	mov    %eax,%ecx
  801ee7:	d3 ea                	shr    %cl,%edx
  801ee9:	89 f9                	mov    %edi,%ecx
  801eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801eef:	d3 e6                	shl    %cl,%esi
  801ef1:	89 eb                	mov    %ebp,%ebx
  801ef3:	89 c1                	mov    %eax,%ecx
  801ef5:	d3 eb                	shr    %cl,%ebx
  801ef7:	09 de                	or     %ebx,%esi
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	f7 74 24 08          	divl   0x8(%esp)
  801eff:	89 d6                	mov    %edx,%esi
  801f01:	89 c3                	mov    %eax,%ebx
  801f03:	f7 64 24 0c          	mull   0xc(%esp)
  801f07:	39 d6                	cmp    %edx,%esi
  801f09:	72 0c                	jb     801f17 <__udivdi3+0xb7>
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e5                	shl    %cl,%ebp
  801f0f:	39 c5                	cmp    %eax,%ebp
  801f11:	73 5d                	jae    801f70 <__udivdi3+0x110>
  801f13:	39 d6                	cmp    %edx,%esi
  801f15:	75 59                	jne    801f70 <__udivdi3+0x110>
  801f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801f1a:	31 ff                	xor    %edi,%edi
  801f1c:	89 fa                	mov    %edi,%edx
  801f1e:	83 c4 1c             	add    $0x1c,%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5f                   	pop    %edi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    
  801f26:	8d 76 00             	lea    0x0(%esi),%esi
  801f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f30:	31 ff                	xor    %edi,%edi
  801f32:	31 c0                	xor    %eax,%eax
  801f34:	89 fa                	mov    %edi,%edx
  801f36:	83 c4 1c             	add    $0x1c,%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5f                   	pop    %edi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    
  801f3e:	66 90                	xchg   %ax,%ax
  801f40:	31 ff                	xor    %edi,%edi
  801f42:	89 e8                	mov    %ebp,%eax
  801f44:	89 f2                	mov    %esi,%edx
  801f46:	f7 f3                	div    %ebx
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	39 f2                	cmp    %esi,%edx
  801f5a:	72 06                	jb     801f62 <__udivdi3+0x102>
  801f5c:	31 c0                	xor    %eax,%eax
  801f5e:	39 eb                	cmp    %ebp,%ebx
  801f60:	77 d2                	ja     801f34 <__udivdi3+0xd4>
  801f62:	b8 01 00 00 00       	mov    $0x1,%eax
  801f67:	eb cb                	jmp    801f34 <__udivdi3+0xd4>
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 d8                	mov    %ebx,%eax
  801f72:	31 ff                	xor    %edi,%edi
  801f74:	eb be                	jmp    801f34 <__udivdi3+0xd4>
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__umoddi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 ed                	test   %ebp,%ebp
  801f99:	89 f0                	mov    %esi,%eax
  801f9b:	89 da                	mov    %ebx,%edx
  801f9d:	75 19                	jne    801fb8 <__umoddi3+0x38>
  801f9f:	39 df                	cmp    %ebx,%edi
  801fa1:	0f 86 b1 00 00 00    	jbe    802058 <__umoddi3+0xd8>
  801fa7:	f7 f7                	div    %edi
  801fa9:	89 d0                	mov    %edx,%eax
  801fab:	31 d2                	xor    %edx,%edx
  801fad:	83 c4 1c             	add    $0x1c,%esp
  801fb0:	5b                   	pop    %ebx
  801fb1:	5e                   	pop    %esi
  801fb2:	5f                   	pop    %edi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    
  801fb5:	8d 76 00             	lea    0x0(%esi),%esi
  801fb8:	39 dd                	cmp    %ebx,%ebp
  801fba:	77 f1                	ja     801fad <__umoddi3+0x2d>
  801fbc:	0f bd cd             	bsr    %ebp,%ecx
  801fbf:	83 f1 1f             	xor    $0x1f,%ecx
  801fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fc6:	0f 84 b4 00 00 00    	je     802080 <__umoddi3+0x100>
  801fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd1:	89 c2                	mov    %eax,%edx
  801fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fd7:	29 c2                	sub    %eax,%edx
  801fd9:	89 c1                	mov    %eax,%ecx
  801fdb:	89 f8                	mov    %edi,%eax
  801fdd:	d3 e5                	shl    %cl,%ebp
  801fdf:	89 d1                	mov    %edx,%ecx
  801fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fe5:	d3 e8                	shr    %cl,%eax
  801fe7:	09 c5                	or     %eax,%ebp
  801fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fed:	89 c1                	mov    %eax,%ecx
  801fef:	d3 e7                	shl    %cl,%edi
  801ff1:	89 d1                	mov    %edx,%ecx
  801ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ff7:	89 df                	mov    %ebx,%edi
  801ff9:	d3 ef                	shr    %cl,%edi
  801ffb:	89 c1                	mov    %eax,%ecx
  801ffd:	89 f0                	mov    %esi,%eax
  801fff:	d3 e3                	shl    %cl,%ebx
  802001:	89 d1                	mov    %edx,%ecx
  802003:	89 fa                	mov    %edi,%edx
  802005:	d3 e8                	shr    %cl,%eax
  802007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80200c:	09 d8                	or     %ebx,%eax
  80200e:	f7 f5                	div    %ebp
  802010:	d3 e6                	shl    %cl,%esi
  802012:	89 d1                	mov    %edx,%ecx
  802014:	f7 64 24 08          	mull   0x8(%esp)
  802018:	39 d1                	cmp    %edx,%ecx
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d7                	mov    %edx,%edi
  80201e:	72 06                	jb     802026 <__umoddi3+0xa6>
  802020:	75 0e                	jne    802030 <__umoddi3+0xb0>
  802022:	39 c6                	cmp    %eax,%esi
  802024:	73 0a                	jae    802030 <__umoddi3+0xb0>
  802026:	2b 44 24 08          	sub    0x8(%esp),%eax
  80202a:	19 ea                	sbb    %ebp,%edx
  80202c:	89 d7                	mov    %edx,%edi
  80202e:	89 c3                	mov    %eax,%ebx
  802030:	89 ca                	mov    %ecx,%edx
  802032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802037:	29 de                	sub    %ebx,%esi
  802039:	19 fa                	sbb    %edi,%edx
  80203b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	d3 e0                	shl    %cl,%eax
  802043:	89 d9                	mov    %ebx,%ecx
  802045:	d3 ee                	shr    %cl,%esi
  802047:	d3 ea                	shr    %cl,%edx
  802049:	09 f0                	or     %esi,%eax
  80204b:	83 c4 1c             	add    $0x1c,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	85 ff                	test   %edi,%edi
  80205a:	89 f9                	mov    %edi,%ecx
  80205c:	75 0b                	jne    802069 <__umoddi3+0xe9>
  80205e:	b8 01 00 00 00       	mov    $0x1,%eax
  802063:	31 d2                	xor    %edx,%edx
  802065:	f7 f7                	div    %edi
  802067:	89 c1                	mov    %eax,%ecx
  802069:	89 d8                	mov    %ebx,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f1                	div    %ecx
  80206f:	89 f0                	mov    %esi,%eax
  802071:	f7 f1                	div    %ecx
  802073:	e9 31 ff ff ff       	jmp    801fa9 <__umoddi3+0x29>
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 dd                	cmp    %ebx,%ebp
  802082:	72 08                	jb     80208c <__umoddi3+0x10c>
  802084:	39 f7                	cmp    %esi,%edi
  802086:	0f 87 21 ff ff ff    	ja     801fad <__umoddi3+0x2d>
  80208c:	89 da                	mov    %ebx,%edx
  80208e:	89 f0                	mov    %esi,%eax
  802090:	29 f8                	sub    %edi,%eax
  802092:	19 ea                	sbb    %ebp,%edx
  802094:	e9 14 ff ff ff       	jmp    801fad <__umoddi3+0x2d>
