
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 92 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 f8 1d 80 00       	push   $0x801df8
  800120:	6a 23                	push   $0x23
  800122:	68 15 1e 80 00       	push   $0x801e15
  800127:	e8 18 0f 00 00       	call   801044 <_panic>

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7f 08                	jg     800196 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 f8 1d 80 00       	push   $0x801df8
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 15 1e 80 00       	push   $0x801e15
  8001a8:	e8 97 0e 00 00       	call   801044 <_panic>

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7f 08                	jg     8001d8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 f8 1d 80 00       	push   $0x801df8
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 15 1e 80 00       	push   $0x801e15
  8001ea:	e8 55 0e 00 00       	call   801044 <_panic>

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7f 08                	jg     80021a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 f8 1d 80 00       	push   $0x801df8
  800225:	6a 23                	push   $0x23
  800227:	68 15 1e 80 00       	push   $0x801e15
  80022c:	e8 13 0e 00 00       	call   801044 <_panic>

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7f 08                	jg     80025c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 f8 1d 80 00       	push   $0x801df8
  800267:	6a 23                	push   $0x23
  800269:	68 15 1e 80 00       	push   $0x801e15
  80026e:	e8 d1 0d 00 00       	call   801044 <_panic>

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7f 08                	jg     80029e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 f8 1d 80 00       	push   $0x801df8
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 15 1e 80 00       	push   $0x801e15
  8002b0:	e8 8f 0d 00 00       	call   801044 <_panic>

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7f 08                	jg     8002e0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	50                   	push   %eax
  8002e4:	6a 0a                	push   $0xa
  8002e6:	68 f8 1d 80 00       	push   $0x801df8
  8002eb:	6a 23                	push   $0x23
  8002ed:	68 15 1e 80 00       	push   $0x801e15
  8002f2:	e8 4d 0d 00 00       	call   801044 <_panic>

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 0c 00 00 00       	mov    $0xc,%eax
  800308:	be 00 00 00 00       	mov    $0x0,%esi
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7f 08                	jg     800344 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 0d                	push   $0xd
  80034a:	68 f8 1d 80 00       	push   $0x801df8
  80034f:	6a 23                	push   $0x23
  800351:	68 15 1e 80 00       	push   $0x801e15
  800356:	e8 e9 0c 00 00       	call   801044 <_panic>

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 2a                	je     8003c8 <fd_alloc+0x46>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	74 19                	je     8003c8 <fd_alloc+0x46>
  8003af:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b9:	75 d2                	jne    80038d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c6:	eb 07                	jmp    8003cf <fd_alloc+0x4d>
			*fd_store = fd;
  8003c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f7                	jmp    800410 <fd_lookup+0x3f>
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb f0                	jmp    800410 <fd_lookup+0x3f>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800425:	eb e9                	jmp    800410 <fd_lookup+0x3f>

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	74 33                	je     800471 <dev_lookup+0x4a>
  80043e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	75 f3                	jne    80043a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800447:	a1 04 40 80 00       	mov    0x804004,%eax
  80044c:	8b 40 48             	mov    0x48(%eax),%eax
  80044f:	83 ec 04             	sub    $0x4,%esp
  800452:	51                   	push   %ecx
  800453:	50                   	push   %eax
  800454:	68 24 1e 80 00       	push   $0x801e24
  800459:	e8 c1 0c 00 00       	call   80111f <cprintf>
	*dev = 0;
  80045e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800461:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    
			*dev = devtab[i];
  800471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb f2                	jmp    80046f <dev_lookup+0x48>

0080047d <fd_close>:
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 1c             	sub    $0x1c,%esp
  800486:	8b 75 08             	mov    0x8(%ebp),%esi
  800489:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800490:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800496:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800499:	50                   	push   %eax
  80049a:	e8 32 ff ff ff       	call   8003d1 <fd_lookup>
  80049f:	89 c3                	mov    %eax,%ebx
  8004a1:	83 c4 08             	add    $0x8,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	78 05                	js     8004ad <fd_close+0x30>
	    || fd != fd2)
  8004a8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004ab:	74 16                	je     8004c3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004ad:	89 f8                	mov    %edi,%eax
  8004af:	84 c0                	test   %al,%al
  8004b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b6:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b9:	89 d8                	mov    %ebx,%eax
  8004bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5e                   	pop    %esi
  8004c0:	5f                   	pop    %edi
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff 36                	pushl  (%esi)
  8004cc:	e8 56 ff ff ff       	call   800427 <dev_lookup>
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	78 15                	js     8004ef <fd_close+0x72>
		if (dev->dev_close)
  8004da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dd:	8b 40 10             	mov    0x10(%eax),%eax
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 1b                	je     8004ff <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 f5 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb ba                	jmp    8004b9 <fd_close+0x3c>
			r = 0;
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800504:	eb e9                	jmp    8004ef <fd_close+0x72>

00800506 <close>:

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 b9 fe ff ff       	call   8003d1 <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 51 ff ff ff       	call   80047d <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800562:	50                   	push   %eax
  800563:	ff 75 08             	pushl  0x8(%ebp)
  800566:	e8 66 fe ff ff       	call   8003d1 <fd_lookup>
  80056b:	89 c3                	mov    %eax,%ebx
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 81 00 00 00    	js     8005f9 <dup+0xa3>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	e8 83 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800583:	8b 75 0c             	mov    0xc(%ebp),%esi
  800586:	c1 e6 0c             	shl    $0xc,%esi
  800589:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058f:	83 c4 04             	add    $0x4,%esp
  800592:	ff 75 e4             	pushl  -0x1c(%ebp)
  800595:	e8 d1 fd ff ff       	call   80036b <fd2data>
  80059a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80059c:	89 34 24             	mov    %esi,(%esp)
  80059f:	e8 c7 fd ff ff       	call   80036b <fd2data>
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 16             	shr    $0x16,%eax
  8005ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b5:	a8 01                	test   $0x1,%al
  8005b7:	74 11                	je     8005ca <dup+0x74>
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c5:	f6 c2 01             	test   $0x1,%dl
  8005c8:	75 39                	jne    800603 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cd:	89 d0                	mov    %edx,%eax
  8005cf:	c1 e8 0c             	shr    $0xc,%eax
  8005d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e1:	50                   	push   %eax
  8005e2:	56                   	push   %esi
  8005e3:	6a 00                	push   $0x0
  8005e5:	52                   	push   %edx
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 c0 fb ff ff       	call   8001ad <sys_page_map>
  8005ed:	89 c3                	mov    %eax,%ebx
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	78 31                	js     800627 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f9:	89 d8                	mov    %ebx,%eax
  8005fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5e                   	pop    %esi
  800600:	5f                   	pop    %edi
  800601:	5d                   	pop    %ebp
  800602:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	57                   	push   %edi
  800614:	6a 00                	push   $0x0
  800616:	53                   	push   %ebx
  800617:	6a 00                	push   $0x0
  800619:	e8 8f fb ff ff       	call   8001ad <sys_page_map>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	83 c4 20             	add    $0x20,%esp
  800623:	85 c0                	test   %eax,%eax
  800625:	79 a3                	jns    8005ca <dup+0x74>
	sys_page_unmap(0, newfd);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	56                   	push   %esi
  80062b:	6a 00                	push   $0x0
  80062d:	e8 bd fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	6a 00                	push   $0x0
  800638:	e8 b2 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb b7                	jmp    8005f9 <dup+0xa3>

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 7b fd ff ff       	call   8003d1 <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	85 c0                	test   %eax,%eax
  80065b:	78 3f                	js     80069c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800667:	ff 30                	pushl  (%eax)
  800669:	e8 b9 fd ff ff       	call   800427 <dev_lookup>
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	85 c0                	test   %eax,%eax
  800673:	78 27                	js     80069c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800675:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800678:	8b 42 08             	mov    0x8(%edx),%eax
  80067b:	83 e0 03             	and    $0x3,%eax
  80067e:	83 f8 01             	cmp    $0x1,%eax
  800681:	74 1e                	je     8006a1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800686:	8b 40 08             	mov    0x8(%eax),%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 35                	je     8006c2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	ff 75 10             	pushl  0x10(%ebp)
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	52                   	push   %edx
  800697:	ff d0                	call   *%eax
  800699:	83 c4 10             	add    $0x10,%esp
}
  80069c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a6:	8b 40 48             	mov    0x48(%eax),%eax
  8006a9:	83 ec 04             	sub    $0x4,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	50                   	push   %eax
  8006ae:	68 65 1e 80 00       	push   $0x801e65
  8006b3:	e8 67 0a 00 00       	call   80111f <cprintf>
		return -E_INVAL;
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c0:	eb da                	jmp    80069c <read+0x5a>
		return -E_NOT_SUPP;
  8006c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c7:	eb d3                	jmp    80069c <read+0x5a>

