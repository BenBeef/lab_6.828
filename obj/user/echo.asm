
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7f 07                	jg     800055 <umain+0x22>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80004e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800053:	eb 4c                	jmp    8000a1 <umain+0x6e>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	68 80 1e 80 00       	push   $0x801e80
  80005d:	ff 76 04             	pushl  0x4(%esi)
  800060:	e8 bc 01 00 00       	call   800221 <strcmp>
  800065:	83 c4 10             	add    $0x10,%esp
	nflag = 0;
  800068:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 db                	jne    80004e <umain+0x1b>
		argc--;
  800073:	83 ef 01             	sub    $0x1,%edi
		argv++;
  800076:	83 c6 04             	add    $0x4,%esi
		nflag = 1;
  800079:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800080:	eb cc                	jmp    80004e <umain+0x1b>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
  800082:	83 ec 0c             	sub    $0xc,%esp
  800085:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800088:	e8 b7 00 00 00       	call   800144 <strlen>
  80008d:	83 c4 0c             	add    $0xc,%esp
  800090:	50                   	push   %eax
  800091:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800094:	6a 01                	push   $0x1
  800096:	e8 7f 0a 00 00       	call   800b1a <write>
	for (i = 1; i < argc; i++) {
  80009b:	83 c3 01             	add    $0x1,%ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	39 df                	cmp    %ebx,%edi
  8000a3:	7e 1b                	jle    8000c0 <umain+0x8d>
		if (i > 1)
  8000a5:	83 fb 01             	cmp    $0x1,%ebx
  8000a8:	7e d8                	jle    800082 <umain+0x4f>
			write(1, " ", 1);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	6a 01                	push   $0x1
  8000af:	68 83 1e 80 00       	push   $0x801e83
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 5f 0a 00 00       	call   800b1a <write>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	eb c2                	jmp    800082 <umain+0x4f>
	}
	if (!nflag)
  8000c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c4:	74 08                	je     8000ce <umain+0x9b>
		write(1, "\n", 1);
}
  8000c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
		write(1, "\n", 1);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 01                	push   $0x1
  8000d3:	68 d3 1f 80 00       	push   $0x801fd3
  8000d8:	6a 01                	push   $0x1
  8000da:	e8 3b 0a 00 00       	call   800b1a <write>
  8000df:	83 c4 10             	add    $0x10,%esp
}
  8000e2:	eb e2                	jmp    8000c6 <umain+0x93>

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000ef:	e8 42 04 00 00       	call   800536 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x2d>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 18 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011b:	e8 0a 00 00 00       	call   80012a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800130:	e8 06 08 00 00       	call   80093b <close_all>
	sys_env_destroy(0);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	6a 00                	push   $0x0
  80013a:	e8 b6 03 00 00       	call   8004f5 <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80014a:	b8 00 00 00 00       	mov    $0x0,%eax
  80014f:	eb 03                	jmp    800154 <strlen+0x10>
		n++;
  800151:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800154:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800158:	75 f7                	jne    800151 <strlen+0xd>
	return n;
}
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800165:	b8 00 00 00 00       	mov    $0x0,%eax
  80016a:	eb 03                	jmp    80016f <strnlen+0x13>
		n++;
  80016c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80016f:	39 d0                	cmp    %edx,%eax
  800171:	74 06                	je     800179 <strnlen+0x1d>
  800173:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800177:	75 f3                	jne    80016c <strnlen+0x10>
	return n;
}
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	53                   	push   %ebx
  80017f:	8b 45 08             	mov    0x8(%ebp),%eax
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800185:	89 c2                	mov    %eax,%edx
  800187:	83 c1 01             	add    $0x1,%ecx
  80018a:	83 c2 01             	add    $0x1,%edx
  80018d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800191:	88 5a ff             	mov    %bl,-0x1(%edx)
  800194:	84 db                	test   %bl,%bl
  800196:	75 ef                	jne    800187 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001a2:	53                   	push   %ebx
  8001a3:	e8 9c ff ff ff       	call   800144 <strlen>
  8001a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001ab:	ff 75 0c             	pushl  0xc(%ebp)
  8001ae:	01 d8                	add    %ebx,%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 c5 ff ff ff       	call   80017b <strcpy>
	return dst;
}
  8001b6:	89 d8                	mov    %ebx,%eax
  8001b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	89 f3                	mov    %esi,%ebx
  8001ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	eb 0f                	jmp    8001e0 <strncpy+0x23>
		*dst++ = *src;
  8001d1:	83 c2 01             	add    $0x1,%edx
  8001d4:	0f b6 01             	movzbl (%ecx),%eax
  8001d7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001da:	80 39 01             	cmpb   $0x1,(%ecx)
  8001dd:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8001e0:	39 da                	cmp    %ebx,%edx
  8001e2:	75 ed                	jne    8001d1 <strncpy+0x14>
	}
	return ret;
}
  8001e4:	89 f0                	mov    %esi,%eax
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001f8:	89 f0                	mov    %esi,%eax
  8001fa:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001fe:	85 c9                	test   %ecx,%ecx
  800200:	75 0b                	jne    80020d <strlcpy+0x23>
  800202:	eb 17                	jmp    80021b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800204:	83 c2 01             	add    $0x1,%edx
  800207:	83 c0 01             	add    $0x1,%eax
  80020a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80020d:	39 d8                	cmp    %ebx,%eax
  80020f:	74 07                	je     800218 <strlcpy+0x2e>
  800211:	0f b6 0a             	movzbl (%edx),%ecx
  800214:	84 c9                	test   %cl,%cl
  800216:	75 ec                	jne    800204 <strlcpy+0x1a>
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 16                	je     800278 <strncmp+0x31>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
}
  800275:	5b                   	pop    %ebx
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    
		return 0;
  800278:	b8 00 00 00 00       	mov    $0x0,%eax
  80027d:	eb f6                	jmp    800275 <strncmp+0x2e>

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	0f b6 10             	movzbl (%eax),%edx
  80028c:	84 d2                	test   %dl,%dl
  80028e:	74 09                	je     800299 <strchr+0x1a>
		if (*s == c)
  800290:	38 ca                	cmp    %cl,%dl
  800292:	74 0a                	je     80029e <strchr+0x1f>
	for (; *s; s++)
  800294:	83 c0 01             	add    $0x1,%eax
  800297:	eb f0                	jmp    800289 <strchr+0xa>
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 13                	je     8002df <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 05                	jne    8002d9 <memset+0x1d>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	74 0d                	je     8002e6 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dc:	fc                   	cld    
  8002dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002df:	89 f8                	mov    %edi,%eax
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		c &= 0xFF;
  8002e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002ea:	89 d3                	mov    %edx,%ebx
  8002ec:	c1 e3 08             	shl    $0x8,%ebx
  8002ef:	89 d0                	mov    %edx,%eax
  8002f1:	c1 e0 18             	shl    $0x18,%eax
  8002f4:	89 d6                	mov    %edx,%esi
  8002f6:	c1 e6 10             	shl    $0x10,%esi
  8002f9:	09 f0                	or     %esi,%eax
  8002fb:	09 c2                	or     %eax,%edx
  8002fd:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8002ff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800302:	89 d0                	mov    %edx,%eax
  800304:	fc                   	cld    
  800305:	f3 ab                	rep stos %eax,%es:(%edi)
  800307:	eb d6                	jmp    8002df <memset+0x23>

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 c2                	cmp    %eax,%edx
  800320:	76 2e                	jbe    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	74 0c                	je     80033d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800331:	83 ef 01             	sub    $0x1,%edi
  800334:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800337:	fd                   	std    
  800338:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80033a:	fc                   	cld    
  80033b:	eb 21                	jmp    80035e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80033d:	f6 c1 03             	test   $0x3,%cl
  800340:	75 ef                	jne    800331 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800342:	83 ef 04             	sub    $0x4,%edi
  800345:	8d 72 fc             	lea    -0x4(%edx),%esi
  800348:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80034b:	fd                   	std    
  80034c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034e:	eb ea                	jmp    80033a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	74 09                	je     800362 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800359:	89 c7                	mov    %eax,%edi
  80035b:	fc                   	cld    
  80035c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800362:	f6 c1 03             	test   $0x3,%cl
  800365:	75 f2                	jne    800359 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800367:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80036a:	89 c7                	mov    %eax,%edi
  80036c:	fc                   	cld    
  80036d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036f:	eb ed                	jmp    80035e <memmove+0x55>

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	39 f0                	cmp    %esi,%eax
  800396:	74 1c                	je     8003b4 <memcmp+0x30>
		if (*s1 != *s2)
  800398:	0f b6 08             	movzbl (%eax),%ecx
  80039b:	0f b6 1a             	movzbl (%edx),%ebx
  80039e:	38 d9                	cmp    %bl,%cl
  8003a0:	75 08                	jne    8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8003a2:	83 c0 01             	add    $0x1,%eax
  8003a5:	83 c2 01             	add    $0x1,%edx
  8003a8:	eb ea                	jmp    800394 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8003aa:	0f b6 c1             	movzbl %cl,%eax
  8003ad:	0f b6 db             	movzbl %bl,%ebx
  8003b0:	29 d8                	sub    %ebx,%eax
  8003b2:	eb 05                	jmp    8003b9 <memcmp+0x35>
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003cb:	39 d0                	cmp    %edx,%eax
  8003cd:	73 09                	jae    8003d8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	38 08                	cmp    %cl,(%eax)
  8003d1:	74 05                	je     8003d8 <memfind+0x1b>
	for (; s < ends; s++)
  8003d3:	83 c0 01             	add    $0x1,%eax
  8003d6:	eb f3                	jmp    8003cb <memfind+0xe>
			break;
	return (void *) s;
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	56                   	push   %esi
  8003df:	53                   	push   %ebx
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e6:	eb 03                	jmp    8003eb <strtol+0x11>
		s++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8003eb:	0f b6 01             	movzbl (%ecx),%eax
  8003ee:	3c 20                	cmp    $0x20,%al
  8003f0:	74 f6                	je     8003e8 <strtol+0xe>
  8003f2:	3c 09                	cmp    $0x9,%al
  8003f4:	74 f2                	je     8003e8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8003f6:	3c 2b                	cmp    $0x2b,%al
  8003f8:	74 2e                	je     800428 <strtol+0x4e>
	int neg = 0;
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8003ff:	3c 2d                	cmp    $0x2d,%al
  800401:	74 2f                	je     800432 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800403:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800409:	75 05                	jne    800410 <strtol+0x36>
  80040b:	80 39 30             	cmpb   $0x30,(%ecx)
  80040e:	74 2c                	je     80043c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800410:	85 db                	test   %ebx,%ebx
  800412:	75 0a                	jne    80041e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800414:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800419:	80 39 30             	cmpb   $0x30,(%ecx)
  80041c:	74 28                	je     800446 <strtol+0x6c>
		base = 10;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800426:	eb 50                	jmp    800478 <strtol+0x9e>
		s++;
  800428:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80042b:	bf 00 00 00 00       	mov    $0x0,%edi
  800430:	eb d1                	jmp    800403 <strtol+0x29>
		s++, neg = 1;
  800432:	83 c1 01             	add    $0x1,%ecx
  800435:	bf 01 00 00 00       	mov    $0x1,%edi
  80043a:	eb c7                	jmp    800403 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80043c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800440:	74 0e                	je     800450 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800442:	85 db                	test   %ebx,%ebx
  800444:	75 d8                	jne    80041e <strtol+0x44>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
  80044e:	eb ce                	jmp    80041e <strtol+0x44>
		s += 2, base = 16;
  800450:	83 c1 02             	add    $0x2,%ecx
  800453:	bb 10 00 00 00       	mov    $0x10,%ebx
  800458:	eb c4                	jmp    80041e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  80045a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80045d:	89 f3                	mov    %esi,%ebx
  80045f:	80 fb 19             	cmp    $0x19,%bl
  800462:	77 29                	ja     80048d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800464:	0f be d2             	movsbl %dl,%edx
  800467:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80046a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80046d:	7d 30                	jge    80049f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80046f:	83 c1 01             	add    $0x1,%ecx
  800472:	0f af 45 10          	imul   0x10(%ebp),%eax
  800476:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800478:	0f b6 11             	movzbl (%ecx),%edx
  80047b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80047e:	89 f3                	mov    %esi,%ebx
  800480:	80 fb 09             	cmp    $0x9,%bl
  800483:	77 d5                	ja     80045a <strtol+0x80>
			dig = *s - '0';
  800485:	0f be d2             	movsbl %dl,%edx
  800488:	83 ea 30             	sub    $0x30,%edx
  80048b:	eb dd                	jmp    80046a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  80048d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800490:	89 f3                	mov    %esi,%ebx
  800492:	80 fb 19             	cmp    $0x19,%bl
  800495:	77 08                	ja     80049f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800497:	0f be d2             	movsbl %dl,%edx
  80049a:	83 ea 37             	sub    $0x37,%edx
  80049d:	eb cb                	jmp    80046a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80049f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a3:	74 05                	je     8004aa <strtol+0xd0>
		*endptr = (char *) s;
  8004a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8004aa:	89 c2                	mov    %eax,%edx
  8004ac:	f7 da                	neg    %edx
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	0f 45 c2             	cmovne %edx,%eax
}
  8004b3:	5b                   	pop    %ebx
  8004b4:	5e                   	pop    %esi
  8004b5:	5f                   	pop    %edi
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c9:	89 c3                	mov    %eax,%ebx
  8004cb:	89 c7                	mov    %eax,%edi
  8004cd:	89 c6                	mov    %eax,%esi
  8004cf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8004e6:	89 d1                	mov    %edx,%ecx
  8004e8:	89 d3                	mov    %edx,%ebx
  8004ea:	89 d7                	mov    %edx,%edi
  8004ec:	89 d6                	mov    %edx,%esi
  8004ee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5f                   	pop    %edi
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	57                   	push   %edi
  8004f9:	56                   	push   %esi
  8004fa:	53                   	push   %ebx
  8004fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	8b 55 08             	mov    0x8(%ebp),%edx
  800506:	b8 03 00 00 00       	mov    $0x3,%eax
  80050b:	89 cb                	mov    %ecx,%ebx
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	89 ce                	mov    %ecx,%esi
  800511:	cd 30                	int    $0x30
	if(check && ret > 0)
  800513:	85 c0                	test   %eax,%eax
  800515:	7f 08                	jg     80051f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800517:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051a:	5b                   	pop    %ebx
  80051b:	5e                   	pop    %esi
  80051c:	5f                   	pop    %edi
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	50                   	push   %eax
  800523:	6a 03                	push   $0x3
  800525:	68 8f 1e 80 00       	push   $0x801e8f
  80052a:	6a 23                	push   $0x23
  80052c:	68 ac 1e 80 00       	push   $0x801eac
  800531:	e8 18 0f 00 00       	call   80144e <_panic>

