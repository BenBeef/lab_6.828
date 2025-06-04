
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 6d 06 00 00       	call   80069e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 b1 0d 00 00       	call   800df8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 37 14 00 00       	call   801490 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 db 13 00 00       	call   801443 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 69 13 00 00       	call   8013e2 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 40 24 80 00       	mov    $0x802440,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 08                	je     8000a6 <umain+0x28>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	0f 88 02 04 00 00    	js     8004a8 <umain+0x42a>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	0f 89 0c 04 00 00    	jns    8004ba <umain+0x43c>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b3:	b8 75 24 80 00       	mov    $0x802475,%eax
  8000b8:	e8 76 ff ff ff       	call   800033 <xopen>
  8000bd:	85 c0                	test   %eax,%eax
  8000bf:	0f 88 09 04 00 00    	js     8004ce <umain+0x450>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c5:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000cc:	0f 85 0e 04 00 00    	jne    8004e0 <umain+0x462>
  8000d2:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000d9:	0f 85 01 04 00 00    	jne    8004e0 <umain+0x462>
  8000df:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000e6:	0f 85 f4 03 00 00    	jne    8004e0 <umain+0x462>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000ec:	83 ec 0c             	sub    $0xc,%esp
  8000ef:	68 96 24 80 00       	push   $0x802496
  8000f4:	e8 e0 06 00 00       	call   8007d9 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000f9:	83 c4 08             	add    $0x8,%esp
  8000fc:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	68 00 c0 cc cc       	push   $0xccccc000
  800108:	ff 15 1c 30 80 00    	call   *0x80301c
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	0f 88 db 03 00 00    	js     8004f4 <umain+0x476>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	ff 35 00 30 80 00    	pushl  0x803000
  800122:	e8 9a 0c 00 00       	call   800dc1 <strlen>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80012d:	0f 85 d3 03 00 00    	jne    800506 <umain+0x488>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 b8 24 80 00       	push   $0x8024b8
  80013b:	e8 99 06 00 00       	call   8007d9 <cprintf>

	memset(buf, 0, sizeof buf);
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	68 00 02 00 00       	push   $0x200
  800148:	6a 00                	push   $0x0
  80014a:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800150:	53                   	push   %ebx
  800151:	e8 e3 0d 00 00       	call   800f39 <memset>
    cprintf("[here] ------------- testfile 1 \n");
  800156:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  80015d:	e8 77 06 00 00       	call   8007d9 <cprintf>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800162:	83 c4 0c             	add    $0xc,%esp
  800165:	68 00 02 00 00       	push   $0x200
  80016a:	53                   	push   %ebx
  80016b:	68 00 c0 cc cc       	push   $0xccccc000
  800170:	ff 15 10 30 80 00    	call   *0x803010
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	0f 88 aa 03 00 00    	js     80052b <umain+0x4ad>
		panic("file_read: %e", r);
    cprintf("[here] ------------- testfile 2 \n");
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	68 a0 26 80 00       	push   $0x8026a0
  800189:	e8 4b 06 00 00       	call   8007d9 <cprintf>
	if (strcmp(buf, msg) != 0)
  80018e:	83 c4 08             	add    $0x8,%esp
  800191:	ff 35 00 30 80 00    	pushl  0x803000
  800197:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80019d:	50                   	push   %eax
  80019e:	e8 fb 0c 00 00       	call   800e9e <strcmp>
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	0f 85 8f 03 00 00    	jne    80053d <umain+0x4bf>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	68 f7 24 80 00       	push   $0x8024f7
  8001b6:	e8 1e 06 00 00       	call   8007d9 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001bb:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001c2:	ff 15 18 30 80 00    	call   *0x803018
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	0f 88 7e 03 00 00    	js     800551 <umain+0x4d3>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 19 25 80 00       	push   $0x802519
  8001db:	e8 f9 05 00 00       	call   8007d9 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001e0:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e8:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f8:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  800200:	83 c4 08             	add    $0x8,%esp
  800203:	68 00 c0 cc cc       	push   $0xccccc000
  800208:	6a 00                	push   $0x0
  80020a:	e8 67 10 00 00       	call   801276 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80020f:	83 c4 0c             	add    $0xc,%esp
  800212:	68 00 02 00 00       	push   $0x200
  800217:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80021d:	50                   	push   %eax
  80021e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	ff 15 10 30 80 00    	call   *0x803010
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80022e:	0f 85 2f 03 00 00    	jne    800563 <umain+0x4e5>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	68 2d 25 80 00       	push   $0x80252d
  80023c:	e8 98 05 00 00       	call   8007d9 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800241:	ba 02 01 00 00       	mov    $0x102,%edx
  800246:	b8 43 25 80 00       	mov    $0x802543,%eax
  80024b:	e8 e3 fd ff ff       	call   800033 <xopen>
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	85 c0                	test   %eax,%eax
  800255:	0f 88 1a 03 00 00    	js     800575 <umain+0x4f7>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  80025b:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 35 00 30 80 00    	pushl  0x803000
  80026a:	e8 52 0b 00 00       	call   800dc1 <strlen>
  80026f:	83 c4 0c             	add    $0xc,%esp
  800272:	50                   	push   %eax
  800273:	ff 35 00 30 80 00    	pushl  0x803000
  800279:	68 00 c0 cc cc       	push   $0xccccc000
  80027e:	ff d3                	call   *%ebx
  800280:	89 c3                	mov    %eax,%ebx
  800282:	83 c4 04             	add    $0x4,%esp
  800285:	ff 35 00 30 80 00    	pushl  0x803000
  80028b:	e8 31 0b 00 00       	call   800dc1 <strlen>
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	39 d8                	cmp    %ebx,%eax
  800295:	0f 85 ec 02 00 00    	jne    800587 <umain+0x509>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	68 75 25 80 00       	push   $0x802575
  8002a3:	e8 31 05 00 00       	call   8007d9 <cprintf>

	FVA->fd_offset = 0;
  8002a8:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8002af:	00 00 00 
	memset(buf, 0, sizeof buf);
  8002b2:	83 c4 0c             	add    $0xc,%esp
  8002b5:	68 00 02 00 00       	push   $0x200
  8002ba:	6a 00                	push   $0x0
  8002bc:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002c2:	53                   	push   %ebx
  8002c3:	e8 71 0c 00 00       	call   800f39 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002c8:	83 c4 0c             	add    $0xc,%esp
  8002cb:	68 00 02 00 00       	push   $0x200
  8002d0:	53                   	push   %ebx
  8002d1:	68 00 c0 cc cc       	push   $0xccccc000
  8002d6:	ff 15 10 30 80 00    	call   *0x803010
  8002dc:	89 c3                	mov    %eax,%ebx
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	0f 88 b0 02 00 00    	js     800599 <umain+0x51b>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	ff 35 00 30 80 00    	pushl  0x803000
  8002f2:	e8 ca 0a 00 00       	call   800dc1 <strlen>
  8002f7:	83 c4 10             	add    $0x10,%esp
  8002fa:	39 d8                	cmp    %ebx,%eax
  8002fc:	0f 85 a9 02 00 00    	jne    8005ab <umain+0x52d>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	ff 35 00 30 80 00    	pushl  0x803000
  80030b:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800311:	50                   	push   %eax
  800312:	e8 87 0b 00 00       	call   800e9e <strcmp>
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 85 9b 02 00 00    	jne    8005bd <umain+0x53f>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	68 84 27 80 00       	push   $0x802784
  80032a:	e8 aa 04 00 00       	call   8007d9 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80032f:	83 c4 08             	add    $0x8,%esp
  800332:	6a 00                	push   $0x0
  800334:	68 40 24 80 00       	push   $0x802440
  800339:	e8 d7 18 00 00       	call   801c15 <open>
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800344:	74 08                	je     80034e <umain+0x2d0>
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 88 83 02 00 00    	js     8005d1 <umain+0x553>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 89 8d 02 00 00    	jns    8005e3 <umain+0x565>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	6a 00                	push   $0x0
  80035b:	68 75 24 80 00       	push   $0x802475
  800360:	e8 b0 18 00 00       	call   801c15 <open>
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 88 87 02 00 00    	js     8005f7 <umain+0x579>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800370:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800373:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80037a:	0f 85 89 02 00 00    	jne    800609 <umain+0x58b>
  800380:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800387:	0f 85 7c 02 00 00    	jne    800609 <umain+0x58b>
  80038d:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  800393:	85 db                	test   %ebx,%ebx
  800395:	0f 85 6e 02 00 00    	jne    800609 <umain+0x58b>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	68 9c 24 80 00       	push   $0x80249c
  8003a3:	e8 31 04 00 00       	call   8007d9 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8003a8:	83 c4 08             	add    $0x8,%esp
  8003ab:	68 01 01 00 00       	push   $0x101
  8003b0:	68 a4 25 80 00       	push   $0x8025a4
  8003b5:	e8 5b 18 00 00       	call   801c15 <open>
  8003ba:	89 c7                	mov    %eax,%edi
  8003bc:	83 c4 10             	add    $0x10,%esp
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 88 56 02 00 00    	js     80061d <umain+0x59f>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003c7:	83 ec 04             	sub    $0x4,%esp
  8003ca:	68 00 02 00 00       	push   $0x200
  8003cf:	6a 00                	push   $0x0
  8003d1:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d7:	50                   	push   %eax
  8003d8:	e8 5c 0b 00 00       	call   800f39 <memset>
  8003dd:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003e0:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003e2:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003e8:	83 ec 04             	sub    $0x4,%esp
  8003eb:	68 00 02 00 00       	push   $0x200
  8003f0:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	57                   	push   %edi
  8003f8:	e8 81 14 00 00       	call   80187e <write>
  8003fd:	83 c4 10             	add    $0x10,%esp
  800400:	85 c0                	test   %eax,%eax
  800402:	0f 88 27 02 00 00    	js     80062f <umain+0x5b1>
  800408:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80040e:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  800414:	75 cc                	jne    8003e2 <umain+0x364>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800416:	83 ec 0c             	sub    $0xc,%esp
  800419:	57                   	push   %edi
  80041a:	e8 55 12 00 00       	call   801674 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80041f:	83 c4 08             	add    $0x8,%esp
  800422:	6a 00                	push   $0x0
  800424:	68 a4 25 80 00       	push   $0x8025a4
  800429:	e8 e7 17 00 00       	call   801c15 <open>
  80042e:	89 c6                	mov    %eax,%esi
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	85 c0                	test   %eax,%eax
  800435:	0f 88 0a 02 00 00    	js     800645 <umain+0x5c7>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80043b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  800441:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800447:	83 ec 04             	sub    $0x4,%esp
  80044a:	68 00 02 00 00       	push   $0x200
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	e8 e1 13 00 00       	call   801837 <readn>
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 c0                	test   %eax,%eax
  80045b:	0f 88 f6 01 00 00    	js     800657 <umain+0x5d9>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  800461:	3d 00 02 00 00       	cmp    $0x200,%eax
  800466:	0f 85 01 02 00 00    	jne    80066d <umain+0x5ef>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80046c:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  800472:	39 d8                	cmp    %ebx,%eax
  800474:	0f 85 0e 02 00 00    	jne    800688 <umain+0x60a>
  80047a:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800480:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  800486:	75 b9                	jne    800441 <umain+0x3c3>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800488:	83 ec 0c             	sub    $0xc,%esp
  80048b:	56                   	push   %esi
  80048c:	e8 e3 11 00 00       	call   801674 <close>
	cprintf("large file is good\n");
  800491:	c7 04 24 e9 25 80 00 	movl   $0x8025e9,(%esp)
  800498:	e8 3c 03 00 00       	call   8007d9 <cprintf>
}
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a3:	5b                   	pop    %ebx
  8004a4:	5e                   	pop    %esi
  8004a5:	5f                   	pop    %edi
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  8004a8:	50                   	push   %eax
  8004a9:	68 4b 24 80 00       	push   $0x80244b
  8004ae:	6a 20                	push   $0x20
  8004b0:	68 65 24 80 00       	push   $0x802465
  8004b5:	e8 44 02 00 00       	call   8006fe <_panic>
		panic("serve_open /not-found succeeded!");
  8004ba:	83 ec 04             	sub    $0x4,%esp
  8004bd:	68 00 26 80 00       	push   $0x802600
  8004c2:	6a 22                	push   $0x22
  8004c4:	68 65 24 80 00       	push   $0x802465
  8004c9:	e8 30 02 00 00       	call   8006fe <_panic>
		panic("serve_open /newmotd: %e", r);
  8004ce:	50                   	push   %eax
  8004cf:	68 7e 24 80 00       	push   $0x80247e
  8004d4:	6a 25                	push   $0x25
  8004d6:	68 65 24 80 00       	push   $0x802465
  8004db:	e8 1e 02 00 00       	call   8006fe <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004e0:	83 ec 04             	sub    $0x4,%esp
  8004e3:	68 24 26 80 00       	push   $0x802624
  8004e8:	6a 27                	push   $0x27
  8004ea:	68 65 24 80 00       	push   $0x802465
  8004ef:	e8 0a 02 00 00       	call   8006fe <_panic>
		panic("file_stat: %e", r);
  8004f4:	50                   	push   %eax
  8004f5:	68 aa 24 80 00       	push   $0x8024aa
  8004fa:	6a 2b                	push   $0x2b
  8004fc:	68 65 24 80 00       	push   $0x802465
  800501:	e8 f8 01 00 00       	call   8006fe <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800506:	83 ec 0c             	sub    $0xc,%esp
  800509:	ff 35 00 30 80 00    	pushl  0x803000
  80050f:	e8 ad 08 00 00       	call   800dc1 <strlen>
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff 75 cc             	pushl  -0x34(%ebp)
  80051a:	68 54 26 80 00       	push   $0x802654
  80051f:	6a 2d                	push   $0x2d
  800521:	68 65 24 80 00       	push   $0x802465
  800526:	e8 d3 01 00 00       	call   8006fe <_panic>
		panic("file_read: %e", r);
  80052b:	50                   	push   %eax
  80052c:	68 cb 24 80 00       	push   $0x8024cb
  800531:	6a 33                	push   $0x33
  800533:	68 65 24 80 00       	push   $0x802465
  800538:	e8 c1 01 00 00       	call   8006fe <_panic>
		panic("file_read returned wrong data");
  80053d:	83 ec 04             	sub    $0x4,%esp
  800540:	68 d9 24 80 00       	push   $0x8024d9
  800545:	6a 36                	push   $0x36
  800547:	68 65 24 80 00       	push   $0x802465
  80054c:	e8 ad 01 00 00       	call   8006fe <_panic>
		panic("file_close: %e", r);
  800551:	50                   	push   %eax
  800552:	68 0a 25 80 00       	push   $0x80250a
  800557:	6a 3a                	push   $0x3a
  800559:	68 65 24 80 00       	push   $0x802465
  80055e:	e8 9b 01 00 00       	call   8006fe <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800563:	50                   	push   %eax
  800564:	68 c4 26 80 00       	push   $0x8026c4
  800569:	6a 45                	push   $0x45
  80056b:	68 65 24 80 00       	push   $0x802465
  800570:	e8 89 01 00 00       	call   8006fe <_panic>
		panic("serve_open /new-file: %e", r);
  800575:	50                   	push   %eax
  800576:	68 4d 25 80 00       	push   $0x80254d
  80057b:	6a 4a                	push   $0x4a
  80057d:	68 65 24 80 00       	push   $0x802465
  800582:	e8 77 01 00 00       	call   8006fe <_panic>
		panic("file_write: %e", r);
  800587:	53                   	push   %ebx
  800588:	68 66 25 80 00       	push   $0x802566
  80058d:	6a 4d                	push   $0x4d
  80058f:	68 65 24 80 00       	push   $0x802465
  800594:	e8 65 01 00 00       	call   8006fe <_panic>
		panic("file_read after file_write: %e", r);
  800599:	50                   	push   %eax
  80059a:	68 fc 26 80 00       	push   $0x8026fc
  80059f:	6a 53                	push   $0x53
  8005a1:	68 65 24 80 00       	push   $0x802465
  8005a6:	e8 53 01 00 00       	call   8006fe <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  8005ab:	53                   	push   %ebx
  8005ac:	68 1c 27 80 00       	push   $0x80271c
  8005b1:	6a 55                	push   $0x55
  8005b3:	68 65 24 80 00       	push   $0x802465
  8005b8:	e8 41 01 00 00       	call   8006fe <_panic>
		panic("file_read after file_write returned wrong data");
  8005bd:	83 ec 04             	sub    $0x4,%esp
  8005c0:	68 54 27 80 00       	push   $0x802754
  8005c5:	6a 57                	push   $0x57
  8005c7:	68 65 24 80 00       	push   $0x802465
  8005cc:	e8 2d 01 00 00       	call   8006fe <_panic>
		panic("open /not-found: %e", r);
  8005d1:	50                   	push   %eax
  8005d2:	68 51 24 80 00       	push   $0x802451
  8005d7:	6a 5c                	push   $0x5c
  8005d9:	68 65 24 80 00       	push   $0x802465
  8005de:	e8 1b 01 00 00       	call   8006fe <_panic>
		panic("open /not-found succeeded!");
  8005e3:	83 ec 04             	sub    $0x4,%esp
  8005e6:	68 89 25 80 00       	push   $0x802589
  8005eb:	6a 5e                	push   $0x5e
  8005ed:	68 65 24 80 00       	push   $0x802465
  8005f2:	e8 07 01 00 00       	call   8006fe <_panic>
		panic("open /newmotd: %e", r);
  8005f7:	50                   	push   %eax
  8005f8:	68 84 24 80 00       	push   $0x802484
  8005fd:	6a 61                	push   $0x61
  8005ff:	68 65 24 80 00       	push   $0x802465
  800604:	e8 f5 00 00 00       	call   8006fe <_panic>
		panic("open did not fill struct Fd correctly\n");
  800609:	83 ec 04             	sub    $0x4,%esp
  80060c:	68 a8 27 80 00       	push   $0x8027a8
  800611:	6a 64                	push   $0x64
  800613:	68 65 24 80 00       	push   $0x802465
  800618:	e8 e1 00 00 00       	call   8006fe <_panic>
		panic("creat /big: %e", f);
  80061d:	50                   	push   %eax
  80061e:	68 a9 25 80 00       	push   $0x8025a9
  800623:	6a 69                	push   $0x69
  800625:	68 65 24 80 00       	push   $0x802465
  80062a:	e8 cf 00 00 00       	call   8006fe <_panic>
			panic("write /big@%d: %e", i, r);
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	50                   	push   %eax
  800633:	56                   	push   %esi
  800634:	68 b8 25 80 00       	push   $0x8025b8
  800639:	6a 6e                	push   $0x6e
  80063b:	68 65 24 80 00       	push   $0x802465
  800640:	e8 b9 00 00 00       	call   8006fe <_panic>
		panic("open /big: %e", f);
  800645:	50                   	push   %eax
  800646:	68 ca 25 80 00       	push   $0x8025ca
  80064b:	6a 73                	push   $0x73
  80064d:	68 65 24 80 00       	push   $0x802465
  800652:	e8 a7 00 00 00       	call   8006fe <_panic>
			panic("read /big@%d: %e", i, r);
  800657:	83 ec 0c             	sub    $0xc,%esp
  80065a:	50                   	push   %eax
  80065b:	53                   	push   %ebx
  80065c:	68 d8 25 80 00       	push   $0x8025d8
  800661:	6a 77                	push   $0x77
  800663:	68 65 24 80 00       	push   $0x802465
  800668:	e8 91 00 00 00       	call   8006fe <_panic>
			panic("read /big from %d returned %d < %d bytes",
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	68 00 02 00 00       	push   $0x200
  800675:	50                   	push   %eax
  800676:	53                   	push   %ebx
  800677:	68 d0 27 80 00       	push   $0x8027d0
  80067c:	6a 7a                	push   $0x7a
  80067e:	68 65 24 80 00       	push   $0x802465
  800683:	e8 76 00 00 00       	call   8006fe <_panic>
			panic("read /big from %d returned bad data %d",
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	50                   	push   %eax
  80068c:	53                   	push   %ebx
  80068d:	68 fc 27 80 00       	push   $0x8027fc
  800692:	6a 7d                	push   $0x7d
  800694:	68 65 24 80 00       	push   $0x802465
  800699:	e8 60 00 00 00       	call   8006fe <_panic>

0080069e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	56                   	push   %esi
  8006a2:	53                   	push   %ebx
  8006a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8006a9:	e8 05 0b 00 00       	call   8011b3 <sys_getenvid>
  8006ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8006b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006bb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	7e 07                	jle    8006cb <libmain+0x2d>
		binaryname = argv[0];
  8006c4:	8b 06                	mov    (%esi),%eax
  8006c6:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	56                   	push   %esi
  8006cf:	53                   	push   %ebx
  8006d0:	e8 a9 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006d5:	e8 0a 00 00 00       	call   8006e4 <exit>
}
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006ea:	e8 b0 0f 00 00       	call   80169f <close_all>
	sys_env_destroy(0);
  8006ef:	83 ec 0c             	sub    $0xc,%esp
  8006f2:	6a 00                	push   $0x0
  8006f4:	e8 79 0a 00 00       	call   801172 <sys_env_destroy>
}
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	56                   	push   %esi
  800702:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800703:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800706:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80070c:	e8 a2 0a 00 00       	call   8011b3 <sys_getenvid>
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	ff 75 08             	pushl  0x8(%ebp)
  80071a:	56                   	push   %esi
  80071b:	50                   	push   %eax
  80071c:	68 54 28 80 00       	push   $0x802854
  800721:	e8 b3 00 00 00       	call   8007d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800726:	83 c4 18             	add    $0x18,%esp
  800729:	53                   	push   %ebx
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	e8 56 00 00 00       	call   800788 <vcprintf>
	cprintf("\n");
  800732:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  800739:	e8 9b 00 00 00       	call   8007d9 <cprintf>
  80073e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800741:	cc                   	int3   
  800742:	eb fd                	jmp    800741 <_panic+0x43>