008006c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	57                   	push   %edi
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	83 ec 0c             	sub    $0xc,%esp
  8006d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dd:	39 f3                	cmp    %esi,%ebx
  8006df:	73 25                	jae    800706 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	29 d8                	sub    %ebx,%eax
  8006e8:	50                   	push   %eax
  8006e9:	89 d8                	mov    %ebx,%eax
  8006eb:	03 45 0c             	add    0xc(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	57                   	push   %edi
  8006f0:	e8 4d ff ff ff       	call   800642 <read>
		if (m < 0)
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 08                	js     800704 <readn+0x3b>
			return m;
		if (m == 0)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 06                	je     800706 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800700:	01 c3                	add    %eax,%ebx
  800702:	eb d9                	jmp    8006dd <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800704:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800706:	89 d8                	mov    %ebx,%eax
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	83 ec 14             	sub    $0x14,%esp
  800717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	53                   	push   %ebx
  80071f:	e8 ad fc ff ff       	call   8003d1 <fd_lookup>
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	85 c0                	test   %eax,%eax
  800729:	78 3a                	js     800765 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	ff 30                	pushl  (%eax)
  800737:	e8 eb fc ff ff       	call   800427 <dev_lookup>
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 22                	js     800765 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074a:	74 1e                	je     80076a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80074c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074f:	8b 52 0c             	mov    0xc(%edx),%edx
  800752:	85 d2                	test   %edx,%edx
  800754:	74 35                	je     80078b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	50                   	push   %eax
  800760:	ff d2                	call   *%edx
  800762:	83 c4 10             	add    $0x10,%esp
}
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 04 40 80 00       	mov    0x804004,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 81 1e 80 00       	push   $0x801e81
  80077c:	e8 9e 09 00 00       	call   80111f <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb da                	jmp    800765 <write+0x55>
		return -E_NOT_SUPP;
  80078b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800790:	eb d3                	jmp    800765 <write+0x55>

00800792 <seek>:

int
seek(int fdnum, off_t offset)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 2d fc ff ff       	call   8003d1 <fd_lookup>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 14             	sub    $0x14,%esp
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	53                   	push   %ebx
  8007ca:	e8 02 fc ff ff       	call   8003d1 <fd_lookup>
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	78 37                	js     80080d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	ff 30                	pushl  (%eax)
  8007e2:	e8 40 fc ff ff       	call   800427 <dev_lookup>
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 1f                	js     80080d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f5:	74 1b                	je     800812 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fa:	8b 52 18             	mov    0x18(%edx),%edx
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 32                	je     800833 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	50                   	push   %eax
  800808:	ff d2                	call   *%edx
  80080a:	83 c4 10             	add    $0x10,%esp
}
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    
			thisenv->env_id, fdnum);
  800812:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	83 ec 04             	sub    $0x4,%esp
  80081d:	53                   	push   %ebx
  80081e:	50                   	push   %eax
  80081f:	68 44 1e 80 00       	push   $0x801e44
  800824:	e8 f6 08 00 00       	call   80111f <cprintf>
		return -E_INVAL;
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800831:	eb da                	jmp    80080d <ftruncate+0x52>
		return -E_NOT_SUPP;
  800833:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800838:	eb d3                	jmp    80080d <ftruncate+0x52>

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 81 fb ff ff       	call   8003d1 <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 4b                	js     8008a2 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	50                   	push   %eax
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	ff 30                	pushl  (%eax)
  800863:	e8 bf fb ff ff       	call   800427 <dev_lookup>
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 33                	js     8008a2 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800876:	74 2f                	je     8008a7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800878:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800882:	00 00 00 
	stat->st_isdir = 0;
  800885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088c:	00 00 00 
	stat->st_dev = dev;
  80088f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	ff 75 f0             	pushl  -0x10(%ebp)
  80089c:	ff 50 14             	call   *0x14(%eax)
  80089f:	83 c4 10             	add    $0x10,%esp
}
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ac:	eb f4                	jmp    8008a2 <fstat+0x68>

008008ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	6a 00                	push   $0x0
  8008b8:	ff 75 08             	pushl  0x8(%ebp)
  8008bb:	e8 e7 01 00 00       	call   800aa7 <open>
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 1b                	js     8008e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	50                   	push   %eax
  8008d0:	e8 65 ff ff ff       	call   80083a <fstat>
  8008d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	e8 27 fc ff ff       	call   800506 <close>
	return r;
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	89 f3                	mov    %esi,%ebx
}
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	89 c6                	mov    %eax,%esi
  8008f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008fd:	74 27                	je     800926 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ff:	6a 07                	push   $0x7
  800901:	68 00 50 80 00       	push   $0x805000
  800906:	56                   	push   %esi
  800907:	ff 35 00 40 80 00    	pushl  0x804000
  80090d:	e8 ca 11 00 00       	call   801adc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800912:	83 c4 0c             	add    $0xc,%esp
  800915:	6a 00                	push   $0x0
  800917:	53                   	push   %ebx
  800918:	6a 00                	push   $0x0
  80091a:	e8 5c 11 00 00       	call   801a7b <ipc_recv>
}
  80091f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 f9 11 00 00       	call   801b29 <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	eb c5                	jmp    8008ff <fsipc+0x12>

0080093a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 40 0c             	mov    0xc(%eax),%eax
  800946:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
  800958:	b8 02 00 00 00       	mov    $0x2,%eax
  80095d:	e8 8b ff ff ff       	call   8008ed <fsipc>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <devfile_flush>:
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	b8 06 00 00 00       	mov    $0x6,%eax
  80097f:	e8 69 ff ff ff       	call   8008ed <fsipc>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <devfile_stat>:
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 04             	sub    $0x4,%esp
  80098d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a5:	e8 43 ff ff ff       	call   8008ed <fsipc>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 2c                	js     8009da <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	68 00 50 80 00       	push   $0x805000
  8009b6:	53                   	push   %ebx
  8009b7:	e8 82 0d 00 00       	call   80173e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bc:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c7:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <devfile_write>:
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 0c             	sub    $0xc,%esp
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009e8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009ed:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f2:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fb:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a01:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a06:	50                   	push   %eax
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	68 08 50 80 00       	push   $0x805008
  800a0f:	e8 b8 0e 00 00       	call   8018cc <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
  800a19:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1e:	e8 ca fe ff ff       	call   8008ed <fsipc>
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <devfile_read>:
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 40 0c             	mov    0xc(%eax),%eax
  800a33:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a38:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a43:	b8 03 00 00 00       	mov    $0x3,%eax
  800a48:	e8 a0 fe ff ff       	call   8008ed <fsipc>
  800a4d:	89 c3                	mov    %eax,%ebx
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	78 1f                	js     800a72 <devfile_read+0x4d>
	assert(r <= n);
  800a53:	39 f0                	cmp    %esi,%eax
  800a55:	77 24                	ja     800a7b <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a57:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5c:	7f 33                	jg     800a91 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a5e:	83 ec 04             	sub    $0x4,%esp
  800a61:	50                   	push   %eax
  800a62:	68 00 50 80 00       	push   $0x805000
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	e8 5d 0e 00 00       	call   8018cc <memmove>
	return r;
  800a6f:	83 c4 10             	add    $0x10,%esp
}
  800a72:	89 d8                	mov    %ebx,%eax
  800a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    
	assert(r <= n);
  800a7b:	68 b0 1e 80 00       	push   $0x801eb0
  800a80:	68 b7 1e 80 00       	push   $0x801eb7
  800a85:	6a 7d                	push   $0x7d
  800a87:	68 cc 1e 80 00       	push   $0x801ecc
  800a8c:	e8 b3 05 00 00       	call   801044 <_panic>
	assert(r <= PGSIZE);
  800a91:	68 d7 1e 80 00       	push   $0x801ed7
  800a96:	68 b7 1e 80 00       	push   $0x801eb7
  800a9b:	6a 7e                	push   $0x7e
  800a9d:	68 cc 1e 80 00       	push   $0x801ecc
  800aa2:	e8 9d 05 00 00       	call   801044 <_panic>

00800aa7 <open>:
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 1c             	sub    $0x1c,%esp
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab2:	56                   	push   %esi
  800ab3:	e8 4f 0c 00 00       	call   801707 <strlen>
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac0:	0f 8f 96 00 00 00    	jg     800b5c <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ac6:	83 ec 0c             	sub    $0xc,%esp
  800ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acc:	50                   	push   %eax
  800acd:	e8 b0 f8 ff ff       	call   800382 <fd_alloc>
  800ad2:	89 c3                	mov    %eax,%ebx
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	78 66                	js     800b41 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800adb:	83 ec 08             	sub    $0x8,%esp
  800ade:	56                   	push   %esi
  800adf:	68 00 50 80 00       	push   $0x805000
  800ae4:	e8 55 0c 00 00       	call   80173e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af4:	b8 01 00 00 00       	mov    $0x1,%eax
  800af9:	e8 ef fd ff ff       	call   8008ed <fsipc>
  800afe:	89 c3                	mov    %eax,%ebx
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	85 c0                	test   %eax,%eax
  800b05:	78 43                	js     800b4a <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0d:	e8 49 f8 ff ff       	call   80035b <fd2num>
  800b12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b15:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b1b:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b1e:	83 c4 08             	add    $0x8,%esp
  800b21:	50                   	push   %eax
  800b22:	52                   	push   %edx
  800b23:	ff 32                	pushl  (%edx)
  800b25:	56                   	push   %esi
  800b26:	51                   	push   %ecx
  800b27:	68 e4 1e 80 00       	push   $0x801ee4
  800b2c:	e8 ee 05 00 00       	call   80111f <cprintf>
	return fd2num(fd);
  800b31:	83 c4 14             	add    $0x14,%esp
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 1f f8 ff ff       	call   80035b <fd2num>
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	83 c4 10             	add    $0x10,%esp
}
  800b41:	89 d8                	mov    %ebx,%eax
  800b43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
		fd_close(fd, 0);
  800b4a:	83 ec 08             	sub    $0x8,%esp
  800b4d:	6a 00                	push   $0x0
  800b4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b52:	e8 26 f9 ff ff       	call   80047d <fd_close>
		return r;
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	eb e5                	jmp    800b41 <open+0x9a>
		return -E_BAD_PATH;
  800b5c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b61:	eb de                	jmp    800b41 <open+0x9a>

