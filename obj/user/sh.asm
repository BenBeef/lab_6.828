
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 01 0b 00 00       	call   800b32 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int t;

	if (s == 0) {
  80003b:	85 db                	test   %ebx,%ebx
  80003d:	74 1d                	je     80005c <_gettoken+0x29>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80003f:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800046:	7f 34                	jg     80007c <_gettoken+0x49>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*p2 = 0;
  800051:	8b 45 10             	mov    0x10(%ebp),%eax
  800054:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80005a:	eb 3a                	jmp    800096 <_gettoken+0x63>
		return 0;
  80005c:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800061:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800068:	7e 59                	jle    8000c3 <_gettoken+0x90>
			cprintf("GETTOKEN NULL\n");
  80006a:	83 ec 0c             	sub    $0xc,%esp
  80006d:	68 20 35 80 00       	push   $0x803520
  800072:	e8 f6 0b 00 00       	call   800c6d <cprintf>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	eb 47                	jmp    8000c3 <_gettoken+0x90>
		cprintf("GETTOKEN: %s\n", s);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	68 2f 35 80 00       	push   $0x80352f
  800085:	e8 e3 0b 00 00       	call   800c6d <cprintf>
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	eb b9                	jmp    800048 <_gettoken+0x15>
		*s++ = 0;
  80008f:	83 c3 01             	add    $0x1,%ebx
  800092:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	0f be 03             	movsbl (%ebx),%eax
  80009c:	50                   	push   %eax
  80009d:	68 3d 35 80 00       	push   $0x80353d
  8000a2:	e8 fb 13 00 00       	call   8014a2 <strchr>
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 e1                	jne    80008f <_gettoken+0x5c>
	if (*s == 0) {
  8000ae:	0f b6 03             	movzbl (%ebx),%eax
  8000b1:	84 c0                	test   %al,%al
  8000b3:	75 29                	jne    8000de <_gettoken+0xab>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000b5:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000ba:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c1:	7f 09                	jg     8000cc <_gettoken+0x99>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000c3:	89 f0                	mov    %esi,%eax
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    
			cprintf("EOL\n");
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	68 42 35 80 00       	push   $0x803542
  8000d4:	e8 94 0b 00 00       	call   800c6d <cprintf>
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	eb e5                	jmp    8000c3 <_gettoken+0x90>
	if (strchr(SYMBOLS, *s)) {
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	0f be c0             	movsbl %al,%eax
  8000e4:	50                   	push   %eax
  8000e5:	68 53 35 80 00       	push   $0x803553
  8000ea:	e8 b3 13 00 00       	call   8014a2 <strchr>
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	74 2f                	je     800125 <_gettoken+0xf2>
		t = *s;
  8000f6:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 18                	mov    %ebx,(%eax)
		*s++ = 0;
  8000fe:	c6 03 00             	movb   $0x0,(%ebx)
  800101:	83 c3 01             	add    $0x1,%ebx
  800104:	8b 45 10             	mov    0x10(%ebp),%eax
  800107:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  800109:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800110:	7e b1                	jle    8000c3 <_gettoken+0x90>
			cprintf("TOK %c\n", t);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	56                   	push   %esi
  800116:	68 47 35 80 00       	push   $0x803547
  80011b:	e8 4d 0b 00 00       	call   800c6d <cprintf>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 9e                	jmp    8000c3 <_gettoken+0x90>
	*p1 = s;
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 18                	mov    %ebx,(%eax)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012a:	eb 03                	jmp    80012f <_gettoken+0xfc>
		s++;
  80012c:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012f:	0f b6 03             	movzbl (%ebx),%eax
  800132:	84 c0                	test   %al,%al
  800134:	74 18                	je     80014e <_gettoken+0x11b>
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	0f be c0             	movsbl %al,%eax
  80013c:	50                   	push   %eax
  80013d:	68 4f 35 80 00       	push   $0x80354f
  800142:	e8 5b 13 00 00       	call   8014a2 <strchr>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	74 de                	je     80012c <_gettoken+0xf9>
	*p2 = s;
  80014e:	8b 45 10             	mov    0x10(%ebp),%eax
  800151:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800153:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  800158:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015f:	0f 8e 5e ff ff ff    	jle    8000c3 <_gettoken+0x90>
		t = **p2;
  800165:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800168:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	ff 30                	pushl  (%eax)
  800173:	68 5b 35 80 00       	push   $0x80355b
  800178:	e8 f0 0a 00 00       	call   800c6d <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 30 ff ff ff       	jmp    8000c3 <_gettoken+0x90>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  80019c:	85 c0                	test   %eax,%eax
  80019e:	74 22                	je     8001c2 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 0c 50 80 00       	push   $0x80500c
  8001a8:	68 10 50 80 00       	push   $0x805010
  8001ad:	50                   	push   %eax
  8001ae:	e8 80 fe ff ff       	call   800033 <_gettoken>
  8001b3:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
	c = nc;
  8001c2:	a1 08 50 80 00       	mov    0x805008,%eax
  8001c7:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001cc:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d5:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	68 0c 50 80 00       	push   $0x80500c
  8001df:	68 10 50 80 00       	push   $0x805010
  8001e4:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ea:	e8 44 fe ff ff       	call   800033 <_gettoken>
  8001ef:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb c2                	jmp    8001c0 <gettoken+0x2d>

008001fe <runcmd>:
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	81 ec 64 04 00 00    	sub    $0x464,%esp
    cprintf("[%08x] ------------- open for write \n", thisenv->env_id);
  80020a:	a1 24 54 80 00       	mov    0x805424,%eax
  80020f:	8b 40 48             	mov    0x48(%eax),%eax
  800212:	50                   	push   %eax
  800213:	68 b8 36 80 00       	push   $0x8036b8
  800218:	e8 50 0a 00 00       	call   800c6d <cprintf>
	gettoken(s, 0);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	6a 00                	push   $0x0
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 69 ff ff ff       	call   800193 <gettoken>
  80022a:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  80022d:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  800230:	bf 00 00 00 00       	mov    $0x0,%edi
        cprintf("[%08x] ------------- open while \n", thisenv->env_id);
  800235:	a1 24 54 80 00       	mov    0x805424,%eax
  80023a:	8b 40 48             	mov    0x48(%eax),%eax
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	50                   	push   %eax
  800241:	68 e0 36 80 00       	push   $0x8036e0
  800246:	e8 22 0a 00 00       	call   800c6d <cprintf>
		switch ((c = gettoken(0, &t))) {
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	6a 00                	push   $0x0
  800251:	e8 3d ff ff ff       	call   800193 <gettoken>
  800256:	89 c3                	mov    %eax,%ebx
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	83 f8 3e             	cmp    $0x3e,%eax
  80025e:	0f 84 56 01 00 00    	je     8003ba <runcmd+0x1bc>
  800264:	83 f8 3e             	cmp    $0x3e,%eax
  800267:	7f 68                	jg     8002d1 <runcmd+0xd3>
  800269:	85 c0                	test   %eax,%eax
  80026b:	0f 84 52 02 00 00    	je     8004c3 <runcmd+0x2c5>
  800271:	83 f8 3c             	cmp    $0x3c,%eax
  800274:	0f 85 ae 02 00 00    	jne    800528 <runcmd+0x32a>
			if (gettoken(0, &t) != 'w') {
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	56                   	push   %esi
  80027e:	6a 00                	push   $0x0
  800280:	e8 0e ff ff ff       	call   800193 <gettoken>
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	83 f8 77             	cmp    $0x77,%eax
  80028b:	0f 85 db 00 00 00    	jne    80036c <runcmd+0x16e>
            cprintf("[%08x] ------------- open %s for read \n", thisenv->env_id, t);
  800291:	a1 24 54 80 00       	mov    0x805424,%eax
  800296:	8b 40 48             	mov    0x48(%eax),%eax
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 a4             	pushl  -0x5c(%ebp)
  80029f:	50                   	push   %eax
  8002a0:	68 2c 37 80 00       	push   $0x80372c
  8002a5:	e8 c3 09 00 00       	call   800c6d <cprintf>
            if ((fd = open(t, O_RDONLY)) < 0) {
  8002aa:	83 c4 08             	add    $0x8,%esp
  8002ad:	6a 00                	push   $0x0
  8002af:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002b2:	e8 ec 22 00 00       	call   8025a3 <open>
  8002b7:	89 c3                	mov    %eax,%ebx
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	0f 88 c2 00 00 00    	js     800386 <runcmd+0x188>
            if (fd != 0) {
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	0f 84 69 ff ff ff    	je     800235 <runcmd+0x37>
  8002cc:	e9 ce 00 00 00       	jmp    80039f <runcmd+0x1a1>
		switch ((c = gettoken(0, &t))) {
  8002d1:	83 f8 77             	cmp    $0x77,%eax
  8002d4:	74 6b                	je     800341 <runcmd+0x143>
  8002d6:	83 f8 7c             	cmp    $0x7c,%eax
  8002d9:	0f 85 49 02 00 00    	jne    800528 <runcmd+0x32a>
			if ((r = pipe(p)) < 0) {
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8002e8:	50                   	push   %eax
  8002e9:	e8 00 2d 00 00       	call   802fee <pipe>
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	0f 88 5c 01 00 00    	js     800455 <runcmd+0x257>
			if (debug)
  8002f9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800300:	0f 85 6a 01 00 00    	jne    800470 <runcmd+0x272>
			if ((r = fork()) < 0) {
  800306:	e8 83 18 00 00       	call   801b8e <fork>
  80030b:	89 c3                	mov    %eax,%ebx
  80030d:	85 c0                	test   %eax,%eax
  80030f:	0f 88 7c 01 00 00    	js     800491 <runcmd+0x293>
			if (r == 0) {
  800315:	85 c0                	test   %eax,%eax
  800317:	0f 85 8a 01 00 00    	jne    8004a7 <runcmd+0x2a9>
				if (p[0] != 0) {
  80031d:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 85 be 01 00 00    	jne    8004e9 <runcmd+0x2eb>
				close(p[1]);
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800334:	e8 c9 1c 00 00       	call   802002 <close>
				goto again;
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	e9 ef fe ff ff       	jmp    800230 <runcmd+0x32>
			if (argc == MAXARGS) {
  800341:	83 ff 10             	cmp    $0x10,%edi
  800344:	74 0f                	je     800355 <runcmd+0x157>
			argv[argc++] = t;
  800346:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800349:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  80034d:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800350:	e9 e0 fe ff ff       	jmp    800235 <runcmd+0x37>
				cprintf("too many arguments\n");
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	68 65 35 80 00       	push   $0x803565
  80035d:	e8 0b 09 00 00       	call   800c6d <cprintf>
				exit();
  800362:	e8 11 08 00 00       	call   800b78 <exit>
  800367:	83 c4 10             	add    $0x10,%esp
  80036a:	eb da                	jmp    800346 <runcmd+0x148>
				cprintf("syntax error: < not followed by word\n");
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	68 04 37 80 00       	push   $0x803704
  800374:	e8 f4 08 00 00       	call   800c6d <cprintf>
				exit();
  800379:	e8 fa 07 00 00       	call   800b78 <exit>
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	e9 0b ff ff ff       	jmp    800291 <runcmd+0x93>
                cprintf("open %s for read: %e", t, fd);
  800386:	83 ec 04             	sub    $0x4,%esp
  800389:	50                   	push   %eax
  80038a:	ff 75 a4             	pushl  -0x5c(%ebp)
  80038d:	68 79 35 80 00       	push   $0x803579
  800392:	e8 d6 08 00 00       	call   800c6d <cprintf>
                exit();
  800397:	e8 dc 07 00 00       	call   800b78 <exit>
  80039c:	83 c4 10             	add    $0x10,%esp
                dup(fd, 0);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	6a 00                	push   $0x0
  8003a4:	53                   	push   %ebx
  8003a5:	e8 a8 1c 00 00       	call   802052 <dup>
                close(fd);
  8003aa:	89 1c 24             	mov    %ebx,(%esp)
  8003ad:	e8 50 1c 00 00       	call   802002 <close>
  8003b2:	83 c4 10             	add    $0x10,%esp
  8003b5:	e9 7b fe ff ff       	jmp    800235 <runcmd+0x37>
            cprintf("[%08x] ------------- open %s for write \n", thisenv->env_id, t);
  8003ba:	a1 24 54 80 00       	mov    0x805424,%eax
  8003bf:	8b 40 48             	mov    0x48(%eax),%eax
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003c8:	50                   	push   %eax
  8003c9:	68 54 37 80 00       	push   $0x803754
  8003ce:	e8 9a 08 00 00       	call   800c6d <cprintf>
			if (gettoken(0, &t) != 'w') {
  8003d3:	83 c4 08             	add    $0x8,%esp
  8003d6:	56                   	push   %esi
  8003d7:	6a 00                	push   $0x0
  8003d9:	e8 b5 fd ff ff       	call   800193 <gettoken>
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	83 f8 77             	cmp    $0x77,%eax
  8003e4:	75 3d                	jne    800423 <runcmd+0x225>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	68 01 03 00 00       	push   $0x301
  8003ee:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003f1:	e8 ad 21 00 00       	call   8025a3 <open>
  8003f6:	89 c3                	mov    %eax,%ebx
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	78 3b                	js     80043a <runcmd+0x23c>
			if (fd != 1) {
  8003ff:	83 fb 01             	cmp    $0x1,%ebx
  800402:	0f 84 2d fe ff ff    	je     800235 <runcmd+0x37>
				dup(fd, 1);
  800408:	83 ec 08             	sub    $0x8,%esp
  80040b:	6a 01                	push   $0x1
  80040d:	53                   	push   %ebx
  80040e:	e8 3f 1c 00 00       	call   802052 <dup>
				close(fd);
  800413:	89 1c 24             	mov    %ebx,(%esp)
  800416:	e8 e7 1b 00 00       	call   802002 <close>
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	e9 12 fe ff ff       	jmp    800235 <runcmd+0x37>
				cprintf("syntax error: > not followed by word\n");
  800423:	83 ec 0c             	sub    $0xc,%esp
  800426:	68 80 37 80 00       	push   $0x803780
  80042b:	e8 3d 08 00 00       	call   800c6d <cprintf>
				exit();
  800430:	e8 43 07 00 00       	call   800b78 <exit>
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb ac                	jmp    8003e6 <runcmd+0x1e8>
				cprintf("open %s for write: %e", t, fd);
  80043a:	83 ec 04             	sub    $0x4,%esp
  80043d:	50                   	push   %eax
  80043e:	ff 75 a4             	pushl  -0x5c(%ebp)
  800441:	68 8e 35 80 00       	push   $0x80358e
  800446:	e8 22 08 00 00       	call   800c6d <cprintf>
				exit();
  80044b:	e8 28 07 00 00       	call   800b78 <exit>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	eb aa                	jmp    8003ff <runcmd+0x201>
				cprintf("pipe: %e", r);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	50                   	push   %eax
  800459:	68 a4 35 80 00       	push   $0x8035a4
  80045e:	e8 0a 08 00 00       	call   800c6d <cprintf>
				exit();
  800463:	e8 10 07 00 00       	call   800b78 <exit>
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	e9 89 fe ff ff       	jmp    8002f9 <runcmd+0xfb>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800479:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80047f:	68 ad 35 80 00       	push   $0x8035ad
  800484:	e8 e4 07 00 00       	call   800c6d <cprintf>
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	e9 75 fe ff ff       	jmp    800306 <runcmd+0x108>
				cprintf("fork: %e", r);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	50                   	push   %eax
  800495:	68 ba 35 80 00       	push   $0x8035ba
  80049a:	e8 ce 07 00 00       	call   800c6d <cprintf>
				exit();
  80049f:	e8 d4 06 00 00       	call   800b78 <exit>
  8004a4:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  8004a7:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8004ad:	83 f8 01             	cmp    $0x1,%eax
  8004b0:	75 58                	jne    80050a <runcmd+0x30c>
				close(p[0]);
  8004b2:	83 ec 0c             	sub    $0xc,%esp
  8004b5:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8004bb:	e8 42 1b 00 00       	call   802002 <close>
				goto runit;
  8004c0:	83 c4 10             	add    $0x10,%esp
	if(argc == 0) {
  8004c3:	85 ff                	test   %edi,%edi
  8004c5:	75 73                	jne    80053a <runcmd+0x33c>
		if (debug)
  8004c7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ce:	0f 84 f0 00 00 00    	je     8005c4 <runcmd+0x3c6>
			cprintf("EMPTY COMMAND\n");
  8004d4:	83 ec 0c             	sub    $0xc,%esp
  8004d7:	68 e9 35 80 00       	push   $0x8035e9
  8004dc:	e8 8c 07 00 00       	call   800c6d <cprintf>
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	e9 db 00 00 00       	jmp    8005c4 <runcmd+0x3c6>
					dup(p[0], 0);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	6a 00                	push   $0x0
  8004ee:	50                   	push   %eax
  8004ef:	e8 5e 1b 00 00       	call   802052 <dup>
					close(p[0]);
  8004f4:	83 c4 04             	add    $0x4,%esp
  8004f7:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8004fd:	e8 00 1b 00 00       	call   802002 <close>
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	e9 21 fe ff ff       	jmp    80032b <runcmd+0x12d>
					dup(p[1], 1);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	6a 01                	push   $0x1
  80050f:	50                   	push   %eax
  800510:	e8 3d 1b 00 00       	call   802052 <dup>
					close(p[1]);
  800515:	83 c4 04             	add    $0x4,%esp
  800518:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80051e:	e8 df 1a 00 00       	call   802002 <close>
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	eb 8a                	jmp    8004b2 <runcmd+0x2b4>
			panic("bad return %d from gettoken", c);
  800528:	53                   	push   %ebx
  800529:	68 c3 35 80 00       	push   $0x8035c3
  80052e:	6a 7b                	push   $0x7b
  800530:	68 df 35 80 00       	push   $0x8035df
  800535:	e8 58 06 00 00       	call   800b92 <_panic>
	if (argv[0][0] != '/') {
  80053a:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80053d:	80 38 2f             	cmpb   $0x2f,(%eax)
  800540:	0f 85 86 00 00 00    	jne    8005cc <runcmd+0x3ce>
	argv[argc] = 0;
  800546:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  80054d:	00 
	if (debug) {
  80054e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800555:	0f 85 99 00 00 00    	jne    8005f4 <runcmd+0x3f6>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800561:	50                   	push   %eax
  800562:	ff 75 a8             	pushl  -0x58(%ebp)
  800565:	e8 5c 22 00 00       	call   8027c6 <spawn>
  80056a:	89 c6                	mov    %eax,%esi
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	85 c0                	test   %eax,%eax
  800571:	0f 88 cb 00 00 00    	js     800642 <runcmd+0x444>
	close_all();
  800577:	e8 b1 1a 00 00       	call   80202d <close_all>
		if (debug)
  80057c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800583:	0f 85 06 01 00 00    	jne    80068f <runcmd+0x491>
		wait(r);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 d8 2b 00 00       	call   80316a <wait>
		if (debug)
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059c:	0f 85 0c 01 00 00    	jne    8006ae <runcmd+0x4b0>
	if (pipe_child) {
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	74 19                	je     8005bf <runcmd+0x3c1>
		wait(pipe_child);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	e8 bb 2b 00 00       	call   80316a <wait>
		if (debug)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b9:	0f 85 0a 01 00 00    	jne    8006c9 <runcmd+0x4cb>
	exit();
  8005bf:	e8 b4 05 00 00       	call   800b78 <exit>
}
  8005c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c7:	5b                   	pop    %ebx
  8005c8:	5e                   	pop    %esi
  8005c9:	5f                   	pop    %edi
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    
		argv0buf[0] = '/';
  8005cc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	50                   	push   %eax
  8005d7:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  8005dd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8005e3:	50                   	push   %eax
  8005e4:	e8 b5 0d 00 00       	call   80139e <strcpy>
		argv[0] = argv0buf;
  8005e9:	89 75 a8             	mov    %esi,-0x58(%ebp)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	e9 52 ff ff ff       	jmp    800546 <runcmd+0x348>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8005f4:	a1 24 54 80 00       	mov    0x805424,%eax
  8005f9:	8b 40 48             	mov    0x48(%eax),%eax
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	50                   	push   %eax
  800600:	68 f8 35 80 00       	push   $0x8035f8
  800605:	e8 63 06 00 00       	call   800c6d <cprintf>
  80060a:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	83 c6 04             	add    $0x4,%esi
  800613:	8b 46 fc             	mov    -0x4(%esi),%eax
  800616:	85 c0                	test   %eax,%eax
  800618:	74 13                	je     80062d <runcmd+0x42f>
			cprintf(" %s", argv[i]);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	50                   	push   %eax
  80061e:	68 80 36 80 00       	push   $0x803680
  800623:	e8 45 06 00 00       	call   800c6d <cprintf>
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb e3                	jmp    800610 <runcmd+0x412>
		cprintf("\n");
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	68 40 35 80 00       	push   $0x803540
  800635:	e8 33 06 00 00       	call   800c6d <cprintf>
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	e9 19 ff ff ff       	jmp    80055b <runcmd+0x35d>
		cprintf("spawn %s: %e\n", argv[0], r);
  800642:	83 ec 04             	sub    $0x4,%esp
  800645:	50                   	push   %eax
  800646:	ff 75 a8             	pushl  -0x58(%ebp)
  800649:	68 06 36 80 00       	push   $0x803606
  80064e:	e8 1a 06 00 00       	call   800c6d <cprintf>
	close_all();
  800653:	e8 d5 19 00 00       	call   80202d <close_all>
  800658:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  80065b:	85 db                	test   %ebx,%ebx
  80065d:	0f 84 5c ff ff ff    	je     8005bf <runcmd+0x3c1>
		if (debug)
  800663:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80066a:	0f 84 36 ff ff ff    	je     8005a6 <runcmd+0x3a8>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800670:	a1 24 54 80 00       	mov    0x805424,%eax
  800675:	8b 40 48             	mov    0x48(%eax),%eax
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	53                   	push   %ebx
  80067c:	50                   	push   %eax
  80067d:	68 3f 36 80 00       	push   $0x80363f
  800682:	e8 e6 05 00 00       	call   800c6d <cprintf>
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	e9 17 ff ff ff       	jmp    8005a6 <runcmd+0x3a8>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80068f:	a1 24 54 80 00       	mov    0x805424,%eax
  800694:	8b 40 48             	mov    0x48(%eax),%eax
  800697:	56                   	push   %esi
  800698:	ff 75 a8             	pushl  -0x58(%ebp)
  80069b:	50                   	push   %eax
  80069c:	68 14 36 80 00       	push   $0x803614
  8006a1:	e8 c7 05 00 00       	call   800c6d <cprintf>
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	e9 db fe ff ff       	jmp    800589 <runcmd+0x38b>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8006ae:	a1 24 54 80 00       	mov    0x805424,%eax
  8006b3:	8b 40 48             	mov    0x48(%eax),%eax
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	50                   	push   %eax
  8006ba:	68 29 36 80 00       	push   $0x803629
  8006bf:	e8 a9 05 00 00       	call   800c6d <cprintf>
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 92                	jmp    80065b <runcmd+0x45d>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8006c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8006ce:	8b 40 48             	mov    0x48(%eax),%eax
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	50                   	push   %eax
  8006d5:	68 29 36 80 00       	push   $0x803629
  8006da:	e8 8e 05 00 00       	call   800c6d <cprintf>
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	e9 d8 fe ff ff       	jmp    8005bf <runcmd+0x3c1>

008006e7 <usage>:


void
usage(void)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  8006ed:	68 a8 37 80 00       	push   $0x8037a8
  8006f2:	e8 76 05 00 00       	call   800c6d <cprintf>
	exit();
  8006f7:	e8 7c 04 00 00       	call   800b78 <exit>
}
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <umain>:

void
umain(int argc, char **argv)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	57                   	push   %edi
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
  800707:	83 ec 30             	sub    $0x30,%esp
  80070a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80070d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800710:	50                   	push   %eax
  800711:	57                   	push   %edi
  800712:	8d 45 08             	lea    0x8(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	e8 e8 15 00 00       	call   801d03 <argstart>
	while ((r = argnext(&args)) >= 0)
  80071b:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  80071e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
	interactive = '?';
  800725:	be 3f 00 00 00       	mov    $0x3f,%esi
	while ((r = argnext(&args)) >= 0)
  80072a:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80072d:	eb 07                	jmp    800736 <umain+0x35>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80072f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
	while ((r = argnext(&args)) >= 0)
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	53                   	push   %ebx
  80073a:	e8 f4 15 00 00       	call   801d33 <argnext>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 26                	js     80076c <umain+0x6b>
		switch (r) {
  800746:	83 f8 69             	cmp    $0x69,%eax
  800749:	74 1a                	je     800765 <umain+0x64>
  80074b:	83 f8 78             	cmp    $0x78,%eax
  80074e:	74 df                	je     80072f <umain+0x2e>
  800750:	83 f8 64             	cmp    $0x64,%eax
  800753:	74 07                	je     80075c <umain+0x5b>
			break;
		default:
			usage();
  800755:	e8 8d ff ff ff       	call   8006e7 <usage>
  80075a:	eb da                	jmp    800736 <umain+0x35>
			debug++;
  80075c:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800763:	eb d1                	jmp    800736 <umain+0x35>
			interactive = 1;
  800765:	be 01 00 00 00       	mov    $0x1,%esi
  80076a:	eb ca                	jmp    800736 <umain+0x35>
		}

	if (argc > 2)
  80076c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800770:	7f 07                	jg     800779 <umain+0x78>
	interactive = '?';
  800772:	bb 00 00 00 00       	mov    $0x0,%ebx
  800777:	eb 2a                	jmp    8007a3 <umain+0xa2>
		usage();
  800779:	e8 69 ff ff ff       	call   8006e7 <usage>
  80077e:	eb f2                	jmp    800772 <umain+0x71>
    for (int i = 0; i < argc; i++) {
        cprintf("[%08x] ------------- sh_umain_%x_%s_%d_%c  \n", thisenv->env_id, i, argv[i], argc, interactive);
  800780:	8b 15 24 54 80 00    	mov    0x805424,%edx
  800786:	8b 52 48             	mov    0x48(%edx),%edx
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	56                   	push   %esi
  80078d:	50                   	push   %eax
  80078e:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800791:	53                   	push   %ebx
  800792:	52                   	push   %edx
  800793:	68 cc 37 80 00       	push   $0x8037cc
  800798:	e8 d0 04 00 00       	call   800c6d <cprintf>
    for (int i = 0; i < argc; i++) {
  80079d:	83 c3 01             	add    $0x1,%ebx
  8007a0:	83 c4 20             	add    $0x20,%esp
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	39 d8                	cmp    %ebx,%eax
  8007a8:	7f d6                	jg     800780 <umain+0x7f>
    }
	if (argc == 2) {
  8007aa:	83 f8 02             	cmp    $0x2,%eax
  8007ad:	74 1c                	je     8007cb <umain+0xca>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  8007af:	83 fe 3f             	cmp    $0x3f,%esi
  8007b2:	74 6d                	je     800821 <umain+0x120>
  8007b4:	85 f6                	test   %esi,%esi
  8007b6:	ba 84 36 80 00       	mov    $0x803684,%edx
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	0f 45 c2             	cmovne %edx,%eax
  8007c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007c6:	e9 1d 01 00 00       	jmp    8008e8 <umain+0x1e7>
		close(0);
  8007cb:	83 ec 0c             	sub    $0xc,%esp
  8007ce:	6a 00                	push   $0x0
  8007d0:	e8 2d 18 00 00       	call   802002 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8007d5:	83 c4 08             	add    $0x8,%esp
  8007d8:	6a 00                	push   $0x0
  8007da:	ff 77 04             	pushl  0x4(%edi)
  8007dd:	e8 c1 1d 00 00       	call   8025a3 <open>
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 1d                	js     800806 <umain+0x105>
		assert(r == 0);
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	74 c2                	je     8007af <umain+0xae>
  8007ed:	68 68 36 80 00       	push   $0x803668
  8007f2:	68 6f 36 80 00       	push   $0x80366f
  8007f7:	68 2f 01 00 00       	push   $0x12f
  8007fc:	68 df 35 80 00       	push   $0x8035df
  800801:	e8 8c 03 00 00       	call   800b92 <_panic>
			panic("open %s: %e", argv[1], r);
  800806:	83 ec 0c             	sub    $0xc,%esp
  800809:	50                   	push   %eax
  80080a:	ff 77 04             	pushl  0x4(%edi)
  80080d:	68 5c 36 80 00       	push   $0x80365c
  800812:	68 2e 01 00 00       	push   $0x12e
  800817:	68 df 35 80 00       	push   $0x8035df
  80081c:	e8 71 03 00 00       	call   800b92 <_panic>
		interactive = iscons(0);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	6a 00                	push   $0x0
  800826:	e8 89 02 00 00       	call   800ab4 <iscons>
  80082b:	89 c6                	mov    %eax,%esi
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	eb 82                	jmp    8007b4 <umain+0xb3>

		buf = readline(interactive ? "$ " : NULL);
        cprintf("[%08x] -------------  sh_umain_%d_%s 2 \n", thisenv->env_id, interactive, buf);
        cprintf("[%08x] -------------  sh_umain 3 ref=%x \n", thisenv->env_id, pageref((void *)0xd0002000));
		if (buf == NULL) {
			if (debug)
  800832:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800839:	75 23                	jne    80085e <umain+0x15d>
				cprintf("EXITING\n");
            cprintf("[%08x] -------------  sh_umain_%d_%s 4 \n", thisenv->env_id, interactive, buf);
  80083b:	a1 24 54 80 00       	mov    0x805424,%eax
  800840:	8b 40 48             	mov    0x48(%eax),%eax
  800843:	6a 00                	push   $0x0
  800845:	56                   	push   %esi
  800846:	50                   	push   %eax
  800847:	68 54 38 80 00       	push   $0x803854
  80084c:	e8 1c 04 00 00       	call   800c6d <cprintf>
			exit();	// end of file
  800851:	e8 22 03 00 00       	call   800b78 <exit>
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	e9 dc 00 00 00       	jmp    80093a <umain+0x239>
				cprintf("EXITING\n");
  80085e:	83 ec 0c             	sub    $0xc,%esp
  800861:	68 87 36 80 00       	push   $0x803687
  800866:	e8 02 04 00 00       	call   800c6d <cprintf>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	eb cb                	jmp    80083b <umain+0x13a>
		}
        cprintf("[%08x] -------------  sh_umain_%d_%s 5 \n", thisenv->env_id, interactive, buf);
		if (debug)
			cprintf("LINE: %s\n", buf);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	68 90 36 80 00       	push   $0x803690
  800879:	e8 ef 03 00 00       	call   800c6d <cprintf>
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	e9 d9 00 00 00       	jmp    80095f <umain+0x25e>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	68 9a 36 80 00       	push   $0x80369a
  80088f:	e8 e1 1e 00 00       	call   802775 <printf>
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	e9 d2 00 00 00       	jmp    80096e <umain+0x26d>
		if (debug)
			cprintf("BEFORE FORK\n");
  80089c:	83 ec 0c             	sub    $0xc,%esp
  80089f:	68 a0 36 80 00       	push   $0x8036a0
  8008a4:	e8 c4 03 00 00       	call   800c6d <cprintf>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	e9 ca 00 00 00       	jmp    80097b <umain+0x27a>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8008b1:	50                   	push   %eax
  8008b2:	68 ba 35 80 00       	push   $0x8035ba
  8008b7:	68 4a 01 00 00       	push   $0x14a
  8008bc:	68 df 35 80 00       	push   $0x8035df
  8008c1:	e8 cc 02 00 00       	call   800b92 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	50                   	push   %eax
  8008ca:	68 ad 36 80 00       	push   $0x8036ad
  8008cf:	e8 99 03 00 00       	call   800c6d <cprintf>
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	e9 bb 00 00 00       	jmp    800997 <umain+0x296>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  8008dc:	83 ec 0c             	sub    $0xc,%esp
  8008df:	57                   	push   %edi
  8008e0:	e8 85 28 00 00       	call   80316a <wait>
  8008e5:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  8008e8:	83 ec 0c             	sub    $0xc,%esp
  8008eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8008ee:	e8 62 09 00 00       	call   801255 <readline>
  8008f3:	89 c3                	mov    %eax,%ebx
        cprintf("[%08x] -------------  sh_umain_%d_%s 2 \n", thisenv->env_id, interactive, buf);
  8008f5:	a1 24 54 80 00       	mov    0x805424,%eax
  8008fa:	8b 40 48             	mov    0x48(%eax),%eax
  8008fd:	53                   	push   %ebx
  8008fe:	56                   	push   %esi
  8008ff:	50                   	push   %eax
  800900:	68 fc 37 80 00       	push   $0x8037fc
  800905:	e8 63 03 00 00       	call   800c6d <cprintf>
        cprintf("[%08x] -------------  sh_umain 3 ref=%x \n", thisenv->env_id, pageref((void *)0xd0002000));
  80090a:	83 c4 14             	add    $0x14,%esp
  80090d:	68 00 20 00 d0       	push   $0xd0002000
  800912:	e8 74 1e 00 00       	call   80278b <pageref>
  800917:	8b 15 24 54 80 00    	mov    0x805424,%edx
  80091d:	8b 52 48             	mov    0x48(%edx),%edx
  800920:	83 c4 0c             	add    $0xc,%esp
  800923:	50                   	push   %eax
  800924:	52                   	push   %edx
  800925:	68 28 38 80 00       	push   $0x803828
  80092a:	e8 3e 03 00 00       	call   800c6d <cprintf>
		if (buf == NULL) {
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	85 db                	test   %ebx,%ebx
  800934:	0f 84 f8 fe ff ff    	je     800832 <umain+0x131>
        cprintf("[%08x] -------------  sh_umain_%d_%s 5 \n", thisenv->env_id, interactive, buf);
  80093a:	a1 24 54 80 00       	mov    0x805424,%eax
  80093f:	8b 40 48             	mov    0x48(%eax),%eax
  800942:	53                   	push   %ebx
  800943:	56                   	push   %esi
  800944:	50                   	push   %eax
  800945:	68 80 38 80 00       	push   $0x803880
  80094a:	e8 1e 03 00 00       	call   800c6d <cprintf>
		if (debug)
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800959:	0f 85 11 ff ff ff    	jne    800870 <umain+0x16f>
		if (buf[0] == '#')
  80095f:	80 3b 23             	cmpb   $0x23,(%ebx)
  800962:	74 84                	je     8008e8 <umain+0x1e7>
		if (echocmds)
  800964:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800968:	0f 85 18 ff ff ff    	jne    800886 <umain+0x185>
		if (debug)
  80096e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800975:	0f 85 21 ff ff ff    	jne    80089c <umain+0x19b>
		if ((r = fork()) < 0)
  80097b:	e8 0e 12 00 00       	call   801b8e <fork>
  800980:	89 c7                	mov    %eax,%edi
  800982:	85 c0                	test   %eax,%eax
  800984:	0f 88 27 ff ff ff    	js     8008b1 <umain+0x1b0>
		if (debug)
  80098a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800991:	0f 85 2f ff ff ff    	jne    8008c6 <umain+0x1c5>
		if (r == 0) {
  800997:	85 ff                	test   %edi,%edi
  800999:	0f 85 3d ff ff ff    	jne    8008dc <umain+0x1db>
			runcmd(buf);
  80099f:	83 ec 0c             	sub    $0xc,%esp
  8009a2:	53                   	push   %ebx
  8009a3:	e8 56 f8 ff ff       	call   8001fe <runcmd>
			exit();
  8009a8:	e8 cb 01 00 00       	call   800b78 <exit>
  8009ad:	83 c4 10             	add    $0x10,%esp
  8009b0:	e9 33 ff ff ff       	jmp    8008e8 <umain+0x1e7>

008009b5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8009c5:	68 a9 38 80 00       	push   $0x8038a9
  8009ca:	ff 75 0c             	pushl  0xc(%ebp)
  8009cd:	e8 cc 09 00 00       	call   80139e <strcpy>
	return 0;
}
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devcons_write>:
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8009e5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8009ea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8009f0:	eb 2f                	jmp    800a21 <devcons_write+0x48>
		m = n - tot;
  8009f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009f5:	29 f3                	sub    %esi,%ebx
  8009f7:	83 fb 7f             	cmp    $0x7f,%ebx
  8009fa:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8009ff:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	53                   	push   %ebx
  800a06:	89 f0                	mov    %esi,%eax
  800a08:	03 45 0c             	add    0xc(%ebp),%eax
  800a0b:	50                   	push   %eax
  800a0c:	57                   	push   %edi
  800a0d:	e8 1a 0b 00 00       	call   80152c <memmove>
		sys_cputs(buf, m);
  800a12:	83 c4 08             	add    $0x8,%esp
  800a15:	53                   	push   %ebx
  800a16:	57                   	push   %edi
  800a17:	e8 bf 0c 00 00       	call   8016db <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800a1c:	01 de                	add    %ebx,%esi
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	3b 75 10             	cmp    0x10(%ebp),%esi
  800a24:	72 cc                	jb     8009f2 <devcons_write+0x19>
}
  800a26:	89 f0                	mov    %esi,%eax
  800a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <devcons_read>:
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800a3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a3f:	75 07                	jne    800a48 <devcons_read+0x18>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    
		sys_yield();
  800a43:	e8 30 0d 00 00       	call   801778 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800a48:	e8 ac 0c 00 00       	call   8016f9 <sys_cgetc>
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 f2                	je     800a43 <devcons_read+0x13>
	if (c < 0)
  800a51:	85 c0                	test   %eax,%eax
  800a53:	78 ec                	js     800a41 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800a55:	83 f8 04             	cmp    $0x4,%eax
  800a58:	74 0c                	je     800a66 <devcons_read+0x36>
	*(char*)vbuf = c;
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	88 02                	mov    %al,(%edx)
	return 1;
  800a5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800a64:	eb db                	jmp    800a41 <devcons_read+0x11>
		return 0;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	eb d4                	jmp    800a41 <devcons_read+0x11>

00800a6d <cputchar>:
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800a79:	6a 01                	push   $0x1
  800a7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800a7e:	50                   	push   %eax
  800a7f:	e8 57 0c 00 00       	call   8016db <sys_cputs>
}
  800a84:	83 c4 10             	add    $0x10,%esp
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <getchar>:
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800a8f:	6a 01                	push   $0x1
  800a91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800a94:	50                   	push   %eax
  800a95:	6a 00                	push   $0x0
  800a97:	e8 a2 16 00 00       	call   80213e <read>
	if (r < 0)
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	78 08                	js     800aab <getchar+0x22>
	if (r < 1)
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	7e 06                	jle    800aad <getchar+0x24>
	return c;
  800aa7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    
		return -E_EOF;
  800aad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800ab2:	eb f7                	jmp    800aab <getchar+0x22>

00800ab4 <iscons>:
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abd:	50                   	push   %eax
  800abe:	ff 75 08             	pushl  0x8(%ebp)
  800ac1:	e8 07 14 00 00       	call   801ecd <fd_lookup>
  800ac6:	83 c4 10             	add    $0x10,%esp
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 11                	js     800ade <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800ad6:	39 10                	cmp    %edx,(%eax)
  800ad8:	0f 94 c0             	sete   %al
  800adb:	0f b6 c0             	movzbl %al,%eax
}
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <opencons>:
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae9:	50                   	push   %eax
  800aea:	e8 8f 13 00 00       	call   801e7e <fd_alloc>
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 3a                	js     800b30 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800af6:	83 ec 04             	sub    $0x4,%esp
  800af9:	68 07 04 00 00       	push   $0x407
  800afe:	ff 75 f4             	pushl  -0xc(%ebp)
  800b01:	6a 00                	push   $0x0
  800b03:	e8 8f 0c 00 00       	call   801797 <sys_page_alloc>
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	78 21                	js     800b30 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b12:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800b18:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b1d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	50                   	push   %eax
  800b28:	e8 2a 13 00 00       	call   801e57 <fd2num>
  800b2d:	83 c4 10             	add    $0x10,%esp
}
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b3a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800b3d:	e8 17 0c 00 00       	call   801759 <sys_getenvid>
  800b42:	25 ff 03 00 00       	and    $0x3ff,%eax
  800b47:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800b4a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800b4f:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800b54:	85 db                	test   %ebx,%ebx
  800b56:	7e 07                	jle    800b5f <libmain+0x2d>
		binaryname = argv[0];
  800b58:	8b 06                	mov    (%esi),%eax
  800b5a:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	e8 98 fb ff ff       	call   800701 <umain>

	// exit gracefully
	exit();
  800b69:	e8 0a 00 00 00       	call   800b78 <exit>
}
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800b7e:	e8 aa 14 00 00       	call   80202d <close_all>
	sys_env_destroy(0);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	6a 00                	push   $0x0
  800b88:	e8 8b 0b 00 00       	call   801718 <sys_env_destroy>
}
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b97:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b9a:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800ba0:	e8 b4 0b 00 00       	call   801759 <sys_getenvid>
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	ff 75 0c             	pushl  0xc(%ebp)
  800bab:	ff 75 08             	pushl  0x8(%ebp)
  800bae:	56                   	push   %esi
  800baf:	50                   	push   %eax
  800bb0:	68 c0 38 80 00       	push   $0x8038c0
  800bb5:	e8 b3 00 00 00       	call   800c6d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bba:	83 c4 18             	add    $0x18,%esp
  800bbd:	53                   	push   %ebx
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	e8 56 00 00 00       	call   800c1c <vcprintf>
	cprintf("\n");
  800bc6:	c7 04 24 40 35 80 00 	movl   $0x803540,(%esp)
  800bcd:	e8 9b 00 00 00       	call   800c6d <cprintf>
  800bd2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bd5:	cc                   	int3   
  800bd6:	eb fd                	jmp    800bd5 <_panic+0x43>

00800bd8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 04             	sub    $0x4,%esp
  800bdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800be2:	8b 13                	mov    (%ebx),%edx
  800be4:	8d 42 01             	lea    0x1(%edx),%eax
  800be7:	89 03                	mov    %eax,(%ebx)
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800bf0:	3d ff 00 00 00       	cmp    $0xff,%eax
  800bf5:	74 09                	je     800c00 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800bf7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800bfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800c00:	83 ec 08             	sub    $0x8,%esp
  800c03:	68 ff 00 00 00       	push   $0xff
  800c08:	8d 43 08             	lea    0x8(%ebx),%eax
  800c0b:	50                   	push   %eax
  800c0c:	e8 ca 0a 00 00       	call   8016db <sys_cputs>
		b->idx = 0;
  800c11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	eb db                	jmp    800bf7 <putch+0x1f>

00800c1c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800c25:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800c2c:	00 00 00 
	b.cnt = 0;
  800c2f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800c36:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	ff 75 08             	pushl  0x8(%ebp)
  800c3f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800c45:	50                   	push   %eax
  800c46:	68 d8 0b 80 00       	push   $0x800bd8
  800c4b:	e8 1a 01 00 00       	call   800d6a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800c50:	83 c4 08             	add    $0x8,%esp
  800c53:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800c59:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800c5f:	50                   	push   %eax
  800c60:	e8 76 0a 00 00       	call   8016db <sys_cputs>

	return b.cnt;
}
  800c65:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800c73:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800c76:	50                   	push   %eax
  800c77:	ff 75 08             	pushl  0x8(%ebp)
  800c7a:	e8 9d ff ff ff       	call   800c1c <vcprintf>
	va_end(ap);

	return cnt;
}
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 1c             	sub    $0x1c,%esp
  800c8a:	89 c7                	mov    %eax,%edi
  800c8c:	89 d6                	mov    %edx,%esi
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c94:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c97:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ca5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800ca8:	39 d3                	cmp    %edx,%ebx
  800caa:	72 05                	jb     800cb1 <printnum+0x30>
  800cac:	39 45 10             	cmp    %eax,0x10(%ebp)
  800caf:	77 7a                	ja     800d2b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	ff 75 18             	pushl  0x18(%ebp)
  800cb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800cbd:	53                   	push   %ebx
  800cbe:	ff 75 10             	pushl  0x10(%ebp)
  800cc1:	83 ec 08             	sub    $0x8,%esp
  800cc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800cca:	ff 75 dc             	pushl  -0x24(%ebp)
  800ccd:	ff 75 d8             	pushl  -0x28(%ebp)
  800cd0:	e8 fb 25 00 00       	call   8032d0 <__udivdi3>
  800cd5:	83 c4 18             	add    $0x18,%esp
  800cd8:	52                   	push   %edx
  800cd9:	50                   	push   %eax
  800cda:	89 f2                	mov    %esi,%edx
  800cdc:	89 f8                	mov    %edi,%eax
  800cde:	e8 9e ff ff ff       	call   800c81 <printnum>
  800ce3:	83 c4 20             	add    $0x20,%esp
  800ce6:	eb 13                	jmp    800cfb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	56                   	push   %esi
  800cec:	ff 75 18             	pushl  0x18(%ebp)
  800cef:	ff d7                	call   *%edi
  800cf1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800cf4:	83 eb 01             	sub    $0x1,%ebx
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	7f ed                	jg     800ce8 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cfb:	83 ec 08             	sub    $0x8,%esp
  800cfe:	56                   	push   %esi
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d05:	ff 75 e0             	pushl  -0x20(%ebp)
  800d08:	ff 75 dc             	pushl  -0x24(%ebp)
  800d0b:	ff 75 d8             	pushl  -0x28(%ebp)
  800d0e:	e8 dd 26 00 00       	call   8033f0 <__umoddi3>
  800d13:	83 c4 14             	add    $0x14,%esp
  800d16:	0f be 80 e3 38 80 00 	movsbl 0x8038e3(%eax),%eax
  800d1d:	50                   	push   %eax
  800d1e:	ff d7                	call   *%edi
}
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    
  800d2b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800d2e:	eb c4                	jmp    800cf4 <printnum+0x73>

00800d30 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800d36:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800d3a:	8b 10                	mov    (%eax),%edx
  800d3c:	3b 50 04             	cmp    0x4(%eax),%edx
  800d3f:	73 0a                	jae    800d4b <sprintputch+0x1b>
		*b->buf++ = ch;
  800d41:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d44:	89 08                	mov    %ecx,(%eax)
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	88 02                	mov    %al,(%edx)
}
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <printfmt>:
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800d53:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800d56:	50                   	push   %eax
  800d57:	ff 75 10             	pushl  0x10(%ebp)
  800d5a:	ff 75 0c             	pushl  0xc(%ebp)
  800d5d:	ff 75 08             	pushl  0x8(%ebp)
  800d60:	e8 05 00 00 00       	call   800d6a <vprintfmt>
}
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <vprintfmt>:
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
  800d73:	8b 75 08             	mov    0x8(%ebp),%esi
  800d76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d79:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d7c:	e9 c1 03 00 00       	jmp    801142 <vprintfmt+0x3d8>
		padc = ' ';
  800d81:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800d8c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800d93:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d9f:	8d 47 01             	lea    0x1(%edi),%eax
  800da2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800da5:	0f b6 17             	movzbl (%edi),%edx
  800da8:	8d 42 dd             	lea    -0x23(%edx),%eax
  800dab:	3c 55                	cmp    $0x55,%al
  800dad:	0f 87 12 04 00 00    	ja     8011c5 <vprintfmt+0x45b>
  800db3:	0f b6 c0             	movzbl %al,%eax
  800db6:	ff 24 85 20 3a 80 00 	jmp    *0x803a20(,%eax,4)
  800dbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800dc0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800dc4:	eb d9                	jmp    800d9f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800dc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800dc9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800dcd:	eb d0                	jmp    800d9f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800dcf:	0f b6 d2             	movzbl %dl,%edx
  800dd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800ddd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800de0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800de4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800de7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800dea:	83 f9 09             	cmp    $0x9,%ecx
  800ded:	77 55                	ja     800e44 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800def:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800df2:	eb e9                	jmp    800ddd <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800df4:	8b 45 14             	mov    0x14(%ebp),%eax
  800df7:	8b 00                	mov    (%eax),%eax
  800df9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800dfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dff:	8d 40 04             	lea    0x4(%eax),%eax
  800e02:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800e05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800e08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e0c:	79 91                	jns    800d9f <vprintfmt+0x35>
				width = precision, precision = -1;
  800e0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e14:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800e1b:	eb 82                	jmp    800d9f <vprintfmt+0x35>
  800e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e20:	85 c0                	test   %eax,%eax
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	0f 49 d0             	cmovns %eax,%edx
  800e2a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800e2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e30:	e9 6a ff ff ff       	jmp    800d9f <vprintfmt+0x35>
  800e35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800e38:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800e3f:	e9 5b ff ff ff       	jmp    800d9f <vprintfmt+0x35>
  800e44:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e47:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800e4a:	eb bc                	jmp    800e08 <vprintfmt+0x9e>
			lflag++;
  800e4c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800e52:	e9 48 ff ff ff       	jmp    800d9f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800e57:	8b 45 14             	mov    0x14(%ebp),%eax
  800e5a:	8d 78 04             	lea    0x4(%eax),%edi
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	53                   	push   %ebx
  800e61:	ff 30                	pushl  (%eax)
  800e63:	ff d6                	call   *%esi
			break;
  800e65:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800e68:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800e6b:	e9 cf 02 00 00       	jmp    80113f <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800e70:	8b 45 14             	mov    0x14(%ebp),%eax
  800e73:	8d 78 04             	lea    0x4(%eax),%edi
  800e76:	8b 00                	mov    (%eax),%eax
  800e78:	99                   	cltd   
  800e79:	31 d0                	xor    %edx,%eax
  800e7b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800e7d:	83 f8 0f             	cmp    $0xf,%eax
  800e80:	7f 23                	jg     800ea5 <vprintfmt+0x13b>
  800e82:	8b 14 85 80 3b 80 00 	mov    0x803b80(,%eax,4),%edx
  800e89:	85 d2                	test   %edx,%edx
  800e8b:	74 18                	je     800ea5 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800e8d:	52                   	push   %edx
  800e8e:	68 81 36 80 00       	push   $0x803681
  800e93:	53                   	push   %ebx
  800e94:	56                   	push   %esi
  800e95:	e8 b3 fe ff ff       	call   800d4d <printfmt>
  800e9a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800e9d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800ea0:	e9 9a 02 00 00       	jmp    80113f <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800ea5:	50                   	push   %eax
  800ea6:	68 fb 38 80 00       	push   $0x8038fb
  800eab:	53                   	push   %ebx
  800eac:	56                   	push   %esi
  800ead:	e8 9b fe ff ff       	call   800d4d <printfmt>
  800eb2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800eb5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800eb8:	e9 82 02 00 00       	jmp    80113f <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec0:	83 c0 04             	add    $0x4,%eax
  800ec3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ec6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ecb:	85 ff                	test   %edi,%edi
  800ecd:	b8 f4 38 80 00       	mov    $0x8038f4,%eax
  800ed2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800ed5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ed9:	0f 8e bd 00 00 00    	jle    800f9c <vprintfmt+0x232>
  800edf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800ee3:	75 0e                	jne    800ef3 <vprintfmt+0x189>
  800ee5:	89 75 08             	mov    %esi,0x8(%ebp)
  800ee8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800eeb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800eee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ef1:	eb 6d                	jmp    800f60 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	ff 75 d0             	pushl  -0x30(%ebp)
  800ef9:	57                   	push   %edi
  800efa:	e8 80 04 00 00       	call   80137f <strnlen>
  800eff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f02:	29 c1                	sub    %eax,%ecx
  800f04:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800f07:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800f0a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800f0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f11:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f14:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800f16:	eb 0f                	jmp    800f27 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800f18:	83 ec 08             	sub    $0x8,%esp
  800f1b:	53                   	push   %ebx
  800f1c:	ff 75 e0             	pushl  -0x20(%ebp)
  800f1f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800f21:	83 ef 01             	sub    $0x1,%edi
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 ff                	test   %edi,%edi
  800f29:	7f ed                	jg     800f18 <vprintfmt+0x1ae>
  800f2b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800f2e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800f31:	85 c9                	test   %ecx,%ecx
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
  800f38:	0f 49 c1             	cmovns %ecx,%eax
  800f3b:	29 c1                	sub    %eax,%ecx
  800f3d:	89 75 08             	mov    %esi,0x8(%ebp)
  800f40:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800f43:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800f46:	89 cb                	mov    %ecx,%ebx
  800f48:	eb 16                	jmp    800f60 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800f4a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f4e:	75 31                	jne    800f81 <vprintfmt+0x217>
					putch(ch, putdat);
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	ff 75 0c             	pushl  0xc(%ebp)
  800f56:	50                   	push   %eax
  800f57:	ff 55 08             	call   *0x8(%ebp)
  800f5a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f5d:	83 eb 01             	sub    $0x1,%ebx
  800f60:	83 c7 01             	add    $0x1,%edi
  800f63:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800f67:	0f be c2             	movsbl %dl,%eax
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	74 59                	je     800fc7 <vprintfmt+0x25d>
  800f6e:	85 f6                	test   %esi,%esi
  800f70:	78 d8                	js     800f4a <vprintfmt+0x1e0>
  800f72:	83 ee 01             	sub    $0x1,%esi
  800f75:	79 d3                	jns    800f4a <vprintfmt+0x1e0>
  800f77:	89 df                	mov    %ebx,%edi
  800f79:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f7f:	eb 37                	jmp    800fb8 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800f81:	0f be d2             	movsbl %dl,%edx
  800f84:	83 ea 20             	sub    $0x20,%edx
  800f87:	83 fa 5e             	cmp    $0x5e,%edx
  800f8a:	76 c4                	jbe    800f50 <vprintfmt+0x1e6>
					putch('?', putdat);
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	ff 75 0c             	pushl  0xc(%ebp)
  800f92:	6a 3f                	push   $0x3f
  800f94:	ff 55 08             	call   *0x8(%ebp)
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	eb c1                	jmp    800f5d <vprintfmt+0x1f3>
  800f9c:	89 75 08             	mov    %esi,0x8(%ebp)
  800f9f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800fa2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800fa5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800fa8:	eb b6                	jmp    800f60 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	53                   	push   %ebx
  800fae:	6a 20                	push   $0x20
  800fb0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800fb2:	83 ef 01             	sub    $0x1,%edi
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 ff                	test   %edi,%edi
  800fba:	7f ee                	jg     800faa <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800fbc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fbf:	89 45 14             	mov    %eax,0x14(%ebp)
  800fc2:	e9 78 01 00 00       	jmp    80113f <vprintfmt+0x3d5>
  800fc7:	89 df                	mov    %ebx,%edi
  800fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fcf:	eb e7                	jmp    800fb8 <vprintfmt+0x24e>
	if (lflag >= 2)
  800fd1:	83 f9 01             	cmp    $0x1,%ecx
  800fd4:	7e 3f                	jle    801015 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800fd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd9:	8b 50 04             	mov    0x4(%eax),%edx
  800fdc:	8b 00                	mov    (%eax),%eax
  800fde:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fe1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800fe4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe7:	8d 40 08             	lea    0x8(%eax),%eax
  800fea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800fed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ff1:	79 5c                	jns    80104f <vprintfmt+0x2e5>
				putch('-', putdat);
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	53                   	push   %ebx
  800ff7:	6a 2d                	push   $0x2d
  800ff9:	ff d6                	call   *%esi
				num = -(long long) num;
  800ffb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ffe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801001:	f7 da                	neg    %edx
  801003:	83 d1 00             	adc    $0x0,%ecx
  801006:	f7 d9                	neg    %ecx
  801008:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80100b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801010:	e9 10 01 00 00       	jmp    801125 <vprintfmt+0x3bb>
	else if (lflag)
  801015:	85 c9                	test   %ecx,%ecx
  801017:	75 1b                	jne    801034 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801019:	8b 45 14             	mov    0x14(%ebp),%eax
  80101c:	8b 00                	mov    (%eax),%eax
  80101e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801021:	89 c1                	mov    %eax,%ecx
  801023:	c1 f9 1f             	sar    $0x1f,%ecx
  801026:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801029:	8b 45 14             	mov    0x14(%ebp),%eax
  80102c:	8d 40 04             	lea    0x4(%eax),%eax
  80102f:	89 45 14             	mov    %eax,0x14(%ebp)
  801032:	eb b9                	jmp    800fed <vprintfmt+0x283>
		return va_arg(*ap, long);
  801034:	8b 45 14             	mov    0x14(%ebp),%eax
  801037:	8b 00                	mov    (%eax),%eax
  801039:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80103c:	89 c1                	mov    %eax,%ecx
  80103e:	c1 f9 1f             	sar    $0x1f,%ecx
  801041:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801044:	8b 45 14             	mov    0x14(%ebp),%eax
  801047:	8d 40 04             	lea    0x4(%eax),%eax
  80104a:	89 45 14             	mov    %eax,0x14(%ebp)
  80104d:	eb 9e                	jmp    800fed <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80104f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801052:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801055:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105a:	e9 c6 00 00 00       	jmp    801125 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80105f:	83 f9 01             	cmp    $0x1,%ecx
  801062:	7e 18                	jle    80107c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801064:	8b 45 14             	mov    0x14(%ebp),%eax
  801067:	8b 10                	mov    (%eax),%edx
  801069:	8b 48 04             	mov    0x4(%eax),%ecx
  80106c:	8d 40 08             	lea    0x8(%eax),%eax
  80106f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801072:	b8 0a 00 00 00       	mov    $0xa,%eax
  801077:	e9 a9 00 00 00       	jmp    801125 <vprintfmt+0x3bb>
	else if (lflag)
  80107c:	85 c9                	test   %ecx,%ecx
  80107e:	75 1a                	jne    80109a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801080:	8b 45 14             	mov    0x14(%ebp),%eax
  801083:	8b 10                	mov    (%eax),%edx
  801085:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108a:	8d 40 04             	lea    0x4(%eax),%eax
  80108d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801090:	b8 0a 00 00 00       	mov    $0xa,%eax
  801095:	e9 8b 00 00 00       	jmp    801125 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80109a:	8b 45 14             	mov    0x14(%ebp),%eax
  80109d:	8b 10                	mov    (%eax),%edx
  80109f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a4:	8d 40 04             	lea    0x4(%eax),%eax
  8010a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8010aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010af:	eb 74                	jmp    801125 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8010b1:	83 f9 01             	cmp    $0x1,%ecx
  8010b4:	7e 15                	jle    8010cb <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8010b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8010b9:	8b 10                	mov    (%eax),%edx
  8010bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8010be:	8d 40 08             	lea    0x8(%eax),%eax
  8010c1:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8010c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8010c9:	eb 5a                	jmp    801125 <vprintfmt+0x3bb>
	else if (lflag)
  8010cb:	85 c9                	test   %ecx,%ecx
  8010cd:	75 17                	jne    8010e6 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8010cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d2:	8b 10                	mov    (%eax),%edx
  8010d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d9:	8d 40 04             	lea    0x4(%eax),%eax
  8010dc:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8010df:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e4:	eb 3f                	jmp    801125 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8010e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e9:	8b 10                	mov    (%eax),%edx
  8010eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f0:	8d 40 04             	lea    0x4(%eax),%eax
  8010f3:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8010f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8010fb:	eb 28                	jmp    801125 <vprintfmt+0x3bb>
			putch('0', putdat);
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	53                   	push   %ebx
  801101:	6a 30                	push   $0x30
  801103:	ff d6                	call   *%esi
			putch('x', putdat);
  801105:	83 c4 08             	add    $0x8,%esp
  801108:	53                   	push   %ebx
  801109:	6a 78                	push   $0x78
  80110b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80110d:	8b 45 14             	mov    0x14(%ebp),%eax
  801110:	8b 10                	mov    (%eax),%edx
  801112:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801117:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80111a:	8d 40 04             	lea    0x4(%eax),%eax
  80111d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801120:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80112c:	57                   	push   %edi
  80112d:	ff 75 e0             	pushl  -0x20(%ebp)
  801130:	50                   	push   %eax
  801131:	51                   	push   %ecx
  801132:	52                   	push   %edx
  801133:	89 da                	mov    %ebx,%edx
  801135:	89 f0                	mov    %esi,%eax
  801137:	e8 45 fb ff ff       	call   800c81 <printnum>
			break;
  80113c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80113f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801142:	83 c7 01             	add    $0x1,%edi
  801145:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801149:	83 f8 25             	cmp    $0x25,%eax
  80114c:	0f 84 2f fc ff ff    	je     800d81 <vprintfmt+0x17>
			if (ch == '\0')
  801152:	85 c0                	test   %eax,%eax
  801154:	0f 84 8b 00 00 00    	je     8011e5 <vprintfmt+0x47b>
			putch(ch, putdat);
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	53                   	push   %ebx
  80115e:	50                   	push   %eax
  80115f:	ff d6                	call   *%esi
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	eb dc                	jmp    801142 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801166:	83 f9 01             	cmp    $0x1,%ecx
  801169:	7e 15                	jle    801180 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80116b:	8b 45 14             	mov    0x14(%ebp),%eax
  80116e:	8b 10                	mov    (%eax),%edx
  801170:	8b 48 04             	mov    0x4(%eax),%ecx
  801173:	8d 40 08             	lea    0x8(%eax),%eax
  801176:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801179:	b8 10 00 00 00       	mov    $0x10,%eax
  80117e:	eb a5                	jmp    801125 <vprintfmt+0x3bb>
	else if (lflag)
  801180:	85 c9                	test   %ecx,%ecx
  801182:	75 17                	jne    80119b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801184:	8b 45 14             	mov    0x14(%ebp),%eax
  801187:	8b 10                	mov    (%eax),%edx
  801189:	b9 00 00 00 00       	mov    $0x0,%ecx
  80118e:	8d 40 04             	lea    0x4(%eax),%eax
  801191:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801194:	b8 10 00 00 00       	mov    $0x10,%eax
  801199:	eb 8a                	jmp    801125 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80119b:	8b 45 14             	mov    0x14(%ebp),%eax
  80119e:	8b 10                	mov    (%eax),%edx
  8011a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a5:	8d 40 04             	lea    0x4(%eax),%eax
  8011a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8011ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8011b0:	e9 70 ff ff ff       	jmp    801125 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	53                   	push   %ebx
  8011b9:	6a 25                	push   $0x25
  8011bb:	ff d6                	call   *%esi
			break;
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	e9 7a ff ff ff       	jmp    80113f <vprintfmt+0x3d5>
			putch('%', putdat);
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	53                   	push   %ebx
  8011c9:	6a 25                	push   $0x25
  8011cb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	89 f8                	mov    %edi,%eax
  8011d2:	eb 03                	jmp    8011d7 <vprintfmt+0x46d>
  8011d4:	83 e8 01             	sub    $0x1,%eax
  8011d7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8011db:	75 f7                	jne    8011d4 <vprintfmt+0x46a>
  8011dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011e0:	e9 5a ff ff ff       	jmp    80113f <vprintfmt+0x3d5>
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 18             	sub    $0x18,%esp
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8011f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801200:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801203:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80120a:	85 c0                	test   %eax,%eax
  80120c:	74 26                	je     801234 <vsnprintf+0x47>
  80120e:	85 d2                	test   %edx,%edx
  801210:	7e 22                	jle    801234 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801212:	ff 75 14             	pushl  0x14(%ebp)
  801215:	ff 75 10             	pushl  0x10(%ebp)
  801218:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	68 30 0d 80 00       	push   $0x800d30
  801221:	e8 44 fb ff ff       	call   800d6a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801226:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801229:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80122c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122f:	83 c4 10             	add    $0x10,%esp
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb f7                	jmp    801232 <vsnprintf+0x45>

0080123b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801241:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801244:	50                   	push   %eax
  801245:	ff 75 10             	pushl  0x10(%ebp)
  801248:	ff 75 0c             	pushl  0xc(%ebp)
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 9a ff ff ff       	call   8011ed <vsnprintf>
	va_end(ap);

	return rc;
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 0c             	sub    $0xc,%esp

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80125e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801262:	74 15                	je     801279 <readline+0x24>
		fprintf(1, "%s", prompt);
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	ff 75 08             	pushl  0x8(%ebp)
  80126a:	68 81 36 80 00       	push   $0x803681
  80126f:	6a 01                	push   $0x1
  801271:	e8 e8 14 00 00       	call   80275e <fprintf>
  801276:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801279:	83 ec 0c             	sub    $0xc,%esp
  80127c:	6a 00                	push   $0x0
  80127e:	e8 31 f8 ff ff       	call   800ab4 <iscons>
  801283:	89 c7                	mov    %eax,%edi
  801285:	83 c4 10             	add    $0x10,%esp
	i = 0;
  801288:	be 00 00 00 00       	mov    $0x0,%esi
  80128d:	eb 57                	jmp    8012e6 <readline+0x91>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80128f:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801292:	74 11                	je     8012a5 <readline+0x50>
				cprintf("read error: %e\n", c);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	50                   	push   %eax
  801298:	68 df 3b 80 00       	push   $0x803bdf
  80129d:	e8 cb f9 ff ff       	call   800c6d <cprintf>
  8012a2:	83 c4 10             	add    $0x10,%esp
            cprintf("[readline]------------- 1 %s \n", prompt);
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	68 f0 3b 80 00       	push   $0x803bf0
  8012b0:	e8 b8 f9 ff ff       	call   800c6d <cprintf>
			return NULL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
			buf[i] = 0;
            cprintf("[readline]------------- 2 %s \n", buf );
			return buf;
		}
	}
}
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
			if (echoing)
  8012c5:	85 ff                	test   %edi,%edi
  8012c7:	75 05                	jne    8012ce <readline+0x79>
			i--;
  8012c9:	83 ee 01             	sub    $0x1,%esi
  8012cc:	eb 18                	jmp    8012e6 <readline+0x91>
				cputchar('\b');
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	6a 08                	push   $0x8
  8012d3:	e8 95 f7 ff ff       	call   800a6d <cputchar>
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	eb ec                	jmp    8012c9 <readline+0x74>
			buf[i++] = c;
  8012dd:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8012e3:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8012e6:	e8 9e f7 ff ff       	call   800a89 <getchar>
  8012eb:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 9e                	js     80128f <readline+0x3a>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8012f1:	83 f8 08             	cmp    $0x8,%eax
  8012f4:	0f 94 c2             	sete   %dl
  8012f7:	83 f8 7f             	cmp    $0x7f,%eax
  8012fa:	0f 94 c0             	sete   %al
  8012fd:	08 c2                	or     %al,%dl
  8012ff:	74 04                	je     801305 <readline+0xb0>
  801301:	85 f6                	test   %esi,%esi
  801303:	7f c0                	jg     8012c5 <readline+0x70>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801305:	83 fb 1f             	cmp    $0x1f,%ebx
  801308:	7e 1a                	jle    801324 <readline+0xcf>
  80130a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801310:	7f 12                	jg     801324 <readline+0xcf>
			if (echoing)
  801312:	85 ff                	test   %edi,%edi
  801314:	74 c7                	je     8012dd <readline+0x88>
				cputchar(c);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	53                   	push   %ebx
  80131a:	e8 4e f7 ff ff       	call   800a6d <cputchar>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	eb b9                	jmp    8012dd <readline+0x88>
		} else if (c == '\n' || c == '\r') {
  801324:	83 fb 0a             	cmp    $0xa,%ebx
  801327:	74 05                	je     80132e <readline+0xd9>
  801329:	83 fb 0d             	cmp    $0xd,%ebx
  80132c:	75 b8                	jne    8012e6 <readline+0x91>
			if (echoing)
  80132e:	85 ff                	test   %edi,%edi
  801330:	75 26                	jne    801358 <readline+0x103>
			buf[i] = 0;
  801332:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
            cprintf("[readline]------------- 2 %s \n", buf );
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	68 20 50 80 00       	push   $0x805020
  801341:	68 10 3c 80 00       	push   $0x803c10
  801346:	e8 22 f9 ff ff       	call   800c6d <cprintf>
			return buf;
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	b8 20 50 80 00       	mov    $0x805020,%eax
  801353:	e9 65 ff ff ff       	jmp    8012bd <readline+0x68>
				cputchar('\n');
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	6a 0a                	push   $0xa
  80135d:	e8 0b f7 ff ff       	call   800a6d <cputchar>
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	eb cb                	jmp    801332 <readline+0xdd>

00801367 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 03                	jmp    801377 <strlen+0x10>
		n++;
  801374:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801377:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80137b:	75 f7                	jne    801374 <strlen+0xd>
	return n;
}
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801385:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	eb 03                	jmp    801392 <strnlen+0x13>
		n++;
  80138f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801392:	39 d0                	cmp    %edx,%eax
  801394:	74 06                	je     80139c <strnlen+0x1d>
  801396:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80139a:	75 f3                	jne    80138f <strnlen+0x10>
	return n;
}
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	83 c1 01             	add    $0x1,%ecx
  8013ad:	83 c2 01             	add    $0x1,%edx
  8013b0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8013b4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8013b7:	84 db                	test   %bl,%bl
  8013b9:	75 ef                	jne    8013aa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8013bb:	5b                   	pop    %ebx
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8013c5:	53                   	push   %ebx
  8013c6:	e8 9c ff ff ff       	call   801367 <strlen>
  8013cb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8013ce:	ff 75 0c             	pushl  0xc(%ebp)
  8013d1:	01 d8                	add    %ebx,%eax
  8013d3:	50                   	push   %eax
  8013d4:	e8 c5 ff ff ff       	call   80139e <strcpy>
	return dst;
}
  8013d9:	89 d8                	mov    %ebx,%eax
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013eb:	89 f3                	mov    %esi,%ebx
  8013ed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8013f0:	89 f2                	mov    %esi,%edx
  8013f2:	eb 0f                	jmp    801403 <strncpy+0x23>
		*dst++ = *src;
  8013f4:	83 c2 01             	add    $0x1,%edx
  8013f7:	0f b6 01             	movzbl (%ecx),%eax
  8013fa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8013fd:	80 39 01             	cmpb   $0x1,(%ecx)
  801400:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801403:	39 da                	cmp    %ebx,%edx
  801405:	75 ed                	jne    8013f4 <strncpy+0x14>
	}
	return ret;
}
  801407:	89 f0                	mov    %esi,%eax
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	8b 75 08             	mov    0x8(%ebp),%esi
  801415:	8b 55 0c             	mov    0xc(%ebp),%edx
  801418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80141b:	89 f0                	mov    %esi,%eax
  80141d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801421:	85 c9                	test   %ecx,%ecx
  801423:	75 0b                	jne    801430 <strlcpy+0x23>
  801425:	eb 17                	jmp    80143e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801427:	83 c2 01             	add    $0x1,%edx
  80142a:	83 c0 01             	add    $0x1,%eax
  80142d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801430:	39 d8                	cmp    %ebx,%eax
  801432:	74 07                	je     80143b <strlcpy+0x2e>
  801434:	0f b6 0a             	movzbl (%edx),%ecx
  801437:	84 c9                	test   %cl,%cl
  801439:	75 ec                	jne    801427 <strlcpy+0x1a>
		*dst = '\0';
  80143b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80143e:	29 f0                	sub    %esi,%eax
}
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80144d:	eb 06                	jmp    801455 <strcmp+0x11>
		p++, q++;
  80144f:	83 c1 01             	add    $0x1,%ecx
  801452:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801455:	0f b6 01             	movzbl (%ecx),%eax
  801458:	84 c0                	test   %al,%al
  80145a:	74 04                	je     801460 <strcmp+0x1c>
  80145c:	3a 02                	cmp    (%edx),%al
  80145e:	74 ef                	je     80144f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801460:	0f b6 c0             	movzbl %al,%eax
  801463:	0f b6 12             	movzbl (%edx),%edx
  801466:	29 d0                	sub    %edx,%eax
}
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	8b 45 08             	mov    0x8(%ebp),%eax
  801471:	8b 55 0c             	mov    0xc(%ebp),%edx
  801474:	89 c3                	mov    %eax,%ebx
  801476:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801479:	eb 06                	jmp    801481 <strncmp+0x17>
		n--, p++, q++;
  80147b:	83 c0 01             	add    $0x1,%eax
  80147e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801481:	39 d8                	cmp    %ebx,%eax
  801483:	74 16                	je     80149b <strncmp+0x31>
  801485:	0f b6 08             	movzbl (%eax),%ecx
  801488:	84 c9                	test   %cl,%cl
  80148a:	74 04                	je     801490 <strncmp+0x26>
  80148c:	3a 0a                	cmp    (%edx),%cl
  80148e:	74 eb                	je     80147b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801490:	0f b6 00             	movzbl (%eax),%eax
  801493:	0f b6 12             	movzbl (%edx),%edx
  801496:	29 d0                	sub    %edx,%eax
}
  801498:	5b                   	pop    %ebx
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
		return 0;
  80149b:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a0:	eb f6                	jmp    801498 <strncmp+0x2e>