00800744 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80074e:	8b 13                	mov    (%ebx),%edx
  800750:	8d 42 01             	lea    0x1(%edx),%eax
  800753:	89 03                	mov    %eax,(%ebx)
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80075c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800761:	74 09                	je     80076c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800763:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	68 ff 00 00 00       	push   $0xff
  800774:	8d 43 08             	lea    0x8(%ebx),%eax
  800777:	50                   	push   %eax
  800778:	e8 b8 09 00 00       	call   801135 <sys_cputs>
		b->idx = 0;
  80077d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	eb db                	jmp    800763 <putch+0x1f>

00800788 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800791:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800798:	00 00 00 
	b.cnt = 0;
  80079b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	68 44 07 80 00       	push   $0x800744
  8007b7:	e8 1a 01 00 00       	call   8008d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007c5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 64 09 00 00       	call   801135 <sys_cputs>

	return b.cnt;
}
  8007d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007e2:	50                   	push   %eax
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 9d ff ff ff       	call   800788 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	57                   	push   %edi
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	83 ec 1c             	sub    $0x1c,%esp
  8007f6:	89 c7                	mov    %eax,%edi
  8007f8:	89 d6                	mov    %edx,%esi
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800800:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800803:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800806:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800809:	bb 00 00 00 00       	mov    $0x0,%ebx
  80080e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800811:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800814:	39 d3                	cmp    %edx,%ebx
  800816:	72 05                	jb     80081d <printnum+0x30>
  800818:	39 45 10             	cmp    %eax,0x10(%ebp)
  80081b:	77 7a                	ja     800897 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80081d:	83 ec 0c             	sub    $0xc,%esp
  800820:	ff 75 18             	pushl  0x18(%ebp)
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800829:	53                   	push   %ebx
  80082a:	ff 75 10             	pushl  0x10(%ebp)
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	ff 75 e4             	pushl  -0x1c(%ebp)
  800833:	ff 75 e0             	pushl  -0x20(%ebp)
  800836:	ff 75 dc             	pushl  -0x24(%ebp)
  800839:	ff 75 d8             	pushl  -0x28(%ebp)
  80083c:	e8 af 19 00 00       	call   8021f0 <__udivdi3>
  800841:	83 c4 18             	add    $0x18,%esp
  800844:	52                   	push   %edx
  800845:	50                   	push   %eax
  800846:	89 f2                	mov    %esi,%edx
  800848:	89 f8                	mov    %edi,%eax
  80084a:	e8 9e ff ff ff       	call   8007ed <printnum>
  80084f:	83 c4 20             	add    $0x20,%esp
  800852:	eb 13                	jmp    800867 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	56                   	push   %esi
  800858:	ff 75 18             	pushl  0x18(%ebp)
  80085b:	ff d7                	call   *%edi
  80085d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800860:	83 eb 01             	sub    $0x1,%ebx
  800863:	85 db                	test   %ebx,%ebx
  800865:	7f ed                	jg     800854 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	56                   	push   %esi
  80086b:	83 ec 04             	sub    $0x4,%esp
  80086e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800871:	ff 75 e0             	pushl  -0x20(%ebp)
  800874:	ff 75 dc             	pushl  -0x24(%ebp)
  800877:	ff 75 d8             	pushl  -0x28(%ebp)
  80087a:	e8 91 1a 00 00       	call   802310 <__umoddi3>
  80087f:	83 c4 14             	add    $0x14,%esp
  800882:	0f be 80 77 28 80 00 	movsbl 0x802877(%eax),%eax
  800889:	50                   	push   %eax
  80088a:	ff d7                	call   *%edi
}
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5f                   	pop    %edi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    
  800897:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80089a:	eb c4                	jmp    800860 <printnum+0x73>