00800b63 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b73:	e8 75 fd ff ff       	call   8008ed <fsipc>
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 de f7 ff ff       	call   80036b <fd2data>
  800b8d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8f:	83 c4 08             	add    $0x8,%esp
  800b92:	68 23 1f 80 00       	push   $0x801f23
  800b97:	53                   	push   %ebx
  800b98:	e8 a1 0b 00 00       	call   80173e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9d:	8b 46 04             	mov    0x4(%esi),%eax
  800ba0:	2b 06                	sub    (%esi),%eax
  800ba2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800baf:	00 00 00 
	stat->st_dev = &devpipe;
  800bb2:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bb9:	30 80 00 
	return 0;
}
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd2:	53                   	push   %ebx
  800bd3:	6a 00                	push   $0x0
  800bd5:	e8 15 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	e8 89 f7 ff ff       	call   80036b <fd2data>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 00                	push   $0x0
  800be8:	e8 02 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <_pipeisclosed>:
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	89 c7                	mov    %eax,%edi
  800bfd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bff:	a1 04 40 80 00       	mov    0x804004,%eax
  800c04:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	57                   	push   %edi
  800c0b:	e8 52 0f 00 00       	call   801b62 <pageref>
  800c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c13:	89 34 24             	mov    %esi,(%esp)
  800c16:	e8 47 0f 00 00       	call   801b62 <pageref>
		nn = thisenv->env_runs;
  800c1b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c21:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	39 cb                	cmp    %ecx,%ebx
  800c29:	74 1b                	je     800c46 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c2b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2e:	75 cf                	jne    800bff <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c30:	8b 42 58             	mov    0x58(%edx),%eax
  800c33:	6a 01                	push   $0x1
  800c35:	50                   	push   %eax
  800c36:	53                   	push   %ebx
  800c37:	68 2a 1f 80 00       	push   $0x801f2a
  800c3c:	e8 de 04 00 00       	call   80111f <cprintf>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	eb b9                	jmp    800bff <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c46:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c49:	0f 94 c0             	sete   %al
  800c4c:	0f b6 c0             	movzbl %al,%eax
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <devpipe_write>:
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 28             	sub    $0x28,%esp
  800c60:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c63:	56                   	push   %esi
  800c64:	e8 02 f7 ff ff       	call   80036b <fd2data>
  800c69:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c76:	74 4f                	je     800cc7 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c78:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7b:	8b 0b                	mov    (%ebx),%ecx
  800c7d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	72 14                	jb     800c98 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c84:	89 da                	mov    %ebx,%edx
  800c86:	89 f0                	mov    %esi,%eax
  800c88:	e8 65 ff ff ff       	call   800bf2 <_pipeisclosed>
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	75 3a                	jne    800ccb <devpipe_write+0x74>
			sys_yield();
  800c91:	e8 b5 f4 ff ff       	call   80014b <sys_yield>
  800c96:	eb e0                	jmp    800c78 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	c1 fa 1f             	sar    $0x1f,%edx
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cac:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800caf:	83 e2 1f             	and    $0x1f,%edx
  800cb2:	29 ca                	sub    %ecx,%edx
  800cb4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cc2:	83 c7 01             	add    $0x1,%edi
  800cc5:	eb ac                	jmp    800c73 <devpipe_write+0x1c>
	return i;
  800cc7:	89 f8                	mov    %edi,%eax
  800cc9:	eb 05                	jmp    800cd0 <devpipe_write+0x79>
				return 0;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <devpipe_read>:
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 18             	sub    $0x18,%esp
  800ce1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ce4:	57                   	push   %edi
  800ce5:	e8 81 f6 ff ff       	call   80036b <fd2data>
  800cea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cf7:	74 47                	je     800d40 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cf9:	8b 03                	mov    (%ebx),%eax
  800cfb:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cfe:	75 22                	jne    800d22 <devpipe_read+0x4a>
			if (i > 0)
  800d00:	85 f6                	test   %esi,%esi
  800d02:	75 14                	jne    800d18 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800d04:	89 da                	mov    %ebx,%edx
  800d06:	89 f8                	mov    %edi,%eax
  800d08:	e8 e5 fe ff ff       	call   800bf2 <_pipeisclosed>
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	75 33                	jne    800d44 <devpipe_read+0x6c>
			sys_yield();
  800d11:	e8 35 f4 ff ff       	call   80014b <sys_yield>
  800d16:	eb e1                	jmp    800cf9 <devpipe_read+0x21>
				return i;
  800d18:	89 f0                	mov    %esi,%eax
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d22:	99                   	cltd   
  800d23:	c1 ea 1b             	shr    $0x1b,%edx
  800d26:	01 d0                	add    %edx,%eax
  800d28:	83 e0 1f             	and    $0x1f,%eax
  800d2b:	29 d0                	sub    %edx,%eax
  800d2d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d38:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d3b:	83 c6 01             	add    $0x1,%esi
  800d3e:	eb b4                	jmp    800cf4 <devpipe_read+0x1c>
	return i;
  800d40:	89 f0                	mov    %esi,%eax
  800d42:	eb d6                	jmp    800d1a <devpipe_read+0x42>
				return 0;
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
  800d49:	eb cf                	jmp    800d1a <devpipe_read+0x42>

00800d4b <pipe>:
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d56:	50                   	push   %eax
  800d57:	e8 26 f6 ff ff       	call   800382 <fd_alloc>
  800d5c:	89 c3                	mov    %eax,%ebx
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 5b                	js     800dc0 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	68 07 04 00 00       	push   $0x407
  800d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d70:	6a 00                	push   $0x0
  800d72:	e8 f3 f3 ff ff       	call   80016a <sys_page_alloc>
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 40                	js     800dc0 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d86:	50                   	push   %eax
  800d87:	e8 f6 f5 ff ff       	call   800382 <fd_alloc>
  800d8c:	89 c3                	mov    %eax,%ebx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	85 c0                	test   %eax,%eax
  800d93:	78 1b                	js     800db0 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 07 04 00 00       	push   $0x407
  800d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800da0:	6a 00                	push   $0x0
  800da2:	e8 c3 f3 ff ff       	call   80016a <sys_page_alloc>
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	79 19                	jns    800dc9 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	ff 75 f4             	pushl  -0xc(%ebp)
  800db6:	6a 00                	push   $0x0
  800db8:	e8 32 f4 ff ff       	call   8001ef <sys_page_unmap>
  800dbd:	83 c4 10             	add    $0x10,%esp
}
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
	va = fd2data(fd0);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcf:	e8 97 f5 ff ff       	call   80036b <fd2data>
  800dd4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd6:	83 c4 0c             	add    $0xc,%esp
  800dd9:	68 07 04 00 00       	push   $0x407
  800dde:	50                   	push   %eax
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 84 f3 ff ff       	call   80016a <sys_page_alloc>
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	0f 88 8c 00 00 00    	js     800e7f <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f0             	pushl  -0x10(%ebp)
  800df9:	e8 6d f5 ff ff       	call   80036b <fd2data>
  800dfe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e05:	50                   	push   %eax
  800e06:	6a 00                	push   $0x0
  800e08:	56                   	push   %esi
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 9d f3 ff ff       	call   8001ad <sys_page_map>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	83 c4 20             	add    $0x20,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	78 58                	js     800e71 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e31:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	ff 75 f4             	pushl  -0xc(%ebp)
  800e49:	e8 0d f5 ff ff       	call   80035b <fd2num>
  800e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e53:	83 c4 04             	add    $0x4,%esp
  800e56:	ff 75 f0             	pushl  -0x10(%ebp)
  800e59:	e8 fd f4 ff ff       	call   80035b <fd2num>
  800e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6c:	e9 4f ff ff ff       	jmp    800dc0 <pipe+0x75>
	sys_page_unmap(0, va);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	56                   	push   %esi
  800e75:	6a 00                	push   $0x0
  800e77:	e8 73 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	ff 75 f0             	pushl  -0x10(%ebp)
  800e85:	6a 00                	push   $0x0
  800e87:	e8 63 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	e9 1c ff ff ff       	jmp    800db0 <pipe+0x65>

00800e94 <pipeisclosed>:
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9d:	50                   	push   %eax
  800e9e:	ff 75 08             	pushl  0x8(%ebp)
  800ea1:	e8 2b f5 ff ff       	call   8003d1 <fd_lookup>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	78 18                	js     800ec5 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb3:	e8 b3 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebd:	e8 30 fd ff ff       	call   800bf2 <_pipeisclosed>
  800ec2:	83 c4 10             	add    $0x10,%esp
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed7:	68 42 1f 80 00       	push   $0x801f42
  800edc:	ff 75 0c             	pushl  0xc(%ebp)
  800edf:	e8 5a 08 00 00       	call   80173e <strcpy>
	return 0;
}
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <devcons_write>:
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ef7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f02:	eb 2f                	jmp    800f33 <devcons_write+0x48>
		m = n - tot;
  800f04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f07:	29 f3                	sub    %esi,%ebx
  800f09:	83 fb 7f             	cmp    $0x7f,%ebx
  800f0c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f11:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	53                   	push   %ebx
  800f18:	89 f0                	mov    %esi,%eax
  800f1a:	03 45 0c             	add    0xc(%ebp),%eax
  800f1d:	50                   	push   %eax
  800f1e:	57                   	push   %edi
  800f1f:	e8 a8 09 00 00       	call   8018cc <memmove>
		sys_cputs(buf, m);
  800f24:	83 c4 08             	add    $0x8,%esp
  800f27:	53                   	push   %ebx
  800f28:	57                   	push   %edi
  800f29:	e8 80 f1 ff ff       	call   8000ae <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f2e:	01 de                	add    %ebx,%esi
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f36:	72 cc                	jb     800f04 <devcons_write+0x19>
}
  800f38:	89 f0                	mov    %esi,%eax
  800f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <devcons_read>:
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f51:	75 07                	jne    800f5a <devcons_read+0x18>
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
		sys_yield();
  800f55:	e8 f1 f1 ff ff       	call   80014b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f5a:	e8 6d f1 ff ff       	call   8000cc <sys_cgetc>
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	74 f2                	je     800f55 <devcons_read+0x13>
	if (c < 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 ec                	js     800f53 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f67:	83 f8 04             	cmp    $0x4,%eax
  800f6a:	74 0c                	je     800f78 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6f:	88 02                	mov    %al,(%edx)
	return 1;
  800f71:	b8 01 00 00 00       	mov    $0x1,%eax
  800f76:	eb db                	jmp    800f53 <devcons_read+0x11>
		return 0;
  800f78:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7d:	eb d4                	jmp    800f53 <devcons_read+0x11>

00800f7f <cputchar>:
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f8b:	6a 01                	push   $0x1
  800f8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	e8 18 f1 ff ff       	call   8000ae <sys_cputs>
}
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <getchar>:
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fa1:	6a 01                	push   $0x1
  800fa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 94 f6 ff ff       	call   800642 <read>
	if (r < 0)
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 08                	js     800fbd <getchar+0x22>
	if (r < 1)
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	7e 06                	jle    800fbf <getchar+0x24>
	return c;
  800fb9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    
		return -E_EOF;
  800fbf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fc4:	eb f7                	jmp    800fbd <getchar+0x22>