008014a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8014ac:	0f b6 10             	movzbl (%eax),%edx
  8014af:	84 d2                	test   %dl,%dl
  8014b1:	74 09                	je     8014bc <strchr+0x1a>
		if (*s == c)
  8014b3:	38 ca                	cmp    %cl,%dl
  8014b5:	74 0a                	je     8014c1 <strchr+0x1f>
	for (; *s; s++)
  8014b7:	83 c0 01             	add    $0x1,%eax
  8014ba:	eb f0                	jmp    8014ac <strchr+0xa>
			return (char *) s;
	return 0;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8014cd:	eb 03                	jmp    8014d2 <strfind+0xf>
  8014cf:	83 c0 01             	add    $0x1,%eax
  8014d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8014d5:	38 ca                	cmp    %cl,%dl
  8014d7:	74 04                	je     8014dd <strfind+0x1a>
  8014d9:	84 d2                	test   %dl,%dl
  8014db:	75 f2                	jne    8014cf <strfind+0xc>
			break;
	return (char *) s;
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	57                   	push   %edi
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8014eb:	85 c9                	test   %ecx,%ecx
  8014ed:	74 13                	je     801502 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8014ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8014f5:	75 05                	jne    8014fc <memset+0x1d>
  8014f7:	f6 c1 03             	test   $0x3,%cl
  8014fa:	74 0d                	je     801509 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	fc                   	cld    
  801500:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801502:	89 f8                	mov    %edi,%eax
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5f                   	pop    %edi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    
		c &= 0xFF;
  801509:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80150d:	89 d3                	mov    %edx,%ebx
  80150f:	c1 e3 08             	shl    $0x8,%ebx
  801512:	89 d0                	mov    %edx,%eax
  801514:	c1 e0 18             	shl    $0x18,%eax
  801517:	89 d6                	mov    %edx,%esi
  801519:	c1 e6 10             	shl    $0x10,%esi
  80151c:	09 f0                	or     %esi,%eax
  80151e:	09 c2                	or     %eax,%edx
  801520:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801522:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801525:	89 d0                	mov    %edx,%eax
  801527:	fc                   	cld    
  801528:	f3 ab                	rep stos %eax,%es:(%edi)
  80152a:	eb d6                	jmp    801502 <memset+0x23>