0080089c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8008ab:	73 0a                	jae    8008b7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8008ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008b0:	89 08                	mov    %ecx,(%eax)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	88 02                	mov    %al,(%edx)
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <printfmt>:
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008c2:	50                   	push   %eax
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 05 00 00 00       	call   8008d6 <vprintfmt>
}
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <vprintfmt>:
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 2c             	sub    $0x2c,%esp
  8008df:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008e8:	e9 c1 03 00 00       	jmp    800cae <vprintfmt+0x3d8>
		padc = ' ';
  8008ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8008f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8008f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8008ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800906:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8d 47 01             	lea    0x1(%edi),%eax
  80090e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800911:	0f b6 17             	movzbl (%edi),%edx
  800914:	8d 42 dd             	lea    -0x23(%edx),%eax
  800917:	3c 55                	cmp    $0x55,%al
  800919:	0f 87 12 04 00 00    	ja     800d31 <vprintfmt+0x45b>
  80091f:	0f b6 c0             	movzbl %al,%eax
  800922:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80092c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800930:	eb d9                	jmp    80090b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800932:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800935:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800939:	eb d0                	jmp    80090b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80093b:	0f b6 d2             	movzbl %dl,%edx
  80093e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800949:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80094c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800950:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800953:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800956:	83 f9 09             	cmp    $0x9,%ecx
  800959:	77 55                	ja     8009b0 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80095b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80095e:	eb e9                	jmp    800949 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 00                	mov    (%eax),%eax
  800965:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8d 40 04             	lea    0x4(%eax),%eax
  80096e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800974:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800978:	79 91                	jns    80090b <vprintfmt+0x35>
				width = precision, precision = -1;
  80097a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80097d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800980:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800987:	eb 82                	jmp    80090b <vprintfmt+0x35>
  800989:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80098c:	85 c0                	test   %eax,%eax
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	0f 49 d0             	cmovns %eax,%edx
  800996:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80099c:	e9 6a ff ff ff       	jmp    80090b <vprintfmt+0x35>
  8009a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8009a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8009ab:	e9 5b ff ff ff       	jmp    80090b <vprintfmt+0x35>
  8009b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b6:	eb bc                	jmp    800974 <vprintfmt+0x9e>
			lflag++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8009bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009be:	e9 48 ff ff ff       	jmp    80090b <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 78 04             	lea    0x4(%eax),%edi
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	53                   	push   %ebx
  8009cd:	ff 30                	pushl  (%eax)
  8009cf:	ff d6                	call   *%esi
			break;
  8009d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8009d4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8009d7:	e9 cf 02 00 00       	jmp    800cab <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8009dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009df:	8d 78 04             	lea    0x4(%eax),%edi
  8009e2:	8b 00                	mov    (%eax),%eax
  8009e4:	99                   	cltd   
  8009e5:	31 d0                	xor    %edx,%eax
  8009e7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009e9:	83 f8 0f             	cmp    $0xf,%eax
  8009ec:	7f 23                	jg     800a11 <vprintfmt+0x13b>
  8009ee:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	74 18                	je     800a11 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8009f9:	52                   	push   %edx
  8009fa:	68 6d 2c 80 00       	push   $0x802c6d
  8009ff:	53                   	push   %ebx
  800a00:	56                   	push   %esi
  800a01:	e8 b3 fe ff ff       	call   8008b9 <printfmt>
  800a06:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a09:	89 7d 14             	mov    %edi,0x14(%ebp)
  800a0c:	e9 9a 02 00 00       	jmp    800cab <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800a11:	50                   	push   %eax
  800a12:	68 8f 28 80 00       	push   $0x80288f
  800a17:	53                   	push   %ebx
  800a18:	56                   	push   %esi
  800a19:	e8 9b fe ff ff       	call   8008b9 <printfmt>
  800a1e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a21:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800a24:	e9 82 02 00 00       	jmp    800cab <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800a29:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2c:	83 c0 04             	add    $0x4,%eax
  800a2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800a32:	8b 45 14             	mov    0x14(%ebp),%eax
  800a35:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a37:	85 ff                	test   %edi,%edi
  800a39:	b8 88 28 80 00       	mov    $0x802888,%eax
  800a3e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a45:	0f 8e bd 00 00 00    	jle    800b08 <vprintfmt+0x232>
  800a4b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a4f:	75 0e                	jne    800a5f <vprintfmt+0x189>
  800a51:	89 75 08             	mov    %esi,0x8(%ebp)
  800a54:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a57:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a5a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a5d:	eb 6d                	jmp    800acc <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	ff 75 d0             	pushl  -0x30(%ebp)
  800a65:	57                   	push   %edi
  800a66:	e8 6e 03 00 00       	call   800dd9 <strnlen>
  800a6b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a6e:	29 c1                	sub    %eax,%ecx
  800a70:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a73:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a76:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a80:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a82:	eb 0f                	jmp    800a93 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	53                   	push   %ebx
  800a88:	ff 75 e0             	pushl  -0x20(%ebp)
  800a8b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	83 c4 10             	add    $0x10,%esp
  800a93:	85 ff                	test   %edi,%edi
  800a95:	7f ed                	jg     800a84 <vprintfmt+0x1ae>
  800a97:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a9a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a9d:	85 c9                	test   %ecx,%ecx
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	0f 49 c1             	cmovns %ecx,%eax
  800aa7:	29 c1                	sub    %eax,%ecx
  800aa9:	89 75 08             	mov    %esi,0x8(%ebp)
  800aac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aaf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ab2:	89 cb                	mov    %ecx,%ebx
  800ab4:	eb 16                	jmp    800acc <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800ab6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800aba:	75 31                	jne    800aed <vprintfmt+0x217>
					putch(ch, putdat);
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	50                   	push   %eax
  800ac3:	ff 55 08             	call   *0x8(%ebp)
  800ac6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac9:	83 eb 01             	sub    $0x1,%ebx
  800acc:	83 c7 01             	add    $0x1,%edi
  800acf:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800ad3:	0f be c2             	movsbl %dl,%eax
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	74 59                	je     800b33 <vprintfmt+0x25d>
  800ada:	85 f6                	test   %esi,%esi
  800adc:	78 d8                	js     800ab6 <vprintfmt+0x1e0>
  800ade:	83 ee 01             	sub    $0x1,%esi
  800ae1:	79 d3                	jns    800ab6 <vprintfmt+0x1e0>
  800ae3:	89 df                	mov    %ebx,%edi
  800ae5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aeb:	eb 37                	jmp    800b24 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 20             	sub    $0x20,%edx
  800af3:	83 fa 5e             	cmp    $0x5e,%edx
  800af6:	76 c4                	jbe    800abc <vprintfmt+0x1e6>
					putch('?', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	ff 75 0c             	pushl  0xc(%ebp)
  800afe:	6a 3f                	push   $0x3f
  800b00:	ff 55 08             	call   *0x8(%ebp)
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb c1                	jmp    800ac9 <vprintfmt+0x1f3>
  800b08:	89 75 08             	mov    %esi,0x8(%ebp)
  800b0b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b0e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b11:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b14:	eb b6                	jmp    800acc <vprintfmt+0x1f6>
				putch(' ', putdat);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	53                   	push   %ebx
  800b1a:	6a 20                	push   $0x20
  800b1c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800b1e:	83 ef 01             	sub    $0x1,%edi
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	85 ff                	test   %edi,%edi
  800b26:	7f ee                	jg     800b16 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800b28:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b2b:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2e:	e9 78 01 00 00       	jmp    800cab <vprintfmt+0x3d5>
  800b33:	89 df                	mov    %ebx,%edi
  800b35:	8b 75 08             	mov    0x8(%ebp),%esi
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3b:	eb e7                	jmp    800b24 <vprintfmt+0x24e>
	if (lflag >= 2)
  800b3d:	83 f9 01             	cmp    $0x1,%ecx
  800b40:	7e 3f                	jle    800b81 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800b42:	8b 45 14             	mov    0x14(%ebp),%eax
  800b45:	8b 50 04             	mov    0x4(%eax),%edx
  800b48:	8b 00                	mov    (%eax),%eax
  800b4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b50:	8b 45 14             	mov    0x14(%ebp),%eax
  800b53:	8d 40 08             	lea    0x8(%eax),%eax
  800b56:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b59:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b5d:	79 5c                	jns    800bbb <vprintfmt+0x2e5>
				putch('-', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2d                	push   $0x2d
  800b65:	ff d6                	call   *%esi
				num = -(long long) num;
  800b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6d:	f7 da                	neg    %edx
  800b6f:	83 d1 00             	adc    $0x0,%ecx
  800b72:	f7 d9                	neg    %ecx
  800b74:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	e9 10 01 00 00       	jmp    800c91 <vprintfmt+0x3bb>
	else if (lflag)
  800b81:	85 c9                	test   %ecx,%ecx
  800b83:	75 1b                	jne    800ba0 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800b85:	8b 45 14             	mov    0x14(%ebp),%eax
  800b88:	8b 00                	mov    (%eax),%eax
  800b8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8d:	89 c1                	mov    %eax,%ecx
  800b8f:	c1 f9 1f             	sar    $0x1f,%ecx
  800b92:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	8d 40 04             	lea    0x4(%eax),%eax
  800b9b:	89 45 14             	mov    %eax,0x14(%ebp)
  800b9e:	eb b9                	jmp    800b59 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800ba0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba3:	8b 00                	mov    (%eax),%eax
  800ba5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba8:	89 c1                	mov    %eax,%ecx
  800baa:	c1 f9 1f             	sar    $0x1f,%ecx
  800bad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb3:	8d 40 04             	lea    0x4(%eax),%eax
  800bb6:	89 45 14             	mov    %eax,0x14(%ebp)
  800bb9:	eb 9e                	jmp    800b59 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800bbb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800bbe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800bc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc6:	e9 c6 00 00 00       	jmp    800c91 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800bcb:	83 f9 01             	cmp    $0x1,%ecx
  800bce:	7e 18                	jle    800be8 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800bd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd3:	8b 10                	mov    (%eax),%edx
  800bd5:	8b 48 04             	mov    0x4(%eax),%ecx
  800bd8:	8d 40 08             	lea    0x8(%eax),%eax
  800bdb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bde:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be3:	e9 a9 00 00 00       	jmp    800c91 <vprintfmt+0x3bb>
	else if (lflag)
  800be8:	85 c9                	test   %ecx,%ecx
  800bea:	75 1a                	jne    800c06 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800bec:	8b 45 14             	mov    0x14(%ebp),%eax
  800bef:	8b 10                	mov    (%eax),%edx
  800bf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf6:	8d 40 04             	lea    0x4(%eax),%eax
  800bf9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c01:	e9 8b 00 00 00       	jmp    800c91 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800c06:	8b 45 14             	mov    0x14(%ebp),%eax
  800c09:	8b 10                	mov    (%eax),%edx
  800c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c10:	8d 40 04             	lea    0x4(%eax),%eax
  800c13:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800c16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c1b:	eb 74                	jmp    800c91 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800c1d:	83 f9 01             	cmp    $0x1,%ecx
  800c20:	7e 15                	jle    800c37 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800c22:	8b 45 14             	mov    0x14(%ebp),%eax
  800c25:	8b 10                	mov    (%eax),%edx
  800c27:	8b 48 04             	mov    0x4(%eax),%ecx
  800c2a:	8d 40 08             	lea    0x8(%eax),%eax
  800c2d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800c30:	b8 08 00 00 00       	mov    $0x8,%eax
  800c35:	eb 5a                	jmp    800c91 <vprintfmt+0x3bb>
	else if (lflag)
  800c37:	85 c9                	test   %ecx,%ecx
  800c39:	75 17                	jne    800c52 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800c3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3e:	8b 10                	mov    (%eax),%edx
  800c40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c45:	8d 40 04             	lea    0x4(%eax),%eax
  800c48:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	eb 3f                	jmp    800c91 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800c52:	8b 45 14             	mov    0x14(%ebp),%eax
  800c55:	8b 10                	mov    (%eax),%edx
  800c57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5c:	8d 40 04             	lea    0x4(%eax),%eax
  800c5f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800c62:	b8 08 00 00 00       	mov    $0x8,%eax
  800c67:	eb 28                	jmp    800c91 <vprintfmt+0x3bb>
			putch('0', putdat);
  800c69:	83 ec 08             	sub    $0x8,%esp
  800c6c:	53                   	push   %ebx
  800c6d:	6a 30                	push   $0x30
  800c6f:	ff d6                	call   *%esi
			putch('x', putdat);
  800c71:	83 c4 08             	add    $0x8,%esp
  800c74:	53                   	push   %ebx
  800c75:	6a 78                	push   $0x78
  800c77:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c79:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7c:	8b 10                	mov    (%eax),%edx
  800c7e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c83:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c86:	8d 40 04             	lea    0x4(%eax),%eax
  800c89:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c8c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c98:	57                   	push   %edi
  800c99:	ff 75 e0             	pushl  -0x20(%ebp)
  800c9c:	50                   	push   %eax
  800c9d:	51                   	push   %ecx
  800c9e:	52                   	push   %edx
  800c9f:	89 da                	mov    %ebx,%edx
  800ca1:	89 f0                	mov    %esi,%eax
  800ca3:	e8 45 fb ff ff       	call   8007ed <printnum>
			break;
  800ca8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800cab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cae:	83 c7 01             	add    $0x1,%edi
  800cb1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800cb5:	83 f8 25             	cmp    $0x25,%eax
  800cb8:	0f 84 2f fc ff ff    	je     8008ed <vprintfmt+0x17>
			if (ch == '\0')
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	0f 84 8b 00 00 00    	je     800d51 <vprintfmt+0x47b>
			putch(ch, putdat);
  800cc6:	83 ec 08             	sub    $0x8,%esp
  800cc9:	53                   	push   %ebx
  800cca:	50                   	push   %eax
  800ccb:	ff d6                	call   *%esi
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	eb dc                	jmp    800cae <vprintfmt+0x3d8>
	if (lflag >= 2)
  800cd2:	83 f9 01             	cmp    $0x1,%ecx
  800cd5:	7e 15                	jle    800cec <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cda:	8b 10                	mov    (%eax),%edx
  800cdc:	8b 48 04             	mov    0x4(%eax),%ecx
  800cdf:	8d 40 08             	lea    0x8(%eax),%eax
  800ce2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ce5:	b8 10 00 00 00       	mov    $0x10,%eax
  800cea:	eb a5                	jmp    800c91 <vprintfmt+0x3bb>
	else if (lflag)
  800cec:	85 c9                	test   %ecx,%ecx
  800cee:	75 17                	jne    800d07 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800cf0:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf3:	8b 10                	mov    (%eax),%edx
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	8d 40 04             	lea    0x4(%eax),%eax
  800cfd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800d00:	b8 10 00 00 00       	mov    $0x10,%eax
  800d05:	eb 8a                	jmp    800c91 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800d07:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0a:	8b 10                	mov    (%eax),%edx
  800d0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d11:	8d 40 04             	lea    0x4(%eax),%eax
  800d14:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800d17:	b8 10 00 00 00       	mov    $0x10,%eax
  800d1c:	e9 70 ff ff ff       	jmp    800c91 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800d21:	83 ec 08             	sub    $0x8,%esp
  800d24:	53                   	push   %ebx
  800d25:	6a 25                	push   $0x25
  800d27:	ff d6                	call   *%esi
			break;
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	e9 7a ff ff ff       	jmp    800cab <vprintfmt+0x3d5>
			putch('%', putdat);
  800d31:	83 ec 08             	sub    $0x8,%esp
  800d34:	53                   	push   %ebx
  800d35:	6a 25                	push   $0x25
  800d37:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	89 f8                	mov    %edi,%eax
  800d3e:	eb 03                	jmp    800d43 <vprintfmt+0x46d>
  800d40:	83 e8 01             	sub    $0x1,%eax
  800d43:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800d47:	75 f7                	jne    800d40 <vprintfmt+0x46a>
  800d49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d4c:	e9 5a ff ff ff       	jmp    800cab <vprintfmt+0x3d5>
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 18             	sub    $0x18,%esp
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d68:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d6c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	74 26                	je     800da0 <vsnprintf+0x47>
  800d7a:	85 d2                	test   %edx,%edx
  800d7c:	7e 22                	jle    800da0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d7e:	ff 75 14             	pushl  0x14(%ebp)
  800d81:	ff 75 10             	pushl  0x10(%ebp)
  800d84:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d87:	50                   	push   %eax
  800d88:	68 9c 08 80 00       	push   $0x80089c
  800d8d:	e8 44 fb ff ff       	call   8008d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d95:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9b:	83 c4 10             	add    $0x10,%esp
}
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    
		return -E_INVAL;
  800da0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da5:	eb f7                	jmp    800d9e <vsnprintf+0x45>

00800da7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800dad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800db0:	50                   	push   %eax
  800db1:	ff 75 10             	pushl  0x10(%ebp)
  800db4:	ff 75 0c             	pushl  0xc(%ebp)
  800db7:	ff 75 08             	pushl  0x8(%ebp)
  800dba:	e8 9a ff ff ff       	call   800d59 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	eb 03                	jmp    800dd1 <strlen+0x10>
		n++;
  800dce:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800dd1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dd5:	75 f7                	jne    800dce <strlen+0xd>
	return n;
}
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de2:	b8 00 00 00 00       	mov    $0x0,%eax
  800de7:	eb 03                	jmp    800dec <strnlen+0x13>
		n++;
  800de9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dec:	39 d0                	cmp    %edx,%eax
  800dee:	74 06                	je     800df6 <strnlen+0x1d>
  800df0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800df4:	75 f3                	jne    800de9 <strnlen+0x10>
	return n;
}
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	53                   	push   %ebx
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	83 c1 01             	add    $0x1,%ecx
  800e07:	83 c2 01             	add    $0x1,%edx
  800e0a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e0e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e11:	84 db                	test   %bl,%bl
  800e13:	75 ef                	jne    800e04 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e15:	5b                   	pop    %ebx
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	53                   	push   %ebx
  800e1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e1f:	53                   	push   %ebx
  800e20:	e8 9c ff ff ff       	call   800dc1 <strlen>
  800e25:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e28:	ff 75 0c             	pushl  0xc(%ebp)
  800e2b:	01 d8                	add    %ebx,%eax
  800e2d:	50                   	push   %eax
  800e2e:	e8 c5 ff ff ff       	call   800df8 <strcpy>
	return dst;
}
  800e33:	89 d8                	mov    %ebx,%eax
  800e35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
  800e3f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	89 f3                	mov    %esi,%ebx
  800e47:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e4a:	89 f2                	mov    %esi,%edx
  800e4c:	eb 0f                	jmp    800e5d <strncpy+0x23>
		*dst++ = *src;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	0f b6 01             	movzbl (%ecx),%eax
  800e54:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e57:	80 39 01             	cmpb   $0x1,(%ecx)
  800e5a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800e5d:	39 da                	cmp    %ebx,%edx
  800e5f:	75 ed                	jne    800e4e <strncpy+0x14>
	}
	return ret;
}
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e72:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e75:	89 f0                	mov    %esi,%eax
  800e77:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e7b:	85 c9                	test   %ecx,%ecx
  800e7d:	75 0b                	jne    800e8a <strlcpy+0x23>
  800e7f:	eb 17                	jmp    800e98 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e81:	83 c2 01             	add    $0x1,%edx
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800e8a:	39 d8                	cmp    %ebx,%eax
  800e8c:	74 07                	je     800e95 <strlcpy+0x2e>
  800e8e:	0f b6 0a             	movzbl (%edx),%ecx
  800e91:	84 c9                	test   %cl,%cl
  800e93:	75 ec                	jne    800e81 <strlcpy+0x1a>
		*dst = '\0';
  800e95:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e98:	29 f0                	sub    %esi,%eax
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ea7:	eb 06                	jmp    800eaf <strcmp+0x11>
		p++, q++;
  800ea9:	83 c1 01             	add    $0x1,%ecx
  800eac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800eaf:	0f b6 01             	movzbl (%ecx),%eax
  800eb2:	84 c0                	test   %al,%al
  800eb4:	74 04                	je     800eba <strcmp+0x1c>
  800eb6:	3a 02                	cmp    (%edx),%al
  800eb8:	74 ef                	je     800ea9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800eba:	0f b6 c0             	movzbl %al,%eax
  800ebd:	0f b6 12             	movzbl (%edx),%edx
  800ec0:	29 d0                	sub    %edx,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ed3:	eb 06                	jmp    800edb <strncmp+0x17>
		n--, p++, q++;
  800ed5:	83 c0 01             	add    $0x1,%eax
  800ed8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800edb:	39 d8                	cmp    %ebx,%eax
  800edd:	74 16                	je     800ef5 <strncmp+0x31>
  800edf:	0f b6 08             	movzbl (%eax),%ecx
  800ee2:	84 c9                	test   %cl,%cl
  800ee4:	74 04                	je     800eea <strncmp+0x26>
  800ee6:	3a 0a                	cmp    (%edx),%cl
  800ee8:	74 eb                	je     800ed5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eea:	0f b6 00             	movzbl (%eax),%eax
  800eed:	0f b6 12             	movzbl (%edx),%edx
  800ef0:	29 d0                	sub    %edx,%eax
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
		return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	eb f6                	jmp    800ef2 <strncmp+0x2e>