00800536 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80053c:	ba 00 00 00 00       	mov    $0x0,%edx
  800541:	b8 02 00 00 00       	mov    $0x2,%eax
  800546:	89 d1                	mov    %edx,%ecx
  800548:	89 d3                	mov    %edx,%ebx
  80054a:	89 d7                	mov    %edx,%edi
  80054c:	89 d6                	mov    %edx,%esi
  80054e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800550:	5b                   	pop    %ebx
  800551:	5e                   	pop    %esi
  800552:	5f                   	pop    %edi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    

00800555 <sys_yield>:

void
sys_yield(void)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80055b:	ba 00 00 00 00       	mov    $0x0,%edx
  800560:	b8 0b 00 00 00       	mov    $0xb,%eax
  800565:	89 d1                	mov    %edx,%ecx
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 d7                	mov    %edx,%edi
  80056b:	89 d6                	mov    %edx,%esi
  80056d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80056f:	5b                   	pop    %ebx
  800570:	5e                   	pop    %esi
  800571:	5f                   	pop    %edi
  800572:	5d                   	pop    %ebp
  800573:	c3                   	ret    

00800574 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80057d:	be 00 00 00 00       	mov    $0x0,%esi
  800582:	8b 55 08             	mov    0x8(%ebp),%edx
  800585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800590:	89 f7                	mov    %esi,%edi
  800592:	cd 30                	int    $0x30
	if(check && ret > 0)
  800594:	85 c0                	test   %eax,%eax
  800596:	7f 08                	jg     8005a0 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800598:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80059b:	5b                   	pop    %ebx
  80059c:	5e                   	pop    %esi
  80059d:	5f                   	pop    %edi
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	50                   	push   %eax
  8005a4:	6a 04                	push   $0x4
  8005a6:	68 8f 1e 80 00       	push   $0x801e8f
  8005ab:	6a 23                	push   $0x23
  8005ad:	68 ac 1e 80 00       	push   $0x801eac
  8005b2:	e8 97 0e 00 00       	call   80144e <_panic>

008005b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005b7:	55                   	push   %ebp
  8005b8:	89 e5                	mov    %esp,%ebp
  8005ba:	57                   	push   %edi
  8005bb:	56                   	push   %esi
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8005c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8005d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	7f 08                	jg     8005e2 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5f                   	pop    %edi
  8005e0:	5d                   	pop    %ebp
  8005e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	50                   	push   %eax
  8005e6:	6a 05                	push   $0x5
  8005e8:	68 8f 1e 80 00       	push   $0x801e8f
  8005ed:	6a 23                	push   $0x23
  8005ef:	68 ac 1e 80 00       	push   $0x801eac
  8005f4:	e8 55 0e 00 00       	call   80144e <_panic>

008005f9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	57                   	push   %edi
  8005fd:	56                   	push   %esi
  8005fe:	53                   	push   %ebx
  8005ff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
  800607:	8b 55 08             	mov    0x8(%ebp),%edx
  80060a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	89 df                	mov    %ebx,%edi
  800614:	89 de                	mov    %ebx,%esi
  800616:	cd 30                	int    $0x30
	if(check && ret > 0)
  800618:	85 c0                	test   %eax,%eax
  80061a:	7f 08                	jg     800624 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80061c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061f:	5b                   	pop    %ebx
  800620:	5e                   	pop    %esi
  800621:	5f                   	pop    %edi
  800622:	5d                   	pop    %ebp
  800623:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	50                   	push   %eax
  800628:	6a 06                	push   $0x6
  80062a:	68 8f 1e 80 00       	push   $0x801e8f
  80062f:	6a 23                	push   $0x23
  800631:	68 ac 1e 80 00       	push   $0x801eac
  800636:	e8 13 0e 00 00       	call   80144e <_panic>

0080063b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	57                   	push   %edi
  80063f:	56                   	push   %esi
  800640:	53                   	push   %ebx
  800641:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800644:	bb 00 00 00 00       	mov    $0x0,%ebx
  800649:	8b 55 08             	mov    0x8(%ebp),%edx
  80064c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	89 df                	mov    %ebx,%edi
  800656:	89 de                	mov    %ebx,%esi
  800658:	cd 30                	int    $0x30
	if(check && ret > 0)
  80065a:	85 c0                	test   %eax,%eax
  80065c:	7f 08                	jg     800666 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800666:	83 ec 0c             	sub    $0xc,%esp
  800669:	50                   	push   %eax
  80066a:	6a 08                	push   $0x8
  80066c:	68 8f 1e 80 00       	push   $0x801e8f
  800671:	6a 23                	push   $0x23
  800673:	68 ac 1e 80 00       	push   $0x801eac
  800678:	e8 d1 0d 00 00       	call   80144e <_panic>

0080067d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	57                   	push   %edi
  800681:	56                   	push   %esi
  800682:	53                   	push   %ebx
  800683:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068b:	8b 55 08             	mov    0x8(%ebp),%edx
  80068e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	89 df                	mov    %ebx,%edi
  800698:	89 de                	mov    %ebx,%esi
  80069a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80069c:	85 c0                	test   %eax,%eax
  80069e:	7f 08                	jg     8006a8 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a3:	5b                   	pop    %ebx
  8006a4:	5e                   	pop    %esi
  8006a5:	5f                   	pop    %edi
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	50                   	push   %eax
  8006ac:	6a 09                	push   $0x9
  8006ae:	68 8f 1e 80 00       	push   $0x801e8f
  8006b3:	6a 23                	push   $0x23
  8006b5:	68 ac 1e 80 00       	push   $0x801eac
  8006ba:	e8 8f 0d 00 00       	call   80144e <_panic>

008006bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	57                   	push   %edi
  8006c3:	56                   	push   %esi
  8006c4:	53                   	push   %ebx
  8006c5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	89 df                	mov    %ebx,%edi
  8006da:	89 de                	mov    %ebx,%esi
  8006dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	7f 08                	jg     8006ea <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ea:	83 ec 0c             	sub    $0xc,%esp
  8006ed:	50                   	push   %eax
  8006ee:	6a 0a                	push   $0xa
  8006f0:	68 8f 1e 80 00       	push   $0x801e8f
  8006f5:	6a 23                	push   $0x23
  8006f7:	68 ac 1e 80 00       	push   $0x801eac
  8006fc:	e8 4d 0d 00 00       	call   80144e <_panic>