0080152c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
  801534:	8b 75 0c             	mov    0xc(%ebp),%esi
  801537:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80153a:	39 c6                	cmp    %eax,%esi
  80153c:	73 35                	jae    801573 <memmove+0x47>
  80153e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801541:	39 c2                	cmp    %eax,%edx
  801543:	76 2e                	jbe    801573 <memmove+0x47>
		s += n;
		d += n;
  801545:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801548:	89 d6                	mov    %edx,%esi
  80154a:	09 fe                	or     %edi,%esi
  80154c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801552:	74 0c                	je     801560 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801554:	83 ef 01             	sub    $0x1,%edi
  801557:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80155a:	fd                   	std    
  80155b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80155d:	fc                   	cld    
  80155e:	eb 21                	jmp    801581 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801560:	f6 c1 03             	test   $0x3,%cl
  801563:	75 ef                	jne    801554 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801565:	83 ef 04             	sub    $0x4,%edi
  801568:	8d 72 fc             	lea    -0x4(%edx),%esi
  80156b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80156e:	fd                   	std    
  80156f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801571:	eb ea                	jmp    80155d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801573:	89 f2                	mov    %esi,%edx
  801575:	09 c2                	or     %eax,%edx
  801577:	f6 c2 03             	test   $0x3,%dl
  80157a:	74 09                	je     801585 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80157c:	89 c7                	mov    %eax,%edi
  80157e:	fc                   	cld    
  80157f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801581:	5e                   	pop    %esi
  801582:	5f                   	pop    %edi
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801585:	f6 c1 03             	test   $0x3,%cl
  801588:	75 f2                	jne    80157c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80158a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80158d:	89 c7                	mov    %eax,%edi
  80158f:	fc                   	cld    
  801590:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801592:	eb ed                	jmp    801581 <memmove+0x55>