00800fc6 <iscons>:
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 08             	pushl  0x8(%ebp)
  800fd3:	e8 f9 f3 ff ff       	call   8003d1 <fd_lookup>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 11                	js     800ff0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fe8:	39 10                	cmp    %edx,(%eax)
  800fea:	0f 94 c0             	sete   %al
  800fed:	0f b6 c0             	movzbl %al,%eax
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <opencons>:
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 81 f3 ff ff       	call   800382 <fd_alloc>
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 3a                	js     801042 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	68 07 04 00 00       	push   $0x407
  801010:	ff 75 f4             	pushl  -0xc(%ebp)
  801013:	6a 00                	push   $0x0
  801015:	e8 50 f1 ff ff       	call   80016a <sys_page_alloc>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	78 21                	js     801042 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801024:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80102a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	50                   	push   %eax
  80103a:	e8 1c f3 ff ff       	call   80035b <fd2num>
  80103f:	83 c4 10             	add    $0x10,%esp
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801049:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104c:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801052:	e8 d5 f0 ff ff       	call   80012c <sys_getenvid>
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	ff 75 0c             	pushl  0xc(%ebp)
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	56                   	push   %esi
  801061:	50                   	push   %eax
  801062:	68 50 1f 80 00       	push   $0x801f50
  801067:	e8 b3 00 00 00       	call   80111f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106c:	83 c4 18             	add    $0x18,%esp
  80106f:	53                   	push   %ebx
  801070:	ff 75 10             	pushl  0x10(%ebp)
  801073:	e8 56 00 00 00       	call   8010ce <vcprintf>
	cprintf("\n");
  801078:	c7 04 24 3b 1f 80 00 	movl   $0x801f3b,(%esp)
  80107f:	e8 9b 00 00 00       	call   80111f <cprintf>
  801084:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801087:	cc                   	int3   
  801088:	eb fd                	jmp    801087 <_panic+0x43>

0080108a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801094:	8b 13                	mov    (%ebx),%edx
  801096:	8d 42 01             	lea    0x1(%edx),%eax
  801099:	89 03                	mov    %eax,(%ebx)
  80109b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a7:	74 09                	je     8010b2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	68 ff 00 00 00       	push   $0xff
  8010ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bd:	50                   	push   %eax
  8010be:	e8 eb ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	eb db                	jmp    8010a9 <putch+0x1f>

008010ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010de:	00 00 00 
	b.cnt = 0;
  8010e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010eb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	68 8a 10 80 00       	push   $0x80108a
  8010fd:	e8 1a 01 00 00       	call   80121c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801102:	83 c4 08             	add    $0x8,%esp
  801105:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801111:	50                   	push   %eax
  801112:	e8 97 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801117:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801125:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801128:	50                   	push   %eax
  801129:	ff 75 08             	pushl  0x8(%ebp)
  80112c:	e8 9d ff ff ff       	call   8010ce <vcprintf>
	va_end(ap);

	return cnt;
}
  801131:	c9                   	leave  
  801132:	c3                   	ret    

00801133 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 1c             	sub    $0x1c,%esp
  80113c:	89 c7                	mov    %eax,%edi
  80113e:	89 d6                	mov    %edx,%esi
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801149:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801154:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801157:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80115a:	39 d3                	cmp    %edx,%ebx
  80115c:	72 05                	jb     801163 <printnum+0x30>
  80115e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801161:	77 7a                	ja     8011dd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	ff 75 18             	pushl  0x18(%ebp)
  801169:	8b 45 14             	mov    0x14(%ebp),%eax
  80116c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116f:	53                   	push   %ebx
  801170:	ff 75 10             	pushl  0x10(%ebp)
  801173:	83 ec 08             	sub    $0x8,%esp
  801176:	ff 75 e4             	pushl  -0x1c(%ebp)
  801179:	ff 75 e0             	pushl  -0x20(%ebp)
  80117c:	ff 75 dc             	pushl  -0x24(%ebp)
  80117f:	ff 75 d8             	pushl  -0x28(%ebp)
  801182:	e8 19 0a 00 00       	call   801ba0 <__udivdi3>
  801187:	83 c4 18             	add    $0x18,%esp
  80118a:	52                   	push   %edx
  80118b:	50                   	push   %eax
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	89 f8                	mov    %edi,%eax
  801190:	e8 9e ff ff ff       	call   801133 <printnum>
  801195:	83 c4 20             	add    $0x20,%esp
  801198:	eb 13                	jmp    8011ad <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	56                   	push   %esi
  80119e:	ff 75 18             	pushl  0x18(%ebp)
  8011a1:	ff d7                	call   *%edi
  8011a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011a6:	83 eb 01             	sub    $0x1,%ebx
  8011a9:	85 db                	test   %ebx,%ebx
  8011ab:	7f ed                	jg     80119a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	56                   	push   %esi
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c0:	e8 fb 0a 00 00       	call   801cc0 <__umoddi3>
  8011c5:	83 c4 14             	add    $0x14,%esp
  8011c8:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff d7                	call   *%edi
}
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
  8011dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011e0:	eb c4                	jmp    8011a6 <printnum+0x73>