00800701 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	57                   	push   %edi
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
	asm volatile("int %1\n"
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800712:	be 00 00 00 00       	mov    $0x0,%esi
  800717:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80071a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80071d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	57                   	push   %edi
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
  800735:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073a:	89 cb                	mov    %ecx,%ebx
  80073c:	89 cf                	mov    %ecx,%edi
  80073e:	89 ce                	mov    %ecx,%esi
  800740:	cd 30                	int    $0x30
	if(check && ret > 0)
  800742:	85 c0                	test   %eax,%eax
  800744:	7f 08                	jg     80074e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800746:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	50                   	push   %eax
  800752:	6a 0d                	push   $0xd
  800754:	68 8f 1e 80 00       	push   $0x801e8f
  800759:	6a 23                	push   $0x23
  80075b:	68 ac 1e 80 00       	push   $0x801eac
  800760:	e8 e9 0c 00 00       	call   80144e <_panic>

00800765 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	05 00 00 00 30       	add    $0x30000000,%eax
  800770:	c1 e8 0c             	shr    $0xc,%eax
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800780:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800785:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800797:	89 c2                	mov    %eax,%edx
  800799:	c1 ea 16             	shr    $0x16,%edx
  80079c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a3:	f6 c2 01             	test   $0x1,%dl
  8007a6:	74 2a                	je     8007d2 <fd_alloc+0x46>
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	c1 ea 0c             	shr    $0xc,%edx
  8007ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b4:	f6 c2 01             	test   $0x1,%dl
  8007b7:	74 19                	je     8007d2 <fd_alloc+0x46>
  8007b9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8007be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007c3:	75 d2                	jne    800797 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007c5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007cb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8007d0:	eb 07                	jmp    8007d9 <fd_alloc+0x4d>
			*fd_store = fd;
  8007d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e1:	83 f8 1f             	cmp    $0x1f,%eax
  8007e4:	77 36                	ja     80081c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007e6:	c1 e0 0c             	shl    $0xc,%eax
  8007e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	c1 ea 16             	shr    $0x16,%edx
  8007f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007fa:	f6 c2 01             	test   $0x1,%dl
  8007fd:	74 24                	je     800823 <fd_lookup+0x48>
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	c1 ea 0c             	shr    $0xc,%edx
  800804:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80080b:	f6 c2 01             	test   $0x1,%dl
  80080e:	74 1a                	je     80082a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 02                	mov    %eax,(%edx)
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb f7                	jmp    80081a <fd_lookup+0x3f>
		return -E_INVAL;
  800823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800828:	eb f0                	jmp    80081a <fd_lookup+0x3f>
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082f:	eb e9                	jmp    80081a <fd_lookup+0x3f>

00800831 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	ba 38 1f 80 00       	mov    $0x801f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80083f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800844:	39 08                	cmp    %ecx,(%eax)
  800846:	74 33                	je     80087b <dev_lookup+0x4a>
  800848:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80084b:	8b 02                	mov    (%edx),%eax
  80084d:	85 c0                	test   %eax,%eax
  80084f:	75 f3                	jne    800844 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800851:	a1 04 40 80 00       	mov    0x804004,%eax
  800856:	8b 40 48             	mov    0x48(%eax),%eax
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	51                   	push   %ecx
  80085d:	50                   	push   %eax
  80085e:	68 bc 1e 80 00       	push   $0x801ebc
  800863:	e8 c1 0c 00 00       	call   801529 <cprintf>
	*dev = 0;
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    
			*dev = devtab[i];
  80087b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f2                	jmp    800879 <dev_lookup+0x48>

00800887 <fd_close>:
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	57                   	push   %edi
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	83 ec 1c             	sub    $0x1c,%esp
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800896:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800899:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80089a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008a3:	50                   	push   %eax
  8008a4:	e8 32 ff ff ff       	call   8007db <fd_lookup>
  8008a9:	89 c3                	mov    %eax,%ebx
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 05                	js     8008b7 <fd_close+0x30>
	    || fd != fd2)
  8008b2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8008b5:	74 16                	je     8008cd <fd_close+0x46>
		return (must_exist ? r : 0);
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	0f 44 d8             	cmove  %eax,%ebx
}
  8008c3:	89 d8                	mov    %ebx,%eax
  8008c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5f                   	pop    %edi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8008d3:	50                   	push   %eax
  8008d4:	ff 36                	pushl  (%esi)
  8008d6:	e8 56 ff ff ff       	call   800831 <dev_lookup>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 15                	js     8008f9 <fd_close+0x72>
		if (dev->dev_close)
  8008e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e7:	8b 40 10             	mov    0x10(%eax),%eax
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	74 1b                	je     800909 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8008ee:	83 ec 0c             	sub    $0xc,%esp
  8008f1:	56                   	push   %esi
  8008f2:	ff d0                	call   *%eax
  8008f4:	89 c3                	mov    %eax,%ebx
  8008f6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	56                   	push   %esi
  8008fd:	6a 00                	push   $0x0
  8008ff:	e8 f5 fc ff ff       	call   8005f9 <sys_page_unmap>
	return r;
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb ba                	jmp    8008c3 <fd_close+0x3c>
			r = 0;
  800909:	bb 00 00 00 00       	mov    $0x0,%ebx
  80090e:	eb e9                	jmp    8008f9 <fd_close+0x72>

00800910 <close>:

int
close(int fdnum)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800916:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800919:	50                   	push   %eax
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 b9 fe ff ff       	call   8007db <fd_lookup>
  800922:	83 c4 08             	add    $0x8,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 10                	js     800939 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	6a 01                	push   $0x1
  80092e:	ff 75 f4             	pushl  -0xc(%ebp)
  800931:	e8 51 ff ff ff       	call   800887 <fd_close>
  800936:	83 c4 10             	add    $0x10,%esp
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <close_all>:

void
close_all(void)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800942:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	53                   	push   %ebx
  80094b:	e8 c0 ff ff ff       	call   800910 <close>
	for (i = 0; i < MAXFD; i++)
  800950:	83 c3 01             	add    $0x1,%ebx
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	83 fb 20             	cmp    $0x20,%ebx
  800959:	75 ec                	jne    800947 <close_all+0xc>
}
  80095b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800969:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	ff 75 08             	pushl  0x8(%ebp)
  800970:	e8 66 fe ff ff       	call   8007db <fd_lookup>
  800975:	89 c3                	mov    %eax,%ebx
  800977:	83 c4 08             	add    $0x8,%esp
  80097a:	85 c0                	test   %eax,%eax
  80097c:	0f 88 81 00 00 00    	js     800a03 <dup+0xa3>
		return r;
	close(newfdnum);
  800982:	83 ec 0c             	sub    $0xc,%esp
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	e8 83 ff ff ff       	call   800910 <close>

	newfd = INDEX2FD(newfdnum);
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	c1 e6 0c             	shl    $0xc,%esi
  800993:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800999:	83 c4 04             	add    $0x4,%esp
  80099c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80099f:	e8 d1 fd ff ff       	call   800775 <fd2data>
  8009a4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009a6:	89 34 24             	mov    %esi,(%esp)
  8009a9:	e8 c7 fd ff ff       	call   800775 <fd2data>
  8009ae:	83 c4 10             	add    $0x10,%esp
  8009b1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009b3:	89 d8                	mov    %ebx,%eax
  8009b5:	c1 e8 16             	shr    $0x16,%eax
  8009b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009bf:	a8 01                	test   $0x1,%al
  8009c1:	74 11                	je     8009d4 <dup+0x74>
  8009c3:	89 d8                	mov    %ebx,%eax
  8009c5:	c1 e8 0c             	shr    $0xc,%eax
  8009c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009cf:	f6 c2 01             	test   $0x1,%dl
  8009d2:	75 39                	jne    800a0d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e8 0c             	shr    $0xc,%eax
  8009dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009e3:	83 ec 0c             	sub    $0xc,%esp
  8009e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8009eb:	50                   	push   %eax
  8009ec:	56                   	push   %esi
  8009ed:	6a 00                	push   $0x0
  8009ef:	52                   	push   %edx
  8009f0:	6a 00                	push   $0x0
  8009f2:	e8 c0 fb ff ff       	call   8005b7 <sys_page_map>
  8009f7:	89 c3                	mov    %eax,%ebx
  8009f9:	83 c4 20             	add    $0x20,%esp
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 31                	js     800a31 <dup+0xd1>
		goto err;

	return newfdnum;
  800a00:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	25 07 0e 00 00       	and    $0xe07,%eax
  800a1c:	50                   	push   %eax
  800a1d:	57                   	push   %edi
  800a1e:	6a 00                	push   $0x0
  800a20:	53                   	push   %ebx
  800a21:	6a 00                	push   $0x0
  800a23:	e8 8f fb ff ff       	call   8005b7 <sys_page_map>
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	83 c4 20             	add    $0x20,%esp
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	79 a3                	jns    8009d4 <dup+0x74>
	sys_page_unmap(0, newfd);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	56                   	push   %esi
  800a35:	6a 00                	push   $0x0
  800a37:	e8 bd fb ff ff       	call   8005f9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a3c:	83 c4 08             	add    $0x8,%esp
  800a3f:	57                   	push   %edi
  800a40:	6a 00                	push   $0x0
  800a42:	e8 b2 fb ff ff       	call   8005f9 <sys_page_unmap>
	return r;
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	eb b7                	jmp    800a03 <dup+0xa3>

00800a4c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 14             	sub    $0x14,%esp
  800a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a59:	50                   	push   %eax
  800a5a:	53                   	push   %ebx
  800a5b:	e8 7b fd ff ff       	call   8007db <fd_lookup>
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 3f                	js     800aa6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6d:	50                   	push   %eax
  800a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a71:	ff 30                	pushl  (%eax)
  800a73:	e8 b9 fd ff ff       	call   800831 <dev_lookup>
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	78 27                	js     800aa6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a82:	8b 42 08             	mov    0x8(%edx),%eax
  800a85:	83 e0 03             	and    $0x3,%eax
  800a88:	83 f8 01             	cmp    $0x1,%eax
  800a8b:	74 1e                	je     800aab <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a90:	8b 40 08             	mov    0x8(%eax),%eax
  800a93:	85 c0                	test   %eax,%eax
  800a95:	74 35                	je     800acc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	ff 75 10             	pushl  0x10(%ebp)
  800a9d:	ff 75 0c             	pushl  0xc(%ebp)
  800aa0:	52                   	push   %edx
  800aa1:	ff d0                	call   *%eax
  800aa3:	83 c4 10             	add    $0x10,%esp
}
  800aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aab:	a1 04 40 80 00       	mov    0x804004,%eax
  800ab0:	8b 40 48             	mov    0x48(%eax),%eax
  800ab3:	83 ec 04             	sub    $0x4,%esp
  800ab6:	53                   	push   %ebx
  800ab7:	50                   	push   %eax
  800ab8:	68 fd 1e 80 00       	push   $0x801efd
  800abd:	e8 67 0a 00 00       	call   801529 <cprintf>
		return -E_INVAL;
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aca:	eb da                	jmp    800aa6 <read+0x5a>
		return -E_NOT_SUPP;
  800acc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ad1:	eb d3                	jmp    800aa6 <read+0x5a>

00800ad3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ae2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae7:	39 f3                	cmp    %esi,%ebx
  800ae9:	73 25                	jae    800b10 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aeb:	83 ec 04             	sub    $0x4,%esp
  800aee:	89 f0                	mov    %esi,%eax
  800af0:	29 d8                	sub    %ebx,%eax
  800af2:	50                   	push   %eax
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	03 45 0c             	add    0xc(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	57                   	push   %edi
  800afa:	e8 4d ff ff ff       	call   800a4c <read>
		if (m < 0)
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 08                	js     800b0e <readn+0x3b>
			return m;
		if (m == 0)
  800b06:	85 c0                	test   %eax,%eax
  800b08:	74 06                	je     800b10 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800b0a:	01 c3                	add    %eax,%ebx
  800b0c:	eb d9                	jmp    800ae7 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b0e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b10:	89 d8                	mov    %ebx,%eax
  800b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 14             	sub    $0x14,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b27:	50                   	push   %eax
  800b28:	53                   	push   %ebx
  800b29:	e8 ad fc ff ff       	call   8007db <fd_lookup>
  800b2e:	83 c4 08             	add    $0x8,%esp
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 3a                	js     800b6f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3b:	50                   	push   %eax
  800b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3f:	ff 30                	pushl  (%eax)
  800b41:	e8 eb fc ff ff       	call   800831 <dev_lookup>
  800b46:	83 c4 10             	add    $0x10,%esp
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	78 22                	js     800b6f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b50:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b54:	74 1e                	je     800b74 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b59:	8b 52 0c             	mov    0xc(%edx),%edx
  800b5c:	85 d2                	test   %edx,%edx
  800b5e:	74 35                	je     800b95 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b60:	83 ec 04             	sub    $0x4,%esp
  800b63:	ff 75 10             	pushl  0x10(%ebp)
  800b66:	ff 75 0c             	pushl  0xc(%ebp)
  800b69:	50                   	push   %eax
  800b6a:	ff d2                	call   *%edx
  800b6c:	83 c4 10             	add    $0x10,%esp
}
  800b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b74:	a1 04 40 80 00       	mov    0x804004,%eax
  800b79:	8b 40 48             	mov    0x48(%eax),%eax
  800b7c:	83 ec 04             	sub    $0x4,%esp
  800b7f:	53                   	push   %ebx
  800b80:	50                   	push   %eax
  800b81:	68 19 1f 80 00       	push   $0x801f19
  800b86:	e8 9e 09 00 00       	call   801529 <cprintf>
		return -E_INVAL;
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b93:	eb da                	jmp    800b6f <write+0x55>
		return -E_NOT_SUPP;
  800b95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b9a:	eb d3                	jmp    800b6f <write+0x55>