00801594 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801597:	ff 75 10             	pushl  0x10(%ebp)
  80159a:	ff 75 0c             	pushl  0xc(%ebp)
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 87 ff ff ff       	call   80152c <memmove>
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	56                   	push   %esi
  8015ab:	53                   	push   %ebx
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b2:	89 c6                	mov    %eax,%esi
  8015b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8015b7:	39 f0                	cmp    %esi,%eax
  8015b9:	74 1c                	je     8015d7 <memcmp+0x30>
		if (*s1 != *s2)
  8015bb:	0f b6 08             	movzbl (%eax),%ecx
  8015be:	0f b6 1a             	movzbl (%edx),%ebx
  8015c1:	38 d9                	cmp    %bl,%cl
  8015c3:	75 08                	jne    8015cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8015c5:	83 c0 01             	add    $0x1,%eax
  8015c8:	83 c2 01             	add    $0x1,%edx
  8015cb:	eb ea                	jmp    8015b7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8015cd:	0f b6 c1             	movzbl %cl,%eax
  8015d0:	0f b6 db             	movzbl %bl,%ebx
  8015d3:	29 d8                	sub    %ebx,%eax
  8015d5:	eb 05                	jmp    8015dc <memcmp+0x35>
	}

	return 0;
  8015d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8015ee:	39 d0                	cmp    %edx,%eax
  8015f0:	73 09                	jae    8015fb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8015f2:	38 08                	cmp    %cl,(%eax)
  8015f4:	74 05                	je     8015fb <memfind+0x1b>
	for (; s < ends; s++)
  8015f6:	83 c0 01             	add    $0x1,%eax
  8015f9:	eb f3                	jmp    8015ee <memfind+0xe>
			break;
	return (void *) s;
}
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    

008015fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801606:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801609:	eb 03                	jmp    80160e <strtol+0x11>
		s++;
  80160b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80160e:	0f b6 01             	movzbl (%ecx),%eax
  801611:	3c 20                	cmp    $0x20,%al
  801613:	74 f6                	je     80160b <strtol+0xe>
  801615:	3c 09                	cmp    $0x9,%al
  801617:	74 f2                	je     80160b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801619:	3c 2b                	cmp    $0x2b,%al
  80161b:	74 2e                	je     80164b <strtol+0x4e>
	int neg = 0;
  80161d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801622:	3c 2d                	cmp    $0x2d,%al
  801624:	74 2f                	je     801655 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801626:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80162c:	75 05                	jne    801633 <strtol+0x36>
  80162e:	80 39 30             	cmpb   $0x30,(%ecx)
  801631:	74 2c                	je     80165f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801633:	85 db                	test   %ebx,%ebx
  801635:	75 0a                	jne    801641 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801637:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80163c:	80 39 30             	cmpb   $0x30,(%ecx)
  80163f:	74 28                	je     801669 <strtol+0x6c>
		base = 10;
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
  801646:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801649:	eb 50                	jmp    80169b <strtol+0x9e>
		s++;
  80164b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80164e:	bf 00 00 00 00       	mov    $0x0,%edi
  801653:	eb d1                	jmp    801626 <strtol+0x29>
		s++, neg = 1;
  801655:	83 c1 01             	add    $0x1,%ecx
  801658:	bf 01 00 00 00       	mov    $0x1,%edi
  80165d:	eb c7                	jmp    801626 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80165f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801663:	74 0e                	je     801673 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801665:	85 db                	test   %ebx,%ebx
  801667:	75 d8                	jne    801641 <strtol+0x44>
		s++, base = 8;
  801669:	83 c1 01             	add    $0x1,%ecx
  80166c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801671:	eb ce                	jmp    801641 <strtol+0x44>
		s += 2, base = 16;
  801673:	83 c1 02             	add    $0x2,%ecx
  801676:	bb 10 00 00 00       	mov    $0x10,%ebx
  80167b:	eb c4                	jmp    801641 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  80167d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801680:	89 f3                	mov    %esi,%ebx
  801682:	80 fb 19             	cmp    $0x19,%bl
  801685:	77 29                	ja     8016b0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801687:	0f be d2             	movsbl %dl,%edx
  80168a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80168d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801690:	7d 30                	jge    8016c2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801692:	83 c1 01             	add    $0x1,%ecx
  801695:	0f af 45 10          	imul   0x10(%ebp),%eax
  801699:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80169b:	0f b6 11             	movzbl (%ecx),%edx
  80169e:	8d 72 d0             	lea    -0x30(%edx),%esi
  8016a1:	89 f3                	mov    %esi,%ebx
  8016a3:	80 fb 09             	cmp    $0x9,%bl
  8016a6:	77 d5                	ja     80167d <strtol+0x80>
			dig = *s - '0';
  8016a8:	0f be d2             	movsbl %dl,%edx
  8016ab:	83 ea 30             	sub    $0x30,%edx
  8016ae:	eb dd                	jmp    80168d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8016b0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8016b3:	89 f3                	mov    %esi,%ebx
  8016b5:	80 fb 19             	cmp    $0x19,%bl
  8016b8:	77 08                	ja     8016c2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8016ba:	0f be d2             	movsbl %dl,%edx
  8016bd:	83 ea 37             	sub    $0x37,%edx
  8016c0:	eb cb                	jmp    80168d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  8016c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8016c6:	74 05                	je     8016cd <strtol+0xd0>
		*endptr = (char *) s;
  8016c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016cb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	f7 da                	neg    %edx
  8016d1:	85 ff                	test   %edi,%edi
  8016d3:	0f 45 c2             	cmovne %edx,%eax
}
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5f                   	pop    %edi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	57                   	push   %edi
  8016df:	56                   	push   %esi
  8016e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	89 c7                	mov    %eax,%edi
  8016f0:	89 c6                	mov    %eax,%esi
  8016f2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5f                   	pop    %edi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	57                   	push   %edi
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
	asm volatile("int %1\n"
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 01 00 00 00       	mov    $0x1,%eax
  801709:	89 d1                	mov    %edx,%ecx
  80170b:	89 d3                	mov    %edx,%ebx
  80170d:	89 d7                	mov    %edx,%edi
  80170f:	89 d6                	mov    %edx,%esi
  801711:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5f                   	pop    %edi
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	57                   	push   %edi
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801721:	b9 00 00 00 00       	mov    $0x0,%ecx
  801726:	8b 55 08             	mov    0x8(%ebp),%edx
  801729:	b8 03 00 00 00       	mov    $0x3,%eax
  80172e:	89 cb                	mov    %ecx,%ebx
  801730:	89 cf                	mov    %ecx,%edi
  801732:	89 ce                	mov    %ecx,%esi
  801734:	cd 30                	int    $0x30
	if(check && ret > 0)
  801736:	85 c0                	test   %eax,%eax
  801738:	7f 08                	jg     801742 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80173a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5f                   	pop    %edi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	50                   	push   %eax
  801746:	6a 03                	push   $0x3
  801748:	68 2f 3c 80 00       	push   $0x803c2f
  80174d:	6a 23                	push   $0x23
  80174f:	68 4c 3c 80 00       	push   $0x803c4c
  801754:	e8 39 f4 ff ff       	call   800b92 <_panic>

00801759 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	57                   	push   %edi
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	b8 02 00 00 00       	mov    $0x2,%eax
  801769:	89 d1                	mov    %edx,%ecx
  80176b:	89 d3                	mov    %edx,%ebx
  80176d:	89 d7                	mov    %edx,%edi
  80176f:	89 d6                	mov    %edx,%esi
  801771:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <sys_yield>:

void
sys_yield(void)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	57                   	push   %edi
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 0b 00 00 00       	mov    $0xb,%eax
  801788:	89 d1                	mov    %edx,%ecx
  80178a:	89 d3                	mov    %edx,%ebx
  80178c:	89 d7                	mov    %edx,%edi
  80178e:	89 d6                	mov    %edx,%esi
  801790:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5f                   	pop    %edi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017a0:	be 00 00 00 00       	mov    $0x0,%esi
  8017a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8017b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017b3:	89 f7                	mov    %esi,%edi
  8017b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	7f 08                	jg     8017c3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8017bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5f                   	pop    %edi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	50                   	push   %eax
  8017c7:	6a 04                	push   $0x4
  8017c9:	68 2f 3c 80 00       	push   $0x803c2f
  8017ce:	6a 23                	push   $0x23
  8017d0:	68 4c 3c 80 00       	push   $0x803c4c
  8017d5:	e8 b8 f3 ff ff       	call   800b92 <_panic>

008017da <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017f1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017f4:	8b 75 18             	mov    0x18(%ebp),%esi
  8017f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	7f 08                	jg     801805 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8017fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5f                   	pop    %edi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	50                   	push   %eax
  801809:	6a 05                	push   $0x5
  80180b:	68 2f 3c 80 00       	push   $0x803c2f
  801810:	6a 23                	push   $0x23
  801812:	68 4c 3c 80 00       	push   $0x803c4c
  801817:	e8 76 f3 ff ff       	call   800b92 <_panic>

0080181c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801825:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182a:	8b 55 08             	mov    0x8(%ebp),%edx
  80182d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801830:	b8 06 00 00 00       	mov    $0x6,%eax
  801835:	89 df                	mov    %ebx,%edi
  801837:	89 de                	mov    %ebx,%esi
  801839:	cd 30                	int    $0x30
	if(check && ret > 0)
  80183b:	85 c0                	test   %eax,%eax
  80183d:	7f 08                	jg     801847 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80183f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	50                   	push   %eax
  80184b:	6a 06                	push   $0x6
  80184d:	68 2f 3c 80 00       	push   $0x803c2f
  801852:	6a 23                	push   $0x23
  801854:	68 4c 3c 80 00       	push   $0x803c4c
  801859:	e8 34 f3 ff ff       	call   800b92 <_panic>

0080185e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801867:	bb 00 00 00 00       	mov    $0x0,%ebx
  80186c:	8b 55 08             	mov    0x8(%ebp),%edx
  80186f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801872:	b8 08 00 00 00       	mov    $0x8,%eax
  801877:	89 df                	mov    %ebx,%edi
  801879:	89 de                	mov    %ebx,%esi
  80187b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80187d:	85 c0                	test   %eax,%eax
  80187f:	7f 08                	jg     801889 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5f                   	pop    %edi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	50                   	push   %eax
  80188d:	6a 08                	push   $0x8
  80188f:	68 2f 3c 80 00       	push   $0x803c2f
  801894:	6a 23                	push   $0x23
  801896:	68 4c 3c 80 00       	push   $0x803c4c
  80189b:	e8 f2 f2 ff ff       	call   800b92 <_panic>

008018a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8018a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8018b9:	89 df                	mov    %ebx,%edi
  8018bb:	89 de                	mov    %ebx,%esi
  8018bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	7f 08                	jg     8018cb <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8018c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	50                   	push   %eax
  8018cf:	6a 09                	push   $0x9
  8018d1:	68 2f 3c 80 00       	push   $0x803c2f
  8018d6:	6a 23                	push   $0x23
  8018d8:	68 4c 3c 80 00       	push   $0x803c4c
  8018dd:	e8 b0 f2 ff ff       	call   800b92 <_panic>

008018e2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	57                   	push   %edi
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8018eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018fb:	89 df                	mov    %ebx,%edi
  8018fd:	89 de                	mov    %ebx,%esi
  8018ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  801901:	85 c0                	test   %eax,%eax
  801903:	7f 08                	jg     80190d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801905:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801908:	5b                   	pop    %ebx
  801909:	5e                   	pop    %esi
  80190a:	5f                   	pop    %edi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	50                   	push   %eax
  801911:	6a 0a                	push   $0xa
  801913:	68 2f 3c 80 00       	push   $0x803c2f
  801918:	6a 23                	push   $0x23
  80191a:	68 4c 3c 80 00       	push   $0x803c4c
  80191f:	e8 6e f2 ff ff       	call   800b92 <_panic>

00801924 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	57                   	push   %edi
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
	asm volatile("int %1\n"
  80192a:	8b 55 08             	mov    0x8(%ebp),%edx
  80192d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801930:	b8 0c 00 00 00       	mov    $0xc,%eax
  801935:	be 00 00 00 00       	mov    $0x0,%esi
  80193a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80193d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801940:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5f                   	pop    %edi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	57                   	push   %edi
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801950:	b9 00 00 00 00       	mov    $0x0,%ecx
  801955:	8b 55 08             	mov    0x8(%ebp),%edx
  801958:	b8 0d 00 00 00       	mov    $0xd,%eax
  80195d:	89 cb                	mov    %ecx,%ebx
  80195f:	89 cf                	mov    %ecx,%edi
  801961:	89 ce                	mov    %ecx,%esi
  801963:	cd 30                	int    $0x30
	if(check && ret > 0)
  801965:	85 c0                	test   %eax,%eax
  801967:	7f 08                	jg     801971 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801969:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196c:	5b                   	pop    %ebx
  80196d:	5e                   	pop    %esi
  80196e:	5f                   	pop    %edi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	50                   	push   %eax
  801975:	6a 0d                	push   $0xd
  801977:	68 2f 3c 80 00       	push   $0x803c2f
  80197c:	6a 23                	push   $0x23
  80197e:	68 4c 3c 80 00       	push   $0x803c4c
  801983:	e8 0a f2 ff ff       	call   800b92 <_panic>

00801988 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	53                   	push   %ebx
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801992:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801994:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801997:	a8 02                	test   $0x2,%al
  801999:	0f 84 89 00 00 00    	je     801a28 <pgfault+0xa0>
  80199f:	89 da                	mov    %ebx,%edx
  8019a1:	c1 ea 0c             	shr    $0xc,%edx
  8019a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ab:	f6 c6 08             	test   $0x8,%dh
  8019ae:	74 78                	je     801a28 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019b0:	83 ec 04             	sub    $0x4,%esp
  8019b3:	6a 07                	push   $0x7
  8019b5:	68 00 f0 7f 00       	push   $0x7ff000
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 d6 fd ff ff       	call   801797 <sys_page_alloc>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 8b 00 00 00    	js     801a57 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	68 00 10 00 00       	push   $0x1000
  8019d4:	53                   	push   %ebx
  8019d5:	68 00 f0 7f 00       	push   $0x7ff000
  8019da:	e8 4d fb ff ff       	call   80152c <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8019df:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8019e6:	53                   	push   %ebx
  8019e7:	6a 00                	push   $0x0
  8019e9:	68 00 f0 7f 00       	push   $0x7ff000
  8019ee:	6a 00                	push   $0x0
  8019f0:	e8 e5 fd ff ff       	call   8017da <sys_page_map>
  8019f5:	83 c4 20             	add    $0x20,%esp
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 6d                	js     801a69 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8019fc:	83 ec 08             	sub    $0x8,%esp
  8019ff:	68 00 f0 7f 00       	push   $0x7ff000
  801a04:	6a 00                	push   $0x0
  801a06:	e8 11 fe ff ff       	call   80181c <sys_page_unmap>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 69                	js     801a7b <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	53                   	push   %ebx
  801a16:	68 b8 3c 80 00       	push   $0x803cb8
  801a1b:	e8 4d f2 ff ff       	call   800c6d <cprintf>

}
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  801a28:	8b 15 24 54 80 00    	mov    0x805424,%edx
  801a2e:	8b 4a 48             	mov    0x48(%edx),%ecx
  801a31:	89 da                	mov    %ebx,%edx
  801a33:	c1 ea 0c             	shr    $0xc,%edx
  801a36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a3d:	51                   	push   %ecx
  801a3e:	53                   	push   %ebx
  801a3f:	68 00 00 40 ef       	push   $0xef400000
  801a44:	52                   	push   %edx
  801a45:	50                   	push   %eax
  801a46:	68 5c 3c 80 00       	push   $0x803c5c
  801a4b:	6a 1e                	push   $0x1e
  801a4d:	68 d9 3c 80 00       	push   $0x803cd9
  801a52:	e8 3b f1 ff ff       	call   800b92 <_panic>
        panic("sys_page_alloc error %e", r);
  801a57:	50                   	push   %eax
  801a58:	68 e4 3c 80 00       	push   $0x803ce4
  801a5d:	6a 28                	push   $0x28
  801a5f:	68 d9 3c 80 00       	push   $0x803cd9
  801a64:	e8 29 f1 ff ff       	call   800b92 <_panic>
        panic("sys_page_map error %e", r);
  801a69:	50                   	push   %eax
  801a6a:	68 fc 3c 80 00       	push   $0x803cfc
  801a6f:	6a 2b                	push   $0x2b
  801a71:	68 d9 3c 80 00       	push   $0x803cd9
  801a76:	e8 17 f1 ff ff       	call   800b92 <_panic>
        panic("sys_page_unmap error %e", r);
  801a7b:	50                   	push   %eax
  801a7c:	68 12 3d 80 00       	push   $0x803d12
  801a81:	6a 2d                	push   $0x2d
  801a83:	68 d9 3c 80 00       	push   $0x803cd9
  801a88:	e8 05 f1 ff ff       	call   800b92 <_panic>

00801a8d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a93:	83 3d 28 54 80 00 00 	cmpl   $0x0,0x805428
  801a9a:	74 23                	je     801abf <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9f:	a3 28 54 80 00       	mov    %eax,0x805428
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801aa4:	a1 24 54 80 00       	mov    0x805424,%eax
  801aa9:	8b 40 48             	mov    0x48(%eax),%eax
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	68 b9 31 80 00       	push   $0x8031b9
  801ab4:	50                   	push   %eax
  801ab5:	e8 28 fe ff ff       	call   8018e2 <sys_env_set_pgfault_upcall>
}
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801abf:	a1 24 54 80 00       	mov    0x805424,%eax
  801ac4:	8b 40 48             	mov    0x48(%eax),%eax
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	6a 07                	push   $0x7
  801acc:	68 00 f0 bf ee       	push   $0xeebff000
  801ad1:	50                   	push   %eax
  801ad2:	e8 c0 fc ff ff       	call   801797 <sys_page_alloc>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	79 be                	jns    801a9c <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  801ade:	50                   	push   %eax
  801adf:	68 2a 3d 80 00       	push   $0x803d2a
  801ae4:	6a 21                	push   $0x21
  801ae6:	68 3d 3d 80 00       	push   $0x803d3d
  801aeb:	e8 a2 f0 ff ff       	call   800b92 <_panic>

00801af0 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	8b 75 08             	mov    0x8(%ebp),%esi
  801af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	6a 07                	push   $0x7
  801b00:	53                   	push   %ebx
  801b01:	56                   	push   %esi
  801b02:	e8 90 fc ff ff       	call   801797 <sys_page_alloc>
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 4a                	js     801b58 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	6a 07                	push   $0x7
  801b13:	68 00 00 40 00       	push   $0x400000
  801b18:	6a 00                	push   $0x0
  801b1a:	53                   	push   %ebx
  801b1b:	56                   	push   %esi
  801b1c:	e8 b9 fc ff ff       	call   8017da <sys_page_map>
  801b21:	83 c4 20             	add    $0x20,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 42                	js     801b6a <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  801b28:	83 ec 04             	sub    $0x4,%esp
  801b2b:	68 00 10 00 00       	push   $0x1000
  801b30:	53                   	push   %ebx
  801b31:	68 00 00 40 00       	push   $0x400000
  801b36:	e8 f1 f9 ff ff       	call   80152c <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b3b:	83 c4 08             	add    $0x8,%esp
  801b3e:	68 00 00 40 00       	push   $0x400000
  801b43:	6a 00                	push   $0x0
  801b45:	e8 d2 fc ff ff       	call   80181c <sys_page_unmap>
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 2b                	js     801b7c <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  801b58:	50                   	push   %eax
  801b59:	68 2a 3d 80 00       	push   $0x803d2a
  801b5e:	6a 63                	push   $0x63
  801b60:	68 d9 3c 80 00       	push   $0x803cd9
  801b65:	e8 28 f0 ff ff       	call   800b92 <_panic>
        panic("sys_page_map: %e", r);
  801b6a:	50                   	push   %eax
  801b6b:	68 4d 3d 80 00       	push   $0x803d4d
  801b70:	6a 65                	push   $0x65
  801b72:	68 d9 3c 80 00       	push   $0x803cd9
  801b77:	e8 16 f0 ff ff       	call   800b92 <_panic>
        panic("sys_page_unmap: %e", r);
  801b7c:	50                   	push   %eax
  801b7d:	68 5e 3d 80 00       	push   $0x803d5e
  801b82:	6a 68                	push   $0x68
  801b84:	68 d9 3c 80 00       	push   $0x803cd9
  801b89:	e8 04 f0 ff ff       	call   800b92 <_panic>