008011e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ec:	8b 10                	mov    (%eax),%edx
  8011ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f1:	73 0a                	jae    8011fd <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f6:	89 08                	mov    %ecx,(%eax)
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	88 02                	mov    %al,(%edx)
}
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <printfmt>:
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801205:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801208:	50                   	push   %eax
  801209:	ff 75 10             	pushl  0x10(%ebp)
  80120c:	ff 75 0c             	pushl  0xc(%ebp)
  80120f:	ff 75 08             	pushl  0x8(%ebp)
  801212:	e8 05 00 00 00       	call   80121c <vprintfmt>
}
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <vprintfmt>:
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	57                   	push   %edi
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	83 ec 2c             	sub    $0x2c,%esp
  801225:	8b 75 08             	mov    0x8(%ebp),%esi
  801228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122e:	e9 c1 03 00 00       	jmp    8015f4 <vprintfmt+0x3d8>
		padc = ' ';
  801233:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801237:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80123e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801245:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80124c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801251:	8d 47 01             	lea    0x1(%edi),%eax
  801254:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801257:	0f b6 17             	movzbl (%edi),%edx
  80125a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80125d:	3c 55                	cmp    $0x55,%al
  80125f:	0f 87 12 04 00 00    	ja     801677 <vprintfmt+0x45b>
  801265:	0f b6 c0             	movzbl %al,%eax
  801268:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801272:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801276:	eb d9                	jmp    801251 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801278:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80127b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80127f:	eb d0                	jmp    801251 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801281:	0f b6 d2             	movzbl %dl,%edx
  801284:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
  80128c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80128f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801292:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801296:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801299:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80129c:	83 f9 09             	cmp    $0x9,%ecx
  80129f:	77 55                	ja     8012f6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8012a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8012a4:	eb e9                	jmp    80128f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8012a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a9:	8b 00                	mov    (%eax),%eax
  8012ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b1:	8d 40 04             	lea    0x4(%eax),%eax
  8012b4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012be:	79 91                	jns    801251 <vprintfmt+0x35>
				width = precision, precision = -1;
  8012c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cd:	eb 82                	jmp    801251 <vprintfmt+0x35>
  8012cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	0f 49 d0             	cmovns %eax,%edx
  8012dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e2:	e9 6a ff ff ff       	jmp    801251 <vprintfmt+0x35>
  8012e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f1:	e9 5b ff ff ff       	jmp    801251 <vprintfmt+0x35>
  8012f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012fc:	eb bc                	jmp    8012ba <vprintfmt+0x9e>
			lflag++;
  8012fe:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801304:	e9 48 ff ff ff       	jmp    801251 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801309:	8b 45 14             	mov    0x14(%ebp),%eax
  80130c:	8d 78 04             	lea    0x4(%eax),%edi
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	53                   	push   %ebx
  801313:	ff 30                	pushl  (%eax)
  801315:	ff d6                	call   *%esi
			break;
  801317:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80131a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80131d:	e9 cf 02 00 00       	jmp    8015f1 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801322:	8b 45 14             	mov    0x14(%ebp),%eax
  801325:	8d 78 04             	lea    0x4(%eax),%edi
  801328:	8b 00                	mov    (%eax),%eax
  80132a:	99                   	cltd   
  80132b:	31 d0                	xor    %edx,%eax
  80132d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80132f:	83 f8 0f             	cmp    $0xf,%eax
  801332:	7f 23                	jg     801357 <vprintfmt+0x13b>
  801334:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80133b:	85 d2                	test   %edx,%edx
  80133d:	74 18                	je     801357 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80133f:	52                   	push   %edx
  801340:	68 c9 1e 80 00       	push   $0x801ec9
  801345:	53                   	push   %ebx
  801346:	56                   	push   %esi
  801347:	e8 b3 fe ff ff       	call   8011ff <printfmt>
  80134c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80134f:	89 7d 14             	mov    %edi,0x14(%ebp)
  801352:	e9 9a 02 00 00       	jmp    8015f1 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801357:	50                   	push   %eax
  801358:	68 8b 1f 80 00       	push   $0x801f8b
  80135d:	53                   	push   %ebx
  80135e:	56                   	push   %esi
  80135f:	e8 9b fe ff ff       	call   8011ff <printfmt>
  801364:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801367:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80136a:	e9 82 02 00 00       	jmp    8015f1 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	83 c0 04             	add    $0x4,%eax
  801375:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801378:	8b 45 14             	mov    0x14(%ebp),%eax
  80137b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80137d:	85 ff                	test   %edi,%edi
  80137f:	b8 84 1f 80 00       	mov    $0x801f84,%eax
  801384:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801387:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80138b:	0f 8e bd 00 00 00    	jle    80144e <vprintfmt+0x232>
  801391:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801395:	75 0e                	jne    8013a5 <vprintfmt+0x189>
  801397:	89 75 08             	mov    %esi,0x8(%ebp)
  80139a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80139d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8013a3:	eb 6d                	jmp    801412 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ab:	57                   	push   %edi
  8013ac:	e8 6e 03 00 00       	call   80171f <strnlen>
  8013b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b4:	29 c1                	sub    %eax,%ecx
  8013b6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013bc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013c3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013c6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c8:	eb 0f                	jmp    8013d9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8013d1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d3:	83 ef 01             	sub    $0x1,%edi
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 ff                	test   %edi,%edi
  8013db:	7f ed                	jg     8013ca <vprintfmt+0x1ae>
  8013dd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013e0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013e3:	85 c9                	test   %ecx,%ecx
  8013e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ea:	0f 49 c1             	cmovns %ecx,%eax
  8013ed:	29 c1                	sub    %eax,%ecx
  8013ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8013f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013f8:	89 cb                	mov    %ecx,%ebx
  8013fa:	eb 16                	jmp    801412 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801400:	75 31                	jne    801433 <vprintfmt+0x217>
					putch(ch, putdat);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	ff 75 0c             	pushl  0xc(%ebp)
  801408:	50                   	push   %eax
  801409:	ff 55 08             	call   *0x8(%ebp)
  80140c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80140f:	83 eb 01             	sub    $0x1,%ebx
  801412:	83 c7 01             	add    $0x1,%edi
  801415:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801419:	0f be c2             	movsbl %dl,%eax
  80141c:	85 c0                	test   %eax,%eax
  80141e:	74 59                	je     801479 <vprintfmt+0x25d>
  801420:	85 f6                	test   %esi,%esi
  801422:	78 d8                	js     8013fc <vprintfmt+0x1e0>
  801424:	83 ee 01             	sub    $0x1,%esi
  801427:	79 d3                	jns    8013fc <vprintfmt+0x1e0>
  801429:	89 df                	mov    %ebx,%edi
  80142b:	8b 75 08             	mov    0x8(%ebp),%esi
  80142e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801431:	eb 37                	jmp    80146a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801433:	0f be d2             	movsbl %dl,%edx
  801436:	83 ea 20             	sub    $0x20,%edx
  801439:	83 fa 5e             	cmp    $0x5e,%edx
  80143c:	76 c4                	jbe    801402 <vprintfmt+0x1e6>
					putch('?', putdat);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	ff 75 0c             	pushl  0xc(%ebp)
  801444:	6a 3f                	push   $0x3f
  801446:	ff 55 08             	call   *0x8(%ebp)
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	eb c1                	jmp    80140f <vprintfmt+0x1f3>
  80144e:	89 75 08             	mov    %esi,0x8(%ebp)
  801451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801457:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145a:	eb b6                	jmp    801412 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	53                   	push   %ebx
  801460:	6a 20                	push   $0x20
  801462:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801464:	83 ef 01             	sub    $0x1,%edi
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 ff                	test   %edi,%edi
  80146c:	7f ee                	jg     80145c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80146e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801471:	89 45 14             	mov    %eax,0x14(%ebp)
  801474:	e9 78 01 00 00       	jmp    8015f1 <vprintfmt+0x3d5>
  801479:	89 df                	mov    %ebx,%edi
  80147b:	8b 75 08             	mov    0x8(%ebp),%esi
  80147e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801481:	eb e7                	jmp    80146a <vprintfmt+0x24e>
	if (lflag >= 2)
  801483:	83 f9 01             	cmp    $0x1,%ecx
  801486:	7e 3f                	jle    8014c7 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801488:	8b 45 14             	mov    0x14(%ebp),%eax
  80148b:	8b 50 04             	mov    0x4(%eax),%edx
  80148e:	8b 00                	mov    (%eax),%eax
  801490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801493:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801496:	8b 45 14             	mov    0x14(%ebp),%eax
  801499:	8d 40 08             	lea    0x8(%eax),%eax
  80149c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80149f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014a3:	79 5c                	jns    801501 <vprintfmt+0x2e5>
				putch('-', putdat);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	6a 2d                	push   $0x2d
  8014ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8014ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014b3:	f7 da                	neg    %edx
  8014b5:	83 d1 00             	adc    $0x0,%ecx
  8014b8:	f7 d9                	neg    %ecx
  8014ba:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c2:	e9 10 01 00 00       	jmp    8015d7 <vprintfmt+0x3bb>
	else if (lflag)
  8014c7:	85 c9                	test   %ecx,%ecx
  8014c9:	75 1b                	jne    8014e6 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8b 00                	mov    (%eax),%eax
  8014d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d3:	89 c1                	mov    %eax,%ecx
  8014d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8d 40 04             	lea    0x4(%eax),%eax
  8014e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e4:	eb b9                	jmp    80149f <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e9:	8b 00                	mov    (%eax),%eax
  8014eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ee:	89 c1                	mov    %eax,%ecx
  8014f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f9:	8d 40 04             	lea    0x4(%eax),%eax
  8014fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ff:	eb 9e                	jmp    80149f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  801501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801507:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150c:	e9 c6 00 00 00       	jmp    8015d7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801511:	83 f9 01             	cmp    $0x1,%ecx
  801514:	7e 18                	jle    80152e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801516:	8b 45 14             	mov    0x14(%ebp),%eax
  801519:	8b 10                	mov    (%eax),%edx
  80151b:	8b 48 04             	mov    0x4(%eax),%ecx
  80151e:	8d 40 08             	lea    0x8(%eax),%eax
  801521:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801524:	b8 0a 00 00 00       	mov    $0xa,%eax
  801529:	e9 a9 00 00 00       	jmp    8015d7 <vprintfmt+0x3bb>
	else if (lflag)
  80152e:	85 c9                	test   %ecx,%ecx
  801530:	75 1a                	jne    80154c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801532:	8b 45 14             	mov    0x14(%ebp),%eax
  801535:	8b 10                	mov    (%eax),%edx
  801537:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153c:	8d 40 04             	lea    0x4(%eax),%eax
  80153f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801542:	b8 0a 00 00 00       	mov    $0xa,%eax
  801547:	e9 8b 00 00 00       	jmp    8015d7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8b 10                	mov    (%eax),%edx
  801551:	b9 00 00 00 00       	mov    $0x0,%ecx
  801556:	8d 40 04             	lea    0x4(%eax),%eax
  801559:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80155c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801561:	eb 74                	jmp    8015d7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801563:	83 f9 01             	cmp    $0x1,%ecx
  801566:	7e 15                	jle    80157d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801568:	8b 45 14             	mov    0x14(%ebp),%eax
  80156b:	8b 10                	mov    (%eax),%edx
  80156d:	8b 48 04             	mov    0x4(%eax),%ecx
  801570:	8d 40 08             	lea    0x8(%eax),%eax
  801573:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801576:	b8 08 00 00 00       	mov    $0x8,%eax
  80157b:	eb 5a                	jmp    8015d7 <vprintfmt+0x3bb>
	else if (lflag)
  80157d:	85 c9                	test   %ecx,%ecx
  80157f:	75 17                	jne    801598 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801581:	8b 45 14             	mov    0x14(%ebp),%eax
  801584:	8b 10                	mov    (%eax),%edx
  801586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158b:	8d 40 04             	lea    0x4(%eax),%eax
  80158e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801591:	b8 08 00 00 00       	mov    $0x8,%eax
  801596:	eb 3f                	jmp    8015d7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8b 10                	mov    (%eax),%edx
  80159d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a2:	8d 40 04             	lea    0x4(%eax),%eax
  8015a5:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8015a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ad:	eb 28                	jmp    8015d7 <vprintfmt+0x3bb>
			putch('0', putdat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 30                	push   $0x30
  8015b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	6a 78                	push   $0x78
  8015bd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c2:	8b 10                	mov    (%eax),%edx
  8015c4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015c9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015cc:	8d 40 04             	lea    0x4(%eax),%eax
  8015cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015de:	57                   	push   %edi
  8015df:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e2:	50                   	push   %eax
  8015e3:	51                   	push   %ecx
  8015e4:	52                   	push   %edx
  8015e5:	89 da                	mov    %ebx,%edx
  8015e7:	89 f0                	mov    %esi,%eax
  8015e9:	e8 45 fb ff ff       	call   801133 <printnum>
			break;
  8015ee:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f4:	83 c7 01             	add    $0x1,%edi
  8015f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015fb:	83 f8 25             	cmp    $0x25,%eax
  8015fe:	0f 84 2f fc ff ff    	je     801233 <vprintfmt+0x17>
			if (ch == '\0')
  801604:	85 c0                	test   %eax,%eax
  801606:	0f 84 8b 00 00 00    	je     801697 <vprintfmt+0x47b>
			putch(ch, putdat);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	53                   	push   %ebx
  801610:	50                   	push   %eax
  801611:	ff d6                	call   *%esi
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb dc                	jmp    8015f4 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801618:	83 f9 01             	cmp    $0x1,%ecx
  80161b:	7e 15                	jle    801632 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80161d:	8b 45 14             	mov    0x14(%ebp),%eax
  801620:	8b 10                	mov    (%eax),%edx
  801622:	8b 48 04             	mov    0x4(%eax),%ecx
  801625:	8d 40 08             	lea    0x8(%eax),%eax
  801628:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80162b:	b8 10 00 00 00       	mov    $0x10,%eax
  801630:	eb a5                	jmp    8015d7 <vprintfmt+0x3bb>
	else if (lflag)
  801632:	85 c9                	test   %ecx,%ecx
  801634:	75 17                	jne    80164d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801636:	8b 45 14             	mov    0x14(%ebp),%eax
  801639:	8b 10                	mov    (%eax),%edx
  80163b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801640:	8d 40 04             	lea    0x4(%eax),%eax
  801643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801646:	b8 10 00 00 00       	mov    $0x10,%eax
  80164b:	eb 8a                	jmp    8015d7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8b 10                	mov    (%eax),%edx
  801652:	b9 00 00 00 00       	mov    $0x0,%ecx
  801657:	8d 40 04             	lea    0x4(%eax),%eax
  80165a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80165d:	b8 10 00 00 00       	mov    $0x10,%eax
  801662:	e9 70 ff ff ff       	jmp    8015d7 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	6a 25                	push   $0x25
  80166d:	ff d6                	call   *%esi
			break;
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	e9 7a ff ff ff       	jmp    8015f1 <vprintfmt+0x3d5>
			putch('%', putdat);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	53                   	push   %ebx
  80167b:	6a 25                	push   $0x25
  80167d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	89 f8                	mov    %edi,%eax
  801684:	eb 03                	jmp    801689 <vprintfmt+0x46d>
  801686:	83 e8 01             	sub    $0x1,%eax
  801689:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80168d:	75 f7                	jne    801686 <vprintfmt+0x46a>
  80168f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801692:	e9 5a ff ff ff       	jmp    8015f1 <vprintfmt+0x3d5>
}
  801697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 18             	sub    $0x18,%esp
  8016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	74 26                	je     8016e6 <vsnprintf+0x47>
  8016c0:	85 d2                	test   %edx,%edx
  8016c2:	7e 22                	jle    8016e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016c4:	ff 75 14             	pushl  0x14(%ebp)
  8016c7:	ff 75 10             	pushl  0x10(%ebp)
  8016ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	68 e2 11 80 00       	push   $0x8011e2
  8016d3:	e8 44 fb ff ff       	call   80121c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e1:	83 c4 10             	add    $0x10,%esp
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    
		return -E_INVAL;
  8016e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016eb:	eb f7                	jmp    8016e4 <vsnprintf+0x45>