00800b9c <seek>:

int
seek(int fdnum, off_t offset)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ba2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ba5:	50                   	push   %eax
  800ba6:	ff 75 08             	pushl  0x8(%ebp)
  800ba9:	e8 2d fc ff ff       	call   8007db <fd_lookup>
  800bae:	83 c4 08             	add    $0x8,%esp
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	78 0e                	js     800bc3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 14             	sub    $0x14,%esp
  800bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bd2:	50                   	push   %eax
  800bd3:	53                   	push   %ebx
  800bd4:	e8 02 fc ff ff       	call   8007db <fd_lookup>
  800bd9:	83 c4 08             	add    $0x8,%esp
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 37                	js     800c17 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be0:	83 ec 08             	sub    $0x8,%esp
  800be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be6:	50                   	push   %eax
  800be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bea:	ff 30                	pushl  (%eax)
  800bec:	e8 40 fc ff ff       	call   800831 <dev_lookup>
  800bf1:	83 c4 10             	add    $0x10,%esp
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	78 1f                	js     800c17 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bff:	74 1b                	je     800c1c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c04:	8b 52 18             	mov    0x18(%edx),%edx
  800c07:	85 d2                	test   %edx,%edx
  800c09:	74 32                	je     800c3d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c0b:	83 ec 08             	sub    $0x8,%esp
  800c0e:	ff 75 0c             	pushl  0xc(%ebp)
  800c11:	50                   	push   %eax
  800c12:	ff d2                	call   *%edx
  800c14:	83 c4 10             	add    $0x10,%esp
}
  800c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c1c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c21:	8b 40 48             	mov    0x48(%eax),%eax
  800c24:	83 ec 04             	sub    $0x4,%esp
  800c27:	53                   	push   %ebx
  800c28:	50                   	push   %eax
  800c29:	68 dc 1e 80 00       	push   $0x801edc
  800c2e:	e8 f6 08 00 00       	call   801529 <cprintf>
		return -E_INVAL;
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c3b:	eb da                	jmp    800c17 <ftruncate+0x52>
		return -E_NOT_SUPP;
  800c3d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c42:	eb d3                	jmp    800c17 <ftruncate+0x52>

00800c44 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	53                   	push   %ebx
  800c48:	83 ec 14             	sub    $0x14,%esp
  800c4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c51:	50                   	push   %eax
  800c52:	ff 75 08             	pushl  0x8(%ebp)
  800c55:	e8 81 fb ff ff       	call   8007db <fd_lookup>
  800c5a:	83 c4 08             	add    $0x8,%esp
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	78 4b                	js     800cac <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c61:	83 ec 08             	sub    $0x8,%esp
  800c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c67:	50                   	push   %eax
  800c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c6b:	ff 30                	pushl  (%eax)
  800c6d:	e8 bf fb ff ff       	call   800831 <dev_lookup>
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 33                	js     800cac <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c80:	74 2f                	je     800cb1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c82:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c85:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c8c:	00 00 00 
	stat->st_isdir = 0;
  800c8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c96:	00 00 00 
	stat->st_dev = dev;
  800c99:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	53                   	push   %ebx
  800ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ca6:	ff 50 14             	call   *0x14(%eax)
  800ca9:	83 c4 10             	add    $0x10,%esp
}
  800cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    
		return -E_NOT_SUPP;
  800cb1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800cb6:	eb f4                	jmp    800cac <fstat+0x68>

00800cb8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cbd:	83 ec 08             	sub    $0x8,%esp
  800cc0:	6a 00                	push   $0x0
  800cc2:	ff 75 08             	pushl  0x8(%ebp)
  800cc5:	e8 e7 01 00 00       	call   800eb1 <open>
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	78 1b                	js     800cee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cd3:	83 ec 08             	sub    $0x8,%esp
  800cd6:	ff 75 0c             	pushl  0xc(%ebp)
  800cd9:	50                   	push   %eax
  800cda:	e8 65 ff ff ff       	call   800c44 <fstat>
  800cdf:	89 c6                	mov    %eax,%esi
	close(fd);
  800ce1:	89 1c 24             	mov    %ebx,(%esp)
  800ce4:	e8 27 fc ff ff       	call   800910 <close>
	return r;
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	89 f3                	mov    %esi,%ebx
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	89 c6                	mov    %eax,%esi
  800cfe:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d00:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d07:	74 27                	je     800d30 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d09:	6a 07                	push   $0x7
  800d0b:	68 00 50 80 00       	push   $0x805000
  800d10:	56                   	push   %esi
  800d11:	ff 35 00 40 80 00    	pushl  0x804000
  800d17:	e8 56 0e 00 00       	call   801b72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d1c:	83 c4 0c             	add    $0xc,%esp
  800d1f:	6a 00                	push   $0x0
  800d21:	53                   	push   %ebx
  800d22:	6a 00                	push   $0x0
  800d24:	e8 e8 0d 00 00       	call   801b11 <ipc_recv>
}
  800d29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	6a 01                	push   $0x1
  800d35:	e8 85 0e 00 00       	call   801bbf <ipc_find_env>
  800d3a:	a3 00 40 80 00       	mov    %eax,0x804000
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	eb c5                	jmp    800d09 <fsipc+0x12>

00800d44 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d50:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d62:	b8 02 00 00 00       	mov    $0x2,%eax
  800d67:	e8 8b ff ff ff       	call   800cf7 <fsipc>
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <devfile_flush>:
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	8b 40 0c             	mov    0xc(%eax),%eax
  800d7a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 06 00 00 00       	mov    $0x6,%eax
  800d89:	e8 69 ff ff ff       	call   800cf7 <fsipc>
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <devfile_stat>:
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800da0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	e8 43 ff ff ff       	call   800cf7 <fsipc>
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 2c                	js     800de4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	68 00 50 80 00       	push   $0x805000
  800dc0:	53                   	push   %ebx
  800dc1:	e8 b5 f3 ff ff       	call   80017b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dc6:	a1 80 50 80 00       	mov    0x805080,%eax
  800dcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dd1:	a1 84 50 80 00       	mov    0x805084,%eax
  800dd6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <devfile_write>:
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  800df2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800df7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dfc:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	8b 52 0c             	mov    0xc(%edx),%edx
  800e05:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800e0b:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  800e10:	50                   	push   %eax
  800e11:	ff 75 0c             	pushl  0xc(%ebp)
  800e14:	68 08 50 80 00       	push   $0x805008
  800e19:	e8 eb f4 ff ff       	call   800309 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e23:	b8 04 00 00 00       	mov    $0x4,%eax
  800e28:	e8 ca fe ff ff       	call   800cf7 <fsipc>
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <devfile_read>:
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e52:	e8 a0 fe ff ff       	call   800cf7 <fsipc>
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 1f                	js     800e7c <devfile_read+0x4d>
	assert(r <= n);
  800e5d:	39 f0                	cmp    %esi,%eax
  800e5f:	77 24                	ja     800e85 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800e61:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e66:	7f 33                	jg     800e9b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	50                   	push   %eax
  800e6c:	68 00 50 80 00       	push   $0x805000
  800e71:	ff 75 0c             	pushl  0xc(%ebp)
  800e74:	e8 90 f4 ff ff       	call   800309 <memmove>
	return r;
  800e79:	83 c4 10             	add    $0x10,%esp
}
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
	assert(r <= n);
  800e85:	68 48 1f 80 00       	push   $0x801f48
  800e8a:	68 4f 1f 80 00       	push   $0x801f4f
  800e8f:	6a 7d                	push   $0x7d
  800e91:	68 64 1f 80 00       	push   $0x801f64
  800e96:	e8 b3 05 00 00       	call   80144e <_panic>
	assert(r <= PGSIZE);
  800e9b:	68 6f 1f 80 00       	push   $0x801f6f
  800ea0:	68 4f 1f 80 00       	push   $0x801f4f
  800ea5:	6a 7e                	push   $0x7e
  800ea7:	68 64 1f 80 00       	push   $0x801f64
  800eac:	e8 9d 05 00 00       	call   80144e <_panic>

00800eb1 <open>:
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 1c             	sub    $0x1c,%esp
  800eb9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ebc:	56                   	push   %esi
  800ebd:	e8 82 f2 ff ff       	call   800144 <strlen>
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800eca:	0f 8f 96 00 00 00    	jg     800f66 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	e8 b0 f8 ff ff       	call   80078c <fd_alloc>
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 66                	js     800f4b <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	56                   	push   %esi
  800ee9:	68 00 50 80 00       	push   $0x805000
  800eee:	e8 88 f2 ff ff       	call   80017b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800efb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800efe:	b8 01 00 00 00       	mov    $0x1,%eax
  800f03:	e8 ef fd ff ff       	call   800cf7 <fsipc>
  800f08:	89 c3                	mov    %eax,%ebx
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 43                	js     800f54 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	ff 75 f4             	pushl  -0xc(%ebp)
  800f17:	e8 49 f8 ff ff       	call   800765 <fd2num>
  800f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f1f:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800f25:	8b 49 48             	mov    0x48(%ecx),%ecx
  800f28:	83 c4 08             	add    $0x8,%esp
  800f2b:	50                   	push   %eax
  800f2c:	52                   	push   %edx
  800f2d:	ff 32                	pushl  (%edx)
  800f2f:	56                   	push   %esi
  800f30:	51                   	push   %ecx
  800f31:	68 7c 1f 80 00       	push   $0x801f7c
  800f36:	e8 ee 05 00 00       	call   801529 <cprintf>
	return fd2num(fd);
  800f3b:	83 c4 14             	add    $0x14,%esp
  800f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f41:	e8 1f f8 ff ff       	call   800765 <fd2num>
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	83 c4 10             	add    $0x10,%esp
}
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
		fd_close(fd, 0);
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	6a 00                	push   $0x0
  800f59:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5c:	e8 26 f9 ff ff       	call   800887 <fd_close>
		return r;
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	eb e5                	jmp    800f4b <open+0x9a>
		return -E_BAD_PATH;
  800f66:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f6b:	eb de                	jmp    800f4b <open+0x9a>