00801b8e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801b97:	a1 24 54 80 00       	mov    0x805424,%eax
  801b9c:	8b 40 64             	mov    0x64(%eax),%eax
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	74 1f                	je     801bc2 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801ba3:	b8 07 00 00 00       	mov    $0x7,%eax
  801ba8:	cd 30                	int    $0x30
  801baa:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	74 21                	je     801bd4 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801bb3:	be 28 54 80 00       	mov    $0x805428,%esi
  801bb8:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801bbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc0:	eb 7b                	jmp    801c3d <fork+0xaf>
        set_pgfault_handler(pgfault);
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	68 88 19 80 00       	push   $0x801988
  801bca:	e8 be fe ff ff       	call   801a8d <set_pgfault_handler>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	eb cf                	jmp    801ba3 <fork+0x15>
        set_pgfault_handler(pgfault);
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	68 88 19 80 00       	push   $0x801988
  801bdc:	e8 ac fe ff ff       	call   801a8d <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801be1:	e8 73 fb ff ff       	call   801759 <sys_getenvid>
  801be6:	25 ff 03 00 00       	and    $0x3ff,%eax
  801beb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf3:	a3 24 54 80 00       	mov    %eax,0x805424
        return 0;
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	e9 ca 00 00 00       	jmp    801cca <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801c00:	89 d1                	mov    %edx,%ecx
  801c02:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801c08:	81 e2 02 08 00 00    	and    $0x802,%edx
  801c0e:	89 cf                	mov    %ecx,%edi
  801c10:	81 cf 00 08 00 00    	or     $0x800,%edi
  801c16:	85 d2                	test   %edx,%edx
  801c18:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	51                   	push   %ecx
  801c1f:	50                   	push   %eax
  801c20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c23:	50                   	push   %eax
  801c24:	6a 00                	push   $0x0
  801c26:	e8 af fb ff ff       	call   8017da <sys_page_map>
  801c2b:	83 c4 20             	add    $0x20,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 45                	js     801c77 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801c32:	83 c3 01             	add    $0x1,%ebx
  801c35:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  801c3b:	74 4c                	je     801c89 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801c3d:	39 de                	cmp    %ebx,%esi
  801c3f:	74 f1                	je     801c32 <fork+0xa4>
  801c41:	89 d8                	mov    %ebx,%eax
  801c43:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	c1 ea 16             	shr    $0x16,%edx
  801c4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801c52:	f6 c2 05             	test   $0x5,%dl
  801c55:	74 db                	je     801c32 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	c1 ea 0c             	shr    $0xc,%edx
  801c5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801c63:	f6 c2 04             	test   $0x4,%dl
  801c66:	74 ca                	je     801c32 <fork+0xa4>
    if (perm & PTE_SHARE) {
  801c68:	f6 c6 04             	test   $0x4,%dh
  801c6b:	74 93                	je     801c00 <fork+0x72>
        perm &= ~PTE_COW;
  801c6d:	89 d1                	mov    %edx,%ecx
  801c6f:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801c75:	eb a4                	jmp    801c1b <fork+0x8d>
        panic("sys_page_map error %e", r);
  801c77:	50                   	push   %eax
  801c78:	68 fc 3c 80 00       	push   $0x803cfc
  801c7d:	6a 57                	push   $0x57
  801c7f:	68 d9 3c 80 00       	push   $0x803cd9
  801c84:	e8 09 ef ff ff       	call   800b92 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  801c89:	83 ec 08             	sub    $0x8,%esp
  801c8c:	b8 28 54 80 00       	mov    $0x805428,%eax
  801c91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c96:	50                   	push   %eax
  801c97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c9a:	e8 51 fe ff ff       	call   801af0 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801c9f:	83 c4 08             	add    $0x8,%esp
  801ca2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ca5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801caa:	50                   	push   %eax
  801cab:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cae:	e8 3d fe ff ff       	call   801af0 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801cb3:	83 c4 08             	add    $0x8,%esp
  801cb6:	6a 02                	push   $0x2
  801cb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cbb:	e8 9e fb ff ff       	call   80185e <sys_env_set_status>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 0d                	js     801cd4 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801cc7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801cca:	89 d8                	mov    %ebx,%eax
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801cd4:	50                   	push   %eax
  801cd5:	68 71 3d 80 00       	push   $0x803d71
  801cda:	68 a0 00 00 00       	push   $0xa0
  801cdf:	68 d9 3c 80 00       	push   $0x803cd9
  801ce4:	e8 a9 ee ff ff       	call   800b92 <_panic>

00801ce9 <sfork>:

// Challenge!
int
sfork(void)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801cef:	68 88 3d 80 00       	push   $0x803d88
  801cf4:	68 a9 00 00 00       	push   $0xa9
  801cf9:	68 d9 3c 80 00       	push   $0x803cd9
  801cfe:	e8 8f ee ff ff       	call   800b92 <_panic>

00801d03 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	8b 55 08             	mov    0x8(%ebp),%edx
  801d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0c:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801d0f:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801d11:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801d14:	83 3a 01             	cmpl   $0x1,(%edx)
  801d17:	7e 09                	jle    801d22 <argstart+0x1f>
  801d19:	ba 41 35 80 00       	mov    $0x803541,%edx
  801d1e:	85 c9                	test   %ecx,%ecx
  801d20:	75 05                	jne    801d27 <argstart+0x24>
  801d22:	ba 00 00 00 00       	mov    $0x0,%edx
  801d27:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801d2a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <argnext>:

int
argnext(struct Argstate *args)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 04             	sub    $0x4,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801d3d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801d44:	8b 43 08             	mov    0x8(%ebx),%eax
  801d47:	85 c0                	test   %eax,%eax
  801d49:	74 72                	je     801dbd <argnext+0x8a>
		return -1;

	if (!*args->curarg) {
  801d4b:	80 38 00             	cmpb   $0x0,(%eax)
  801d4e:	75 48                	jne    801d98 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801d50:	8b 0b                	mov    (%ebx),%ecx
  801d52:	83 39 01             	cmpl   $0x1,(%ecx)
  801d55:	74 58                	je     801daf <argnext+0x7c>
		    || args->argv[1][0] != '-'
  801d57:	8b 53 04             	mov    0x4(%ebx),%edx
  801d5a:	8b 42 04             	mov    0x4(%edx),%eax
  801d5d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d60:	75 4d                	jne    801daf <argnext+0x7c>
		    || args->argv[1][1] == '\0')
  801d62:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d66:	74 47                	je     801daf <argnext+0x7c>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801d68:	83 c0 01             	add    $0x1,%eax
  801d6b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	8b 01                	mov    (%ecx),%eax
  801d73:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d7a:	50                   	push   %eax
  801d7b:	8d 42 08             	lea    0x8(%edx),%eax
  801d7e:	50                   	push   %eax
  801d7f:	83 c2 04             	add    $0x4,%edx
  801d82:	52                   	push   %edx
  801d83:	e8 a4 f7 ff ff       	call   80152c <memmove>
		(*args->argc)--;
  801d88:	8b 03                	mov    (%ebx),%eax
  801d8a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d8d:	8b 43 08             	mov    0x8(%ebx),%eax
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d96:	74 11                	je     801da9 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d98:	8b 53 08             	mov    0x8(%ebx),%edx
  801d9b:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801d9e:	83 c2 01             	add    $0x1,%edx
  801da1:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801da4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801da9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801dad:	75 e9                	jne    801d98 <argnext+0x65>
	args->curarg = 0;
  801daf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801dbb:	eb e7                	jmp    801da4 <argnext+0x71>
		return -1;
  801dbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801dc2:	eb e0                	jmp    801da4 <argnext+0x71>

00801dc4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801dce:	8b 43 08             	mov    0x8(%ebx),%eax
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	74 5b                	je     801e30 <argnextvalue+0x6c>
		return 0;
	if (*args->curarg) {
  801dd5:	80 38 00             	cmpb   $0x0,(%eax)
  801dd8:	74 12                	je     801dec <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801dda:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801ddd:	c7 43 08 41 35 80 00 	movl   $0x803541,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801de4:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    
	} else if (*args->argc > 1) {
  801dec:	8b 13                	mov    (%ebx),%edx
  801dee:	83 3a 01             	cmpl   $0x1,(%edx)
  801df1:	7f 10                	jg     801e03 <argnextvalue+0x3f>
		args->argvalue = 0;
  801df3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801dfa:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801e01:	eb e1                	jmp    801de4 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801e03:	8b 43 04             	mov    0x4(%ebx),%eax
  801e06:	8b 48 04             	mov    0x4(%eax),%ecx
  801e09:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801e0c:	83 ec 04             	sub    $0x4,%esp
  801e0f:	8b 12                	mov    (%edx),%edx
  801e11:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801e18:	52                   	push   %edx
  801e19:	8d 50 08             	lea    0x8(%eax),%edx
  801e1c:	52                   	push   %edx
  801e1d:	83 c0 04             	add    $0x4,%eax
  801e20:	50                   	push   %eax
  801e21:	e8 06 f7 ff ff       	call   80152c <memmove>
		(*args->argc)--;
  801e26:	8b 03                	mov    (%ebx),%eax
  801e28:	83 28 01             	subl   $0x1,(%eax)
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	eb b4                	jmp    801de4 <argnextvalue+0x20>
		return 0;
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
  801e35:	eb b0                	jmp    801de7 <argnextvalue+0x23>

00801e37 <argvalue>:
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 08             	sub    $0x8,%esp
  801e3d:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e40:	8b 42 0c             	mov    0xc(%edx),%eax
  801e43:	85 c0                	test   %eax,%eax
  801e45:	74 02                	je     801e49 <argvalue+0x12>
}
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	52                   	push   %edx
  801e4d:	e8 72 ff ff ff       	call   801dc4 <argnextvalue>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	eb f0                	jmp    801e47 <argvalue+0x10>

00801e57 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	05 00 00 00 30       	add    $0x30000000,%eax
  801e62:	c1 e8 0c             	shr    $0xc,%eax
}
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801e72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801e77:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e84:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	c1 ea 16             	shr    $0x16,%edx
  801e8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e95:	f6 c2 01             	test   $0x1,%dl
  801e98:	74 2a                	je     801ec4 <fd_alloc+0x46>
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 ea 0c             	shr    $0xc,%edx
  801e9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ea6:	f6 c2 01             	test   $0x1,%dl
  801ea9:	74 19                	je     801ec4 <fd_alloc+0x46>
  801eab:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801eb0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801eb5:	75 d2                	jne    801e89 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801eb7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801ebd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801ec2:	eb 07                	jmp    801ecb <fd_alloc+0x4d>
			*fd_store = fd;
  801ec4:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ed3:	83 f8 1f             	cmp    $0x1f,%eax
  801ed6:	77 36                	ja     801f0e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ed8:	c1 e0 0c             	shl    $0xc,%eax
  801edb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ee0:	89 c2                	mov    %eax,%edx
  801ee2:	c1 ea 16             	shr    $0x16,%edx
  801ee5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801eec:	f6 c2 01             	test   $0x1,%dl
  801eef:	74 24                	je     801f15 <fd_lookup+0x48>
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	c1 ea 0c             	shr    $0xc,%edx
  801ef6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801efd:	f6 c2 01             	test   $0x1,%dl
  801f00:	74 1a                	je     801f1c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801f02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f05:	89 02                	mov    %eax,(%edx)
	return 0;
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    
		return -E_INVAL;
  801f0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f13:	eb f7                	jmp    801f0c <fd_lookup+0x3f>
		return -E_INVAL;
  801f15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f1a:	eb f0                	jmp    801f0c <fd_lookup+0x3f>
  801f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f21:	eb e9                	jmp    801f0c <fd_lookup+0x3f>

00801f23 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
  801f29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f2c:	ba 1c 3e 80 00       	mov    $0x803e1c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801f31:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801f36:	39 08                	cmp    %ecx,(%eax)
  801f38:	74 33                	je     801f6d <dev_lookup+0x4a>
  801f3a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801f3d:	8b 02                	mov    (%edx),%eax
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	75 f3                	jne    801f36 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f43:	a1 24 54 80 00       	mov    0x805424,%eax
  801f48:	8b 40 48             	mov    0x48(%eax),%eax
  801f4b:	83 ec 04             	sub    $0x4,%esp
  801f4e:	51                   	push   %ecx
  801f4f:	50                   	push   %eax
  801f50:	68 a0 3d 80 00       	push   $0x803da0
  801f55:	e8 13 ed ff ff       	call   800c6d <cprintf>
	*dev = 0;
  801f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    
			*dev = devtab[i];
  801f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f70:	89 01                	mov    %eax,(%ecx)
			return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
  801f77:	eb f2                	jmp    801f6b <dev_lookup+0x48>

00801f79 <fd_close>:
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	57                   	push   %edi
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 1c             	sub    $0x1c,%esp
  801f82:	8b 75 08             	mov    0x8(%ebp),%esi
  801f85:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f88:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f8b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801f8c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801f92:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f95:	50                   	push   %eax
  801f96:	e8 32 ff ff ff       	call   801ecd <fd_lookup>
  801f9b:	89 c3                	mov    %eax,%ebx
  801f9d:	83 c4 08             	add    $0x8,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 05                	js     801fa9 <fd_close+0x30>
	    || fd != fd2)
  801fa4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801fa7:	74 16                	je     801fbf <fd_close+0x46>
		return (must_exist ? r : 0);
  801fa9:	89 f8                	mov    %edi,%eax
  801fab:	84 c0                	test   %al,%al
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb2:	0f 44 d8             	cmove  %eax,%ebx
}
  801fb5:	89 d8                	mov    %ebx,%eax
  801fb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fba:	5b                   	pop    %ebx
  801fbb:	5e                   	pop    %esi
  801fbc:	5f                   	pop    %edi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801fbf:	83 ec 08             	sub    $0x8,%esp
  801fc2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	ff 36                	pushl  (%esi)
  801fc8:	e8 56 ff ff ff       	call   801f23 <dev_lookup>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 15                	js     801feb <fd_close+0x72>
		if (dev->dev_close)
  801fd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fd9:	8b 40 10             	mov    0x10(%eax),%eax
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	74 1b                	je     801ffb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	56                   	push   %esi
  801fe4:	ff d0                	call   *%eax
  801fe6:	89 c3                	mov    %eax,%ebx
  801fe8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801feb:	83 ec 08             	sub    $0x8,%esp
  801fee:	56                   	push   %esi
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 26 f8 ff ff       	call   80181c <sys_page_unmap>
	return r;
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	eb ba                	jmp    801fb5 <fd_close+0x3c>
			r = 0;
  801ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  802000:	eb e9                	jmp    801feb <fd_close+0x72>

00802002 <close>:

int
close(int fdnum)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	ff 75 08             	pushl  0x8(%ebp)
  80200f:	e8 b9 fe ff ff       	call   801ecd <fd_lookup>
  802014:	83 c4 08             	add    $0x8,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	78 10                	js     80202b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80201b:	83 ec 08             	sub    $0x8,%esp
  80201e:	6a 01                	push   $0x1
  802020:	ff 75 f4             	pushl  -0xc(%ebp)
  802023:	e8 51 ff ff ff       	call   801f79 <fd_close>
  802028:	83 c4 10             	add    $0x10,%esp
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <close_all>:

void
close_all(void)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	53                   	push   %ebx
  802031:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802034:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	53                   	push   %ebx
  80203d:	e8 c0 ff ff ff       	call   802002 <close>
	for (i = 0; i < MAXFD; i++)
  802042:	83 c3 01             	add    $0x1,%ebx
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	83 fb 20             	cmp    $0x20,%ebx
  80204b:	75 ec                	jne    802039 <close_all+0xc>
}
  80204d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80205b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80205e:	50                   	push   %eax
  80205f:	ff 75 08             	pushl  0x8(%ebp)
  802062:	e8 66 fe ff ff       	call   801ecd <fd_lookup>
  802067:	89 c3                	mov    %eax,%ebx
  802069:	83 c4 08             	add    $0x8,%esp
  80206c:	85 c0                	test   %eax,%eax
  80206e:	0f 88 81 00 00 00    	js     8020f5 <dup+0xa3>
		return r;
	close(newfdnum);
  802074:	83 ec 0c             	sub    $0xc,%esp
  802077:	ff 75 0c             	pushl  0xc(%ebp)
  80207a:	e8 83 ff ff ff       	call   802002 <close>

	newfd = INDEX2FD(newfdnum);
  80207f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802082:	c1 e6 0c             	shl    $0xc,%esi
  802085:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80208b:	83 c4 04             	add    $0x4,%esp
  80208e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802091:	e8 d1 fd ff ff       	call   801e67 <fd2data>
  802096:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802098:	89 34 24             	mov    %esi,(%esp)
  80209b:	e8 c7 fd ff ff       	call   801e67 <fd2data>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8020a5:	89 d8                	mov    %ebx,%eax
  8020a7:	c1 e8 16             	shr    $0x16,%eax
  8020aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020b1:	a8 01                	test   $0x1,%al
  8020b3:	74 11                	je     8020c6 <dup+0x74>
  8020b5:	89 d8                	mov    %ebx,%eax
  8020b7:	c1 e8 0c             	shr    $0xc,%eax
  8020ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020c1:	f6 c2 01             	test   $0x1,%dl
  8020c4:	75 39                	jne    8020ff <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8020c9:	89 d0                	mov    %edx,%eax
  8020cb:	c1 e8 0c             	shr    $0xc,%eax
  8020ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020d5:	83 ec 0c             	sub    $0xc,%esp
  8020d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8020dd:	50                   	push   %eax
  8020de:	56                   	push   %esi
  8020df:	6a 00                	push   $0x0
  8020e1:	52                   	push   %edx
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 f1 f6 ff ff       	call   8017da <sys_page_map>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	83 c4 20             	add    $0x20,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 31                	js     802123 <dup+0xd1>
		goto err;

	return newfdnum;
  8020f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8020f5:	89 d8                	mov    %ebx,%eax
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	25 07 0e 00 00       	and    $0xe07,%eax
  80210e:	50                   	push   %eax
  80210f:	57                   	push   %edi
  802110:	6a 00                	push   $0x0
  802112:	53                   	push   %ebx
  802113:	6a 00                	push   $0x0
  802115:	e8 c0 f6 ff ff       	call   8017da <sys_page_map>
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	83 c4 20             	add    $0x20,%esp
  80211f:	85 c0                	test   %eax,%eax
  802121:	79 a3                	jns    8020c6 <dup+0x74>
	sys_page_unmap(0, newfd);
  802123:	83 ec 08             	sub    $0x8,%esp
  802126:	56                   	push   %esi
  802127:	6a 00                	push   $0x0
  802129:	e8 ee f6 ff ff       	call   80181c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80212e:	83 c4 08             	add    $0x8,%esp
  802131:	57                   	push   %edi
  802132:	6a 00                	push   $0x0
  802134:	e8 e3 f6 ff ff       	call   80181c <sys_page_unmap>
	return r;
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	eb b7                	jmp    8020f5 <dup+0xa3>

0080213e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	53                   	push   %ebx
  802142:	83 ec 14             	sub    $0x14,%esp
  802145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80214b:	50                   	push   %eax
  80214c:	53                   	push   %ebx
  80214d:	e8 7b fd ff ff       	call   801ecd <fd_lookup>
  802152:	83 c4 08             	add    $0x8,%esp
  802155:	85 c0                	test   %eax,%eax
  802157:	78 3f                	js     802198 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802159:	83 ec 08             	sub    $0x8,%esp
  80215c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215f:	50                   	push   %eax
  802160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802163:	ff 30                	pushl  (%eax)
  802165:	e8 b9 fd ff ff       	call   801f23 <dev_lookup>
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 27                	js     802198 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802171:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802174:	8b 42 08             	mov    0x8(%edx),%eax
  802177:	83 e0 03             	and    $0x3,%eax
  80217a:	83 f8 01             	cmp    $0x1,%eax
  80217d:	74 1e                	je     80219d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80217f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802182:	8b 40 08             	mov    0x8(%eax),%eax
  802185:	85 c0                	test   %eax,%eax
  802187:	74 35                	je     8021be <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802189:	83 ec 04             	sub    $0x4,%esp
  80218c:	ff 75 10             	pushl  0x10(%ebp)
  80218f:	ff 75 0c             	pushl  0xc(%ebp)
  802192:	52                   	push   %edx
  802193:	ff d0                	call   *%eax
  802195:	83 c4 10             	add    $0x10,%esp
}
  802198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80219b:	c9                   	leave  
  80219c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80219d:	a1 24 54 80 00       	mov    0x805424,%eax
  8021a2:	8b 40 48             	mov    0x48(%eax),%eax
  8021a5:	83 ec 04             	sub    $0x4,%esp
  8021a8:	53                   	push   %ebx
  8021a9:	50                   	push   %eax
  8021aa:	68 e1 3d 80 00       	push   $0x803de1
  8021af:	e8 b9 ea ff ff       	call   800c6d <cprintf>
		return -E_INVAL;
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021bc:	eb da                	jmp    802198 <read+0x5a>
		return -E_NOT_SUPP;
  8021be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021c3:	eb d3                	jmp    802198 <read+0x5a>

008021c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	57                   	push   %edi
  8021c9:	56                   	push   %esi
  8021ca:	53                   	push   %ebx
  8021cb:	83 ec 0c             	sub    $0xc,%esp
  8021ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d9:	39 f3                	cmp    %esi,%ebx
  8021db:	73 25                	jae    802202 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021dd:	83 ec 04             	sub    $0x4,%esp
  8021e0:	89 f0                	mov    %esi,%eax
  8021e2:	29 d8                	sub    %ebx,%eax
  8021e4:	50                   	push   %eax
  8021e5:	89 d8                	mov    %ebx,%eax
  8021e7:	03 45 0c             	add    0xc(%ebp),%eax
  8021ea:	50                   	push   %eax
  8021eb:	57                   	push   %edi
  8021ec:	e8 4d ff ff ff       	call   80213e <read>
		if (m < 0)
  8021f1:	83 c4 10             	add    $0x10,%esp
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 08                	js     802200 <readn+0x3b>
			return m;
		if (m == 0)
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	74 06                	je     802202 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8021fc:	01 c3                	add    %eax,%ebx
  8021fe:	eb d9                	jmp    8021d9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802200:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802202:	89 d8                	mov    %ebx,%eax
  802204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    

0080220c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	53                   	push   %ebx
  802210:	83 ec 14             	sub    $0x14,%esp
  802213:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802216:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	53                   	push   %ebx
  80221b:	e8 ad fc ff ff       	call   801ecd <fd_lookup>
  802220:	83 c4 08             	add    $0x8,%esp
  802223:	85 c0                	test   %eax,%eax
  802225:	78 3a                	js     802261 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222d:	50                   	push   %eax
  80222e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802231:	ff 30                	pushl  (%eax)
  802233:	e8 eb fc ff ff       	call   801f23 <dev_lookup>
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	85 c0                	test   %eax,%eax
  80223d:	78 22                	js     802261 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80223f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802242:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802246:	74 1e                	je     802266 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802248:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80224b:	8b 52 0c             	mov    0xc(%edx),%edx
  80224e:	85 d2                	test   %edx,%edx
  802250:	74 35                	je     802287 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802252:	83 ec 04             	sub    $0x4,%esp
  802255:	ff 75 10             	pushl  0x10(%ebp)
  802258:	ff 75 0c             	pushl  0xc(%ebp)
  80225b:	50                   	push   %eax
  80225c:	ff d2                	call   *%edx
  80225e:	83 c4 10             	add    $0x10,%esp
}
  802261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802264:	c9                   	leave  
  802265:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802266:	a1 24 54 80 00       	mov    0x805424,%eax
  80226b:	8b 40 48             	mov    0x48(%eax),%eax
  80226e:	83 ec 04             	sub    $0x4,%esp
  802271:	53                   	push   %ebx
  802272:	50                   	push   %eax
  802273:	68 fd 3d 80 00       	push   $0x803dfd
  802278:	e8 f0 e9 ff ff       	call   800c6d <cprintf>
		return -E_INVAL;
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802285:	eb da                	jmp    802261 <write+0x55>
		return -E_NOT_SUPP;
  802287:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80228c:	eb d3                	jmp    802261 <write+0x55>

0080228e <seek>:

int
seek(int fdnum, off_t offset)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802294:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802297:	50                   	push   %eax
  802298:	ff 75 08             	pushl  0x8(%ebp)
  80229b:	e8 2d fc ff ff       	call   801ecd <fd_lookup>
  8022a0:	83 c4 08             	add    $0x8,%esp
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	78 0e                	js     8022b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8022a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8022ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8022b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	53                   	push   %ebx
  8022bb:	83 ec 14             	sub    $0x14,%esp
  8022be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022c4:	50                   	push   %eax
  8022c5:	53                   	push   %ebx
  8022c6:	e8 02 fc ff ff       	call   801ecd <fd_lookup>
  8022cb:	83 c4 08             	add    $0x8,%esp
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 37                	js     802309 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022d2:	83 ec 08             	sub    $0x8,%esp
  8022d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d8:	50                   	push   %eax
  8022d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022dc:	ff 30                	pushl  (%eax)
  8022de:	e8 40 fc ff ff       	call   801f23 <dev_lookup>
  8022e3:	83 c4 10             	add    $0x10,%esp
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	78 1f                	js     802309 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022f1:	74 1b                	je     80230e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8022f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022f6:	8b 52 18             	mov    0x18(%edx),%edx
  8022f9:	85 d2                	test   %edx,%edx
  8022fb:	74 32                	je     80232f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8022fd:	83 ec 08             	sub    $0x8,%esp
  802300:	ff 75 0c             	pushl  0xc(%ebp)
  802303:	50                   	push   %eax
  802304:	ff d2                	call   *%edx
  802306:	83 c4 10             	add    $0x10,%esp
}
  802309:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80230c:	c9                   	leave  
  80230d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80230e:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802313:	8b 40 48             	mov    0x48(%eax),%eax
  802316:	83 ec 04             	sub    $0x4,%esp
  802319:	53                   	push   %ebx
  80231a:	50                   	push   %eax
  80231b:	68 c0 3d 80 00       	push   $0x803dc0
  802320:	e8 48 e9 ff ff       	call   800c6d <cprintf>
		return -E_INVAL;
  802325:	83 c4 10             	add    $0x10,%esp
  802328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80232d:	eb da                	jmp    802309 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80232f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802334:	eb d3                	jmp    802309 <ftruncate+0x52>