008016ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016f6:	50                   	push   %eax
  8016f7:	ff 75 10             	pushl  0x10(%ebp)
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	ff 75 08             	pushl  0x8(%ebp)
  801700:	e8 9a ff ff ff       	call   80169f <vsnprintf>
	va_end(ap);

	return rc;
}
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80170d:	b8 00 00 00 00       	mov    $0x0,%eax
  801712:	eb 03                	jmp    801717 <strlen+0x10>
		n++;
  801714:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801717:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80171b:	75 f7                	jne    801714 <strlen+0xd>
	return n;
}
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801725:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801728:	b8 00 00 00 00       	mov    $0x0,%eax
  80172d:	eb 03                	jmp    801732 <strnlen+0x13>
		n++;
  80172f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801732:	39 d0                	cmp    %edx,%eax
  801734:	74 06                	je     80173c <strnlen+0x1d>
  801736:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80173a:	75 f3                	jne    80172f <strnlen+0x10>
	return n;
}
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801748:	89 c2                	mov    %eax,%edx
  80174a:	83 c1 01             	add    $0x1,%ecx
  80174d:	83 c2 01             	add    $0x1,%edx
  801750:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801754:	88 5a ff             	mov    %bl,-0x1(%edx)
  801757:	84 db                	test   %bl,%bl
  801759:	75 ef                	jne    80174a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80175b:	5b                   	pop    %ebx
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801765:	53                   	push   %ebx
  801766:	e8 9c ff ff ff       	call   801707 <strlen>
  80176b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	01 d8                	add    %ebx,%eax
  801773:	50                   	push   %eax
  801774:	e8 c5 ff ff ff       	call   80173e <strcpy>
	return dst;
}
  801779:	89 d8                	mov    %ebx,%eax
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	8b 75 08             	mov    0x8(%ebp),%esi
  801788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178b:	89 f3                	mov    %esi,%ebx
  80178d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801790:	89 f2                	mov    %esi,%edx
  801792:	eb 0f                	jmp    8017a3 <strncpy+0x23>
		*dst++ = *src;
  801794:	83 c2 01             	add    $0x1,%edx
  801797:	0f b6 01             	movzbl (%ecx),%eax
  80179a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80179d:	80 39 01             	cmpb   $0x1,(%ecx)
  8017a0:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8017a3:	39 da                	cmp    %ebx,%edx
  8017a5:	75 ed                	jne    801794 <strncpy+0x14>
	}
	return ret;
}
  8017a7:	89 f0                	mov    %esi,%eax
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
  8017b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017bb:	89 f0                	mov    %esi,%eax
  8017bd:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017c1:	85 c9                	test   %ecx,%ecx
  8017c3:	75 0b                	jne    8017d0 <strlcpy+0x23>
  8017c5:	eb 17                	jmp    8017de <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017c7:	83 c2 01             	add    $0x1,%edx
  8017ca:	83 c0 01             	add    $0x1,%eax
  8017cd:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017d0:	39 d8                	cmp    %ebx,%eax
  8017d2:	74 07                	je     8017db <strlcpy+0x2e>
  8017d4:	0f b6 0a             	movzbl (%edx),%ecx
  8017d7:	84 c9                	test   %cl,%cl
  8017d9:	75 ec                	jne    8017c7 <strlcpy+0x1a>
		*dst = '\0';
  8017db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017de:	29 f0                	sub    %esi,%eax
}
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ed:	eb 06                	jmp    8017f5 <strcmp+0x11>
		p++, q++;
  8017ef:	83 c1 01             	add    $0x1,%ecx
  8017f2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017f5:	0f b6 01             	movzbl (%ecx),%eax
  8017f8:	84 c0                	test   %al,%al
  8017fa:	74 04                	je     801800 <strcmp+0x1c>
  8017fc:	3a 02                	cmp    (%edx),%al
  8017fe:	74 ef                	je     8017ef <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801800:	0f b6 c0             	movzbl %al,%eax
  801803:	0f b6 12             	movzbl (%edx),%edx
  801806:	29 d0                	sub    %edx,%eax
}
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 55 0c             	mov    0xc(%ebp),%edx
  801814:	89 c3                	mov    %eax,%ebx
  801816:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801819:	eb 06                	jmp    801821 <strncmp+0x17>
		n--, p++, q++;
  80181b:	83 c0 01             	add    $0x1,%eax
  80181e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801821:	39 d8                	cmp    %ebx,%eax
  801823:	74 16                	je     80183b <strncmp+0x31>
  801825:	0f b6 08             	movzbl (%eax),%ecx
  801828:	84 c9                	test   %cl,%cl
  80182a:	74 04                	je     801830 <strncmp+0x26>
  80182c:	3a 0a                	cmp    (%edx),%cl
  80182e:	74 eb                	je     80181b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801830:	0f b6 00             	movzbl (%eax),%eax
  801833:	0f b6 12             	movzbl (%edx),%edx
  801836:	29 d0                	sub    %edx,%eax
}
  801838:	5b                   	pop    %ebx
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    
		return 0;
  80183b:	b8 00 00 00 00       	mov    $0x0,%eax
  801840:	eb f6                	jmp    801838 <strncmp+0x2e>