00800f6d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f73:	ba 00 00 00 00       	mov    $0x0,%edx
  800f78:	b8 08 00 00 00       	mov    $0x8,%eax
  800f7d:	e8 75 fd ff ff       	call   800cf7 <fsipc>
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	e8 de f7 ff ff       	call   800775 <fd2data>
  800f97:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f99:	83 c4 08             	add    $0x8,%esp
  800f9c:	68 bb 1f 80 00       	push   $0x801fbb
  800fa1:	53                   	push   %ebx
  800fa2:	e8 d4 f1 ff ff       	call   80017b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fa7:	8b 46 04             	mov    0x4(%esi),%eax
  800faa:	2b 06                	sub    (%esi),%eax
  800fac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fb2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fb9:	00 00 00 
	stat->st_dev = &devpipe;
  800fbc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fc3:	30 80 00 
	return 0;
}
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fdc:	53                   	push   %ebx
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 15 f6 ff ff       	call   8005f9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fe4:	89 1c 24             	mov    %ebx,(%esp)
  800fe7:	e8 89 f7 ff ff       	call   800775 <fd2data>
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	50                   	push   %eax
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 02 f6 ff ff       	call   8005f9 <sys_page_unmap>
}
  800ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <_pipeisclosed>:
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 1c             	sub    $0x1c,%esp
  801005:	89 c7                	mov    %eax,%edi
  801007:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801009:	a1 04 40 80 00       	mov    0x804004,%eax
  80100e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	57                   	push   %edi
  801015:	e8 de 0b 00 00       	call   801bf8 <pageref>
  80101a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80101d:	89 34 24             	mov    %esi,(%esp)
  801020:	e8 d3 0b 00 00       	call   801bf8 <pageref>
		nn = thisenv->env_runs;
  801025:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80102b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	39 cb                	cmp    %ecx,%ebx
  801033:	74 1b                	je     801050 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801035:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801038:	75 cf                	jne    801009 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80103a:	8b 42 58             	mov    0x58(%edx),%eax
  80103d:	6a 01                	push   $0x1
  80103f:	50                   	push   %eax
  801040:	53                   	push   %ebx
  801041:	68 c2 1f 80 00       	push   $0x801fc2
  801046:	e8 de 04 00 00       	call   801529 <cprintf>
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	eb b9                	jmp    801009 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801050:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801053:	0f 94 c0             	sete   %al
  801056:	0f b6 c0             	movzbl %al,%eax
}
  801059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <devpipe_write>:
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 28             	sub    $0x28,%esp
  80106a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80106d:	56                   	push   %esi
  80106e:	e8 02 f7 ff ff       	call   800775 <fd2data>
  801073:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	bf 00 00 00 00       	mov    $0x0,%edi
  80107d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801080:	74 4f                	je     8010d1 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801082:	8b 43 04             	mov    0x4(%ebx),%eax
  801085:	8b 0b                	mov    (%ebx),%ecx
  801087:	8d 51 20             	lea    0x20(%ecx),%edx
  80108a:	39 d0                	cmp    %edx,%eax
  80108c:	72 14                	jb     8010a2 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80108e:	89 da                	mov    %ebx,%edx
  801090:	89 f0                	mov    %esi,%eax
  801092:	e8 65 ff ff ff       	call   800ffc <_pipeisclosed>
  801097:	85 c0                	test   %eax,%eax
  801099:	75 3a                	jne    8010d5 <devpipe_write+0x74>
			sys_yield();
  80109b:	e8 b5 f4 ff ff       	call   800555 <sys_yield>
  8010a0:	eb e0                	jmp    801082 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010a9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	c1 fa 1f             	sar    $0x1f,%edx
  8010b1:	89 d1                	mov    %edx,%ecx
  8010b3:	c1 e9 1b             	shr    $0x1b,%ecx
  8010b6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010b9:	83 e2 1f             	and    $0x1f,%edx
  8010bc:	29 ca                	sub    %ecx,%edx
  8010be:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010c6:	83 c0 01             	add    $0x1,%eax
  8010c9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8010cc:	83 c7 01             	add    $0x1,%edi
  8010cf:	eb ac                	jmp    80107d <devpipe_write+0x1c>
	return i;
  8010d1:	89 f8                	mov    %edi,%eax
  8010d3:	eb 05                	jmp    8010da <devpipe_write+0x79>
				return 0;
  8010d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <devpipe_read>:
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 18             	sub    $0x18,%esp
  8010eb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8010ee:	57                   	push   %edi
  8010ef:	e8 81 f6 ff ff       	call   800775 <fd2data>
  8010f4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	be 00 00 00 00       	mov    $0x0,%esi
  8010fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801101:	74 47                	je     80114a <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801103:	8b 03                	mov    (%ebx),%eax
  801105:	3b 43 04             	cmp    0x4(%ebx),%eax
  801108:	75 22                	jne    80112c <devpipe_read+0x4a>
			if (i > 0)
  80110a:	85 f6                	test   %esi,%esi
  80110c:	75 14                	jne    801122 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80110e:	89 da                	mov    %ebx,%edx
  801110:	89 f8                	mov    %edi,%eax
  801112:	e8 e5 fe ff ff       	call   800ffc <_pipeisclosed>
  801117:	85 c0                	test   %eax,%eax
  801119:	75 33                	jne    80114e <devpipe_read+0x6c>
			sys_yield();
  80111b:	e8 35 f4 ff ff       	call   800555 <sys_yield>
  801120:	eb e1                	jmp    801103 <devpipe_read+0x21>
				return i;
  801122:	89 f0                	mov    %esi,%eax
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80112c:	99                   	cltd   
  80112d:	c1 ea 1b             	shr    $0x1b,%edx
  801130:	01 d0                	add    %edx,%eax
  801132:	83 e0 1f             	and    $0x1f,%eax
  801135:	29 d0                	sub    %edx,%eax
  801137:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801142:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801145:	83 c6 01             	add    $0x1,%esi
  801148:	eb b4                	jmp    8010fe <devpipe_read+0x1c>
	return i;
  80114a:	89 f0                	mov    %esi,%eax
  80114c:	eb d6                	jmp    801124 <devpipe_read+0x42>
				return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb cf                	jmp    801124 <devpipe_read+0x42>

00801155 <pipe>:
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	e8 26 f6 ff ff       	call   80078c <fd_alloc>
  801166:	89 c3                	mov    %eax,%ebx
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 5b                	js     8011ca <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	68 07 04 00 00       	push   $0x407
  801177:	ff 75 f4             	pushl  -0xc(%ebp)
  80117a:	6a 00                	push   $0x0
  80117c:	e8 f3 f3 ff ff       	call   800574 <sys_page_alloc>
  801181:	89 c3                	mov    %eax,%ebx
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	78 40                	js     8011ca <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	e8 f6 f5 ff ff       	call   80078c <fd_alloc>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 1b                	js     8011ba <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	68 07 04 00 00       	push   $0x407
  8011a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8011aa:	6a 00                	push   $0x0
  8011ac:	e8 c3 f3 ff ff       	call   800574 <sys_page_alloc>
  8011b1:	89 c3                	mov    %eax,%ebx
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	79 19                	jns    8011d3 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c0:	6a 00                	push   $0x0
  8011c2:	e8 32 f4 ff ff       	call   8005f9 <sys_page_unmap>
  8011c7:	83 c4 10             	add    $0x10,%esp
}
  8011ca:	89 d8                	mov    %ebx,%eax
  8011cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    
	va = fd2data(fd0);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d9:	e8 97 f5 ff ff       	call   800775 <fd2data>
  8011de:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e0:	83 c4 0c             	add    $0xc,%esp
  8011e3:	68 07 04 00 00       	push   $0x407
  8011e8:	50                   	push   %eax
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 84 f3 ff ff       	call   800574 <sys_page_alloc>
  8011f0:	89 c3                	mov    %eax,%ebx
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 88 8c 00 00 00    	js     801289 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	ff 75 f0             	pushl  -0x10(%ebp)
  801203:	e8 6d f5 ff ff       	call   800775 <fd2data>
  801208:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80120f:	50                   	push   %eax
  801210:	6a 00                	push   $0x0
  801212:	56                   	push   %esi
  801213:	6a 00                	push   $0x0
  801215:	e8 9d f3 ff ff       	call   8005b7 <sys_page_map>
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	83 c4 20             	add    $0x20,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 58                	js     80127b <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801223:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801226:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80122c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80122e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801231:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801241:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	ff 75 f4             	pushl  -0xc(%ebp)
  801253:	e8 0d f5 ff ff       	call   800765 <fd2num>
  801258:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80125d:	83 c4 04             	add    $0x4,%esp
  801260:	ff 75 f0             	pushl  -0x10(%ebp)
  801263:	e8 fd f4 ff ff       	call   800765 <fd2num>
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
  801276:	e9 4f ff ff ff       	jmp    8011ca <pipe+0x75>
	sys_page_unmap(0, va);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	56                   	push   %esi
  80127f:	6a 00                	push   $0x0
  801281:	e8 73 f3 ff ff       	call   8005f9 <sys_page_unmap>
  801286:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	ff 75 f0             	pushl  -0x10(%ebp)
  80128f:	6a 00                	push   $0x0
  801291:	e8 63 f3 ff ff       	call   8005f9 <sys_page_unmap>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	e9 1c ff ff ff       	jmp    8011ba <pipe+0x65>

0080129e <pipeisclosed>:
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 2b f5 ff ff       	call   8007db <fd_lookup>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 18                	js     8012cf <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bd:	e8 b3 f4 ff ff       	call   800775 <fd2data>
	return _pipeisclosed(fd, p);
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c7:	e8 30 fd ff ff       	call   800ffc <_pipeisclosed>
  8012cc:	83 c4 10             	add    $0x10,%esp
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012e1:	68 da 1f 80 00       	push   $0x801fda
  8012e6:	ff 75 0c             	pushl  0xc(%ebp)
  8012e9:	e8 8d ee ff ff       	call   80017b <strcpy>
	return 0;
}
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    

008012f5 <devcons_write>:
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
  8012fb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801301:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801306:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80130c:	eb 2f                	jmp    80133d <devcons_write+0x48>
		m = n - tot;
  80130e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801311:	29 f3                	sub    %esi,%ebx
  801313:	83 fb 7f             	cmp    $0x7f,%ebx
  801316:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80131b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	53                   	push   %ebx
  801322:	89 f0                	mov    %esi,%eax
  801324:	03 45 0c             	add    0xc(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	57                   	push   %edi
  801329:	e8 db ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	57                   	push   %edi
  801333:	e8 80 f1 ff ff       	call   8004b8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801338:	01 de                	add    %ebx,%esi
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801340:	72 cc                	jb     80130e <devcons_write+0x19>
}
  801342:	89 f0                	mov    %esi,%eax
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <devcons_read>:
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801357:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80135b:	75 07                	jne    801364 <devcons_read+0x18>
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    
		sys_yield();
  80135f:	e8 f1 f1 ff ff       	call   800555 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801364:	e8 6d f1 ff ff       	call   8004d6 <sys_cgetc>
  801369:	85 c0                	test   %eax,%eax
  80136b:	74 f2                	je     80135f <devcons_read+0x13>
	if (c < 0)
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 ec                	js     80135d <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801371:	83 f8 04             	cmp    $0x4,%eax
  801374:	74 0c                	je     801382 <devcons_read+0x36>
	*(char*)vbuf = c;
  801376:	8b 55 0c             	mov    0xc(%ebp),%edx
  801379:	88 02                	mov    %al,(%edx)
	return 1;
  80137b:	b8 01 00 00 00       	mov    $0x1,%eax
  801380:	eb db                	jmp    80135d <devcons_read+0x11>
		return 0;
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	eb d4                	jmp    80135d <devcons_read+0x11>

00801389 <cputchar>:
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80138f:	8b 45 08             	mov    0x8(%ebp),%eax
  801392:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801395:	6a 01                	push   $0x1
  801397:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	e8 18 f1 ff ff       	call   8004b8 <sys_cputs>
}
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <getchar>:
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8013ab:	6a 01                	push   $0x1
  8013ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 94 f6 ff ff       	call   800a4c <read>
	if (r < 0)
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 08                	js     8013c7 <getchar+0x22>
	if (r < 1)
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	7e 06                	jle    8013c9 <getchar+0x24>
	return c;
  8013c3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    
		return -E_EOF;
  8013c9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8013ce:	eb f7                	jmp    8013c7 <getchar+0x22>