00802336 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	53                   	push   %ebx
  80233a:	83 ec 14             	sub    $0x14,%esp
  80233d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802340:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802343:	50                   	push   %eax
  802344:	ff 75 08             	pushl  0x8(%ebp)
  802347:	e8 81 fb ff ff       	call   801ecd <fd_lookup>
  80234c:	83 c4 08             	add    $0x8,%esp
  80234f:	85 c0                	test   %eax,%eax
  802351:	78 4b                	js     80239e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802353:	83 ec 08             	sub    $0x8,%esp
  802356:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802359:	50                   	push   %eax
  80235a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80235d:	ff 30                	pushl  (%eax)
  80235f:	e8 bf fb ff ff       	call   801f23 <dev_lookup>
  802364:	83 c4 10             	add    $0x10,%esp
  802367:	85 c0                	test   %eax,%eax
  802369:	78 33                	js     80239e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80236b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802372:	74 2f                	je     8023a3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802374:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802377:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80237e:	00 00 00 
	stat->st_isdir = 0;
  802381:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802388:	00 00 00 
	stat->st_dev = dev;
  80238b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802391:	83 ec 08             	sub    $0x8,%esp
  802394:	53                   	push   %ebx
  802395:	ff 75 f0             	pushl  -0x10(%ebp)
  802398:	ff 50 14             	call   *0x14(%eax)
  80239b:	83 c4 10             	add    $0x10,%esp
}
  80239e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023a1:	c9                   	leave  
  8023a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8023a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8023a8:	eb f4                	jmp    80239e <fstat+0x68>

008023aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8023af:	83 ec 08             	sub    $0x8,%esp
  8023b2:	6a 00                	push   $0x0
  8023b4:	ff 75 08             	pushl  0x8(%ebp)
  8023b7:	e8 e7 01 00 00       	call   8025a3 <open>
  8023bc:	89 c3                	mov    %eax,%ebx
  8023be:	83 c4 10             	add    $0x10,%esp
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	78 1b                	js     8023e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8023c5:	83 ec 08             	sub    $0x8,%esp
  8023c8:	ff 75 0c             	pushl  0xc(%ebp)
  8023cb:	50                   	push   %eax
  8023cc:	e8 65 ff ff ff       	call   802336 <fstat>
  8023d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8023d3:	89 1c 24             	mov    %ebx,(%esp)
  8023d6:	e8 27 fc ff ff       	call   802002 <close>
	return r;
  8023db:	83 c4 10             	add    $0x10,%esp
  8023de:	89 f3                	mov    %esi,%ebx
}
  8023e0:	89 d8                	mov    %ebx,%eax
  8023e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e5:	5b                   	pop    %ebx
  8023e6:	5e                   	pop    %esi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    

008023e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	56                   	push   %esi
  8023ed:	53                   	push   %ebx
  8023ee:	89 c6                	mov    %eax,%esi
  8023f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8023f2:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8023f9:	74 27                	je     802422 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8023fb:	6a 07                	push   $0x7
  8023fd:	68 00 60 80 00       	push   $0x806000
  802402:	56                   	push   %esi
  802403:	ff 35 20 54 80 00    	pushl  0x805420
  802409:	e8 32 0e 00 00       	call   803240 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80240e:	83 c4 0c             	add    $0xc,%esp
  802411:	6a 00                	push   $0x0
  802413:	53                   	push   %ebx
  802414:	6a 00                	push   $0x0
  802416:	e8 c4 0d 00 00       	call   8031df <ipc_recv>
}
  80241b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80241e:	5b                   	pop    %ebx
  80241f:	5e                   	pop    %esi
  802420:	5d                   	pop    %ebp
  802421:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802422:	83 ec 0c             	sub    $0xc,%esp
  802425:	6a 01                	push   $0x1
  802427:	e8 61 0e 00 00       	call   80328d <ipc_find_env>
  80242c:	a3 20 54 80 00       	mov    %eax,0x805420
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	eb c5                	jmp    8023fb <fsipc+0x12>

00802436 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	8b 40 0c             	mov    0xc(%eax),%eax
  802442:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802447:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80244f:	ba 00 00 00 00       	mov    $0x0,%edx
  802454:	b8 02 00 00 00       	mov    $0x2,%eax
  802459:	e8 8b ff ff ff       	call   8023e9 <fsipc>
}
  80245e:	c9                   	leave  
  80245f:	c3                   	ret    

00802460 <devfile_flush>:
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	8b 40 0c             	mov    0xc(%eax),%eax
  80246c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802471:	ba 00 00 00 00       	mov    $0x0,%edx
  802476:	b8 06 00 00 00       	mov    $0x6,%eax
  80247b:	e8 69 ff ff ff       	call   8023e9 <fsipc>
}
  802480:	c9                   	leave  
  802481:	c3                   	ret    

00802482 <devfile_stat>:
{
  802482:	55                   	push   %ebp
  802483:	89 e5                	mov    %esp,%ebp
  802485:	53                   	push   %ebx
  802486:	83 ec 04             	sub    $0x4,%esp
  802489:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80248c:	8b 45 08             	mov    0x8(%ebp),%eax
  80248f:	8b 40 0c             	mov    0xc(%eax),%eax
  802492:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802497:	ba 00 00 00 00       	mov    $0x0,%edx
  80249c:	b8 05 00 00 00       	mov    $0x5,%eax
  8024a1:	e8 43 ff ff ff       	call   8023e9 <fsipc>
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	78 2c                	js     8024d6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024aa:	83 ec 08             	sub    $0x8,%esp
  8024ad:	68 00 60 80 00       	push   $0x806000
  8024b2:	53                   	push   %ebx
  8024b3:	e8 e6 ee ff ff       	call   80139e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024b8:	a1 80 60 80 00       	mov    0x806080,%eax
  8024bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8024c3:	a1 84 60 80 00       	mov    0x806084,%eax
  8024c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8024ce:	83 c4 10             	add    $0x10,%esp
  8024d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024d9:	c9                   	leave  
  8024da:	c3                   	ret    

008024db <devfile_write>:
{
  8024db:	55                   	push   %ebp
  8024dc:	89 e5                	mov    %esp,%ebp
  8024de:	83 ec 0c             	sub    $0xc,%esp
  8024e1:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8024e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8024e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8024ee:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8024f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8024f7:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  8024fd:	a3 04 60 80 00       	mov    %eax,0x806004
    memmove(fsipcbuf.write.req_buf, buf, n);
  802502:	50                   	push   %eax
  802503:	ff 75 0c             	pushl  0xc(%ebp)
  802506:	68 08 60 80 00       	push   $0x806008
  80250b:	e8 1c f0 ff ff       	call   80152c <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  802510:	ba 00 00 00 00       	mov    $0x0,%edx
  802515:	b8 04 00 00 00       	mov    $0x4,%eax
  80251a:	e8 ca fe ff ff       	call   8023e9 <fsipc>
}
  80251f:	c9                   	leave  
  802520:	c3                   	ret    

00802521 <devfile_read>:
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	56                   	push   %esi
  802525:	53                   	push   %ebx
  802526:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802529:	8b 45 08             	mov    0x8(%ebp),%eax
  80252c:	8b 40 0c             	mov    0xc(%eax),%eax
  80252f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802534:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80253a:	ba 00 00 00 00       	mov    $0x0,%edx
  80253f:	b8 03 00 00 00       	mov    $0x3,%eax
  802544:	e8 a0 fe ff ff       	call   8023e9 <fsipc>
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	85 c0                	test   %eax,%eax
  80254d:	78 1f                	js     80256e <devfile_read+0x4d>
	assert(r <= n);
  80254f:	39 f0                	cmp    %esi,%eax
  802551:	77 24                	ja     802577 <devfile_read+0x56>
	assert(r <= PGSIZE);
  802553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802558:	7f 33                	jg     80258d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80255a:	83 ec 04             	sub    $0x4,%esp
  80255d:	50                   	push   %eax
  80255e:	68 00 60 80 00       	push   $0x806000
  802563:	ff 75 0c             	pushl  0xc(%ebp)
  802566:	e8 c1 ef ff ff       	call   80152c <memmove>
	return r;
  80256b:	83 c4 10             	add    $0x10,%esp
}
  80256e:	89 d8                	mov    %ebx,%eax
  802570:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5d                   	pop    %ebp
  802576:	c3                   	ret    
	assert(r <= n);
  802577:	68 2c 3e 80 00       	push   $0x803e2c
  80257c:	68 6f 36 80 00       	push   $0x80366f
  802581:	6a 7d                	push   $0x7d
  802583:	68 33 3e 80 00       	push   $0x803e33
  802588:	e8 05 e6 ff ff       	call   800b92 <_panic>
	assert(r <= PGSIZE);
  80258d:	68 3e 3e 80 00       	push   $0x803e3e
  802592:	68 6f 36 80 00       	push   $0x80366f
  802597:	6a 7e                	push   $0x7e
  802599:	68 33 3e 80 00       	push   $0x803e33
  80259e:	e8 ef e5 ff ff       	call   800b92 <_panic>

008025a3 <open>:
{
  8025a3:	55                   	push   %ebp
  8025a4:	89 e5                	mov    %esp,%ebp
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
  8025ab:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8025ae:	56                   	push   %esi
  8025af:	e8 b3 ed ff ff       	call   801367 <strlen>
  8025b4:	83 c4 10             	add    $0x10,%esp
  8025b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025bc:	0f 8f 96 00 00 00    	jg     802658 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8025c2:	83 ec 0c             	sub    $0xc,%esp
  8025c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025c8:	50                   	push   %eax
  8025c9:	e8 b0 f8 ff ff       	call   801e7e <fd_alloc>
  8025ce:	89 c3                	mov    %eax,%ebx
  8025d0:	83 c4 10             	add    $0x10,%esp
  8025d3:	85 c0                	test   %eax,%eax
  8025d5:	78 66                	js     80263d <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8025d7:	83 ec 08             	sub    $0x8,%esp
  8025da:	56                   	push   %esi
  8025db:	68 00 60 80 00       	push   $0x806000
  8025e0:	e8 b9 ed ff ff       	call   80139e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025e8:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8025ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f5:	e8 ef fd ff ff       	call   8023e9 <fsipc>
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	83 c4 10             	add    $0x10,%esp
  8025ff:	85 c0                	test   %eax,%eax
  802601:	78 43                	js     802646 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  802603:	83 ec 0c             	sub    $0xc,%esp
  802606:	ff 75 f4             	pushl  -0xc(%ebp)
  802609:	e8 49 f8 ff ff       	call   801e57 <fd2num>
  80260e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802611:	8b 0d 24 54 80 00    	mov    0x805424,%ecx
  802617:	8b 49 48             	mov    0x48(%ecx),%ecx
  80261a:	83 c4 08             	add    $0x8,%esp
  80261d:	50                   	push   %eax
  80261e:	52                   	push   %edx
  80261f:	ff 32                	pushl  (%edx)
  802621:	56                   	push   %esi
  802622:	51                   	push   %ecx
  802623:	68 4c 3e 80 00       	push   $0x803e4c
  802628:	e8 40 e6 ff ff       	call   800c6d <cprintf>
	return fd2num(fd);
  80262d:	83 c4 14             	add    $0x14,%esp
  802630:	ff 75 f4             	pushl  -0xc(%ebp)
  802633:	e8 1f f8 ff ff       	call   801e57 <fd2num>
  802638:	89 c3                	mov    %eax,%ebx
  80263a:	83 c4 10             	add    $0x10,%esp
}
  80263d:	89 d8                	mov    %ebx,%eax
  80263f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802642:	5b                   	pop    %ebx
  802643:	5e                   	pop    %esi
  802644:	5d                   	pop    %ebp
  802645:	c3                   	ret    
		fd_close(fd, 0);
  802646:	83 ec 08             	sub    $0x8,%esp
  802649:	6a 00                	push   $0x0
  80264b:	ff 75 f4             	pushl  -0xc(%ebp)
  80264e:	e8 26 f9 ff ff       	call   801f79 <fd_close>
		return r;
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	eb e5                	jmp    80263d <open+0x9a>
		return -E_BAD_PATH;
  802658:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80265d:	eb de                	jmp    80263d <open+0x9a>

0080265f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802665:	ba 00 00 00 00       	mov    $0x0,%edx
  80266a:	b8 08 00 00 00       	mov    $0x8,%eax
  80266f:	e8 75 fd ff ff       	call   8023e9 <fsipc>
}
  802674:	c9                   	leave  
  802675:	c3                   	ret    

00802676 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802676:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80267a:	7e 38                	jle    8026b4 <writebuf+0x3e>
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	53                   	push   %ebx
  802680:	83 ec 08             	sub    $0x8,%esp
  802683:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  802685:	ff 70 04             	pushl  0x4(%eax)
  802688:	8d 40 10             	lea    0x10(%eax),%eax
  80268b:	50                   	push   %eax
  80268c:	ff 33                	pushl  (%ebx)
  80268e:	e8 79 fb ff ff       	call   80220c <write>
		if (result > 0)
  802693:	83 c4 10             	add    $0x10,%esp
  802696:	85 c0                	test   %eax,%eax
  802698:	7e 03                	jle    80269d <writebuf+0x27>
			b->result += result;
  80269a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80269d:	39 43 04             	cmp    %eax,0x4(%ebx)
  8026a0:	74 0d                	je     8026af <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8026a2:	85 c0                	test   %eax,%eax
  8026a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8026a9:	0f 4f c2             	cmovg  %edx,%eax
  8026ac:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8026af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026b2:	c9                   	leave  
  8026b3:	c3                   	ret    
  8026b4:	f3 c3                	repz ret 

008026b6 <putch>:

static void
putch(int ch, void *thunk)
{
  8026b6:	55                   	push   %ebp
  8026b7:	89 e5                	mov    %esp,%ebp
  8026b9:	53                   	push   %ebx
  8026ba:	83 ec 04             	sub    $0x4,%esp
  8026bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8026c0:	8b 53 04             	mov    0x4(%ebx),%edx
  8026c3:	8d 42 01             	lea    0x1(%edx),%eax
  8026c6:	89 43 04             	mov    %eax,0x4(%ebx)
  8026c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026cc:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8026d0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8026d5:	74 06                	je     8026dd <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8026d7:	83 c4 04             	add    $0x4,%esp
  8026da:	5b                   	pop    %ebx
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
		writebuf(b);
  8026dd:	89 d8                	mov    %ebx,%eax
  8026df:	e8 92 ff ff ff       	call   802676 <writebuf>
		b->idx = 0;
  8026e4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8026eb:	eb ea                	jmp    8026d7 <putch+0x21>

008026ed <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026ed:	55                   	push   %ebp
  8026ee:	89 e5                	mov    %esp,%ebp
  8026f0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8026f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f9:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8026ff:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802706:	00 00 00 
	b.result = 0;
  802709:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802710:	00 00 00 
	b.error = 1;
  802713:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80271a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80271d:	ff 75 10             	pushl  0x10(%ebp)
  802720:	ff 75 0c             	pushl  0xc(%ebp)
  802723:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802729:	50                   	push   %eax
  80272a:	68 b6 26 80 00       	push   $0x8026b6
  80272f:	e8 36 e6 ff ff       	call   800d6a <vprintfmt>
	if (b.idx > 0)
  802734:	83 c4 10             	add    $0x10,%esp
  802737:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80273e:	7f 11                	jg     802751 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  802740:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802746:	85 c0                	test   %eax,%eax
  802748:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80274f:	c9                   	leave  
  802750:	c3                   	ret    
		writebuf(&b);
  802751:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802757:	e8 1a ff ff ff       	call   802676 <writebuf>
  80275c:	eb e2                	jmp    802740 <vfprintf+0x53>

0080275e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802764:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802767:	50                   	push   %eax
  802768:	ff 75 0c             	pushl  0xc(%ebp)
  80276b:	ff 75 08             	pushl  0x8(%ebp)
  80276e:	e8 7a ff ff ff       	call   8026ed <vfprintf>
	va_end(ap);

	return cnt;
}
  802773:	c9                   	leave  
  802774:	c3                   	ret    

00802775 <printf>:

int
printf(const char *fmt, ...)
{
  802775:	55                   	push   %ebp
  802776:	89 e5                	mov    %esp,%ebp
  802778:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80277b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80277e:	50                   	push   %eax
  80277f:	ff 75 08             	pushl  0x8(%ebp)
  802782:	6a 01                	push   $0x1
  802784:	e8 64 ff ff ff       	call   8026ed <vfprintf>
	va_end(ap);

	return cnt;
}
  802789:	c9                   	leave  
  80278a:	c3                   	ret    

0080278b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80278b:	55                   	push   %ebp
  80278c:	89 e5                	mov    %esp,%ebp
  80278e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802791:	89 d0                	mov    %edx,%eax
  802793:	c1 e8 16             	shr    $0x16,%eax
  802796:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80279d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8027a2:	f6 c1 01             	test   $0x1,%cl
  8027a5:	74 1d                	je     8027c4 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8027a7:	c1 ea 0c             	shr    $0xc,%edx
  8027aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027b1:	f6 c2 01             	test   $0x1,%dl
  8027b4:	74 0e                	je     8027c4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027b6:	c1 ea 0c             	shr    $0xc,%edx
  8027b9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027c0:	ef 
  8027c1:	0f b7 c0             	movzwl %ax,%eax
}
  8027c4:	5d                   	pop    %ebp
  8027c5:	c3                   	ret    