00800efc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f06:	0f b6 10             	movzbl (%eax),%edx
  800f09:	84 d2                	test   %dl,%dl
  800f0b:	74 09                	je     800f16 <strchr+0x1a>
		if (*s == c)
  800f0d:	38 ca                	cmp    %cl,%dl
  800f0f:	74 0a                	je     800f1b <strchr+0x1f>
	for (; *s; s++)
  800f11:	83 c0 01             	add    $0x1,%eax
  800f14:	eb f0                	jmp    800f06 <strchr+0xa>
			return (char *) s;
	return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f27:	eb 03                	jmp    800f2c <strfind+0xf>
  800f29:	83 c0 01             	add    $0x1,%eax
  800f2c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f2f:	38 ca                	cmp    %cl,%dl
  800f31:	74 04                	je     800f37 <strfind+0x1a>
  800f33:	84 d2                	test   %dl,%dl
  800f35:	75 f2                	jne    800f29 <strfind+0xc>
			break;
	return (char *) s;
}
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f45:	85 c9                	test   %ecx,%ecx
  800f47:	74 13                	je     800f5c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f4f:	75 05                	jne    800f56 <memset+0x1d>
  800f51:	f6 c1 03             	test   $0x3,%cl
  800f54:	74 0d                	je     800f63 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f59:	fc                   	cld    
  800f5a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f5c:	89 f8                	mov    %edi,%eax
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
		c &= 0xFF;
  800f63:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f67:	89 d3                	mov    %edx,%ebx
  800f69:	c1 e3 08             	shl    $0x8,%ebx
  800f6c:	89 d0                	mov    %edx,%eax
  800f6e:	c1 e0 18             	shl    $0x18,%eax
  800f71:	89 d6                	mov    %edx,%esi
  800f73:	c1 e6 10             	shl    $0x10,%esi
  800f76:	09 f0                	or     %esi,%eax
  800f78:	09 c2                	or     %eax,%edx
  800f7a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800f7c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f7f:	89 d0                	mov    %edx,%eax
  800f81:	fc                   	cld    
  800f82:	f3 ab                	rep stos %eax,%es:(%edi)
  800f84:	eb d6                	jmp    800f5c <memset+0x23>

00800f86 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f94:	39 c6                	cmp    %eax,%esi
  800f96:	73 35                	jae    800fcd <memmove+0x47>
  800f98:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f9b:	39 c2                	cmp    %eax,%edx
  800f9d:	76 2e                	jbe    800fcd <memmove+0x47>
		s += n;
		d += n;
  800f9f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa2:	89 d6                	mov    %edx,%esi
  800fa4:	09 fe                	or     %edi,%esi
  800fa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fac:	74 0c                	je     800fba <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fae:	83 ef 01             	sub    $0x1,%edi
  800fb1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800fb4:	fd                   	std    
  800fb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb7:	fc                   	cld    
  800fb8:	eb 21                	jmp    800fdb <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fba:	f6 c1 03             	test   $0x3,%cl
  800fbd:	75 ef                	jne    800fae <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fbf:	83 ef 04             	sub    $0x4,%edi
  800fc2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fc5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800fc8:	fd                   	std    
  800fc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fcb:	eb ea                	jmp    800fb7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	09 c2                	or     %eax,%edx
  800fd1:	f6 c2 03             	test   $0x3,%dl
  800fd4:	74 09                	je     800fdf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fd6:	89 c7                	mov    %eax,%edi
  800fd8:	fc                   	cld    
  800fd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fdf:	f6 c1 03             	test   $0x3,%cl
  800fe2:	75 f2                	jne    800fd6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fe4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	fc                   	cld    
  800fea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fec:	eb ed                	jmp    800fdb <memmove+0x55>

00800fee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ff1:	ff 75 10             	pushl  0x10(%ebp)
  800ff4:	ff 75 0c             	pushl  0xc(%ebp)
  800ff7:	ff 75 08             	pushl  0x8(%ebp)
  800ffa:	e8 87 ff ff ff       	call   800f86 <memmove>
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801011:	39 f0                	cmp    %esi,%eax
  801013:	74 1c                	je     801031 <memcmp+0x30>
		if (*s1 != *s2)
  801015:	0f b6 08             	movzbl (%eax),%ecx
  801018:	0f b6 1a             	movzbl (%edx),%ebx
  80101b:	38 d9                	cmp    %bl,%cl
  80101d:	75 08                	jne    801027 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80101f:	83 c0 01             	add    $0x1,%eax
  801022:	83 c2 01             	add    $0x1,%edx
  801025:	eb ea                	jmp    801011 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801027:	0f b6 c1             	movzbl %cl,%eax
  80102a:	0f b6 db             	movzbl %bl,%ebx
  80102d:	29 d8                	sub    %ebx,%eax
  80102f:	eb 05                	jmp    801036 <memcmp+0x35>
	}

	return 0;
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801043:	89 c2                	mov    %eax,%edx
  801045:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801048:	39 d0                	cmp    %edx,%eax
  80104a:	73 09                	jae    801055 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104c:	38 08                	cmp    %cl,(%eax)
  80104e:	74 05                	je     801055 <memfind+0x1b>
	for (; s < ends; s++)
  801050:	83 c0 01             	add    $0x1,%eax
  801053:	eb f3                	jmp    801048 <memfind+0xe>
			break;
	return (void *) s;
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801060:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801063:	eb 03                	jmp    801068 <strtol+0x11>
		s++;
  801065:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801068:	0f b6 01             	movzbl (%ecx),%eax
  80106b:	3c 20                	cmp    $0x20,%al
  80106d:	74 f6                	je     801065 <strtol+0xe>
  80106f:	3c 09                	cmp    $0x9,%al
  801071:	74 f2                	je     801065 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801073:	3c 2b                	cmp    $0x2b,%al
  801075:	74 2e                	je     8010a5 <strtol+0x4e>
	int neg = 0;
  801077:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80107c:	3c 2d                	cmp    $0x2d,%al
  80107e:	74 2f                	je     8010af <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801080:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801086:	75 05                	jne    80108d <strtol+0x36>
  801088:	80 39 30             	cmpb   $0x30,(%ecx)
  80108b:	74 2c                	je     8010b9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80108d:	85 db                	test   %ebx,%ebx
  80108f:	75 0a                	jne    80109b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801091:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801096:	80 39 30             	cmpb   $0x30,(%ecx)
  801099:	74 28                	je     8010c3 <strtol+0x6c>
		base = 10;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8010a3:	eb 50                	jmp    8010f5 <strtol+0x9e>
		s++;
  8010a5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8010a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ad:	eb d1                	jmp    801080 <strtol+0x29>
		s++, neg = 1;
  8010af:	83 c1 01             	add    $0x1,%ecx
  8010b2:	bf 01 00 00 00       	mov    $0x1,%edi
  8010b7:	eb c7                	jmp    801080 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010bd:	74 0e                	je     8010cd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8010bf:	85 db                	test   %ebx,%ebx
  8010c1:	75 d8                	jne    80109b <strtol+0x44>
		s++, base = 8;
  8010c3:	83 c1 01             	add    $0x1,%ecx
  8010c6:	bb 08 00 00 00       	mov    $0x8,%ebx
  8010cb:	eb ce                	jmp    80109b <strtol+0x44>
		s += 2, base = 16;
  8010cd:	83 c1 02             	add    $0x2,%ecx
  8010d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010d5:	eb c4                	jmp    80109b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8010d7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010da:	89 f3                	mov    %esi,%ebx
  8010dc:	80 fb 19             	cmp    $0x19,%bl
  8010df:	77 29                	ja     80110a <strtol+0xb3>
			dig = *s - 'a' + 10;
  8010e1:	0f be d2             	movsbl %dl,%edx
  8010e4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010e7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010ea:	7d 30                	jge    80111c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8010ec:	83 c1 01             	add    $0x1,%ecx
  8010ef:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010f3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8010f5:	0f b6 11             	movzbl (%ecx),%edx
  8010f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010fb:	89 f3                	mov    %esi,%ebx
  8010fd:	80 fb 09             	cmp    $0x9,%bl
  801100:	77 d5                	ja     8010d7 <strtol+0x80>
			dig = *s - '0';
  801102:	0f be d2             	movsbl %dl,%edx
  801105:	83 ea 30             	sub    $0x30,%edx
  801108:	eb dd                	jmp    8010e7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  80110a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80110d:	89 f3                	mov    %esi,%ebx
  80110f:	80 fb 19             	cmp    $0x19,%bl
  801112:	77 08                	ja     80111c <strtol+0xc5>
			dig = *s - 'A' + 10;
  801114:	0f be d2             	movsbl %dl,%edx
  801117:	83 ea 37             	sub    $0x37,%edx
  80111a:	eb cb                	jmp    8010e7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80111c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801120:	74 05                	je     801127 <strtol+0xd0>
		*endptr = (char *) s;
  801122:	8b 75 0c             	mov    0xc(%ebp),%esi
  801125:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801127:	89 c2                	mov    %eax,%edx
  801129:	f7 da                	neg    %edx
  80112b:	85 ff                	test   %edi,%edi
  80112d:	0f 45 c2             	cmovne %edx,%eax
}
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
  801140:	8b 55 08             	mov    0x8(%ebp),%edx
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	89 c3                	mov    %eax,%ebx
  801148:	89 c7                	mov    %eax,%edi
  80114a:	89 c6                	mov    %eax,%esi
  80114c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_cgetc>:

int
sys_cgetc(void)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
	asm volatile("int %1\n"
  801159:	ba 00 00 00 00       	mov    $0x0,%edx
  80115e:	b8 01 00 00 00       	mov    $0x1,%eax
  801163:	89 d1                	mov    %edx,%ecx
  801165:	89 d3                	mov    %edx,%ebx
  801167:	89 d7                	mov    %edx,%edi
  801169:	89 d6                	mov    %edx,%esi
  80116b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80117b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801180:	8b 55 08             	mov    0x8(%ebp),%edx
  801183:	b8 03 00 00 00       	mov    $0x3,%eax
  801188:	89 cb                	mov    %ecx,%ebx
  80118a:	89 cf                	mov    %ecx,%edi
  80118c:	89 ce                	mov    %ecx,%esi
  80118e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	7f 08                	jg     80119c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80119c:	83 ec 0c             	sub    $0xc,%esp
  80119f:	50                   	push   %eax
  8011a0:	6a 03                	push   $0x3
  8011a2:	68 7f 2b 80 00       	push   $0x802b7f
  8011a7:	6a 23                	push   $0x23
  8011a9:	68 9c 2b 80 00       	push   $0x802b9c
  8011ae:	e8 4b f5 ff ff       	call   8006fe <_panic>

008011b3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011be:	b8 02 00 00 00       	mov    $0x2,%eax
  8011c3:	89 d1                	mov    %edx,%ecx
  8011c5:	89 d3                	mov    %edx,%ebx
  8011c7:	89 d7                	mov    %edx,%edi
  8011c9:	89 d6                	mov    %edx,%esi
  8011cb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sys_yield>:

void
sys_yield(void)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011dd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011e2:	89 d1                	mov    %edx,%ecx
  8011e4:	89 d3                	mov    %edx,%ebx
  8011e6:	89 d7                	mov    %edx,%edi
  8011e8:	89 d6                	mov    %edx,%esi
  8011ea:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011fa:	be 00 00 00 00       	mov    $0x0,%esi
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801205:	b8 04 00 00 00       	mov    $0x4,%eax
  80120a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80120d:	89 f7                	mov    %esi,%edi
  80120f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7f 08                	jg     80121d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	50                   	push   %eax
  801221:	6a 04                	push   $0x4
  801223:	68 7f 2b 80 00       	push   $0x802b7f
  801228:	6a 23                	push   $0x23
  80122a:	68 9c 2b 80 00       	push   $0x802b9c
  80122f:	e8 ca f4 ff ff       	call   8006fe <_panic>

00801234 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80123d:	8b 55 08             	mov    0x8(%ebp),%edx
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	b8 05 00 00 00       	mov    $0x5,%eax
  801248:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124e:	8b 75 18             	mov    0x18(%ebp),%esi
  801251:	cd 30                	int    $0x30
	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7f 08                	jg     80125f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	50                   	push   %eax
  801263:	6a 05                	push   $0x5
  801265:	68 7f 2b 80 00       	push   $0x802b7f
  80126a:	6a 23                	push   $0x23
  80126c:	68 9c 2b 80 00       	push   $0x802b9c
  801271:	e8 88 f4 ff ff       	call   8006fe <_panic>

00801276 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80127f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801284:	8b 55 08             	mov    0x8(%ebp),%edx
  801287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128a:	b8 06 00 00 00       	mov    $0x6,%eax
  80128f:	89 df                	mov    %ebx,%edi
  801291:	89 de                	mov    %ebx,%esi
  801293:	cd 30                	int    $0x30
	if(check && ret > 0)
  801295:	85 c0                	test   %eax,%eax
  801297:	7f 08                	jg     8012a1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	50                   	push   %eax
  8012a5:	6a 06                	push   $0x6
  8012a7:	68 7f 2b 80 00       	push   $0x802b7f
  8012ac:	6a 23                	push   $0x23
  8012ae:	68 9c 2b 80 00       	push   $0x802b9c
  8012b3:	e8 46 f4 ff ff       	call   8006fe <_panic>

008012b8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	57                   	push   %edi
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8012d1:	89 df                	mov    %ebx,%edi
  8012d3:	89 de                	mov    %ebx,%esi
  8012d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	7f 08                	jg     8012e3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	50                   	push   %eax
  8012e7:	6a 08                	push   $0x8
  8012e9:	68 7f 2b 80 00       	push   $0x802b7f
  8012ee:	6a 23                	push   $0x23
  8012f0:	68 9c 2b 80 00       	push   $0x802b9c
  8012f5:	e8 04 f4 ff ff       	call   8006fe <_panic>

008012fa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801303:	bb 00 00 00 00       	mov    $0x0,%ebx
  801308:	8b 55 08             	mov    0x8(%ebp),%edx
  80130b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130e:	b8 09 00 00 00       	mov    $0x9,%eax
  801313:	89 df                	mov    %ebx,%edi
  801315:	89 de                	mov    %ebx,%esi
  801317:	cd 30                	int    $0x30
	if(check && ret > 0)
  801319:	85 c0                	test   %eax,%eax
  80131b:	7f 08                	jg     801325 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80131d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	50                   	push   %eax
  801329:	6a 09                	push   $0x9
  80132b:	68 7f 2b 80 00       	push   $0x802b7f
  801330:	6a 23                	push   $0x23
  801332:	68 9c 2b 80 00       	push   $0x802b9c
  801337:	e8 c2 f3 ff ff       	call   8006fe <_panic>

0080133c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	57                   	push   %edi
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801345:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134a:	8b 55 08             	mov    0x8(%ebp),%edx
  80134d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801350:	b8 0a 00 00 00       	mov    $0xa,%eax
  801355:	89 df                	mov    %ebx,%edi
  801357:	89 de                	mov    %ebx,%esi
  801359:	cd 30                	int    $0x30
	if(check && ret > 0)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	7f 08                	jg     801367 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80135f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	50                   	push   %eax
  80136b:	6a 0a                	push   $0xa
  80136d:	68 7f 2b 80 00       	push   $0x802b7f
  801372:	6a 23                	push   $0x23
  801374:	68 9c 2b 80 00       	push   $0x802b9c
  801379:	e8 80 f3 ff ff       	call   8006fe <_panic>

0080137e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
	asm volatile("int %1\n"
  801384:	8b 55 08             	mov    0x8(%ebp),%edx
  801387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80138f:	be 00 00 00 00       	mov    $0x0,%esi
  801394:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801397:	8b 7d 14             	mov    0x14(%ebp),%edi
  80139a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	57                   	push   %edi
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013af:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013b7:	89 cb                	mov    %ecx,%ebx
  8013b9:	89 cf                	mov    %ecx,%edi
  8013bb:	89 ce                	mov    %ecx,%esi
  8013bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	7f 08                	jg     8013cb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	50                   	push   %eax
  8013cf:	6a 0d                	push   $0xd
  8013d1:	68 7f 2b 80 00       	push   $0x802b7f
  8013d6:	6a 23                	push   $0x23
  8013d8:	68 9c 2b 80 00       	push   $0x802b9c
  8013dd:	e8 1c f3 ff ff       	call   8006fe <_panic>

008013e2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8013f7:	0f 44 c2             	cmove  %edx,%eax
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	50                   	push   %eax
  8013fe:	e8 9e ff ff ff       	call   8013a1 <sys_ipc_recv>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 2b                	js     801435 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  80140a:	85 f6                	test   %esi,%esi
  80140c:	74 0a                	je     801418 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  80140e:	a1 04 40 80 00       	mov    0x804004,%eax
  801413:	8b 40 74             	mov    0x74(%eax),%eax
  801416:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801418:	85 db                	test   %ebx,%ebx
  80141a:	74 0a                	je     801426 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  80141c:	a1 04 40 80 00       	mov    0x804004,%eax
  801421:	8b 40 78             	mov    0x78(%eax),%eax
  801424:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801426:	a1 04 40 80 00       	mov    0x804004,%eax
  80142b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80142e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    
        *from_env_store = 0;
  801435:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  80143b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801441:	eb eb                	jmp    80142e <ipc_recv+0x4c>

00801443 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	57                   	push   %edi
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801452:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801455:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801457:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80145c:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  80145f:	ff 75 14             	pushl  0x14(%ebp)
  801462:	53                   	push   %ebx
  801463:	56                   	push   %esi
  801464:	57                   	push   %edi
  801465:	e8 14 ff ff ff       	call   80137e <sys_ipc_try_send>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	74 17                	je     801488 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801471:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801474:	74 e9                	je     80145f <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801476:	50                   	push   %eax
  801477:	68 aa 2b 80 00       	push   $0x802baa
  80147c:	6a 3e                	push   $0x3e
  80147e:	68 bc 2b 80 00       	push   $0x802bbc
  801483:	e8 76 f2 ff ff       	call   8006fe <_panic>
        }
    }
}
  801488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5f                   	pop    %edi
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80149b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80149e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014a4:	8b 52 50             	mov    0x50(%edx),%edx
  8014a7:	39 ca                	cmp    %ecx,%edx
  8014a9:	74 11                	je     8014bc <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8014ab:	83 c0 01             	add    $0x1,%eax
  8014ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014b3:	75 e6                	jne    80149b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ba:	eb 0b                	jmp    8014c7 <ipc_find_env+0x37>
			return envs[i].env_id;
  8014bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014c4:	8b 40 48             	mov    0x48(%eax),%eax
}
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	c1 ea 16             	shr    $0x16,%edx
  801500:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801507:	f6 c2 01             	test   $0x1,%dl
  80150a:	74 2a                	je     801536 <fd_alloc+0x46>
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	c1 ea 0c             	shr    $0xc,%edx
  801511:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801518:	f6 c2 01             	test   $0x1,%dl
  80151b:	74 19                	je     801536 <fd_alloc+0x46>
  80151d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801522:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801527:	75 d2                	jne    8014fb <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801529:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80152f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801534:	eb 07                	jmp    80153d <fd_alloc+0x4d>
			*fd_store = fd;
  801536:	89 01                	mov    %eax,(%ecx)
			return 0;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    

0080153f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801545:	83 f8 1f             	cmp    $0x1f,%eax
  801548:	77 36                	ja     801580 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80154a:	c1 e0 0c             	shl    $0xc,%eax
  80154d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801552:	89 c2                	mov    %eax,%edx
  801554:	c1 ea 16             	shr    $0x16,%edx
  801557:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80155e:	f6 c2 01             	test   $0x1,%dl
  801561:	74 24                	je     801587 <fd_lookup+0x48>
  801563:	89 c2                	mov    %eax,%edx
  801565:	c1 ea 0c             	shr    $0xc,%edx
  801568:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80156f:	f6 c2 01             	test   $0x1,%dl
  801572:	74 1a                	je     80158e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801574:	8b 55 0c             	mov    0xc(%ebp),%edx
  801577:	89 02                	mov    %eax,(%edx)
	return 0;
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
		return -E_INVAL;
  801580:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801585:	eb f7                	jmp    80157e <fd_lookup+0x3f>
		return -E_INVAL;
  801587:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158c:	eb f0                	jmp    80157e <fd_lookup+0x3f>
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801593:	eb e9                	jmp    80157e <fd_lookup+0x3f>

00801595 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159e:	ba 44 2c 80 00       	mov    $0x802c44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a3:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015a8:	39 08                	cmp    %ecx,(%eax)
  8015aa:	74 33                	je     8015df <dev_lookup+0x4a>
  8015ac:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8015af:	8b 02                	mov    (%edx),%eax
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	75 f3                	jne    8015a8 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ba:	8b 40 48             	mov    0x48(%eax),%eax
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	51                   	push   %ecx
  8015c1:	50                   	push   %eax
  8015c2:	68 c8 2b 80 00       	push   $0x802bc8
  8015c7:	e8 0d f2 ff ff       	call   8007d9 <cprintf>
	*dev = 0;
  8015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    
			*dev = devtab[i];
  8015df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e9:	eb f2                	jmp    8015dd <dev_lookup+0x48>

008015eb <fd_close>:
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 1c             	sub    $0x1c,%esp
  8015f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015fd:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801604:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801607:	50                   	push   %eax
  801608:	e8 32 ff ff ff       	call   80153f <fd_lookup>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 05                	js     80161b <fd_close+0x30>
	    || fd != fd2)
  801616:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801619:	74 16                	je     801631 <fd_close+0x46>
		return (must_exist ? r : 0);
  80161b:	89 f8                	mov    %edi,%eax
  80161d:	84 c0                	test   %al,%al
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
  801624:	0f 44 d8             	cmove  %eax,%ebx
}
  801627:	89 d8                	mov    %ebx,%eax
  801629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5f                   	pop    %edi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	ff 36                	pushl  (%esi)
  80163a:	e8 56 ff ff ff       	call   801595 <dev_lookup>
  80163f:	89 c3                	mov    %eax,%ebx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 15                	js     80165d <fd_close+0x72>
		if (dev->dev_close)
  801648:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80164b:	8b 40 10             	mov    0x10(%eax),%eax
  80164e:	85 c0                	test   %eax,%eax
  801650:	74 1b                	je     80166d <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	56                   	push   %esi
  801656:	ff d0                	call   *%eax
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	56                   	push   %esi
  801661:	6a 00                	push   $0x0
  801663:	e8 0e fc ff ff       	call   801276 <sys_page_unmap>
	return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb ba                	jmp    801627 <fd_close+0x3c>
			r = 0;
  80166d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801672:	eb e9                	jmp    80165d <fd_close+0x72>