008013d0 <iscons>:
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 75 08             	pushl  0x8(%ebp)
  8013dd:	e8 f9 f3 ff ff       	call   8007db <fd_lookup>
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 11                	js     8013fa <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013f2:	39 10                	cmp    %edx,(%eax)
  8013f4:	0f 94 c0             	sete   %al
  8013f7:	0f b6 c0             	movzbl %al,%eax
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <opencons>:
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 81 f3 ff ff       	call   80078c <fd_alloc>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 3a                	js     80144c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801412:	83 ec 04             	sub    $0x4,%esp
  801415:	68 07 04 00 00       	push   $0x407
  80141a:	ff 75 f4             	pushl  -0xc(%ebp)
  80141d:	6a 00                	push   $0x0
  80141f:	e8 50 f1 ff ff       	call   800574 <sys_page_alloc>
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 21                	js     80144c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80142b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801434:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	50                   	push   %eax
  801444:	e8 1c f3 ff ff       	call   800765 <fd2num>
  801449:	83 c4 10             	add    $0x10,%esp
}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801453:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801456:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80145c:	e8 d5 f0 ff ff       	call   800536 <sys_getenvid>
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	ff 75 08             	pushl  0x8(%ebp)
  80146a:	56                   	push   %esi
  80146b:	50                   	push   %eax
  80146c:	68 e8 1f 80 00       	push   $0x801fe8
  801471:	e8 b3 00 00 00       	call   801529 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801476:	83 c4 18             	add    $0x18,%esp
  801479:	53                   	push   %ebx
  80147a:	ff 75 10             	pushl  0x10(%ebp)
  80147d:	e8 56 00 00 00       	call   8014d8 <vcprintf>
	cprintf("\n");
  801482:	c7 04 24 d3 1f 80 00 	movl   $0x801fd3,(%esp)
  801489:	e8 9b 00 00 00       	call   801529 <cprintf>
  80148e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801491:	cc                   	int3   
  801492:	eb fd                	jmp    801491 <_panic+0x43>

00801494 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80149e:	8b 13                	mov    (%ebx),%edx
  8014a0:	8d 42 01             	lea    0x1(%edx),%eax
  8014a3:	89 03                	mov    %eax,(%ebx)
  8014a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014b1:	74 09                	je     8014bc <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8014b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	68 ff 00 00 00       	push   $0xff
  8014c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8014c7:	50                   	push   %eax
  8014c8:	e8 eb ef ff ff       	call   8004b8 <sys_cputs>
		b->idx = 0;
  8014cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	eb db                	jmp    8014b3 <putch+0x1f>

008014d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014e8:	00 00 00 
	b.cnt = 0;
  8014eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014f5:	ff 75 0c             	pushl  0xc(%ebp)
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	68 94 14 80 00       	push   $0x801494
  801507:	e8 1a 01 00 00       	call   801626 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801515:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	e8 97 ef ff ff       	call   8004b8 <sys_cputs>

	return b.cnt;
}
  801521:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80152f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801532:	50                   	push   %eax
  801533:	ff 75 08             	pushl  0x8(%ebp)
  801536:	e8 9d ff ff ff       	call   8014d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	57                   	push   %edi
  801541:	56                   	push   %esi
  801542:	53                   	push   %ebx
  801543:	83 ec 1c             	sub    $0x1c,%esp
  801546:	89 c7                	mov    %eax,%edi
  801548:	89 d6                	mov    %edx,%esi
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801553:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801556:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801561:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801564:	39 d3                	cmp    %edx,%ebx
  801566:	72 05                	jb     80156d <printnum+0x30>
  801568:	39 45 10             	cmp    %eax,0x10(%ebp)
  80156b:	77 7a                	ja     8015e7 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	ff 75 18             	pushl  0x18(%ebp)
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801579:	53                   	push   %ebx
  80157a:	ff 75 10             	pushl  0x10(%ebp)
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	ff 75 e4             	pushl  -0x1c(%ebp)
  801583:	ff 75 e0             	pushl  -0x20(%ebp)
  801586:	ff 75 dc             	pushl  -0x24(%ebp)
  801589:	ff 75 d8             	pushl  -0x28(%ebp)
  80158c:	e8 af 06 00 00       	call   801c40 <__udivdi3>
  801591:	83 c4 18             	add    $0x18,%esp
  801594:	52                   	push   %edx
  801595:	50                   	push   %eax
  801596:	89 f2                	mov    %esi,%edx
  801598:	89 f8                	mov    %edi,%eax
  80159a:	e8 9e ff ff ff       	call   80153d <printnum>
  80159f:	83 c4 20             	add    $0x20,%esp
  8015a2:	eb 13                	jmp    8015b7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	56                   	push   %esi
  8015a8:	ff 75 18             	pushl  0x18(%ebp)
  8015ab:	ff d7                	call   *%edi
  8015ad:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8015b0:	83 eb 01             	sub    $0x1,%ebx
  8015b3:	85 db                	test   %ebx,%ebx
  8015b5:	7f ed                	jg     8015a4 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	56                   	push   %esi
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ca:	e8 91 07 00 00       	call   801d60 <__umoddi3>
  8015cf:	83 c4 14             	add    $0x14,%esp
  8015d2:	0f be 80 0b 20 80 00 	movsbl 0x80200b(%eax),%eax
  8015d9:	50                   	push   %eax
  8015da:	ff d7                	call   *%edi
}
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5f                   	pop    %edi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    
  8015e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8015ea:	eb c4                	jmp    8015b0 <printnum+0x73>