008027c6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027c6:	55                   	push   %ebp
  8027c7:	89 e5                	mov    %esp,%ebp
  8027c9:	57                   	push   %edi
  8027ca:	56                   	push   %esi
  8027cb:	53                   	push   %ebx
  8027cc:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027d2:	6a 00                	push   $0x0
  8027d4:	ff 75 08             	pushl  0x8(%ebp)
  8027d7:	e8 c7 fd ff ff       	call   8025a3 <open>
  8027dc:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8027e2:	83 c4 10             	add    $0x10,%esp
  8027e5:	85 c0                	test   %eax,%eax
  8027e7:	0f 88 40 03 00 00    	js     802b2d <spawn+0x367>
  8027ed:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8027ef:	83 ec 04             	sub    $0x4,%esp
  8027f2:	68 00 02 00 00       	push   $0x200
  8027f7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8027fd:	50                   	push   %eax
  8027fe:	51                   	push   %ecx
  8027ff:	e8 c1 f9 ff ff       	call   8021c5 <readn>
  802804:	83 c4 10             	add    $0x10,%esp
  802807:	3d 00 02 00 00       	cmp    $0x200,%eax
  80280c:	75 5d                	jne    80286b <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  80280e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802815:	45 4c 46 
  802818:	75 51                	jne    80286b <spawn+0xa5>
  80281a:	b8 07 00 00 00       	mov    $0x7,%eax
  80281f:	cd 30                	int    $0x30
  802821:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802827:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80282d:	85 c0                	test   %eax,%eax
  80282f:	0f 88 79 04 00 00    	js     802cae <spawn+0x4e8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802835:	25 ff 03 00 00       	and    $0x3ff,%eax
  80283a:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80283d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802843:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802849:	b9 11 00 00 00       	mov    $0x11,%ecx
  80284e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802850:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802856:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80285c:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  802861:	be 00 00 00 00       	mov    $0x0,%esi
  802866:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802869:	eb 4b                	jmp    8028b6 <spawn+0xf0>
		close(fd);
  80286b:	83 ec 0c             	sub    $0xc,%esp
  80286e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802874:	e8 89 f7 ff ff       	call   802002 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802879:	83 c4 0c             	add    $0xc,%esp
  80287c:	68 7f 45 4c 46       	push   $0x464c457f
  802881:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802887:	68 8b 3e 80 00       	push   $0x803e8b
  80288c:	e8 dc e3 ff ff       	call   800c6d <cprintf>
		return -E_NOT_EXEC;
  802891:	83 c4 10             	add    $0x10,%esp
  802894:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  80289b:	ff ff ff 
  80289e:	e9 8a 02 00 00       	jmp    802b2d <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  8028a3:	83 ec 0c             	sub    $0xc,%esp
  8028a6:	50                   	push   %eax
  8028a7:	e8 bb ea ff ff       	call   801367 <strlen>
  8028ac:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8028b0:	83 c3 01             	add    $0x1,%ebx
  8028b3:	83 c4 10             	add    $0x10,%esp
  8028b6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8028bd:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8028c0:	85 c0                	test   %eax,%eax
  8028c2:	75 df                	jne    8028a3 <spawn+0xdd>
  8028c4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8028ca:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8028d0:	bf 00 10 40 00       	mov    $0x401000,%edi
  8028d5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8028d7:	89 fa                	mov    %edi,%edx
  8028d9:	83 e2 fc             	and    $0xfffffffc,%edx
  8028dc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8028e3:	29 c2                	sub    %eax,%edx
  8028e5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8028eb:	8d 42 f8             	lea    -0x8(%edx),%eax
  8028ee:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8028f3:	0f 86 c6 03 00 00    	jbe    802cbf <spawn+0x4f9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8028f9:	83 ec 04             	sub    $0x4,%esp
  8028fc:	6a 07                	push   $0x7
  8028fe:	68 00 00 40 00       	push   $0x400000
  802903:	6a 00                	push   $0x0
  802905:	e8 8d ee ff ff       	call   801797 <sys_page_alloc>
  80290a:	83 c4 10             	add    $0x10,%esp
  80290d:	85 c0                	test   %eax,%eax
  80290f:	0f 88 af 03 00 00    	js     802cc4 <spawn+0x4fe>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802915:	be 00 00 00 00       	mov    $0x0,%esi
  80291a:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802923:	eb 30                	jmp    802955 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  802925:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80292b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802931:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802934:	83 ec 08             	sub    $0x8,%esp
  802937:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80293a:	57                   	push   %edi
  80293b:	e8 5e ea ff ff       	call   80139e <strcpy>
		string_store += strlen(argv[i]) + 1;
  802940:	83 c4 04             	add    $0x4,%esp
  802943:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802946:	e8 1c ea ff ff       	call   801367 <strlen>
  80294b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  80294f:	83 c6 01             	add    $0x1,%esi
  802952:	83 c4 10             	add    $0x10,%esp
  802955:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  80295b:	7f c8                	jg     802925 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  80295d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802963:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802969:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802970:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802976:	0f 85 8c 00 00 00    	jne    802a08 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80297c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802982:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802988:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80298b:	89 f8                	mov    %edi,%eax
  80298d:	8b 8d 88 fd ff ff    	mov    -0x278(%ebp),%ecx
  802993:	89 4f f8             	mov    %ecx,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802996:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80299b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8029a1:	83 ec 0c             	sub    $0xc,%esp
  8029a4:	6a 07                	push   $0x7
  8029a6:	68 00 d0 bf ee       	push   $0xeebfd000
  8029ab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029b1:	68 00 00 40 00       	push   $0x400000
  8029b6:	6a 00                	push   $0x0
  8029b8:	e8 1d ee ff ff       	call   8017da <sys_page_map>
  8029bd:	89 c3                	mov    %eax,%ebx
  8029bf:	83 c4 20             	add    $0x20,%esp
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	0f 88 70 03 00 00    	js     802d3a <spawn+0x574>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8029ca:	83 ec 08             	sub    $0x8,%esp
  8029cd:	68 00 00 40 00       	push   $0x400000
  8029d2:	6a 00                	push   $0x0
  8029d4:	e8 43 ee ff ff       	call   80181c <sys_page_unmap>
  8029d9:	89 c3                	mov    %eax,%ebx
  8029db:	83 c4 10             	add    $0x10,%esp
  8029de:	85 c0                	test   %eax,%eax
  8029e0:	0f 88 54 03 00 00    	js     802d3a <spawn+0x574>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8029e6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8029ec:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8029f3:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8029f9:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802a00:	00 00 00 
  802a03:	e9 56 01 00 00       	jmp    802b5e <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  802a08:	68 00 3f 80 00       	push   $0x803f00
  802a0d:	68 6f 36 80 00       	push   $0x80366f
  802a12:	68 f6 00 00 00       	push   $0xf6
  802a17:	68 a5 3e 80 00       	push   $0x803ea5
  802a1c:	e8 71 e1 ff ff       	call   800b92 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a21:	83 ec 04             	sub    $0x4,%esp
  802a24:	6a 07                	push   $0x7
  802a26:	68 00 00 40 00       	push   $0x400000
  802a2b:	6a 00                	push   $0x0
  802a2d:	e8 65 ed ff ff       	call   801797 <sys_page_alloc>
  802a32:	83 c4 10             	add    $0x10,%esp
  802a35:	85 c0                	test   %eax,%eax
  802a37:	0f 88 92 02 00 00    	js     802ccf <spawn+0x509>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a3d:	83 ec 08             	sub    $0x8,%esp
  802a40:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a46:	01 f0                	add    %esi,%eax
  802a48:	50                   	push   %eax
  802a49:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802a4f:	e8 3a f8 ff ff       	call   80228e <seek>
  802a54:	83 c4 10             	add    $0x10,%esp
  802a57:	85 c0                	test   %eax,%eax
  802a59:	0f 88 77 02 00 00    	js     802cd6 <spawn+0x510>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a5f:	83 ec 04             	sub    $0x4,%esp
  802a62:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802a68:	29 f0                	sub    %esi,%eax
  802a6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802a6f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802a74:	0f 47 c1             	cmova  %ecx,%eax
  802a77:	50                   	push   %eax
  802a78:	68 00 00 40 00       	push   $0x400000
  802a7d:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802a83:	e8 3d f7 ff ff       	call   8021c5 <readn>
  802a88:	83 c4 10             	add    $0x10,%esp
  802a8b:	85 c0                	test   %eax,%eax
  802a8d:	0f 88 4a 02 00 00    	js     802cdd <spawn+0x517>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802a93:	83 ec 0c             	sub    $0xc,%esp
  802a96:	57                   	push   %edi
  802a97:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  802a9d:	56                   	push   %esi
  802a9e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802aa4:	68 00 00 40 00       	push   $0x400000
  802aa9:	6a 00                	push   $0x0
  802aab:	e8 2a ed ff ff       	call   8017da <sys_page_map>
  802ab0:	83 c4 20             	add    $0x20,%esp
  802ab3:	85 c0                	test   %eax,%eax
  802ab5:	0f 88 80 00 00 00    	js     802b3b <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  802abb:	83 ec 08             	sub    $0x8,%esp
  802abe:	68 00 00 40 00       	push   $0x400000
  802ac3:	6a 00                	push   $0x0
  802ac5:	e8 52 ed ff ff       	call   80181c <sys_page_unmap>
  802aca:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802acd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802ad3:	89 de                	mov    %ebx,%esi
  802ad5:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802adb:	76 73                	jbe    802b50 <spawn+0x38a>
		if (i >= filesz) {
  802add:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802ae3:	0f 87 38 ff ff ff    	ja     802a21 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802ae9:	83 ec 04             	sub    $0x4,%esp
  802aec:	57                   	push   %edi
  802aed:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  802af3:	56                   	push   %esi
  802af4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802afa:	e8 98 ec ff ff       	call   801797 <sys_page_alloc>
  802aff:	83 c4 10             	add    $0x10,%esp
  802b02:	85 c0                	test   %eax,%eax
  802b04:	79 c7                	jns    802acd <spawn+0x307>
  802b06:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802b08:	83 ec 0c             	sub    $0xc,%esp
  802b0b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802b11:	e8 02 ec ff ff       	call   801718 <sys_env_destroy>
	close(fd);
  802b16:	83 c4 04             	add    $0x4,%esp
  802b19:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802b1f:	e8 de f4 ff ff       	call   802002 <close>
	return r;
  802b24:	83 c4 10             	add    $0x10,%esp
  802b27:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  802b2d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b36:	5b                   	pop    %ebx
  802b37:	5e                   	pop    %esi
  802b38:	5f                   	pop    %edi
  802b39:	5d                   	pop    %ebp
  802b3a:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  802b3b:	50                   	push   %eax
  802b3c:	68 b1 3e 80 00       	push   $0x803eb1
  802b41:	68 29 01 00 00       	push   $0x129
  802b46:	68 a5 3e 80 00       	push   $0x803ea5
  802b4b:	e8 42 e0 ff ff       	call   800b92 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b50:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802b57:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  802b5e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802b65:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802b6b:	7e 71                	jle    802bde <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  802b6d:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  802b73:	83 3a 01             	cmpl   $0x1,(%edx)
  802b76:	75 d8                	jne    802b50 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802b78:	8b 42 18             	mov    0x18(%edx),%eax
  802b7b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802b7e:	83 f8 01             	cmp    $0x1,%eax
  802b81:	19 ff                	sbb    %edi,%edi
  802b83:	83 e7 fe             	and    $0xfffffffe,%edi
  802b86:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802b89:	8b 72 04             	mov    0x4(%edx),%esi
  802b8c:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802b92:	8b 5a 10             	mov    0x10(%edx),%ebx
  802b95:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802b9b:	8b 42 14             	mov    0x14(%edx),%eax
  802b9e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802ba4:	8b 4a 08             	mov    0x8(%edx),%ecx
  802ba7:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  802bad:	89 c8                	mov    %ecx,%eax
  802baf:	25 ff 0f 00 00       	and    $0xfff,%eax
  802bb4:	74 1e                	je     802bd4 <spawn+0x40e>
		va -= i;
  802bb6:	29 c1                	sub    %eax,%ecx
  802bb8:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
		memsz += i;
  802bbe:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802bc4:	01 c3                	add    %eax,%ebx
  802bc6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  802bcc:	29 c6                	sub    %eax,%esi
  802bce:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  802bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bd9:	e9 f5 fe ff ff       	jmp    802ad3 <spawn+0x30d>
	close(fd);
  802bde:	83 ec 0c             	sub    $0xc,%esp
  802be1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802be7:	e8 16 f4 ff ff       	call   802002 <close>
  802bec:	83 c4 10             	add    $0x10,%esp
  802bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bf4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  802bfa:	eb 12                	jmp    802c0e <spawn+0x448>
  802bfc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// LAB 5: Your code here.
    uint32_t *va;
    pte_t pte;
    int perm, r;
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  802c02:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  802c08:	0f 84 d6 00 00 00    	je     802ce4 <spawn+0x51e>
        va = (void *)(i*PGSIZE);
        if (!(uvpd[PDX(va)] & PTE_P) || !(uvpt[PGNUM(va)] & PTE_P))
  802c0e:	89 d8                	mov    %ebx,%eax
  802c10:	c1 e8 16             	shr    $0x16,%eax
  802c13:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c1a:	a8 01                	test   $0x1,%al
  802c1c:	74 de                	je     802bfc <spawn+0x436>
  802c1e:	89 d8                	mov    %ebx,%eax
  802c20:	c1 e8 0c             	shr    $0xc,%eax
  802c23:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c2a:	f6 c2 01             	test   $0x1,%dl
  802c2d:	74 cd                	je     802bfc <spawn+0x436>
            continue;
        pte = (pte_t)uvpt[PGNUM(va)];
  802c2f:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
        if (!(pte & PTE_SHARE))
  802c36:	f7 c7 00 04 00 00    	test   $0x400,%edi
  802c3c:	74 be                	je     802bfc <spawn+0x436>
            continue;
        cprintf("[%08x] -------- shared --------- va=%x \n", thisenv->env_id, va);
  802c3e:	a1 24 54 80 00       	mov    0x805424,%eax
  802c43:	8b 40 48             	mov    0x48(%eax),%eax
  802c46:	83 ec 04             	sub    $0x4,%esp
  802c49:	53                   	push   %ebx
  802c4a:	50                   	push   %eax
  802c4b:	68 28 3f 80 00       	push   $0x803f28
  802c50:	e8 18 e0 ff ff       	call   800c6d <cprintf>
        perm = pte & PTE_SYSCALL;
  802c55:	81 e7 07 0e 00 00    	and    $0xe07,%edi
        if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  802c5b:	89 3c 24             	mov    %edi,(%esp)
  802c5e:	53                   	push   %ebx
  802c5f:	56                   	push   %esi
  802c60:	53                   	push   %ebx
  802c61:	6a 00                	push   $0x0
  802c63:	e8 72 eb ff ff       	call   8017da <sys_page_map>
  802c68:	83 c4 20             	add    $0x20,%esp
  802c6b:	85 c0                	test   %eax,%eax
  802c6d:	79 8d                	jns    802bfc <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  802c6f:	50                   	push   %eax
  802c70:	68 e8 3e 80 00       	push   $0x803ee8
  802c75:	68 82 00 00 00       	push   $0x82
  802c7a:	68 a5 3e 80 00       	push   $0x803ea5
  802c7f:	e8 0e df ff ff       	call   800b92 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802c84:	50                   	push   %eax
  802c85:	68 ce 3e 80 00       	push   $0x803ece
  802c8a:	68 86 00 00 00       	push   $0x86
  802c8f:	68 a5 3e 80 00       	push   $0x803ea5
  802c94:	e8 f9 de ff ff       	call   800b92 <_panic>
		panic("sys_env_set_status: %e", r);
  802c99:	50                   	push   %eax
  802c9a:	68 71 3d 80 00       	push   $0x803d71
  802c9f:	68 89 00 00 00       	push   $0x89
  802ca4:	68 a5 3e 80 00       	push   $0x803ea5
  802ca9:	e8 e4 de ff ff       	call   800b92 <_panic>
		return r;
  802cae:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802cb4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802cba:	e9 6e fe ff ff       	jmp    802b2d <spawn+0x367>
		return -E_NO_MEM;
  802cbf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802cc4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802cca:	e9 5e fe ff ff       	jmp    802b2d <spawn+0x367>
  802ccf:	89 c7                	mov    %eax,%edi
  802cd1:	e9 32 fe ff ff       	jmp    802b08 <spawn+0x342>
  802cd6:	89 c7                	mov    %eax,%edi
  802cd8:	e9 2b fe ff ff       	jmp    802b08 <spawn+0x342>
  802cdd:	89 c7                	mov    %eax,%edi
  802cdf:	e9 24 fe ff ff       	jmp    802b08 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802ce4:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802ceb:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802cee:	83 ec 08             	sub    $0x8,%esp
  802cf1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802cf7:	50                   	push   %eax
  802cf8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802cfe:	e8 9d eb ff ff       	call   8018a0 <sys_env_set_trapframe>
  802d03:	83 c4 10             	add    $0x10,%esp
  802d06:	85 c0                	test   %eax,%eax
  802d08:	0f 88 76 ff ff ff    	js     802c84 <spawn+0x4be>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802d0e:	83 ec 08             	sub    $0x8,%esp
  802d11:	6a 02                	push   $0x2
  802d13:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802d19:	e8 40 eb ff ff       	call   80185e <sys_env_set_status>
  802d1e:	83 c4 10             	add    $0x10,%esp
  802d21:	85 c0                	test   %eax,%eax
  802d23:	0f 88 70 ff ff ff    	js     802c99 <spawn+0x4d3>
	return child;
  802d29:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d2f:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802d35:	e9 f3 fd ff ff       	jmp    802b2d <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  802d3a:	83 ec 08             	sub    $0x8,%esp
  802d3d:	68 00 00 40 00       	push   $0x400000
  802d42:	6a 00                	push   $0x0
  802d44:	e8 d3 ea ff ff       	call   80181c <sys_page_unmap>
  802d49:	83 c4 10             	add    $0x10,%esp
  802d4c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802d52:	e9 d6 fd ff ff       	jmp    802b2d <spawn+0x367>

00802d57 <spawnl>:
{
  802d57:	55                   	push   %ebp
  802d58:	89 e5                	mov    %esp,%ebp
  802d5a:	57                   	push   %edi
  802d5b:	56                   	push   %esi
  802d5c:	53                   	push   %ebx
  802d5d:	83 ec 1c             	sub    $0x1c,%esp
	va_start(vl, arg0);
  802d60:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  802d63:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(va_arg(vl, void *) != NULL)
  802d68:	eb 05                	jmp    802d6f <spawnl+0x18>
		argc++;
  802d6a:	83 c3 01             	add    $0x1,%ebx
	while(va_arg(vl, void *) != NULL)
  802d6d:	89 d0                	mov    %edx,%eax
  802d6f:	8d 50 04             	lea    0x4(%eax),%edx
  802d72:	83 38 00             	cmpl   $0x0,(%eax)
  802d75:	75 f3                	jne    802d6a <spawnl+0x13>
	const char *argv[argc+2];
  802d77:	8d 04 9d 1a 00 00 00 	lea    0x1a(,%ebx,4),%eax
  802d7e:	83 e0 f0             	and    $0xfffffff0,%eax
  802d81:	29 c4                	sub    %eax,%esp
  802d83:	8d 44 24 03          	lea    0x3(%esp),%eax
  802d87:	c1 e8 02             	shr    $0x2,%eax
  802d8a:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802d91:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802d94:	89 f7                	mov    %esi,%edi
	argv[0] = arg0;
  802d96:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d99:	89 14 85 00 00 00 00 	mov    %edx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802da0:	c7 44 9e 04 00 00 00 	movl   $0x0,0x4(%esi,%ebx,4)
  802da7:	00 
	va_start(vl, arg0);
  802da8:	8d 75 10             	lea    0x10(%ebp),%esi
    cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[0]);
  802dab:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802db1:	8b 52 48             	mov    0x48(%edx),%edx
  802db4:	83 ec 04             	sub    $0x4,%esp
  802db7:	ff 34 85 00 00 00 00 	pushl  0x0(,%eax,4)
  802dbe:	52                   	push   %edx
  802dbf:	68 54 3f 80 00       	push   $0x803f54
  802dc4:	e8 a4 de ff ff       	call   800c6d <cprintf>
  802dc9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<argc;i++) {
  802dcc:	83 c4 10             	add    $0x10,%esp
  802dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dd4:	89 f0                	mov    %esi,%eax
  802dd6:	89 fe                	mov    %edi,%esi
  802dd8:	eb 28                	jmp    802e02 <spawnl+0xab>
        argv[i+1] = va_arg(vl, const char *);
  802dda:	83 c3 01             	add    $0x1,%ebx
  802ddd:	8d 78 04             	lea    0x4(%eax),%edi
  802de0:	8b 00                	mov    (%eax),%eax
  802de2:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
        cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[i+1]);
  802de5:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802deb:	8b 52 48             	mov    0x48(%edx),%edx
  802dee:	83 ec 04             	sub    $0x4,%esp
  802df1:	50                   	push   %eax
  802df2:	52                   	push   %edx
  802df3:	68 54 3f 80 00       	push   $0x803f54
  802df8:	e8 70 de ff ff       	call   800c6d <cprintf>
	for(i=0;i<argc;i++) {
  802dfd:	83 c4 10             	add    $0x10,%esp
        argv[i+1] = va_arg(vl, const char *);
  802e00:	89 f8                	mov    %edi,%eax
	for(i=0;i<argc;i++) {
  802e02:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  802e05:	75 d3                	jne    802dda <spawnl+0x83>
	return spawn(prog, argv);
  802e07:	83 ec 08             	sub    $0x8,%esp
  802e0a:	ff 75 e0             	pushl  -0x20(%ebp)
  802e0d:	ff 75 08             	pushl  0x8(%ebp)
  802e10:	e8 b1 f9 ff ff       	call   8027c6 <spawn>
}
  802e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e18:	5b                   	pop    %ebx
  802e19:	5e                   	pop    %esi
  802e1a:	5f                   	pop    %edi
  802e1b:	5d                   	pop    %ebp
  802e1c:	c3                   	ret    

00802e1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802e1d:	55                   	push   %ebp
  802e1e:	89 e5                	mov    %esp,%ebp
  802e20:	56                   	push   %esi
  802e21:	53                   	push   %ebx
  802e22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802e25:	83 ec 0c             	sub    $0xc,%esp
  802e28:	ff 75 08             	pushl  0x8(%ebp)
  802e2b:	e8 37 f0 ff ff       	call   801e67 <fd2data>
  802e30:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802e32:	83 c4 08             	add    $0x8,%esp
  802e35:	68 7c 3f 80 00       	push   $0x803f7c
  802e3a:	53                   	push   %ebx
  802e3b:	e8 5e e5 ff ff       	call   80139e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802e40:	8b 46 04             	mov    0x4(%esi),%eax
  802e43:	2b 06                	sub    (%esi),%eax
  802e45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802e4b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e52:	00 00 00 
	stat->st_dev = &devpipe;
  802e55:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802e5c:	40 80 00 
	return 0;
}
  802e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  802e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e67:	5b                   	pop    %ebx
  802e68:	5e                   	pop    %esi
  802e69:	5d                   	pop    %ebp
  802e6a:	c3                   	ret    

00802e6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802e6b:	55                   	push   %ebp
  802e6c:	89 e5                	mov    %esp,%ebp
  802e6e:	53                   	push   %ebx
  802e6f:	83 ec 0c             	sub    $0xc,%esp
  802e72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802e75:	53                   	push   %ebx
  802e76:	6a 00                	push   $0x0
  802e78:	e8 9f e9 ff ff       	call   80181c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802e7d:	89 1c 24             	mov    %ebx,(%esp)
  802e80:	e8 e2 ef ff ff       	call   801e67 <fd2data>
  802e85:	83 c4 08             	add    $0x8,%esp
  802e88:	50                   	push   %eax
  802e89:	6a 00                	push   $0x0
  802e8b:	e8 8c e9 ff ff       	call   80181c <sys_page_unmap>
}
  802e90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e93:	c9                   	leave  
  802e94:	c3                   	ret    

00802e95 <_pipeisclosed>:
{
  802e95:	55                   	push   %ebp
  802e96:	89 e5                	mov    %esp,%ebp
  802e98:	57                   	push   %edi
  802e99:	56                   	push   %esi
  802e9a:	53                   	push   %ebx
  802e9b:	83 ec 1c             	sub    $0x1c,%esp
  802e9e:	89 c7                	mov    %eax,%edi
  802ea0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802ea2:	a1 24 54 80 00       	mov    0x805424,%eax
  802ea7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802eaa:	83 ec 0c             	sub    $0xc,%esp
  802ead:	57                   	push   %edi
  802eae:	e8 d8 f8 ff ff       	call   80278b <pageref>
  802eb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802eb6:	89 34 24             	mov    %esi,(%esp)
  802eb9:	e8 cd f8 ff ff       	call   80278b <pageref>
		nn = thisenv->env_runs;
  802ebe:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802ec4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802ec7:	83 c4 10             	add    $0x10,%esp
  802eca:	39 cb                	cmp    %ecx,%ebx
  802ecc:	74 1b                	je     802ee9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802ece:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802ed1:	75 cf                	jne    802ea2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802ed3:	8b 42 58             	mov    0x58(%edx),%eax
  802ed6:	6a 01                	push   $0x1
  802ed8:	50                   	push   %eax
  802ed9:	53                   	push   %ebx
  802eda:	68 83 3f 80 00       	push   $0x803f83
  802edf:	e8 89 dd ff ff       	call   800c6d <cprintf>
  802ee4:	83 c4 10             	add    $0x10,%esp
  802ee7:	eb b9                	jmp    802ea2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802ee9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802eec:	0f 94 c0             	sete   %al
  802eef:	0f b6 c0             	movzbl %al,%eax
}
  802ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ef5:	5b                   	pop    %ebx
  802ef6:	5e                   	pop    %esi
  802ef7:	5f                   	pop    %edi
  802ef8:	5d                   	pop    %ebp
  802ef9:	c3                   	ret    