00801674 <close>:

int
close(int fdnum)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 b9 fe ff ff       	call   80153f <fd_lookup>
  801686:	83 c4 08             	add    $0x8,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 10                	js     80169d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	6a 01                	push   $0x1
  801692:	ff 75 f4             	pushl  -0xc(%ebp)
  801695:	e8 51 ff ff ff       	call   8015eb <fd_close>
  80169a:	83 c4 10             	add    $0x10,%esp
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <close_all>:

void
close_all(void)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	53                   	push   %ebx
  8016af:	e8 c0 ff ff ff       	call   801674 <close>
	for (i = 0; i < MAXFD; i++)
  8016b4:	83 c3 01             	add    $0x1,%ebx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	83 fb 20             	cmp    $0x20,%ebx
  8016bd:	75 ec                	jne    8016ab <close_all+0xc>
}
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	57                   	push   %edi
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 66 fe ff ff       	call   80153f <fd_lookup>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	83 c4 08             	add    $0x8,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	0f 88 81 00 00 00    	js     801767 <dup+0xa3>
		return r;
	close(newfdnum);
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	e8 83 ff ff ff       	call   801674 <close>

	newfd = INDEX2FD(newfdnum);
  8016f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016f4:	c1 e6 0c             	shl    $0xc,%esi
  8016f7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016fd:	83 c4 04             	add    $0x4,%esp
  801700:	ff 75 e4             	pushl  -0x1c(%ebp)
  801703:	e8 d1 fd ff ff       	call   8014d9 <fd2data>
  801708:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80170a:	89 34 24             	mov    %esi,(%esp)
  80170d:	e8 c7 fd ff ff       	call   8014d9 <fd2data>
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801717:	89 d8                	mov    %ebx,%eax
  801719:	c1 e8 16             	shr    $0x16,%eax
  80171c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801723:	a8 01                	test   $0x1,%al
  801725:	74 11                	je     801738 <dup+0x74>
  801727:	89 d8                	mov    %ebx,%eax
  801729:	c1 e8 0c             	shr    $0xc,%eax
  80172c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801733:	f6 c2 01             	test   $0x1,%dl
  801736:	75 39                	jne    801771 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801738:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80173b:	89 d0                	mov    %edx,%eax
  80173d:	c1 e8 0c             	shr    $0xc,%eax
  801740:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801747:	83 ec 0c             	sub    $0xc,%esp
  80174a:	25 07 0e 00 00       	and    $0xe07,%eax
  80174f:	50                   	push   %eax
  801750:	56                   	push   %esi
  801751:	6a 00                	push   $0x0
  801753:	52                   	push   %edx
  801754:	6a 00                	push   $0x0
  801756:	e8 d9 fa ff ff       	call   801234 <sys_page_map>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 20             	add    $0x20,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 31                	js     801795 <dup+0xd1>
		goto err;

	return newfdnum;
  801764:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801767:	89 d8                	mov    %ebx,%eax
  801769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5e                   	pop    %esi
  80176e:	5f                   	pop    %edi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801771:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801778:	83 ec 0c             	sub    $0xc,%esp
  80177b:	25 07 0e 00 00       	and    $0xe07,%eax
  801780:	50                   	push   %eax
  801781:	57                   	push   %edi
  801782:	6a 00                	push   $0x0
  801784:	53                   	push   %ebx
  801785:	6a 00                	push   $0x0
  801787:	e8 a8 fa ff ff       	call   801234 <sys_page_map>
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	83 c4 20             	add    $0x20,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	79 a3                	jns    801738 <dup+0x74>
	sys_page_unmap(0, newfd);
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	56                   	push   %esi
  801799:	6a 00                	push   $0x0
  80179b:	e8 d6 fa ff ff       	call   801276 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	57                   	push   %edi
  8017a4:	6a 00                	push   $0x0
  8017a6:	e8 cb fa ff ff       	call   801276 <sys_page_unmap>
	return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	eb b7                	jmp    801767 <dup+0xa3>

008017b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 14             	sub    $0x14,%esp
  8017b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bd:	50                   	push   %eax
  8017be:	53                   	push   %ebx
  8017bf:	e8 7b fd ff ff       	call   80153f <fd_lookup>
  8017c4:	83 c4 08             	add    $0x8,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 3f                	js     80180a <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d5:	ff 30                	pushl  (%eax)
  8017d7:	e8 b9 fd ff ff       	call   801595 <dev_lookup>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 27                	js     80180a <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e6:	8b 42 08             	mov    0x8(%edx),%eax
  8017e9:	83 e0 03             	and    $0x3,%eax
  8017ec:	83 f8 01             	cmp    $0x1,%eax
  8017ef:	74 1e                	je     80180f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f4:	8b 40 08             	mov    0x8(%eax),%eax
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	74 35                	je     801830 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	ff 75 10             	pushl  0x10(%ebp)
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	52                   	push   %edx
  801805:	ff d0                	call   *%eax
  801807:	83 c4 10             	add    $0x10,%esp
}
  80180a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180f:	a1 04 40 80 00       	mov    0x804004,%eax
  801814:	8b 40 48             	mov    0x48(%eax),%eax
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	53                   	push   %ebx
  80181b:	50                   	push   %eax
  80181c:	68 09 2c 80 00       	push   $0x802c09
  801821:	e8 b3 ef ff ff       	call   8007d9 <cprintf>
		return -E_INVAL;
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182e:	eb da                	jmp    80180a <read+0x5a>
		return -E_NOT_SUPP;
  801830:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801835:	eb d3                	jmp    80180a <read+0x5a>

00801837 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	8b 7d 08             	mov    0x8(%ebp),%edi
  801843:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801846:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184b:	39 f3                	cmp    %esi,%ebx
  80184d:	73 25                	jae    801874 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	89 f0                	mov    %esi,%eax
  801854:	29 d8                	sub    %ebx,%eax
  801856:	50                   	push   %eax
  801857:	89 d8                	mov    %ebx,%eax
  801859:	03 45 0c             	add    0xc(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	57                   	push   %edi
  80185e:	e8 4d ff ff ff       	call   8017b0 <read>
		if (m < 0)
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	78 08                	js     801872 <readn+0x3b>
			return m;
		if (m == 0)
  80186a:	85 c0                	test   %eax,%eax
  80186c:	74 06                	je     801874 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80186e:	01 c3                	add    %eax,%ebx
  801870:	eb d9                	jmp    80184b <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801872:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801874:	89 d8                	mov    %ebx,%eax
  801876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 14             	sub    $0x14,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	53                   	push   %ebx
  80188d:	e8 ad fc ff ff       	call   80153f <fd_lookup>
  801892:	83 c4 08             	add    $0x8,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 3a                	js     8018d3 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801899:	83 ec 08             	sub    $0x8,%esp
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a3:	ff 30                	pushl  (%eax)
  8018a5:	e8 eb fc ff ff       	call   801595 <dev_lookup>
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 22                	js     8018d3 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b8:	74 1e                	je     8018d8 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c0:	85 d2                	test   %edx,%edx
  8018c2:	74 35                	je     8018f9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	ff 75 10             	pushl  0x10(%ebp)
  8018ca:	ff 75 0c             	pushl  0xc(%ebp)
  8018cd:	50                   	push   %eax
  8018ce:	ff d2                	call   *%edx
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018dd:	8b 40 48             	mov    0x48(%eax),%eax
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	50                   	push   %eax
  8018e5:	68 25 2c 80 00       	push   $0x802c25
  8018ea:	e8 ea ee ff ff       	call   8007d9 <cprintf>
		return -E_INVAL;
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f7:	eb da                	jmp    8018d3 <write+0x55>
		return -E_NOT_SUPP;
  8018f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018fe:	eb d3                	jmp    8018d3 <write+0x55>

00801900 <seek>:

int
seek(int fdnum, off_t offset)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801906:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	ff 75 08             	pushl  0x8(%ebp)
  80190d:	e8 2d fc ff ff       	call   80153f <fd_lookup>
  801912:	83 c4 08             	add    $0x8,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	78 0e                	js     801927 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80191f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 14             	sub    $0x14,%esp
  801930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801933:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	53                   	push   %ebx
  801938:	e8 02 fc ff ff       	call   80153f <fd_lookup>
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	78 37                	js     80197b <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194e:	ff 30                	pushl  (%eax)
  801950:	e8 40 fc ff ff       	call   801595 <dev_lookup>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 1f                	js     80197b <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801963:	74 1b                	je     801980 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801968:	8b 52 18             	mov    0x18(%edx),%edx
  80196b:	85 d2                	test   %edx,%edx
  80196d:	74 32                	je     8019a1 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	50                   	push   %eax
  801976:	ff d2                	call   *%edx
  801978:	83 c4 10             	add    $0x10,%esp
}
  80197b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801980:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801985:	8b 40 48             	mov    0x48(%eax),%eax
  801988:	83 ec 04             	sub    $0x4,%esp
  80198b:	53                   	push   %ebx
  80198c:	50                   	push   %eax
  80198d:	68 e8 2b 80 00       	push   $0x802be8
  801992:	e8 42 ee ff ff       	call   8007d9 <cprintf>
		return -E_INVAL;
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80199f:	eb da                	jmp    80197b <ftruncate+0x52>
		return -E_NOT_SUPP;
  8019a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a6:	eb d3                	jmp    80197b <ftruncate+0x52>

008019a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 14             	sub    $0x14,%esp
  8019af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 81 fb ff ff       	call   80153f <fd_lookup>
  8019be:	83 c4 08             	add    $0x8,%esp
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 4b                	js     801a10 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cb:	50                   	push   %eax
  8019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cf:	ff 30                	pushl  (%eax)
  8019d1:	e8 bf fb ff ff       	call   801595 <dev_lookup>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 33                	js     801a10 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e4:	74 2f                	je     801a15 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f0:	00 00 00 
	stat->st_isdir = 0;
  8019f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fa:	00 00 00 
	stat->st_dev = dev;
  8019fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	53                   	push   %ebx
  801a07:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0a:	ff 50 14             	call   *0x14(%eax)
  801a0d:	83 c4 10             	add    $0x10,%esp
}
  801a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    
		return -E_NOT_SUPP;
  801a15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a1a:	eb f4                	jmp    801a10 <fstat+0x68>

00801a1c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	6a 00                	push   $0x0
  801a26:	ff 75 08             	pushl  0x8(%ebp)
  801a29:	e8 e7 01 00 00       	call   801c15 <open>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 1b                	js     801a52 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	ff 75 0c             	pushl  0xc(%ebp)
  801a3d:	50                   	push   %eax
  801a3e:	e8 65 ff ff ff       	call   8019a8 <fstat>
  801a43:	89 c6                	mov    %eax,%esi
	close(fd);
  801a45:	89 1c 24             	mov    %ebx,(%esp)
  801a48:	e8 27 fc ff ff       	call   801674 <close>
	return r;
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	89 f3                	mov    %esi,%ebx
}
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	89 c6                	mov    %eax,%esi
  801a62:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a64:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a6b:	74 27                	je     801a94 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a6d:	6a 07                	push   $0x7
  801a6f:	68 00 50 80 00       	push   $0x805000
  801a74:	56                   	push   %esi
  801a75:	ff 35 00 40 80 00    	pushl  0x804000
  801a7b:	e8 c3 f9 ff ff       	call   801443 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a80:	83 c4 0c             	add    $0xc,%esp
  801a83:	6a 00                	push   $0x0
  801a85:	53                   	push   %ebx
  801a86:	6a 00                	push   $0x0
  801a88:	e8 55 f9 ff ff       	call   8013e2 <ipc_recv>
}
  801a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	6a 01                	push   $0x1
  801a99:	e8 f2 f9 ff ff       	call   801490 <ipc_find_env>
  801a9e:	a3 00 40 80 00       	mov    %eax,0x804000
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb c5                	jmp    801a6d <fsipc+0x12>

00801aa8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac6:	b8 02 00 00 00       	mov    $0x2,%eax
  801acb:	e8 8b ff ff ff       	call   801a5b <fsipc>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devfile_flush>:
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ade:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae8:	b8 06 00 00 00       	mov    $0x6,%eax
  801aed:	e8 69 ff ff ff       	call   801a5b <fsipc>
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <devfile_stat>:
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	53                   	push   %ebx
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	8b 40 0c             	mov    0xc(%eax),%eax
  801b04:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b09:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801b13:	e8 43 ff ff ff       	call   801a5b <fsipc>
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 2c                	js     801b48 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	68 00 50 80 00       	push   $0x805000
  801b24:	53                   	push   %ebx
  801b25:	e8 ce f2 ff ff       	call   800df8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b2a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b35:	a1 84 50 80 00       	mov    0x805084,%eax
  801b3a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <devfile_write>:
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801b56:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b5b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b60:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b63:	8b 55 08             	mov    0x8(%ebp),%edx
  801b66:	8b 52 0c             	mov    0xc(%edx),%edx
  801b69:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801b6f:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801b74:	50                   	push   %eax
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	68 08 50 80 00       	push   $0x805008
  801b7d:	e8 04 f4 ff ff       	call   800f86 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
  801b87:	b8 04 00 00 00       	mov    $0x4,%eax
  801b8c:	e8 ca fe ff ff       	call   801a5b <fsipc>
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devfile_read>:
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ba6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bac:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb1:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb6:	e8 a0 fe ff ff       	call   801a5b <fsipc>
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 1f                	js     801be0 <devfile_read+0x4d>
	assert(r <= n);
  801bc1:	39 f0                	cmp    %esi,%eax
  801bc3:	77 24                	ja     801be9 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801bc5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bca:	7f 33                	jg     801bff <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	50                   	push   %eax
  801bd0:	68 00 50 80 00       	push   $0x805000
  801bd5:	ff 75 0c             	pushl  0xc(%ebp)
  801bd8:	e8 a9 f3 ff ff       	call   800f86 <memmove>
	return r;
  801bdd:	83 c4 10             	add    $0x10,%esp
}
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    
	assert(r <= n);
  801be9:	68 54 2c 80 00       	push   $0x802c54
  801bee:	68 5b 2c 80 00       	push   $0x802c5b
  801bf3:	6a 7d                	push   $0x7d
  801bf5:	68 70 2c 80 00       	push   $0x802c70
  801bfa:	e8 ff ea ff ff       	call   8006fe <_panic>
	assert(r <= PGSIZE);
  801bff:	68 7b 2c 80 00       	push   $0x802c7b
  801c04:	68 5b 2c 80 00       	push   $0x802c5b
  801c09:	6a 7e                	push   $0x7e
  801c0b:	68 70 2c 80 00       	push   $0x802c70
  801c10:	e8 e9 ea ff ff       	call   8006fe <_panic>