00801842 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184c:	0f b6 10             	movzbl (%eax),%edx
  80184f:	84 d2                	test   %dl,%dl
  801851:	74 09                	je     80185c <strchr+0x1a>
		if (*s == c)
  801853:	38 ca                	cmp    %cl,%dl
  801855:	74 0a                	je     801861 <strchr+0x1f>
	for (; *s; s++)
  801857:	83 c0 01             	add    $0x1,%eax
  80185a:	eb f0                	jmp    80184c <strchr+0xa>
			return (char *) s;
	return 0;
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80186d:	eb 03                	jmp    801872 <strfind+0xf>
  80186f:	83 c0 01             	add    $0x1,%eax
  801872:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801875:	38 ca                	cmp    %cl,%dl
  801877:	74 04                	je     80187d <strfind+0x1a>
  801879:	84 d2                	test   %dl,%dl
  80187b:	75 f2                	jne    80186f <strfind+0xc>
			break;
	return (char *) s;
}
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	57                   	push   %edi
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 7d 08             	mov    0x8(%ebp),%edi
  801888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80188b:	85 c9                	test   %ecx,%ecx
  80188d:	74 13                	je     8018a2 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80188f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801895:	75 05                	jne    80189c <memset+0x1d>
  801897:	f6 c1 03             	test   $0x3,%cl
  80189a:	74 0d                	je     8018a9 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189f:	fc                   	cld    
  8018a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a2:	89 f8                	mov    %edi,%eax
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    
		c &= 0xFF;
  8018a9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018ad:	89 d3                	mov    %edx,%ebx
  8018af:	c1 e3 08             	shl    $0x8,%ebx
  8018b2:	89 d0                	mov    %edx,%eax
  8018b4:	c1 e0 18             	shl    $0x18,%eax
  8018b7:	89 d6                	mov    %edx,%esi
  8018b9:	c1 e6 10             	shl    $0x10,%esi
  8018bc:	09 f0                	or     %esi,%eax
  8018be:	09 c2                	or     %eax,%edx
  8018c0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018c2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018c5:	89 d0                	mov    %edx,%eax
  8018c7:	fc                   	cld    
  8018c8:	f3 ab                	rep stos %eax,%es:(%edi)
  8018ca:	eb d6                	jmp    8018a2 <memset+0x23>

008018cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	57                   	push   %edi
  8018d0:	56                   	push   %esi
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018da:	39 c6                	cmp    %eax,%esi
  8018dc:	73 35                	jae    801913 <memmove+0x47>
  8018de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018e1:	39 c2                	cmp    %eax,%edx
  8018e3:	76 2e                	jbe    801913 <memmove+0x47>
		s += n;
		d += n;
  8018e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e8:	89 d6                	mov    %edx,%esi
  8018ea:	09 fe                	or     %edi,%esi
  8018ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018f2:	74 0c                	je     801900 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018f4:	83 ef 01             	sub    $0x1,%edi
  8018f7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018fa:	fd                   	std    
  8018fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018fd:	fc                   	cld    
  8018fe:	eb 21                	jmp    801921 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801900:	f6 c1 03             	test   $0x3,%cl
  801903:	75 ef                	jne    8018f4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801905:	83 ef 04             	sub    $0x4,%edi
  801908:	8d 72 fc             	lea    -0x4(%edx),%esi
  80190b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80190e:	fd                   	std    
  80190f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801911:	eb ea                	jmp    8018fd <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801913:	89 f2                	mov    %esi,%edx
  801915:	09 c2                	or     %eax,%edx
  801917:	f6 c2 03             	test   $0x3,%dl
  80191a:	74 09                	je     801925 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80191c:	89 c7                	mov    %eax,%edi
  80191e:	fc                   	cld    
  80191f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801921:	5e                   	pop    %esi
  801922:	5f                   	pop    %edi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801925:	f6 c1 03             	test   $0x3,%cl
  801928:	75 f2                	jne    80191c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80192a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80192d:	89 c7                	mov    %eax,%edi
  80192f:	fc                   	cld    
  801930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801932:	eb ed                	jmp    801921 <memmove+0x55>

00801934 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801937:	ff 75 10             	pushl  0x10(%ebp)
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	ff 75 08             	pushl  0x8(%ebp)
  801940:	e8 87 ff ff ff       	call   8018cc <memmove>
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801952:	89 c6                	mov    %eax,%esi
  801954:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801957:	39 f0                	cmp    %esi,%eax
  801959:	74 1c                	je     801977 <memcmp+0x30>
		if (*s1 != *s2)
  80195b:	0f b6 08             	movzbl (%eax),%ecx
  80195e:	0f b6 1a             	movzbl (%edx),%ebx
  801961:	38 d9                	cmp    %bl,%cl
  801963:	75 08                	jne    80196d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801965:	83 c0 01             	add    $0x1,%eax
  801968:	83 c2 01             	add    $0x1,%edx
  80196b:	eb ea                	jmp    801957 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80196d:	0f b6 c1             	movzbl %cl,%eax
  801970:	0f b6 db             	movzbl %bl,%ebx
  801973:	29 d8                	sub    %ebx,%eax
  801975:	eb 05                	jmp    80197c <memcmp+0x35>
	}

	return 0;
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801989:	89 c2                	mov    %eax,%edx
  80198b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80198e:	39 d0                	cmp    %edx,%eax
  801990:	73 09                	jae    80199b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801992:	38 08                	cmp    %cl,(%eax)
  801994:	74 05                	je     80199b <memfind+0x1b>
	for (; s < ends; s++)
  801996:	83 c0 01             	add    $0x1,%eax
  801999:	eb f3                	jmp    80198e <memfind+0xe>
			break;
	return (void *) s;
}
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	57                   	push   %edi
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a9:	eb 03                	jmp    8019ae <strtol+0x11>
		s++;
  8019ab:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019ae:	0f b6 01             	movzbl (%ecx),%eax
  8019b1:	3c 20                	cmp    $0x20,%al
  8019b3:	74 f6                	je     8019ab <strtol+0xe>
  8019b5:	3c 09                	cmp    $0x9,%al
  8019b7:	74 f2                	je     8019ab <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019b9:	3c 2b                	cmp    $0x2b,%al
  8019bb:	74 2e                	je     8019eb <strtol+0x4e>
	int neg = 0;
  8019bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019c2:	3c 2d                	cmp    $0x2d,%al
  8019c4:	74 2f                	je     8019f5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019cc:	75 05                	jne    8019d3 <strtol+0x36>
  8019ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d1:	74 2c                	je     8019ff <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d3:	85 db                	test   %ebx,%ebx
  8019d5:	75 0a                	jne    8019e1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8019df:	74 28                	je     801a09 <strtol+0x6c>
		base = 10;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019e9:	eb 50                	jmp    801a3b <strtol+0x9e>
		s++;
  8019eb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8019f3:	eb d1                	jmp    8019c6 <strtol+0x29>
		s++, neg = 1;
  8019f5:	83 c1 01             	add    $0x1,%ecx
  8019f8:	bf 01 00 00 00       	mov    $0x1,%edi
  8019fd:	eb c7                	jmp    8019c6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a03:	74 0e                	je     801a13 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a05:	85 db                	test   %ebx,%ebx
  801a07:	75 d8                	jne    8019e1 <strtol+0x44>
		s++, base = 8;
  801a09:	83 c1 01             	add    $0x1,%ecx
  801a0c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a11:	eb ce                	jmp    8019e1 <strtol+0x44>
		s += 2, base = 16;
  801a13:	83 c1 02             	add    $0x2,%ecx
  801a16:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a1b:	eb c4                	jmp    8019e1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a20:	89 f3                	mov    %esi,%ebx
  801a22:	80 fb 19             	cmp    $0x19,%bl
  801a25:	77 29                	ja     801a50 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a27:	0f be d2             	movsbl %dl,%edx
  801a2a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a30:	7d 30                	jge    801a62 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a32:	83 c1 01             	add    $0x1,%ecx
  801a35:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a39:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a3b:	0f b6 11             	movzbl (%ecx),%edx
  801a3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a41:	89 f3                	mov    %esi,%ebx
  801a43:	80 fb 09             	cmp    $0x9,%bl
  801a46:	77 d5                	ja     801a1d <strtol+0x80>
			dig = *s - '0';
  801a48:	0f be d2             	movsbl %dl,%edx
  801a4b:	83 ea 30             	sub    $0x30,%edx
  801a4e:	eb dd                	jmp    801a2d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a50:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a53:	89 f3                	mov    %esi,%ebx
  801a55:	80 fb 19             	cmp    $0x19,%bl
  801a58:	77 08                	ja     801a62 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a5a:	0f be d2             	movsbl %dl,%edx
  801a5d:	83 ea 37             	sub    $0x37,%edx
  801a60:	eb cb                	jmp    801a2d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a66:	74 05                	je     801a6d <strtol+0xd0>
		*endptr = (char *) s;
  801a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a6d:	89 c2                	mov    %eax,%edx
  801a6f:	f7 da                	neg    %edx
  801a71:	85 ff                	test   %edi,%edi
  801a73:	0f 45 c2             	cmovne %edx,%eax
}
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	8b 75 08             	mov    0x8(%ebp),%esi
  801a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a90:	0f 44 c2             	cmove  %edx,%eax
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	50                   	push   %eax
  801a97:	e8 7e e8 ff ff       	call   80031a <sys_ipc_recv>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 2b                	js     801ace <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	74 0a                	je     801ab1 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801aa7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aac:	8b 40 74             	mov    0x74(%eax),%eax
  801aaf:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	74 0a                	je     801abf <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801ab5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aba:	8b 40 78             	mov    0x78(%eax),%eax
  801abd:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    
        *from_env_store = 0;
  801ace:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ad4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ada:	eb eb                	jmp    801ac7 <ipc_recv+0x4c>