00802efa <devpipe_write>:
{
  802efa:	55                   	push   %ebp
  802efb:	89 e5                	mov    %esp,%ebp
  802efd:	57                   	push   %edi
  802efe:	56                   	push   %esi
  802eff:	53                   	push   %ebx
  802f00:	83 ec 28             	sub    $0x28,%esp
  802f03:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802f06:	56                   	push   %esi
  802f07:	e8 5b ef ff ff       	call   801e67 <fd2data>
  802f0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802f0e:	83 c4 10             	add    $0x10,%esp
  802f11:	bf 00 00 00 00       	mov    $0x0,%edi
  802f16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802f19:	74 4f                	je     802f6a <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802f1b:	8b 43 04             	mov    0x4(%ebx),%eax
  802f1e:	8b 0b                	mov    (%ebx),%ecx
  802f20:	8d 51 20             	lea    0x20(%ecx),%edx
  802f23:	39 d0                	cmp    %edx,%eax
  802f25:	72 14                	jb     802f3b <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  802f27:	89 da                	mov    %ebx,%edx
  802f29:	89 f0                	mov    %esi,%eax
  802f2b:	e8 65 ff ff ff       	call   802e95 <_pipeisclosed>
  802f30:	85 c0                	test   %eax,%eax
  802f32:	75 3a                	jne    802f6e <devpipe_write+0x74>
			sys_yield();
  802f34:	e8 3f e8 ff ff       	call   801778 <sys_yield>
  802f39:	eb e0                	jmp    802f1b <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f3e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802f42:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802f45:	89 c2                	mov    %eax,%edx
  802f47:	c1 fa 1f             	sar    $0x1f,%edx
  802f4a:	89 d1                	mov    %edx,%ecx
  802f4c:	c1 e9 1b             	shr    $0x1b,%ecx
  802f4f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802f52:	83 e2 1f             	and    $0x1f,%edx
  802f55:	29 ca                	sub    %ecx,%edx
  802f57:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802f5b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802f5f:	83 c0 01             	add    $0x1,%eax
  802f62:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802f65:	83 c7 01             	add    $0x1,%edi
  802f68:	eb ac                	jmp    802f16 <devpipe_write+0x1c>
	return i;
  802f6a:	89 f8                	mov    %edi,%eax
  802f6c:	eb 05                	jmp    802f73 <devpipe_write+0x79>
				return 0;
  802f6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f76:	5b                   	pop    %ebx
  802f77:	5e                   	pop    %esi
  802f78:	5f                   	pop    %edi
  802f79:	5d                   	pop    %ebp
  802f7a:	c3                   	ret    

00802f7b <devpipe_read>:
{
  802f7b:	55                   	push   %ebp
  802f7c:	89 e5                	mov    %esp,%ebp
  802f7e:	57                   	push   %edi
  802f7f:	56                   	push   %esi
  802f80:	53                   	push   %ebx
  802f81:	83 ec 18             	sub    $0x18,%esp
  802f84:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802f87:	57                   	push   %edi
  802f88:	e8 da ee ff ff       	call   801e67 <fd2data>
  802f8d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802f8f:	83 c4 10             	add    $0x10,%esp
  802f92:	be 00 00 00 00       	mov    $0x0,%esi
  802f97:	3b 75 10             	cmp    0x10(%ebp),%esi
  802f9a:	74 47                	je     802fe3 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802f9c:	8b 03                	mov    (%ebx),%eax
  802f9e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802fa1:	75 22                	jne    802fc5 <devpipe_read+0x4a>
			if (i > 0)
  802fa3:	85 f6                	test   %esi,%esi
  802fa5:	75 14                	jne    802fbb <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802fa7:	89 da                	mov    %ebx,%edx
  802fa9:	89 f8                	mov    %edi,%eax
  802fab:	e8 e5 fe ff ff       	call   802e95 <_pipeisclosed>
  802fb0:	85 c0                	test   %eax,%eax
  802fb2:	75 33                	jne    802fe7 <devpipe_read+0x6c>
			sys_yield();
  802fb4:	e8 bf e7 ff ff       	call   801778 <sys_yield>
  802fb9:	eb e1                	jmp    802f9c <devpipe_read+0x21>
				return i;
  802fbb:	89 f0                	mov    %esi,%eax
}
  802fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fc0:	5b                   	pop    %ebx
  802fc1:	5e                   	pop    %esi
  802fc2:	5f                   	pop    %edi
  802fc3:	5d                   	pop    %ebp
  802fc4:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802fc5:	99                   	cltd   
  802fc6:	c1 ea 1b             	shr    $0x1b,%edx
  802fc9:	01 d0                	add    %edx,%eax
  802fcb:	83 e0 1f             	and    $0x1f,%eax
  802fce:	29 d0                	sub    %edx,%eax
  802fd0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802fd8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802fdb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802fde:	83 c6 01             	add    $0x1,%esi
  802fe1:	eb b4                	jmp    802f97 <devpipe_read+0x1c>
	return i;
  802fe3:	89 f0                	mov    %esi,%eax
  802fe5:	eb d6                	jmp    802fbd <devpipe_read+0x42>
				return 0;
  802fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  802fec:	eb cf                	jmp    802fbd <devpipe_read+0x42>

00802fee <pipe>:
{
  802fee:	55                   	push   %ebp
  802fef:	89 e5                	mov    %esp,%ebp
  802ff1:	56                   	push   %esi
  802ff2:	53                   	push   %ebx
  802ff3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ff9:	50                   	push   %eax
  802ffa:	e8 7f ee ff ff       	call   801e7e <fd_alloc>
  802fff:	89 c3                	mov    %eax,%ebx
  803001:	83 c4 10             	add    $0x10,%esp
  803004:	85 c0                	test   %eax,%eax
  803006:	78 5b                	js     803063 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803008:	83 ec 04             	sub    $0x4,%esp
  80300b:	68 07 04 00 00       	push   $0x407
  803010:	ff 75 f4             	pushl  -0xc(%ebp)
  803013:	6a 00                	push   $0x0
  803015:	e8 7d e7 ff ff       	call   801797 <sys_page_alloc>
  80301a:	89 c3                	mov    %eax,%ebx
  80301c:	83 c4 10             	add    $0x10,%esp
  80301f:	85 c0                	test   %eax,%eax
  803021:	78 40                	js     803063 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  803023:	83 ec 0c             	sub    $0xc,%esp
  803026:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803029:	50                   	push   %eax
  80302a:	e8 4f ee ff ff       	call   801e7e <fd_alloc>
  80302f:	89 c3                	mov    %eax,%ebx
  803031:	83 c4 10             	add    $0x10,%esp
  803034:	85 c0                	test   %eax,%eax
  803036:	78 1b                	js     803053 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803038:	83 ec 04             	sub    $0x4,%esp
  80303b:	68 07 04 00 00       	push   $0x407
  803040:	ff 75 f0             	pushl  -0x10(%ebp)
  803043:	6a 00                	push   $0x0
  803045:	e8 4d e7 ff ff       	call   801797 <sys_page_alloc>
  80304a:	89 c3                	mov    %eax,%ebx
  80304c:	83 c4 10             	add    $0x10,%esp
  80304f:	85 c0                	test   %eax,%eax
  803051:	79 19                	jns    80306c <pipe+0x7e>
	sys_page_unmap(0, fd0);
  803053:	83 ec 08             	sub    $0x8,%esp
  803056:	ff 75 f4             	pushl  -0xc(%ebp)
  803059:	6a 00                	push   $0x0
  80305b:	e8 bc e7 ff ff       	call   80181c <sys_page_unmap>
  803060:	83 c4 10             	add    $0x10,%esp
}
  803063:	89 d8                	mov    %ebx,%eax
  803065:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803068:	5b                   	pop    %ebx
  803069:	5e                   	pop    %esi
  80306a:	5d                   	pop    %ebp
  80306b:	c3                   	ret    
	va = fd2data(fd0);
  80306c:	83 ec 0c             	sub    $0xc,%esp
  80306f:	ff 75 f4             	pushl  -0xc(%ebp)
  803072:	e8 f0 ed ff ff       	call   801e67 <fd2data>
  803077:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803079:	83 c4 0c             	add    $0xc,%esp
  80307c:	68 07 04 00 00       	push   $0x407
  803081:	50                   	push   %eax
  803082:	6a 00                	push   $0x0
  803084:	e8 0e e7 ff ff       	call   801797 <sys_page_alloc>
  803089:	89 c3                	mov    %eax,%ebx
  80308b:	83 c4 10             	add    $0x10,%esp
  80308e:	85 c0                	test   %eax,%eax
  803090:	0f 88 8c 00 00 00    	js     803122 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803096:	83 ec 0c             	sub    $0xc,%esp
  803099:	ff 75 f0             	pushl  -0x10(%ebp)
  80309c:	e8 c6 ed ff ff       	call   801e67 <fd2data>
  8030a1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8030a8:	50                   	push   %eax
  8030a9:	6a 00                	push   $0x0
  8030ab:	56                   	push   %esi
  8030ac:	6a 00                	push   $0x0
  8030ae:	e8 27 e7 ff ff       	call   8017da <sys_page_map>
  8030b3:	89 c3                	mov    %eax,%ebx
  8030b5:	83 c4 20             	add    $0x20,%esp
  8030b8:	85 c0                	test   %eax,%eax
  8030ba:	78 58                	js     803114 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8030bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030bf:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8030c5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8030c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8030d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030d4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8030da:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8030dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030df:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8030e6:	83 ec 0c             	sub    $0xc,%esp
  8030e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8030ec:	e8 66 ed ff ff       	call   801e57 <fd2num>
  8030f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030f4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8030f6:	83 c4 04             	add    $0x4,%esp
  8030f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8030fc:	e8 56 ed ff ff       	call   801e57 <fd2num>
  803101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803104:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803107:	83 c4 10             	add    $0x10,%esp
  80310a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80310f:	e9 4f ff ff ff       	jmp    803063 <pipe+0x75>
	sys_page_unmap(0, va);
  803114:	83 ec 08             	sub    $0x8,%esp
  803117:	56                   	push   %esi
  803118:	6a 00                	push   $0x0
  80311a:	e8 fd e6 ff ff       	call   80181c <sys_page_unmap>
  80311f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803122:	83 ec 08             	sub    $0x8,%esp
  803125:	ff 75 f0             	pushl  -0x10(%ebp)
  803128:	6a 00                	push   $0x0
  80312a:	e8 ed e6 ff ff       	call   80181c <sys_page_unmap>
  80312f:	83 c4 10             	add    $0x10,%esp
  803132:	e9 1c ff ff ff       	jmp    803053 <pipe+0x65>

00803137 <pipeisclosed>:
{
  803137:	55                   	push   %ebp
  803138:	89 e5                	mov    %esp,%ebp
  80313a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80313d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803140:	50                   	push   %eax
  803141:	ff 75 08             	pushl  0x8(%ebp)
  803144:	e8 84 ed ff ff       	call   801ecd <fd_lookup>
  803149:	83 c4 10             	add    $0x10,%esp
  80314c:	85 c0                	test   %eax,%eax
  80314e:	78 18                	js     803168 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  803150:	83 ec 0c             	sub    $0xc,%esp
  803153:	ff 75 f4             	pushl  -0xc(%ebp)
  803156:	e8 0c ed ff ff       	call   801e67 <fd2data>
	return _pipeisclosed(fd, p);
  80315b:	89 c2                	mov    %eax,%edx
  80315d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803160:	e8 30 fd ff ff       	call   802e95 <_pipeisclosed>
  803165:	83 c4 10             	add    $0x10,%esp
}
  803168:	c9                   	leave  
  803169:	c3                   	ret    

0080316a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80316a:	55                   	push   %ebp
  80316b:	89 e5                	mov    %esp,%ebp
  80316d:	56                   	push   %esi
  80316e:	53                   	push   %ebx
  80316f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803172:	85 f6                	test   %esi,%esi
  803174:	74 13                	je     803189 <wait+0x1f>
	e = &envs[ENVX(envid)];
  803176:	89 f3                	mov    %esi,%ebx
  803178:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80317e:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  803181:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803187:	eb 1b                	jmp    8031a4 <wait+0x3a>
	assert(envid != 0);
  803189:	68 9b 3f 80 00       	push   $0x803f9b
  80318e:	68 6f 36 80 00       	push   $0x80366f
  803193:	6a 09                	push   $0x9
  803195:	68 a6 3f 80 00       	push   $0x803fa6
  80319a:	e8 f3 d9 ff ff       	call   800b92 <_panic>
		sys_yield();
  80319f:	e8 d4 e5 ff ff       	call   801778 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8031a4:	8b 43 48             	mov    0x48(%ebx),%eax
  8031a7:	39 f0                	cmp    %esi,%eax
  8031a9:	75 07                	jne    8031b2 <wait+0x48>
  8031ab:	8b 43 54             	mov    0x54(%ebx),%eax
  8031ae:	85 c0                	test   %eax,%eax
  8031b0:	75 ed                	jne    80319f <wait+0x35>
}
  8031b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031b5:	5b                   	pop    %ebx
  8031b6:	5e                   	pop    %esi
  8031b7:	5d                   	pop    %ebp
  8031b8:	c3                   	ret    

008031b9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8031b9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8031ba:	a1 28 54 80 00       	mov    0x805428,%eax
	call *%eax
  8031bf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8031c1:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  8031c4:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  8031c7:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  8031cb:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  8031cf:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  8031d2:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  8031d6:	89 18                	mov    %ebx,(%eax)

    popal
  8031d8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  8031d9:	83 c4 04             	add    $0x4,%esp
    popfl
  8031dc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  8031dd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8031de:	c3                   	ret    

008031df <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8031df:	55                   	push   %ebp
  8031e0:	89 e5                	mov    %esp,%ebp
  8031e2:	56                   	push   %esi
  8031e3:	53                   	push   %ebx
  8031e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8031e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  8031ed:	85 c0                	test   %eax,%eax
  8031ef:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8031f4:	0f 44 c2             	cmove  %edx,%eax
  8031f7:	83 ec 0c             	sub    $0xc,%esp
  8031fa:	50                   	push   %eax
  8031fb:	e8 47 e7 ff ff       	call   801947 <sys_ipc_recv>
  803200:	83 c4 10             	add    $0x10,%esp
  803203:	85 c0                	test   %eax,%eax
  803205:	78 2b                	js     803232 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  803207:	85 f6                	test   %esi,%esi
  803209:	74 0a                	je     803215 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  80320b:	a1 24 54 80 00       	mov    0x805424,%eax
  803210:	8b 40 74             	mov    0x74(%eax),%eax
  803213:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  803215:	85 db                	test   %ebx,%ebx
  803217:	74 0a                	je     803223 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  803219:	a1 24 54 80 00       	mov    0x805424,%eax
  80321e:	8b 40 78             	mov    0x78(%eax),%eax
  803221:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  803223:	a1 24 54 80 00       	mov    0x805424,%eax
  803228:	8b 40 70             	mov    0x70(%eax),%eax
}
  80322b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80322e:	5b                   	pop    %ebx
  80322f:	5e                   	pop    %esi
  803230:	5d                   	pop    %ebp
  803231:	c3                   	ret    
        *from_env_store = 0;
  803232:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  803238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  80323e:	eb eb                	jmp    80322b <ipc_recv+0x4c>

00803240 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803240:	55                   	push   %ebp
  803241:	89 e5                	mov    %esp,%ebp
  803243:	57                   	push   %edi
  803244:	56                   	push   %esi
  803245:	53                   	push   %ebx
  803246:	83 ec 0c             	sub    $0xc,%esp
  803249:	8b 7d 08             	mov    0x8(%ebp),%edi
  80324c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80324f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  803252:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  803254:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803259:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  80325c:	ff 75 14             	pushl  0x14(%ebp)
  80325f:	53                   	push   %ebx
  803260:	56                   	push   %esi
  803261:	57                   	push   %edi
  803262:	e8 bd e6 ff ff       	call   801924 <sys_ipc_try_send>
  803267:	83 c4 10             	add    $0x10,%esp
  80326a:	85 c0                	test   %eax,%eax
  80326c:	74 17                	je     803285 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  80326e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803271:	74 e9                	je     80325c <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  803273:	50                   	push   %eax
  803274:	68 b1 3f 80 00       	push   $0x803fb1
  803279:	6a 3e                	push   $0x3e
  80327b:	68 c3 3f 80 00       	push   $0x803fc3
  803280:	e8 0d d9 ff ff       	call   800b92 <_panic>
        }
    }
}
  803285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803288:	5b                   	pop    %ebx
  803289:	5e                   	pop    %esi
  80328a:	5f                   	pop    %edi
  80328b:	5d                   	pop    %ebp
  80328c:	c3                   	ret    

0080328d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80328d:	55                   	push   %ebp
  80328e:	89 e5                	mov    %esp,%ebp
  803290:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803293:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803298:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80329b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8032a1:	8b 52 50             	mov    0x50(%edx),%edx
  8032a4:	39 ca                	cmp    %ecx,%edx
  8032a6:	74 11                	je     8032b9 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8032a8:	83 c0 01             	add    $0x1,%eax
  8032ab:	3d 00 04 00 00       	cmp    $0x400,%eax
  8032b0:	75 e6                	jne    803298 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8032b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8032b7:	eb 0b                	jmp    8032c4 <ipc_find_env+0x37>
			return envs[i].env_id;
  8032b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8032bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8032c1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8032c4:	5d                   	pop    %ebp
  8032c5:	c3                   	ret    
  8032c6:	66 90                	xchg   %ax,%ax
  8032c8:	66 90                	xchg   %ax,%ax
  8032ca:	66 90                	xchg   %ax,%ax
  8032cc:	66 90                	xchg   %ax,%ax
  8032ce:	66 90                	xchg   %ax,%ax

008032d0 <__udivdi3>:
  8032d0:	55                   	push   %ebp
  8032d1:	57                   	push   %edi
  8032d2:	56                   	push   %esi
  8032d3:	53                   	push   %ebx
  8032d4:	83 ec 1c             	sub    $0x1c,%esp
  8032d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8032db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8032df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8032e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8032e7:	85 d2                	test   %edx,%edx
  8032e9:	75 35                	jne    803320 <__udivdi3+0x50>
  8032eb:	39 f3                	cmp    %esi,%ebx
  8032ed:	0f 87 bd 00 00 00    	ja     8033b0 <__udivdi3+0xe0>
  8032f3:	85 db                	test   %ebx,%ebx
  8032f5:	89 d9                	mov    %ebx,%ecx
  8032f7:	75 0b                	jne    803304 <__udivdi3+0x34>
  8032f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8032fe:	31 d2                	xor    %edx,%edx
  803300:	f7 f3                	div    %ebx
  803302:	89 c1                	mov    %eax,%ecx
  803304:	31 d2                	xor    %edx,%edx
  803306:	89 f0                	mov    %esi,%eax
  803308:	f7 f1                	div    %ecx
  80330a:	89 c6                	mov    %eax,%esi
  80330c:	89 e8                	mov    %ebp,%eax
  80330e:	89 f7                	mov    %esi,%edi
  803310:	f7 f1                	div    %ecx
  803312:	89 fa                	mov    %edi,%edx
  803314:	83 c4 1c             	add    $0x1c,%esp
  803317:	5b                   	pop    %ebx
  803318:	5e                   	pop    %esi
  803319:	5f                   	pop    %edi
  80331a:	5d                   	pop    %ebp
  80331b:	c3                   	ret    
  80331c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803320:	39 f2                	cmp    %esi,%edx
  803322:	77 7c                	ja     8033a0 <__udivdi3+0xd0>
  803324:	0f bd fa             	bsr    %edx,%edi
  803327:	83 f7 1f             	xor    $0x1f,%edi
  80332a:	0f 84 98 00 00 00    	je     8033c8 <__udivdi3+0xf8>
  803330:	89 f9                	mov    %edi,%ecx
  803332:	b8 20 00 00 00       	mov    $0x20,%eax
  803337:	29 f8                	sub    %edi,%eax
  803339:	d3 e2                	shl    %cl,%edx
  80333b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80333f:	89 c1                	mov    %eax,%ecx
  803341:	89 da                	mov    %ebx,%edx
  803343:	d3 ea                	shr    %cl,%edx
  803345:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803349:	09 d1                	or     %edx,%ecx
  80334b:	89 f2                	mov    %esi,%edx
  80334d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803351:	89 f9                	mov    %edi,%ecx
  803353:	d3 e3                	shl    %cl,%ebx
  803355:	89 c1                	mov    %eax,%ecx
  803357:	d3 ea                	shr    %cl,%edx
  803359:	89 f9                	mov    %edi,%ecx
  80335b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80335f:	d3 e6                	shl    %cl,%esi
  803361:	89 eb                	mov    %ebp,%ebx
  803363:	89 c1                	mov    %eax,%ecx
  803365:	d3 eb                	shr    %cl,%ebx
  803367:	09 de                	or     %ebx,%esi
  803369:	89 f0                	mov    %esi,%eax
  80336b:	f7 74 24 08          	divl   0x8(%esp)
  80336f:	89 d6                	mov    %edx,%esi
  803371:	89 c3                	mov    %eax,%ebx
  803373:	f7 64 24 0c          	mull   0xc(%esp)
  803377:	39 d6                	cmp    %edx,%esi
  803379:	72 0c                	jb     803387 <__udivdi3+0xb7>
  80337b:	89 f9                	mov    %edi,%ecx
  80337d:	d3 e5                	shl    %cl,%ebp
  80337f:	39 c5                	cmp    %eax,%ebp
  803381:	73 5d                	jae    8033e0 <__udivdi3+0x110>
  803383:	39 d6                	cmp    %edx,%esi
  803385:	75 59                	jne    8033e0 <__udivdi3+0x110>
  803387:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80338a:	31 ff                	xor    %edi,%edi
  80338c:	89 fa                	mov    %edi,%edx
  80338e:	83 c4 1c             	add    $0x1c,%esp
  803391:	5b                   	pop    %ebx
  803392:	5e                   	pop    %esi
  803393:	5f                   	pop    %edi
  803394:	5d                   	pop    %ebp
  803395:	c3                   	ret    
  803396:	8d 76 00             	lea    0x0(%esi),%esi
  803399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8033a0:	31 ff                	xor    %edi,%edi
  8033a2:	31 c0                	xor    %eax,%eax
  8033a4:	89 fa                	mov    %edi,%edx
  8033a6:	83 c4 1c             	add    $0x1c,%esp
  8033a9:	5b                   	pop    %ebx
  8033aa:	5e                   	pop    %esi
  8033ab:	5f                   	pop    %edi
  8033ac:	5d                   	pop    %ebp
  8033ad:	c3                   	ret    
  8033ae:	66 90                	xchg   %ax,%ax
  8033b0:	31 ff                	xor    %edi,%edi
  8033b2:	89 e8                	mov    %ebp,%eax
  8033b4:	89 f2                	mov    %esi,%edx
  8033b6:	f7 f3                	div    %ebx
  8033b8:	89 fa                	mov    %edi,%edx
  8033ba:	83 c4 1c             	add    $0x1c,%esp
  8033bd:	5b                   	pop    %ebx
  8033be:	5e                   	pop    %esi
  8033bf:	5f                   	pop    %edi
  8033c0:	5d                   	pop    %ebp
  8033c1:	c3                   	ret    
  8033c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8033c8:	39 f2                	cmp    %esi,%edx
  8033ca:	72 06                	jb     8033d2 <__udivdi3+0x102>
  8033cc:	31 c0                	xor    %eax,%eax
  8033ce:	39 eb                	cmp    %ebp,%ebx
  8033d0:	77 d2                	ja     8033a4 <__udivdi3+0xd4>
  8033d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8033d7:	eb cb                	jmp    8033a4 <__udivdi3+0xd4>
  8033d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033e0:	89 d8                	mov    %ebx,%eax
  8033e2:	31 ff                	xor    %edi,%edi
  8033e4:	eb be                	jmp    8033a4 <__udivdi3+0xd4>
  8033e6:	66 90                	xchg   %ax,%ax
  8033e8:	66 90                	xchg   %ax,%ax
  8033ea:	66 90                	xchg   %ax,%ax
  8033ec:	66 90                	xchg   %ax,%ax
  8033ee:	66 90                	xchg   %ax,%ax

008033f0 <__umoddi3>:
  8033f0:	55                   	push   %ebp
  8033f1:	57                   	push   %edi
  8033f2:	56                   	push   %esi
  8033f3:	53                   	push   %ebx
  8033f4:	83 ec 1c             	sub    $0x1c,%esp
  8033f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8033fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8033ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803407:	85 ed                	test   %ebp,%ebp
  803409:	89 f0                	mov    %esi,%eax
  80340b:	89 da                	mov    %ebx,%edx
  80340d:	75 19                	jne    803428 <__umoddi3+0x38>
  80340f:	39 df                	cmp    %ebx,%edi
  803411:	0f 86 b1 00 00 00    	jbe    8034c8 <__umoddi3+0xd8>
  803417:	f7 f7                	div    %edi
  803419:	89 d0                	mov    %edx,%eax
  80341b:	31 d2                	xor    %edx,%edx
  80341d:	83 c4 1c             	add    $0x1c,%esp
  803420:	5b                   	pop    %ebx
  803421:	5e                   	pop    %esi
  803422:	5f                   	pop    %edi
  803423:	5d                   	pop    %ebp
  803424:	c3                   	ret    
  803425:	8d 76 00             	lea    0x0(%esi),%esi
  803428:	39 dd                	cmp    %ebx,%ebp
  80342a:	77 f1                	ja     80341d <__umoddi3+0x2d>
  80342c:	0f bd cd             	bsr    %ebp,%ecx
  80342f:	83 f1 1f             	xor    $0x1f,%ecx
  803432:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803436:	0f 84 b4 00 00 00    	je     8034f0 <__umoddi3+0x100>
  80343c:	b8 20 00 00 00       	mov    $0x20,%eax
  803441:	89 c2                	mov    %eax,%edx
  803443:	8b 44 24 04          	mov    0x4(%esp),%eax
  803447:	29 c2                	sub    %eax,%edx
  803449:	89 c1                	mov    %eax,%ecx
  80344b:	89 f8                	mov    %edi,%eax
  80344d:	d3 e5                	shl    %cl,%ebp
  80344f:	89 d1                	mov    %edx,%ecx
  803451:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803455:	d3 e8                	shr    %cl,%eax
  803457:	09 c5                	or     %eax,%ebp
  803459:	8b 44 24 04          	mov    0x4(%esp),%eax
  80345d:	89 c1                	mov    %eax,%ecx
  80345f:	d3 e7                	shl    %cl,%edi
  803461:	89 d1                	mov    %edx,%ecx
  803463:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803467:	89 df                	mov    %ebx,%edi
  803469:	d3 ef                	shr    %cl,%edi
  80346b:	89 c1                	mov    %eax,%ecx
  80346d:	89 f0                	mov    %esi,%eax
  80346f:	d3 e3                	shl    %cl,%ebx
  803471:	89 d1                	mov    %edx,%ecx
  803473:	89 fa                	mov    %edi,%edx
  803475:	d3 e8                	shr    %cl,%eax
  803477:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80347c:	09 d8                	or     %ebx,%eax
  80347e:	f7 f5                	div    %ebp
  803480:	d3 e6                	shl    %cl,%esi
  803482:	89 d1                	mov    %edx,%ecx
  803484:	f7 64 24 08          	mull   0x8(%esp)
  803488:	39 d1                	cmp    %edx,%ecx
  80348a:	89 c3                	mov    %eax,%ebx
  80348c:	89 d7                	mov    %edx,%edi
  80348e:	72 06                	jb     803496 <__umoddi3+0xa6>
  803490:	75 0e                	jne    8034a0 <__umoddi3+0xb0>
  803492:	39 c6                	cmp    %eax,%esi
  803494:	73 0a                	jae    8034a0 <__umoddi3+0xb0>
  803496:	2b 44 24 08          	sub    0x8(%esp),%eax
  80349a:	19 ea                	sbb    %ebp,%edx
  80349c:	89 d7                	mov    %edx,%edi
  80349e:	89 c3                	mov    %eax,%ebx
  8034a0:	89 ca                	mov    %ecx,%edx
  8034a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8034a7:	29 de                	sub    %ebx,%esi
  8034a9:	19 fa                	sbb    %edi,%edx
  8034ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8034af:	89 d0                	mov    %edx,%eax
  8034b1:	d3 e0                	shl    %cl,%eax
  8034b3:	89 d9                	mov    %ebx,%ecx
  8034b5:	d3 ee                	shr    %cl,%esi
  8034b7:	d3 ea                	shr    %cl,%edx
  8034b9:	09 f0                	or     %esi,%eax
  8034bb:	83 c4 1c             	add    $0x1c,%esp
  8034be:	5b                   	pop    %ebx
  8034bf:	5e                   	pop    %esi
  8034c0:	5f                   	pop    %edi
  8034c1:	5d                   	pop    %ebp
  8034c2:	c3                   	ret    
  8034c3:	90                   	nop
  8034c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8034c8:	85 ff                	test   %edi,%edi
  8034ca:	89 f9                	mov    %edi,%ecx
  8034cc:	75 0b                	jne    8034d9 <__umoddi3+0xe9>
  8034ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8034d3:	31 d2                	xor    %edx,%edx
  8034d5:	f7 f7                	div    %edi
  8034d7:	89 c1                	mov    %eax,%ecx
  8034d9:	89 d8                	mov    %ebx,%eax
  8034db:	31 d2                	xor    %edx,%edx
  8034dd:	f7 f1                	div    %ecx
  8034df:	89 f0                	mov    %esi,%eax
  8034e1:	f7 f1                	div    %ecx
  8034e3:	e9 31 ff ff ff       	jmp    803419 <__umoddi3+0x29>
  8034e8:	90                   	nop
  8034e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034f0:	39 dd                	cmp    %ebx,%ebp
  8034f2:	72 08                	jb     8034fc <__umoddi3+0x10c>
  8034f4:	39 f7                	cmp    %esi,%edi
  8034f6:	0f 87 21 ff ff ff    	ja     80341d <__umoddi3+0x2d>
  8034fc:	89 da                	mov    %ebx,%edx
  8034fe:	89 f0                	mov    %esi,%eax
  803500:	29 f8                	sub    %edi,%eax
  803502:	19 ea                	sbb    %ebp,%edx
  803504:	e9 14 ff ff ff       	jmp    80341d <__umoddi3+0x2d>