00801c15 <open>:
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	56                   	push   %esi
  801c19:	53                   	push   %ebx
  801c1a:	83 ec 1c             	sub    $0x1c,%esp
  801c1d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c20:	56                   	push   %esi
  801c21:	e8 9b f1 ff ff       	call   800dc1 <strlen>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c2e:	0f 8f 96 00 00 00    	jg     801cca <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3a:	50                   	push   %eax
  801c3b:	e8 b0 f8 ff ff       	call   8014f0 <fd_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 66                	js     801caf <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	56                   	push   %esi
  801c4d:	68 00 50 80 00       	push   $0x805000
  801c52:	e8 a1 f1 ff ff       	call   800df8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	e8 ef fd ff ff       	call   801a5b <fsipc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 43                	js     801cb8 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7b:	e8 49 f8 ff ff       	call   8014c9 <fd2num>
  801c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c83:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801c89:	8b 49 48             	mov    0x48(%ecx),%ecx
  801c8c:	83 c4 08             	add    $0x8,%esp
  801c8f:	50                   	push   %eax
  801c90:	52                   	push   %edx
  801c91:	ff 32                	pushl  (%edx)
  801c93:	56                   	push   %esi
  801c94:	51                   	push   %ecx
  801c95:	68 88 2c 80 00       	push   $0x802c88
  801c9a:	e8 3a eb ff ff       	call   8007d9 <cprintf>
	return fd2num(fd);
  801c9f:	83 c4 14             	add    $0x14,%esp
  801ca2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca5:	e8 1f f8 ff ff       	call   8014c9 <fd2num>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
}
  801caf:	89 d8                	mov    %ebx,%eax
  801cb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
		fd_close(fd, 0);
  801cb8:	83 ec 08             	sub    $0x8,%esp
  801cbb:	6a 00                	push   $0x0
  801cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc0:	e8 26 f9 ff ff       	call   8015eb <fd_close>
		return r;
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	eb e5                	jmp    801caf <open+0x9a>
		return -E_BAD_PATH;
  801cca:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ccf:	eb de                	jmp    801caf <open+0x9a>

00801cd1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdc:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce1:	e8 75 fd ff ff       	call   801a5b <fsipc>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	56                   	push   %esi
  801cec:	53                   	push   %ebx
  801ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	ff 75 08             	pushl  0x8(%ebp)
  801cf6:	e8 de f7 ff ff       	call   8014d9 <fd2data>
  801cfb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cfd:	83 c4 08             	add    $0x8,%esp
  801d00:	68 c8 2c 80 00       	push   $0x802cc8
  801d05:	53                   	push   %ebx
  801d06:	e8 ed f0 ff ff       	call   800df8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d0b:	8b 46 04             	mov    0x4(%esi),%eax
  801d0e:	2b 06                	sub    (%esi),%eax
  801d10:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d1d:	00 00 00 
	stat->st_dev = &devpipe;
  801d20:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d27:	30 80 00 
	return 0;
}
  801d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d32:	5b                   	pop    %ebx
  801d33:	5e                   	pop    %esi
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    

00801d36 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	53                   	push   %ebx
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d40:	53                   	push   %ebx
  801d41:	6a 00                	push   $0x0
  801d43:	e8 2e f5 ff ff       	call   801276 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d48:	89 1c 24             	mov    %ebx,(%esp)
  801d4b:	e8 89 f7 ff ff       	call   8014d9 <fd2data>
  801d50:	83 c4 08             	add    $0x8,%esp
  801d53:	50                   	push   %eax
  801d54:	6a 00                	push   $0x0
  801d56:	e8 1b f5 ff ff       	call   801276 <sys_page_unmap>
}
  801d5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <_pipeisclosed>:
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	57                   	push   %edi
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	83 ec 1c             	sub    $0x1c,%esp
  801d69:	89 c7                	mov    %eax,%edi
  801d6b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801d72:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d75:	83 ec 0c             	sub    $0xc,%esp
  801d78:	57                   	push   %edi
  801d79:	e8 34 04 00 00       	call   8021b2 <pageref>
  801d7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d81:	89 34 24             	mov    %esi,(%esp)
  801d84:	e8 29 04 00 00       	call   8021b2 <pageref>
		nn = thisenv->env_runs;
  801d89:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	39 cb                	cmp    %ecx,%ebx
  801d97:	74 1b                	je     801db4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d99:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d9c:	75 cf                	jne    801d6d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d9e:	8b 42 58             	mov    0x58(%edx),%eax
  801da1:	6a 01                	push   $0x1
  801da3:	50                   	push   %eax
  801da4:	53                   	push   %ebx
  801da5:	68 cf 2c 80 00       	push   $0x802ccf
  801daa:	e8 2a ea ff ff       	call   8007d9 <cprintf>
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	eb b9                	jmp    801d6d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801db4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801db7:	0f 94 c0             	sete   %al
  801dba:	0f b6 c0             	movzbl %al,%eax
}
  801dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <devpipe_write>:
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	57                   	push   %edi
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 28             	sub    $0x28,%esp
  801dce:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dd1:	56                   	push   %esi
  801dd2:	e8 02 f7 ff ff       	call   8014d9 <fd2data>
  801dd7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	bf 00 00 00 00       	mov    $0x0,%edi
  801de1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de4:	74 4f                	je     801e35 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801de6:	8b 43 04             	mov    0x4(%ebx),%eax
  801de9:	8b 0b                	mov    (%ebx),%ecx
  801deb:	8d 51 20             	lea    0x20(%ecx),%edx
  801dee:	39 d0                	cmp    %edx,%eax
  801df0:	72 14                	jb     801e06 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801df2:	89 da                	mov    %ebx,%edx
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	e8 65 ff ff ff       	call   801d60 <_pipeisclosed>
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	75 3a                	jne    801e39 <devpipe_write+0x74>
			sys_yield();
  801dff:	e8 ce f3 ff ff       	call   8011d2 <sys_yield>
  801e04:	eb e0                	jmp    801de6 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e09:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e0d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	c1 fa 1f             	sar    $0x1f,%edx
  801e15:	89 d1                	mov    %edx,%ecx
  801e17:	c1 e9 1b             	shr    $0x1b,%ecx
  801e1a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e1d:	83 e2 1f             	and    $0x1f,%edx
  801e20:	29 ca                	sub    %ecx,%edx
  801e22:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e2a:	83 c0 01             	add    $0x1,%eax
  801e2d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e30:	83 c7 01             	add    $0x1,%edi
  801e33:	eb ac                	jmp    801de1 <devpipe_write+0x1c>
	return i;
  801e35:	89 f8                	mov    %edi,%eax
  801e37:	eb 05                	jmp    801e3e <devpipe_write+0x79>
				return 0;
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <devpipe_read>:
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	57                   	push   %edi
  801e4a:	56                   	push   %esi
  801e4b:	53                   	push   %ebx
  801e4c:	83 ec 18             	sub    $0x18,%esp
  801e4f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e52:	57                   	push   %edi
  801e53:	e8 81 f6 ff ff       	call   8014d9 <fd2data>
  801e58:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	be 00 00 00 00       	mov    $0x0,%esi
  801e62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e65:	74 47                	je     801eae <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801e67:	8b 03                	mov    (%ebx),%eax
  801e69:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e6c:	75 22                	jne    801e90 <devpipe_read+0x4a>
			if (i > 0)
  801e6e:	85 f6                	test   %esi,%esi
  801e70:	75 14                	jne    801e86 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801e72:	89 da                	mov    %ebx,%edx
  801e74:	89 f8                	mov    %edi,%eax
  801e76:	e8 e5 fe ff ff       	call   801d60 <_pipeisclosed>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	75 33                	jne    801eb2 <devpipe_read+0x6c>
			sys_yield();
  801e7f:	e8 4e f3 ff ff       	call   8011d2 <sys_yield>
  801e84:	eb e1                	jmp    801e67 <devpipe_read+0x21>
				return i;
  801e86:	89 f0                	mov    %esi,%eax
}
  801e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5f                   	pop    %edi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e90:	99                   	cltd   
  801e91:	c1 ea 1b             	shr    $0x1b,%edx
  801e94:	01 d0                	add    %edx,%eax
  801e96:	83 e0 1f             	and    $0x1f,%eax
  801e99:	29 d0                	sub    %edx,%eax
  801e9b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ea6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ea9:	83 c6 01             	add    $0x1,%esi
  801eac:	eb b4                	jmp    801e62 <devpipe_read+0x1c>
	return i;
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	eb d6                	jmp    801e88 <devpipe_read+0x42>
				return 0;
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	eb cf                	jmp    801e88 <devpipe_read+0x42>

00801eb9 <pipe>:
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec4:	50                   	push   %eax
  801ec5:	e8 26 f6 ff ff       	call   8014f0 <fd_alloc>
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 5b                	js     801f2e <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed3:	83 ec 04             	sub    $0x4,%esp
  801ed6:	68 07 04 00 00       	push   $0x407
  801edb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 0c f3 ff ff       	call   8011f1 <sys_page_alloc>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 40                	js     801f2e <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef4:	50                   	push   %eax
  801ef5:	e8 f6 f5 ff ff       	call   8014f0 <fd_alloc>
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 1b                	js     801f1e <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f03:	83 ec 04             	sub    $0x4,%esp
  801f06:	68 07 04 00 00       	push   $0x407
  801f0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 dc f2 ff ff       	call   8011f1 <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	79 19                	jns    801f37 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801f1e:	83 ec 08             	sub    $0x8,%esp
  801f21:	ff 75 f4             	pushl  -0xc(%ebp)
  801f24:	6a 00                	push   $0x0
  801f26:	e8 4b f3 ff ff       	call   801276 <sys_page_unmap>
  801f2b:	83 c4 10             	add    $0x10,%esp
}
  801f2e:	89 d8                	mov    %ebx,%eax
  801f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
	va = fd2data(fd0);
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3d:	e8 97 f5 ff ff       	call   8014d9 <fd2data>
  801f42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f44:	83 c4 0c             	add    $0xc,%esp
  801f47:	68 07 04 00 00       	push   $0x407
  801f4c:	50                   	push   %eax
  801f4d:	6a 00                	push   $0x0
  801f4f:	e8 9d f2 ff ff       	call   8011f1 <sys_page_alloc>
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	0f 88 8c 00 00 00    	js     801fed <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f61:	83 ec 0c             	sub    $0xc,%esp
  801f64:	ff 75 f0             	pushl  -0x10(%ebp)
  801f67:	e8 6d f5 ff ff       	call   8014d9 <fd2data>
  801f6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f73:	50                   	push   %eax
  801f74:	6a 00                	push   $0x0
  801f76:	56                   	push   %esi
  801f77:	6a 00                	push   $0x0
  801f79:	e8 b6 f2 ff ff       	call   801234 <sys_page_map>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	83 c4 20             	add    $0x20,%esp
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 58                	js     801fdf <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fa5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801faa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fb1:	83 ec 0c             	sub    $0xc,%esp
  801fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb7:	e8 0d f5 ff ff       	call   8014c9 <fd2num>
  801fbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fbf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc1:	83 c4 04             	add    $0x4,%esp
  801fc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc7:	e8 fd f4 ff ff       	call   8014c9 <fd2num>
  801fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fcf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fda:	e9 4f ff ff ff       	jmp    801f2e <pipe+0x75>
	sys_page_unmap(0, va);
  801fdf:	83 ec 08             	sub    $0x8,%esp
  801fe2:	56                   	push   %esi
  801fe3:	6a 00                	push   $0x0
  801fe5:	e8 8c f2 ff ff       	call   801276 <sys_page_unmap>
  801fea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fed:	83 ec 08             	sub    $0x8,%esp
  801ff0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 7c f2 ff ff       	call   801276 <sys_page_unmap>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	e9 1c ff ff ff       	jmp    801f1e <pipe+0x65>

00802002 <pipeisclosed>:
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	ff 75 08             	pushl  0x8(%ebp)
  80200f:	e8 2b f5 ff ff       	call   80153f <fd_lookup>
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	78 18                	js     802033 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	ff 75 f4             	pushl  -0xc(%ebp)
  802021:	e8 b3 f4 ff ff       	call   8014d9 <fd2data>
	return _pipeisclosed(fd, p);
  802026:	89 c2                	mov    %eax,%edx
  802028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202b:	e8 30 fd ff ff       	call   801d60 <_pipeisclosed>
  802030:	83 c4 10             	add    $0x10,%esp
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802045:	68 e7 2c 80 00       	push   $0x802ce7
  80204a:	ff 75 0c             	pushl  0xc(%ebp)
  80204d:	e8 a6 ed ff ff       	call   800df8 <strcpy>
	return 0;
}
  802052:	b8 00 00 00 00       	mov    $0x0,%eax
  802057:	c9                   	leave  
  802058:	c3                   	ret    