008015ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015f6:	8b 10                	mov    (%eax),%edx
  8015f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8015fb:	73 0a                	jae    801607 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  801600:	89 08                	mov    %ecx,(%eax)
  801602:	8b 45 08             	mov    0x8(%ebp),%eax
  801605:	88 02                	mov    %al,(%edx)
}
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <printfmt>:
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80160f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801612:	50                   	push   %eax
  801613:	ff 75 10             	pushl  0x10(%ebp)
  801616:	ff 75 0c             	pushl  0xc(%ebp)
  801619:	ff 75 08             	pushl  0x8(%ebp)
  80161c:	e8 05 00 00 00       	call   801626 <vprintfmt>
}
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <vprintfmt>:
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	57                   	push   %edi
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
  80162c:	83 ec 2c             	sub    $0x2c,%esp
  80162f:	8b 75 08             	mov    0x8(%ebp),%esi
  801632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801635:	8b 7d 10             	mov    0x10(%ebp),%edi
  801638:	e9 c1 03 00 00       	jmp    8019fe <vprintfmt+0x3d8>
		padc = ' ';
  80163d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801641:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801648:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80164f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801656:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80165b:	8d 47 01             	lea    0x1(%edi),%eax
  80165e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801661:	0f b6 17             	movzbl (%edi),%edx
  801664:	8d 42 dd             	lea    -0x23(%edx),%eax
  801667:	3c 55                	cmp    $0x55,%al
  801669:	0f 87 12 04 00 00    	ja     801a81 <vprintfmt+0x45b>
  80166f:	0f b6 c0             	movzbl %al,%eax
  801672:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  801679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80167c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801680:	eb d9                	jmp    80165b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801685:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801689:	eb d0                	jmp    80165b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80168b:	0f b6 d2             	movzbl %dl,%edx
  80168e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
  801696:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801699:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80169c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8016a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8016a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8016a6:	83 f9 09             	cmp    $0x9,%ecx
  8016a9:	77 55                	ja     801700 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8016ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8016ae:	eb e9                	jmp    801699 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8016b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b3:	8b 00                	mov    (%eax),%eax
  8016b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bb:	8d 40 04             	lea    0x4(%eax),%eax
  8016be:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8016c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8016c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016c8:	79 91                	jns    80165b <vprintfmt+0x35>
				width = precision, precision = -1;
  8016ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016d7:	eb 82                	jmp    80165b <vprintfmt+0x35>
  8016d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e3:	0f 49 d0             	cmovns %eax,%edx
  8016e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8016e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016ec:	e9 6a ff ff ff       	jmp    80165b <vprintfmt+0x35>
  8016f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8016f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016fb:	e9 5b ff ff ff       	jmp    80165b <vprintfmt+0x35>
  801700:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801703:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801706:	eb bc                	jmp    8016c4 <vprintfmt+0x9e>
			lflag++;
  801708:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80170b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80170e:	e9 48 ff ff ff       	jmp    80165b <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801713:	8b 45 14             	mov    0x14(%ebp),%eax
  801716:	8d 78 04             	lea    0x4(%eax),%edi
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	53                   	push   %ebx
  80171d:	ff 30                	pushl  (%eax)
  80171f:	ff d6                	call   *%esi
			break;
  801721:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801724:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801727:	e9 cf 02 00 00       	jmp    8019fb <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80172c:	8b 45 14             	mov    0x14(%ebp),%eax
  80172f:	8d 78 04             	lea    0x4(%eax),%edi
  801732:	8b 00                	mov    (%eax),%eax
  801734:	99                   	cltd   
  801735:	31 d0                	xor    %edx,%eax
  801737:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801739:	83 f8 0f             	cmp    $0xf,%eax
  80173c:	7f 23                	jg     801761 <vprintfmt+0x13b>
  80173e:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  801745:	85 d2                	test   %edx,%edx
  801747:	74 18                	je     801761 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801749:	52                   	push   %edx
  80174a:	68 61 1f 80 00       	push   $0x801f61
  80174f:	53                   	push   %ebx
  801750:	56                   	push   %esi
  801751:	e8 b3 fe ff ff       	call   801609 <printfmt>
  801756:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801759:	89 7d 14             	mov    %edi,0x14(%ebp)
  80175c:	e9 9a 02 00 00       	jmp    8019fb <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801761:	50                   	push   %eax
  801762:	68 23 20 80 00       	push   $0x802023
  801767:	53                   	push   %ebx
  801768:	56                   	push   %esi
  801769:	e8 9b fe ff ff       	call   801609 <printfmt>
  80176e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801771:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801774:	e9 82 02 00 00       	jmp    8019fb <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	83 c0 04             	add    $0x4,%eax
  80177f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801782:	8b 45 14             	mov    0x14(%ebp),%eax
  801785:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801787:	85 ff                	test   %edi,%edi
  801789:	b8 1c 20 80 00       	mov    $0x80201c,%eax
  80178e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801791:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801795:	0f 8e bd 00 00 00    	jle    801858 <vprintfmt+0x232>
  80179b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80179f:	75 0e                	jne    8017af <vprintfmt+0x189>
  8017a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8017a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017ad:	eb 6d                	jmp    80181c <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8017b5:	57                   	push   %edi
  8017b6:	e8 a1 e9 ff ff       	call   80015c <strnlen>
  8017bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017be:	29 c1                	sub    %eax,%ecx
  8017c0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8017c3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017c6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017d0:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8017d2:	eb 0f                	jmp    8017e3 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8017db:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8017dd:	83 ef 01             	sub    $0x1,%edi
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 ff                	test   %edi,%edi
  8017e5:	7f ed                	jg     8017d4 <vprintfmt+0x1ae>
  8017e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017ea:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8017ed:	85 c9                	test   %ecx,%ecx
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f4:	0f 49 c1             	cmovns %ecx,%eax
  8017f7:	29 c1                	sub    %eax,%ecx
  8017f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8017fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801802:	89 cb                	mov    %ecx,%ebx
  801804:	eb 16                	jmp    80181c <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  801806:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80180a:	75 31                	jne    80183d <vprintfmt+0x217>
					putch(ch, putdat);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	50                   	push   %eax
  801813:	ff 55 08             	call   *0x8(%ebp)
  801816:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801819:	83 eb 01             	sub    $0x1,%ebx
  80181c:	83 c7 01             	add    $0x1,%edi
  80181f:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801823:	0f be c2             	movsbl %dl,%eax
  801826:	85 c0                	test   %eax,%eax
  801828:	74 59                	je     801883 <vprintfmt+0x25d>
  80182a:	85 f6                	test   %esi,%esi
  80182c:	78 d8                	js     801806 <vprintfmt+0x1e0>
  80182e:	83 ee 01             	sub    $0x1,%esi
  801831:	79 d3                	jns    801806 <vprintfmt+0x1e0>
  801833:	89 df                	mov    %ebx,%edi
  801835:	8b 75 08             	mov    0x8(%ebp),%esi
  801838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80183b:	eb 37                	jmp    801874 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80183d:	0f be d2             	movsbl %dl,%edx
  801840:	83 ea 20             	sub    $0x20,%edx
  801843:	83 fa 5e             	cmp    $0x5e,%edx
  801846:	76 c4                	jbe    80180c <vprintfmt+0x1e6>
					putch('?', putdat);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	6a 3f                	push   $0x3f
  801850:	ff 55 08             	call   *0x8(%ebp)
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	eb c1                	jmp    801819 <vprintfmt+0x1f3>
  801858:	89 75 08             	mov    %esi,0x8(%ebp)
  80185b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80185e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801861:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801864:	eb b6                	jmp    80181c <vprintfmt+0x1f6>
				putch(' ', putdat);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	53                   	push   %ebx
  80186a:	6a 20                	push   $0x20
  80186c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80186e:	83 ef 01             	sub    $0x1,%edi
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 ff                	test   %edi,%edi
  801876:	7f ee                	jg     801866 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801878:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80187b:	89 45 14             	mov    %eax,0x14(%ebp)
  80187e:	e9 78 01 00 00       	jmp    8019fb <vprintfmt+0x3d5>
  801883:	89 df                	mov    %ebx,%edi
  801885:	8b 75 08             	mov    0x8(%ebp),%esi
  801888:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80188b:	eb e7                	jmp    801874 <vprintfmt+0x24e>
	if (lflag >= 2)
  80188d:	83 f9 01             	cmp    $0x1,%ecx
  801890:	7e 3f                	jle    8018d1 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801892:	8b 45 14             	mov    0x14(%ebp),%eax
  801895:	8b 50 04             	mov    0x4(%eax),%edx
  801898:	8b 00                	mov    (%eax),%eax
  80189a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80189d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a3:	8d 40 08             	lea    0x8(%eax),%eax
  8018a6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8018a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018ad:	79 5c                	jns    80190b <vprintfmt+0x2e5>
				putch('-', putdat);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	6a 2d                	push   $0x2d
  8018b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8018b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8018bd:	f7 da                	neg    %edx
  8018bf:	83 d1 00             	adc    $0x0,%ecx
  8018c2:	f7 d9                	neg    %ecx
  8018c4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8018c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018cc:	e9 10 01 00 00       	jmp    8019e1 <vprintfmt+0x3bb>
	else if (lflag)
  8018d1:	85 c9                	test   %ecx,%ecx
  8018d3:	75 1b                	jne    8018f0 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8018d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d8:	8b 00                	mov    (%eax),%eax
  8018da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018dd:	89 c1                	mov    %eax,%ecx
  8018df:	c1 f9 1f             	sar    $0x1f,%ecx
  8018e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e8:	8d 40 04             	lea    0x4(%eax),%eax
  8018eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8018ee:	eb b9                	jmp    8018a9 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8018f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f3:	8b 00                	mov    (%eax),%eax
  8018f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f8:	89 c1                	mov    %eax,%ecx
  8018fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8018fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801900:	8b 45 14             	mov    0x14(%ebp),%eax
  801903:	8d 40 04             	lea    0x4(%eax),%eax
  801906:	89 45 14             	mov    %eax,0x14(%ebp)
  801909:	eb 9e                	jmp    8018a9 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80190b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80190e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801911:	b8 0a 00 00 00       	mov    $0xa,%eax
  801916:	e9 c6 00 00 00       	jmp    8019e1 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80191b:	83 f9 01             	cmp    $0x1,%ecx
  80191e:	7e 18                	jle    801938 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801920:	8b 45 14             	mov    0x14(%ebp),%eax
  801923:	8b 10                	mov    (%eax),%edx
  801925:	8b 48 04             	mov    0x4(%eax),%ecx
  801928:	8d 40 08             	lea    0x8(%eax),%eax
  80192b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80192e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801933:	e9 a9 00 00 00       	jmp    8019e1 <vprintfmt+0x3bb>
	else if (lflag)
  801938:	85 c9                	test   %ecx,%ecx
  80193a:	75 1a                	jne    801956 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80193c:	8b 45 14             	mov    0x14(%ebp),%eax
  80193f:	8b 10                	mov    (%eax),%edx
  801941:	b9 00 00 00 00       	mov    $0x0,%ecx
  801946:	8d 40 04             	lea    0x4(%eax),%eax
  801949:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80194c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801951:	e9 8b 00 00 00       	jmp    8019e1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801956:	8b 45 14             	mov    0x14(%ebp),%eax
  801959:	8b 10                	mov    (%eax),%edx
  80195b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801960:	8d 40 04             	lea    0x4(%eax),%eax
  801963:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801966:	b8 0a 00 00 00       	mov    $0xa,%eax
  80196b:	eb 74                	jmp    8019e1 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80196d:	83 f9 01             	cmp    $0x1,%ecx
  801970:	7e 15                	jle    801987 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801972:	8b 45 14             	mov    0x14(%ebp),%eax
  801975:	8b 10                	mov    (%eax),%edx
  801977:	8b 48 04             	mov    0x4(%eax),%ecx
  80197a:	8d 40 08             	lea    0x8(%eax),%eax
  80197d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801980:	b8 08 00 00 00       	mov    $0x8,%eax
  801985:	eb 5a                	jmp    8019e1 <vprintfmt+0x3bb>
	else if (lflag)
  801987:	85 c9                	test   %ecx,%ecx
  801989:	75 17                	jne    8019a2 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80198b:	8b 45 14             	mov    0x14(%ebp),%eax
  80198e:	8b 10                	mov    (%eax),%edx
  801990:	b9 00 00 00 00       	mov    $0x0,%ecx
  801995:	8d 40 04             	lea    0x4(%eax),%eax
  801998:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80199b:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a0:	eb 3f                	jmp    8019e1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8019a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a5:	8b 10                	mov    (%eax),%edx
  8019a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ac:	8d 40 04             	lea    0x4(%eax),%eax
  8019af:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8019b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b7:	eb 28                	jmp    8019e1 <vprintfmt+0x3bb>
			putch('0', putdat);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	6a 30                	push   $0x30
  8019bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8019c1:	83 c4 08             	add    $0x8,%esp
  8019c4:	53                   	push   %ebx
  8019c5:	6a 78                	push   $0x78
  8019c7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8019c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cc:	8b 10                	mov    (%eax),%edx
  8019ce:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8019d3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8019d6:	8d 40 04             	lea    0x4(%eax),%eax
  8019d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019dc:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8019e8:	57                   	push   %edi
  8019e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ec:	50                   	push   %eax
  8019ed:	51                   	push   %ecx
  8019ee:	52                   	push   %edx
  8019ef:	89 da                	mov    %ebx,%edx
  8019f1:	89 f0                	mov    %esi,%eax
  8019f3:	e8 45 fb ff ff       	call   80153d <printnum>
			break;
  8019f8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8019fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019fe:	83 c7 01             	add    $0x1,%edi
  801a01:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a05:	83 f8 25             	cmp    $0x25,%eax
  801a08:	0f 84 2f fc ff ff    	je     80163d <vprintfmt+0x17>
			if (ch == '\0')
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	0f 84 8b 00 00 00    	je     801aa1 <vprintfmt+0x47b>
			putch(ch, putdat);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	53                   	push   %ebx
  801a1a:	50                   	push   %eax
  801a1b:	ff d6                	call   *%esi
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	eb dc                	jmp    8019fe <vprintfmt+0x3d8>
	if (lflag >= 2)
  801a22:	83 f9 01             	cmp    $0x1,%ecx
  801a25:	7e 15                	jle    801a3c <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801a27:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2a:	8b 10                	mov    (%eax),%edx
  801a2c:	8b 48 04             	mov    0x4(%eax),%ecx
  801a2f:	8d 40 08             	lea    0x8(%eax),%eax
  801a32:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a35:	b8 10 00 00 00       	mov    $0x10,%eax
  801a3a:	eb a5                	jmp    8019e1 <vprintfmt+0x3bb>
	else if (lflag)
  801a3c:	85 c9                	test   %ecx,%ecx
  801a3e:	75 17                	jne    801a57 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801a40:	8b 45 14             	mov    0x14(%ebp),%eax
  801a43:	8b 10                	mov    (%eax),%edx
  801a45:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a4a:	8d 40 04             	lea    0x4(%eax),%eax
  801a4d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a50:	b8 10 00 00 00       	mov    $0x10,%eax
  801a55:	eb 8a                	jmp    8019e1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801a57:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5a:	8b 10                	mov    (%eax),%edx
  801a5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a61:	8d 40 04             	lea    0x4(%eax),%eax
  801a64:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a67:	b8 10 00 00 00       	mov    $0x10,%eax
  801a6c:	e9 70 ff ff ff       	jmp    8019e1 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	53                   	push   %ebx
  801a75:	6a 25                	push   $0x25
  801a77:	ff d6                	call   *%esi
			break;
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	e9 7a ff ff ff       	jmp    8019fb <vprintfmt+0x3d5>
			putch('%', putdat);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	53                   	push   %ebx
  801a85:	6a 25                	push   $0x25
  801a87:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	89 f8                	mov    %edi,%eax
  801a8e:	eb 03                	jmp    801a93 <vprintfmt+0x46d>
  801a90:	83 e8 01             	sub    $0x1,%eax
  801a93:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801a97:	75 f7                	jne    801a90 <vprintfmt+0x46a>
  801a99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a9c:	e9 5a ff ff ff       	jmp    8019fb <vprintfmt+0x3d5>
}
  801aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 18             	sub    $0x18,%esp
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	74 26                	je     801af0 <vsnprintf+0x47>
  801aca:	85 d2                	test   %edx,%edx
  801acc:	7e 22                	jle    801af0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ace:	ff 75 14             	pushl  0x14(%ebp)
  801ad1:	ff 75 10             	pushl  0x10(%ebp)
  801ad4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	68 ec 15 80 00       	push   $0x8015ec
  801add:	e8 44 fb ff ff       	call   801626 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	83 c4 10             	add    $0x10,%esp
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    
		return -E_INVAL;
  801af0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801af5:	eb f7                	jmp    801aee <vsnprintf+0x45>