00801adc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	57                   	push   %edi
  801ae0:	56                   	push   %esi
  801ae1:	53                   	push   %ebx
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801aee:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801af0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af5:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801af8:	ff 75 14             	pushl  0x14(%ebp)
  801afb:	53                   	push   %ebx
  801afc:	56                   	push   %esi
  801afd:	57                   	push   %edi
  801afe:	e8 f4 e7 ff ff       	call   8002f7 <sys_ipc_try_send>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	74 17                	je     801b21 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801b0a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0d:	74 e9                	je     801af8 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801b0f:	50                   	push   %eax
  801b10:	68 80 22 80 00       	push   $0x802280
  801b15:	6a 3e                	push   $0x3e
  801b17:	68 92 22 80 00       	push   $0x802292
  801b1c:	e8 23 f5 ff ff       	call   801044 <_panic>
        }
    }
}
  801b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5f                   	pop    %edi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3d:	8b 52 50             	mov    0x50(%edx),%edx
  801b40:	39 ca                	cmp    %ecx,%edx
  801b42:	74 11                	je     801b55 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b44:	83 c0 01             	add    $0x1,%eax
  801b47:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4c:	75 e6                	jne    801b34 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b53:	eb 0b                	jmp    801b60 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b55:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b68:	89 d0                	mov    %edx,%eax
  801b6a:	c1 e8 16             	shr    $0x16,%eax
  801b6d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b79:	f6 c1 01             	test   $0x1,%cl
  801b7c:	74 1d                	je     801b9b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b7e:	c1 ea 0c             	shr    $0xc,%edx
  801b81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b88:	f6 c2 01             	test   $0x1,%dl
  801b8b:	74 0e                	je     801b9b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8d:	c1 ea 0c             	shr    $0xc,%edx
  801b90:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b97:	ef 
  801b98:	0f b7 c0             	movzwl %ax,%eax
}
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801baf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bb7:	85 d2                	test   %edx,%edx
  801bb9:	75 35                	jne    801bf0 <__udivdi3+0x50>
  801bbb:	39 f3                	cmp    %esi,%ebx
  801bbd:	0f 87 bd 00 00 00    	ja     801c80 <__udivdi3+0xe0>
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	89 d9                	mov    %ebx,%ecx
  801bc7:	75 0b                	jne    801bd4 <__udivdi3+0x34>
  801bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f3                	div    %ebx
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	31 d2                	xor    %edx,%edx
  801bd6:	89 f0                	mov    %esi,%eax
  801bd8:	f7 f1                	div    %ecx
  801bda:	89 c6                	mov    %eax,%esi
  801bdc:	89 e8                	mov    %ebp,%eax
  801bde:	89 f7                	mov    %esi,%edi
  801be0:	f7 f1                	div    %ecx
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	83 c4 1c             	add    $0x1c,%esp
  801be7:	5b                   	pop    %ebx
  801be8:	5e                   	pop    %esi
  801be9:	5f                   	pop    %edi
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    
  801bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 f2                	cmp    %esi,%edx
  801bf2:	77 7c                	ja     801c70 <__udivdi3+0xd0>
  801bf4:	0f bd fa             	bsr    %edx,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0xf8>
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	b8 20 00 00 00       	mov    $0x20,%eax
  801c07:	29 f8                	sub    %edi,%eax
  801c09:	d3 e2                	shl    %cl,%edx
  801c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	89 da                	mov    %ebx,%edx
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c19:	09 d1                	or     %edx,%ecx
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e3                	shl    %cl,%ebx
  801c25:	89 c1                	mov    %eax,%ecx
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 f9                	mov    %edi,%ecx
  801c2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c2f:	d3 e6                	shl    %cl,%esi
  801c31:	89 eb                	mov    %ebp,%ebx
  801c33:	89 c1                	mov    %eax,%ecx
  801c35:	d3 eb                	shr    %cl,%ebx
  801c37:	09 de                	or     %ebx,%esi
  801c39:	89 f0                	mov    %esi,%eax
  801c3b:	f7 74 24 08          	divl   0x8(%esp)
  801c3f:	89 d6                	mov    %edx,%esi
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	f7 64 24 0c          	mull   0xc(%esp)
  801c47:	39 d6                	cmp    %edx,%esi
  801c49:	72 0c                	jb     801c57 <__udivdi3+0xb7>
  801c4b:	89 f9                	mov    %edi,%ecx
  801c4d:	d3 e5                	shl    %cl,%ebp
  801c4f:	39 c5                	cmp    %eax,%ebp
  801c51:	73 5d                	jae    801cb0 <__udivdi3+0x110>
  801c53:	39 d6                	cmp    %edx,%esi
  801c55:	75 59                	jne    801cb0 <__udivdi3+0x110>
  801c57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c5a:	31 ff                	xor    %edi,%edi
  801c5c:	89 fa                	mov    %edi,%edx
  801c5e:	83 c4 1c             	add    $0x1c,%esp
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    
  801c66:	8d 76 00             	lea    0x0(%esi),%esi
  801c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	31 c0                	xor    %eax,%eax
  801c74:	89 fa                	mov    %edi,%edx
  801c76:	83 c4 1c             	add    $0x1c,%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    
  801c7e:	66 90                	xchg   %ax,%ax
  801c80:	31 ff                	xor    %edi,%edi
  801c82:	89 e8                	mov    %ebp,%eax
  801c84:	89 f2                	mov    %esi,%edx
  801c86:	f7 f3                	div    %ebx
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	72 06                	jb     801ca2 <__udivdi3+0x102>
  801c9c:	31 c0                	xor    %eax,%eax
  801c9e:	39 eb                	cmp    %ebp,%ebx
  801ca0:	77 d2                	ja     801c74 <__udivdi3+0xd4>
  801ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca7:	eb cb                	jmp    801c74 <__udivdi3+0xd4>
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	31 ff                	xor    %edi,%edi
  801cb4:	eb be                	jmp    801c74 <__udivdi3+0xd4>
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ccb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ccf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 ed                	test   %ebp,%ebp
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	89 da                	mov    %ebx,%edx
  801cdd:	75 19                	jne    801cf8 <__umoddi3+0x38>
  801cdf:	39 df                	cmp    %ebx,%edi
  801ce1:	0f 86 b1 00 00 00    	jbe    801d98 <__umoddi3+0xd8>
  801ce7:	f7 f7                	div    %edi
  801ce9:	89 d0                	mov    %edx,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	83 c4 1c             	add    $0x1c,%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    
  801cf5:	8d 76 00             	lea    0x0(%esi),%esi
  801cf8:	39 dd                	cmp    %ebx,%ebp
  801cfa:	77 f1                	ja     801ced <__umoddi3+0x2d>
  801cfc:	0f bd cd             	bsr    %ebp,%ecx
  801cff:	83 f1 1f             	xor    $0x1f,%ecx
  801d02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d06:	0f 84 b4 00 00 00    	je     801dc0 <__umoddi3+0x100>
  801d0c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d11:	89 c2                	mov    %eax,%edx
  801d13:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d17:	29 c2                	sub    %eax,%edx
  801d19:	89 c1                	mov    %eax,%ecx
  801d1b:	89 f8                	mov    %edi,%eax
  801d1d:	d3 e5                	shl    %cl,%ebp
  801d1f:	89 d1                	mov    %edx,%ecx
  801d21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d25:	d3 e8                	shr    %cl,%eax
  801d27:	09 c5                	or     %eax,%ebp
  801d29:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d2d:	89 c1                	mov    %eax,%ecx
  801d2f:	d3 e7                	shl    %cl,%edi
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d37:	89 df                	mov    %ebx,%edi
  801d39:	d3 ef                	shr    %cl,%edi
  801d3b:	89 c1                	mov    %eax,%ecx
  801d3d:	89 f0                	mov    %esi,%eax
  801d3f:	d3 e3                	shl    %cl,%ebx
  801d41:	89 d1                	mov    %edx,%ecx
  801d43:	89 fa                	mov    %edi,%edx
  801d45:	d3 e8                	shr    %cl,%eax
  801d47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d4c:	09 d8                	or     %ebx,%eax
  801d4e:	f7 f5                	div    %ebp
  801d50:	d3 e6                	shl    %cl,%esi
  801d52:	89 d1                	mov    %edx,%ecx
  801d54:	f7 64 24 08          	mull   0x8(%esp)
  801d58:	39 d1                	cmp    %edx,%ecx
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	72 06                	jb     801d66 <__umoddi3+0xa6>
  801d60:	75 0e                	jne    801d70 <__umoddi3+0xb0>
  801d62:	39 c6                	cmp    %eax,%esi
  801d64:	73 0a                	jae    801d70 <__umoddi3+0xb0>
  801d66:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d6a:	19 ea                	sbb    %ebp,%edx
  801d6c:	89 d7                	mov    %edx,%edi
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	89 ca                	mov    %ecx,%edx
  801d72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d77:	29 de                	sub    %ebx,%esi
  801d79:	19 fa                	sbb    %edi,%edx
  801d7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d7f:	89 d0                	mov    %edx,%eax
  801d81:	d3 e0                	shl    %cl,%eax
  801d83:	89 d9                	mov    %ebx,%ecx
  801d85:	d3 ee                	shr    %cl,%esi
  801d87:	d3 ea                	shr    %cl,%edx
  801d89:	09 f0                	or     %esi,%eax
  801d8b:	83 c4 1c             	add    $0x1c,%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 f9                	mov    %edi,%ecx
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0xe9>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f1                	div    %ecx
  801daf:	89 f0                	mov    %esi,%eax
  801db1:	f7 f1                	div    %ecx
  801db3:	e9 31 ff ff ff       	jmp    801ce9 <__umoddi3+0x29>
  801db8:	90                   	nop
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	39 dd                	cmp    %ebx,%ebp
  801dc2:	72 08                	jb     801dcc <__umoddi3+0x10c>
  801dc4:	39 f7                	cmp    %esi,%edi
  801dc6:	0f 87 21 ff ff ff    	ja     801ced <__umoddi3+0x2d>
  801dcc:	89 da                	mov    %ebx,%edx
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	29 f8                	sub    %edi,%eax
  801dd2:	19 ea                	sbb    %ebp,%edx
  801dd4:	e9 14 ff ff ff       	jmp    801ced <__umoddi3+0x2d>