00802059 <devcons_write>:
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	57                   	push   %edi
  80205d:	56                   	push   %esi
  80205e:	53                   	push   %ebx
  80205f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802065:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80206a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802070:	eb 2f                	jmp    8020a1 <devcons_write+0x48>
		m = n - tot;
  802072:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802075:	29 f3                	sub    %esi,%ebx
  802077:	83 fb 7f             	cmp    $0x7f,%ebx
  80207a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80207f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802082:	83 ec 04             	sub    $0x4,%esp
  802085:	53                   	push   %ebx
  802086:	89 f0                	mov    %esi,%eax
  802088:	03 45 0c             	add    0xc(%ebp),%eax
  80208b:	50                   	push   %eax
  80208c:	57                   	push   %edi
  80208d:	e8 f4 ee ff ff       	call   800f86 <memmove>
		sys_cputs(buf, m);
  802092:	83 c4 08             	add    $0x8,%esp
  802095:	53                   	push   %ebx
  802096:	57                   	push   %edi
  802097:	e8 99 f0 ff ff       	call   801135 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80209c:	01 de                	add    %ebx,%esi
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020a4:	72 cc                	jb     802072 <devcons_write+0x19>
}
  8020a6:	89 f0                	mov    %esi,%eax
  8020a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5f                   	pop    %edi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <devcons_read>:
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	83 ec 08             	sub    $0x8,%esp
  8020b6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020bf:	75 07                	jne    8020c8 <devcons_read+0x18>
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    
		sys_yield();
  8020c3:	e8 0a f1 ff ff       	call   8011d2 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020c8:	e8 86 f0 ff ff       	call   801153 <sys_cgetc>
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	74 f2                	je     8020c3 <devcons_read+0x13>
	if (c < 0)
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	78 ec                	js     8020c1 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8020d5:	83 f8 04             	cmp    $0x4,%eax
  8020d8:	74 0c                	je     8020e6 <devcons_read+0x36>
	*(char*)vbuf = c;
  8020da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020dd:	88 02                	mov    %al,(%edx)
	return 1;
  8020df:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e4:	eb db                	jmp    8020c1 <devcons_read+0x11>
		return 0;
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020eb:	eb d4                	jmp    8020c1 <devcons_read+0x11>

008020ed <cputchar>:
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f6:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020f9:	6a 01                	push   $0x1
  8020fb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020fe:	50                   	push   %eax
  8020ff:	e8 31 f0 ff ff       	call   801135 <sys_cputs>
}
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	c9                   	leave  
  802108:	c3                   	ret    

00802109 <getchar>:
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80210f:	6a 01                	push   $0x1
  802111:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802114:	50                   	push   %eax
  802115:	6a 00                	push   $0x0
  802117:	e8 94 f6 ff ff       	call   8017b0 <read>
	if (r < 0)
  80211c:	83 c4 10             	add    $0x10,%esp
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 08                	js     80212b <getchar+0x22>
	if (r < 1)
  802123:	85 c0                	test   %eax,%eax
  802125:	7e 06                	jle    80212d <getchar+0x24>
	return c;
  802127:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    
		return -E_EOF;
  80212d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802132:	eb f7                	jmp    80212b <getchar+0x22>

00802134 <iscons>:
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80213a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213d:	50                   	push   %eax
  80213e:	ff 75 08             	pushl  0x8(%ebp)
  802141:	e8 f9 f3 ff ff       	call   80153f <fd_lookup>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	78 11                	js     80215e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80214d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802150:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802156:	39 10                	cmp    %edx,(%eax)
  802158:	0f 94 c0             	sete   %al
  80215b:	0f b6 c0             	movzbl %al,%eax
}
  80215e:	c9                   	leave  
  80215f:	c3                   	ret    

00802160 <opencons>:
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802166:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802169:	50                   	push   %eax
  80216a:	e8 81 f3 ff ff       	call   8014f0 <fd_alloc>
  80216f:	83 c4 10             	add    $0x10,%esp
  802172:	85 c0                	test   %eax,%eax
  802174:	78 3a                	js     8021b0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802176:	83 ec 04             	sub    $0x4,%esp
  802179:	68 07 04 00 00       	push   $0x407
  80217e:	ff 75 f4             	pushl  -0xc(%ebp)
  802181:	6a 00                	push   $0x0
  802183:	e8 69 f0 ff ff       	call   8011f1 <sys_page_alloc>
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	85 c0                	test   %eax,%eax
  80218d:	78 21                	js     8021b0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802198:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021a4:	83 ec 0c             	sub    $0xc,%esp
  8021a7:	50                   	push   %eax
  8021a8:	e8 1c f3 ff ff       	call   8014c9 <fd2num>
  8021ad:	83 c4 10             	add    $0x10,%esp
}
  8021b0:	c9                   	leave  
  8021b1:	c3                   	ret    

008021b2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b8:	89 d0                	mov    %edx,%eax
  8021ba:	c1 e8 16             	shr    $0x16,%eax
  8021bd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021c9:	f6 c1 01             	test   $0x1,%cl
  8021cc:	74 1d                	je     8021eb <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021ce:	c1 ea 0c             	shr    $0xc,%edx
  8021d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d8:	f6 c2 01             	test   $0x1,%dl
  8021db:	74 0e                	je     8021eb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021dd:	c1 ea 0c             	shr    $0xc,%edx
  8021e0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e7:	ef 
  8021e8:	0f b7 c0             	movzwl %ax,%eax
}
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802207:	85 d2                	test   %edx,%edx
  802209:	75 35                	jne    802240 <__udivdi3+0x50>
  80220b:	39 f3                	cmp    %esi,%ebx
  80220d:	0f 87 bd 00 00 00    	ja     8022d0 <__udivdi3+0xe0>
  802213:	85 db                	test   %ebx,%ebx
  802215:	89 d9                	mov    %ebx,%ecx
  802217:	75 0b                	jne    802224 <__udivdi3+0x34>
  802219:	b8 01 00 00 00       	mov    $0x1,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f3                	div    %ebx
  802222:	89 c1                	mov    %eax,%ecx
  802224:	31 d2                	xor    %edx,%edx
  802226:	89 f0                	mov    %esi,%eax
  802228:	f7 f1                	div    %ecx
  80222a:	89 c6                	mov    %eax,%esi
  80222c:	89 e8                	mov    %ebp,%eax
  80222e:	89 f7                	mov    %esi,%edi
  802230:	f7 f1                	div    %ecx
  802232:	89 fa                	mov    %edi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 f2                	cmp    %esi,%edx
  802242:	77 7c                	ja     8022c0 <__udivdi3+0xd0>
  802244:	0f bd fa             	bsr    %edx,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0xf8>
  802250:	89 f9                	mov    %edi,%ecx
  802252:	b8 20 00 00 00       	mov    $0x20,%eax
  802257:	29 f8                	sub    %edi,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 da                	mov    %ebx,%edx
  802263:	d3 ea                	shr    %cl,%edx
  802265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802269:	09 d1                	or     %edx,%ecx
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e3                	shl    %cl,%ebx
  802275:	89 c1                	mov    %eax,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	89 f9                	mov    %edi,%ecx
  80227b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80227f:	d3 e6                	shl    %cl,%esi
  802281:	89 eb                	mov    %ebp,%ebx
  802283:	89 c1                	mov    %eax,%ecx
  802285:	d3 eb                	shr    %cl,%ebx
  802287:	09 de                	or     %ebx,%esi
  802289:	89 f0                	mov    %esi,%eax
  80228b:	f7 74 24 08          	divl   0x8(%esp)
  80228f:	89 d6                	mov    %edx,%esi
  802291:	89 c3                	mov    %eax,%ebx
  802293:	f7 64 24 0c          	mull   0xc(%esp)
  802297:	39 d6                	cmp    %edx,%esi
  802299:	72 0c                	jb     8022a7 <__udivdi3+0xb7>
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e5                	shl    %cl,%ebp
  80229f:	39 c5                	cmp    %eax,%ebp
  8022a1:	73 5d                	jae    802300 <__udivdi3+0x110>
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	75 59                	jne    802300 <__udivdi3+0x110>
  8022a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022aa:	31 ff                	xor    %edi,%edi
  8022ac:	89 fa                	mov    %edi,%edx
  8022ae:	83 c4 1c             	add    $0x1c,%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5f                   	pop    %edi
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    
  8022b6:	8d 76 00             	lea    0x0(%esi),%esi
  8022b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022c0:	31 ff                	xor    %edi,%edi
  8022c2:	31 c0                	xor    %eax,%eax
  8022c4:	89 fa                	mov    %edi,%edx
  8022c6:	83 c4 1c             	add    $0x1c,%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5f                   	pop    %edi
  8022cc:	5d                   	pop    %ebp
  8022cd:	c3                   	ret    
  8022ce:	66 90                	xchg   %ax,%ax
  8022d0:	31 ff                	xor    %edi,%edi
  8022d2:	89 e8                	mov    %ebp,%eax
  8022d4:	89 f2                	mov    %esi,%edx
  8022d6:	f7 f3                	div    %ebx
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	72 06                	jb     8022f2 <__udivdi3+0x102>
  8022ec:	31 c0                	xor    %eax,%eax
  8022ee:	39 eb                	cmp    %ebp,%ebx
  8022f0:	77 d2                	ja     8022c4 <__udivdi3+0xd4>
  8022f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f7:	eb cb                	jmp    8022c4 <__udivdi3+0xd4>
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	31 ff                	xor    %edi,%edi
  802304:	eb be                	jmp    8022c4 <__udivdi3+0xd4>
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80231b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80231f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 ed                	test   %ebp,%ebp
  802329:	89 f0                	mov    %esi,%eax
  80232b:	89 da                	mov    %ebx,%edx
  80232d:	75 19                	jne    802348 <__umoddi3+0x38>
  80232f:	39 df                	cmp    %ebx,%edi
  802331:	0f 86 b1 00 00 00    	jbe    8023e8 <__umoddi3+0xd8>
  802337:	f7 f7                	div    %edi
  802339:	89 d0                	mov    %edx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	83 c4 1c             	add    $0x1c,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	39 dd                	cmp    %ebx,%ebp
  80234a:	77 f1                	ja     80233d <__umoddi3+0x2d>
  80234c:	0f bd cd             	bsr    %ebp,%ecx
  80234f:	83 f1 1f             	xor    $0x1f,%ecx
  802352:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802356:	0f 84 b4 00 00 00    	je     802410 <__umoddi3+0x100>
  80235c:	b8 20 00 00 00       	mov    $0x20,%eax
  802361:	89 c2                	mov    %eax,%edx
  802363:	8b 44 24 04          	mov    0x4(%esp),%eax
  802367:	29 c2                	sub    %eax,%edx
  802369:	89 c1                	mov    %eax,%ecx
  80236b:	89 f8                	mov    %edi,%eax
  80236d:	d3 e5                	shl    %cl,%ebp
  80236f:	89 d1                	mov    %edx,%ecx
  802371:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802375:	d3 e8                	shr    %cl,%eax
  802377:	09 c5                	or     %eax,%ebp
  802379:	8b 44 24 04          	mov    0x4(%esp),%eax
  80237d:	89 c1                	mov    %eax,%ecx
  80237f:	d3 e7                	shl    %cl,%edi
  802381:	89 d1                	mov    %edx,%ecx
  802383:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802387:	89 df                	mov    %ebx,%edi
  802389:	d3 ef                	shr    %cl,%edi
  80238b:	89 c1                	mov    %eax,%ecx
  80238d:	89 f0                	mov    %esi,%eax
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 d1                	mov    %edx,%ecx
  802393:	89 fa                	mov    %edi,%edx
  802395:	d3 e8                	shr    %cl,%eax
  802397:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80239c:	09 d8                	or     %ebx,%eax
  80239e:	f7 f5                	div    %ebp
  8023a0:	d3 e6                	shl    %cl,%esi
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	f7 64 24 08          	mull   0x8(%esp)
  8023a8:	39 d1                	cmp    %edx,%ecx
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d7                	mov    %edx,%edi
  8023ae:	72 06                	jb     8023b6 <__umoddi3+0xa6>
  8023b0:	75 0e                	jne    8023c0 <__umoddi3+0xb0>
  8023b2:	39 c6                	cmp    %eax,%esi
  8023b4:	73 0a                	jae    8023c0 <__umoddi3+0xb0>
  8023b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8023ba:	19 ea                	sbb    %ebp,%edx
  8023bc:	89 d7                	mov    %edx,%edi
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	89 ca                	mov    %ecx,%edx
  8023c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8023c7:	29 de                	sub    %ebx,%esi
  8023c9:	19 fa                	sbb    %edi,%edx
  8023cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	d3 e0                	shl    %cl,%eax
  8023d3:	89 d9                	mov    %ebx,%ecx
  8023d5:	d3 ee                	shr    %cl,%esi
  8023d7:	d3 ea                	shr    %cl,%edx
  8023d9:	09 f0                	or     %esi,%eax
  8023db:	83 c4 1c             	add    $0x1c,%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	85 ff                	test   %edi,%edi
  8023ea:	89 f9                	mov    %edi,%ecx
  8023ec:	75 0b                	jne    8023f9 <__umoddi3+0xe9>
  8023ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f7                	div    %edi
  8023f7:	89 c1                	mov    %eax,%ecx
  8023f9:	89 d8                	mov    %ebx,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f1                	div    %ecx
  8023ff:	89 f0                	mov    %esi,%eax
  802401:	f7 f1                	div    %ecx
  802403:	e9 31 ff ff ff       	jmp    802339 <__umoddi3+0x29>
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	39 dd                	cmp    %ebx,%ebp
  802412:	72 08                	jb     80241c <__umoddi3+0x10c>
  802414:	39 f7                	cmp    %esi,%edi
  802416:	0f 87 21 ff ff ff    	ja     80233d <__umoddi3+0x2d>
  80241c:	89 da                	mov    %ebx,%edx
  80241e:	89 f0                	mov    %esi,%eax
  802420:	29 f8                	sub    %edi,%eax
  802422:	19 ea                	sbb    %ebp,%edx
  802424:	e9 14 ff ff ff       	jmp    80233d <__umoddi3+0x2d>