00801af7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b00:	50                   	push   %eax
  801b01:	ff 75 10             	pushl  0x10(%ebp)
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	ff 75 08             	pushl  0x8(%ebp)
  801b0a:	e8 9a ff ff ff       	call   801aa9 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	8b 75 08             	mov    0x8(%ebp),%esi
  801b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b26:	0f 44 c2             	cmove  %edx,%eax
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	50                   	push   %eax
  801b2d:	e8 f2 eb ff ff       	call   800724 <sys_ipc_recv>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 2b                	js     801b64 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801b39:	85 f6                	test   %esi,%esi
  801b3b:	74 0a                	je     801b47 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801b3d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b42:	8b 40 74             	mov    0x74(%eax),%eax
  801b45:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801b47:	85 db                	test   %ebx,%ebx
  801b49:	74 0a                	je     801b55 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801b4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b50:	8b 40 78             	mov    0x78(%eax),%eax
  801b53:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801b55:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    
        *from_env_store = 0;
  801b64:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801b6a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801b70:	eb eb                	jmp    801b5d <ipc_recv+0x4c>

00801b72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801b84:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801b86:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b8b:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801b8e:	ff 75 14             	pushl  0x14(%ebp)
  801b91:	53                   	push   %ebx
  801b92:	56                   	push   %esi
  801b93:	57                   	push   %edi
  801b94:	e8 68 eb ff ff       	call   800701 <sys_ipc_try_send>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	74 17                	je     801bb7 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801ba0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba3:	74 e9                	je     801b8e <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801ba5:	50                   	push   %eax
  801ba6:	68 00 23 80 00       	push   $0x802300
  801bab:	6a 3e                	push   $0x3e
  801bad:	68 12 23 80 00       	push   $0x802312
  801bb2:	e8 97 f8 ff ff       	call   80144e <_panic>
        }
    }
}
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bcd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd3:	8b 52 50             	mov    0x50(%edx),%edx
  801bd6:	39 ca                	cmp    %ecx,%edx
  801bd8:	74 11                	je     801beb <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bda:	83 c0 01             	add    $0x1,%eax
  801bdd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be2:	75 e6                	jne    801bca <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
  801be9:	eb 0b                	jmp    801bf6 <ipc_find_env+0x37>
			return envs[i].env_id;
  801beb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf3:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfe:	89 d0                	mov    %edx,%eax
  801c00:	c1 e8 16             	shr    $0x16,%eax
  801c03:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c0f:	f6 c1 01             	test   $0x1,%cl
  801c12:	74 1d                	je     801c31 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c14:	c1 ea 0c             	shr    $0xc,%edx
  801c17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c1e:	f6 c2 01             	test   $0x1,%dl
  801c21:	74 0e                	je     801c31 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c23:	c1 ea 0c             	shr    $0xc,%edx
  801c26:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c2d:	ef 
  801c2e:	0f b7 c0             	movzwl %ax,%eax
}
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    
  801c33:	66 90                	xchg   %ax,%ax
  801c35:	66 90                	xchg   %ax,%ax
  801c37:	66 90                	xchg   %ax,%ax
  801c39:	66 90                	xchg   %ax,%ax
  801c3b:	66 90                	xchg   %ax,%ax
  801c3d:	66 90                	xchg   %ax,%ax
  801c3f:	90                   	nop

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c57:	85 d2                	test   %edx,%edx
  801c59:	75 35                	jne    801c90 <__udivdi3+0x50>
  801c5b:	39 f3                	cmp    %esi,%ebx
  801c5d:	0f 87 bd 00 00 00    	ja     801d20 <__udivdi3+0xe0>
  801c63:	85 db                	test   %ebx,%ebx
  801c65:	89 d9                	mov    %ebx,%ecx
  801c67:	75 0b                	jne    801c74 <__udivdi3+0x34>
  801c69:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f3                	div    %ebx
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	31 d2                	xor    %edx,%edx
  801c76:	89 f0                	mov    %esi,%eax
  801c78:	f7 f1                	div    %ecx
  801c7a:	89 c6                	mov    %eax,%esi
  801c7c:	89 e8                	mov    %ebp,%eax
  801c7e:	89 f7                	mov    %esi,%edi
  801c80:	f7 f1                	div    %ecx
  801c82:	89 fa                	mov    %edi,%edx
  801c84:	83 c4 1c             	add    $0x1c,%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5f                   	pop    %edi
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    
  801c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 f2                	cmp    %esi,%edx
  801c92:	77 7c                	ja     801d10 <__udivdi3+0xd0>
  801c94:	0f bd fa             	bsr    %edx,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0xf8>
  801ca0:	89 f9                	mov    %edi,%ecx
  801ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ca7:	29 f8                	sub    %edi,%eax
  801ca9:	d3 e2                	shl    %cl,%edx
  801cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	89 da                	mov    %ebx,%edx
  801cb3:	d3 ea                	shr    %cl,%edx
  801cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cb9:	09 d1                	or     %edx,%ecx
  801cbb:	89 f2                	mov    %esi,%edx
  801cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e3                	shl    %cl,%ebx
  801cc5:	89 c1                	mov    %eax,%ecx
  801cc7:	d3 ea                	shr    %cl,%edx
  801cc9:	89 f9                	mov    %edi,%ecx
  801ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ccf:	d3 e6                	shl    %cl,%esi
  801cd1:	89 eb                	mov    %ebp,%ebx
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	d3 eb                	shr    %cl,%ebx
  801cd7:	09 de                	or     %ebx,%esi
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	f7 74 24 08          	divl   0x8(%esp)
  801cdf:	89 d6                	mov    %edx,%esi
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	f7 64 24 0c          	mull   0xc(%esp)
  801ce7:	39 d6                	cmp    %edx,%esi
  801ce9:	72 0c                	jb     801cf7 <__udivdi3+0xb7>
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e5                	shl    %cl,%ebp
  801cef:	39 c5                	cmp    %eax,%ebp
  801cf1:	73 5d                	jae    801d50 <__udivdi3+0x110>
  801cf3:	39 d6                	cmp    %edx,%esi
  801cf5:	75 59                	jne    801d50 <__udivdi3+0x110>
  801cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cfa:	31 ff                	xor    %edi,%edi
  801cfc:	89 fa                	mov    %edi,%edx
  801cfe:	83 c4 1c             	add    $0x1c,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    
  801d06:	8d 76 00             	lea    0x0(%esi),%esi
  801d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d10:	31 ff                	xor    %edi,%edi
  801d12:	31 c0                	xor    %eax,%eax
  801d14:	89 fa                	mov    %edi,%edx
  801d16:	83 c4 1c             	add    $0x1c,%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    
  801d1e:	66 90                	xchg   %ax,%ax
  801d20:	31 ff                	xor    %edi,%edi
  801d22:	89 e8                	mov    %ebp,%eax
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	f7 f3                	div    %ebx
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	72 06                	jb     801d42 <__udivdi3+0x102>
  801d3c:	31 c0                	xor    %eax,%eax
  801d3e:	39 eb                	cmp    %ebp,%ebx
  801d40:	77 d2                	ja     801d14 <__udivdi3+0xd4>
  801d42:	b8 01 00 00 00       	mov    $0x1,%eax
  801d47:	eb cb                	jmp    801d14 <__udivdi3+0xd4>
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	31 ff                	xor    %edi,%edi
  801d54:	eb be                	jmp    801d14 <__udivdi3+0xd4>
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 ed                	test   %ebp,%ebp
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	89 da                	mov    %ebx,%edx
  801d7d:	75 19                	jne    801d98 <__umoddi3+0x38>
  801d7f:	39 df                	cmp    %ebx,%edi
  801d81:	0f 86 b1 00 00 00    	jbe    801e38 <__umoddi3+0xd8>
  801d87:	f7 f7                	div    %edi
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	39 dd                	cmp    %ebx,%ebp
  801d9a:	77 f1                	ja     801d8d <__umoddi3+0x2d>
  801d9c:	0f bd cd             	bsr    %ebp,%ecx
  801d9f:	83 f1 1f             	xor    $0x1f,%ecx
  801da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801da6:	0f 84 b4 00 00 00    	je     801e60 <__umoddi3+0x100>
  801dac:	b8 20 00 00 00       	mov    $0x20,%eax
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801db7:	29 c2                	sub    %eax,%edx
  801db9:	89 c1                	mov    %eax,%ecx
  801dbb:	89 f8                	mov    %edi,%eax
  801dbd:	d3 e5                	shl    %cl,%ebp
  801dbf:	89 d1                	mov    %edx,%ecx
  801dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dc5:	d3 e8                	shr    %cl,%eax
  801dc7:	09 c5                	or     %eax,%ebp
  801dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dcd:	89 c1                	mov    %eax,%ecx
  801dcf:	d3 e7                	shl    %cl,%edi
  801dd1:	89 d1                	mov    %edx,%ecx
  801dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dd7:	89 df                	mov    %ebx,%edi
  801dd9:	d3 ef                	shr    %cl,%edi
  801ddb:	89 c1                	mov    %eax,%ecx
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	d3 e3                	shl    %cl,%ebx
  801de1:	89 d1                	mov    %edx,%ecx
  801de3:	89 fa                	mov    %edi,%edx
  801de5:	d3 e8                	shr    %cl,%eax
  801de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dec:	09 d8                	or     %ebx,%eax
  801dee:	f7 f5                	div    %ebp
  801df0:	d3 e6                	shl    %cl,%esi
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	f7 64 24 08          	mull   0x8(%esp)
  801df8:	39 d1                	cmp    %edx,%ecx
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	89 d7                	mov    %edx,%edi
  801dfe:	72 06                	jb     801e06 <__umoddi3+0xa6>
  801e00:	75 0e                	jne    801e10 <__umoddi3+0xb0>
  801e02:	39 c6                	cmp    %eax,%esi
  801e04:	73 0a                	jae    801e10 <__umoddi3+0xb0>
  801e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e0a:	19 ea                	sbb    %ebp,%edx
  801e0c:	89 d7                	mov    %edx,%edi
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	89 ca                	mov    %ecx,%edx
  801e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e17:	29 de                	sub    %ebx,%esi
  801e19:	19 fa                	sbb    %edi,%edx
  801e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e1f:	89 d0                	mov    %edx,%eax
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 d9                	mov    %ebx,%ecx
  801e25:	d3 ee                	shr    %cl,%esi
  801e27:	d3 ea                	shr    %cl,%edx
  801e29:	09 f0                	or     %esi,%eax
  801e2b:	83 c4 1c             	add    $0x1c,%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5f                   	pop    %edi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    
  801e33:	90                   	nop
  801e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e38:	85 ff                	test   %edi,%edi
  801e3a:	89 f9                	mov    %edi,%ecx
  801e3c:	75 0b                	jne    801e49 <__umoddi3+0xe9>
  801e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f7                	div    %edi
  801e47:	89 c1                	mov    %eax,%ecx
  801e49:	89 d8                	mov    %ebx,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f1                	div    %ecx
  801e4f:	89 f0                	mov    %esi,%eax
  801e51:	f7 f1                	div    %ecx
  801e53:	e9 31 ff ff ff       	jmp    801d89 <__umoddi3+0x29>
  801e58:	90                   	nop
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	39 dd                	cmp    %ebx,%ebp
  801e62:	72 08                	jb     801e6c <__umoddi3+0x10c>
  801e64:	39 f7                	cmp    %esi,%edi
  801e66:	0f 87 21 ff ff ff    	ja     801d8d <__umoddi3+0x2d>
  801e6c:	89 da                	mov    %ebx,%edx
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	29 f8                	sub    %edi,%eax
  801e72:	19 ea                	sbb    %ebp,%edx
  801e74:	e9 14 ff ff ff       	jmp    801d8d <__umoddi3+0x2d>
