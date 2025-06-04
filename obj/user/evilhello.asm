
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 92 04 00 00       	call   80052d <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 ea 1d 80 00       	push   $0x801dea
  80011c:	6a 23                	push   $0x23
  80011e:	68 07 1e 80 00       	push   $0x801e07
  800123:	e8 18 0f 00 00       	call   801040 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7f 08                	jg     800192 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	6a 04                	push   $0x4
  800198:	68 ea 1d 80 00       	push   $0x801dea
  80019d:	6a 23                	push   $0x23
  80019f:	68 07 1e 80 00       	push   $0x801e07
  8001a4:	e8 97 0e 00 00       	call   801040 <_panic>

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7f 08                	jg     8001d4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	50                   	push   %eax
  8001d8:	6a 05                	push   $0x5
  8001da:	68 ea 1d 80 00       	push   $0x801dea
  8001df:	6a 23                	push   $0x23
  8001e1:	68 07 1e 80 00       	push   $0x801e07
  8001e6:	e8 55 0e 00 00       	call   801040 <_panic>

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7f 08                	jg     800216 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	50                   	push   %eax
  80021a:	6a 06                	push   $0x6
  80021c:	68 ea 1d 80 00       	push   $0x801dea
  800221:	6a 23                	push   $0x23
  800223:	68 07 1e 80 00       	push   $0x801e07
  800228:	e8 13 0e 00 00       	call   801040 <_panic>

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7f 08                	jg     800258 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	50                   	push   %eax
  80025c:	6a 08                	push   $0x8
  80025e:	68 ea 1d 80 00       	push   $0x801dea
  800263:	6a 23                	push   $0x23
  800265:	68 07 1e 80 00       	push   $0x801e07
  80026a:	e8 d1 0d 00 00       	call   801040 <_panic>

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7f 08                	jg     80029a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	83 ec 0c             	sub    $0xc,%esp
  80029d:	50                   	push   %eax
  80029e:	6a 09                	push   $0x9
  8002a0:	68 ea 1d 80 00       	push   $0x801dea
  8002a5:	6a 23                	push   $0x23
  8002a7:	68 07 1e 80 00       	push   $0x801e07
  8002ac:	e8 8f 0d 00 00       	call   801040 <_panic>

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7f 08                	jg     8002dc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	50                   	push   %eax
  8002e0:	6a 0a                	push   $0xa
  8002e2:	68 ea 1d 80 00       	push   $0x801dea
  8002e7:	6a 23                	push   $0x23
  8002e9:	68 07 1e 80 00       	push   $0x801e07
  8002ee:	e8 4d 0d 00 00       	call   801040 <_panic>

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	be 00 00 00 00       	mov    $0x0,%esi
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7f 08                	jg     800340 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	50                   	push   %eax
  800344:	6a 0d                	push   $0xd
  800346:	68 ea 1d 80 00       	push   $0x801dea
  80034b:	6a 23                	push   $0x23
  80034d:	68 07 1e 80 00       	push   $0x801e07
  800352:	e8 e9 0c 00 00       	call   801040 <_panic>

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 2a                	je     8003c4 <fd_alloc+0x46>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	74 19                	je     8003c4 <fd_alloc+0x46>
  8003ab:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b5:	75 d2                	jne    800389 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c2:	eb 07                	jmp    8003cb <fd_alloc+0x4d>
			*fd_store = fd;
  8003c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb f7                	jmp    80040c <fd_lookup+0x3f>
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb f0                	jmp    80040c <fd_lookup+0x3f>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb e9                	jmp    80040c <fd_lookup+0x3f>

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	74 33                	je     80046d <dev_lookup+0x4a>
  80043a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 f3                	jne    800436 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800443:	a1 04 40 80 00       	mov    0x804004,%eax
  800448:	8b 40 48             	mov    0x48(%eax),%eax
  80044b:	83 ec 04             	sub    $0x4,%esp
  80044e:	51                   	push   %ecx
  80044f:	50                   	push   %eax
  800450:	68 18 1e 80 00       	push   $0x801e18
  800455:	e8 c1 0c 00 00       	call   80111b <cprintf>
	*dev = 0;
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    
			*dev = devtab[i];
  80046d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800470:	89 01                	mov    %eax,(%ecx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb f2                	jmp    80046b <dev_lookup+0x48>

00800479 <fd_close>:
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	57                   	push   %edi
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 1c             	sub    $0x1c,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800495:	50                   	push   %eax
  800496:	e8 32 ff ff ff       	call   8003cd <fd_lookup>
  80049b:	89 c3                	mov    %eax,%ebx
  80049d:	83 c4 08             	add    $0x8,%esp
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	78 05                	js     8004a9 <fd_close+0x30>
	    || fd != fd2)
  8004a4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a7:	74 16                	je     8004bf <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a9:	89 f8                	mov    %edi,%eax
  8004ab:	84 c0                	test   %al,%al
  8004ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b5:	89 d8                	mov    %ebx,%eax
  8004b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff 36                	pushl  (%esi)
  8004c8:	e8 56 ff ff ff       	call   800423 <dev_lookup>
  8004cd:	89 c3                	mov    %eax,%ebx
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	78 15                	js     8004eb <fd_close+0x72>
		if (dev->dev_close)
  8004d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d9:	8b 40 10             	mov    0x10(%eax),%eax
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	74 1b                	je     8004fb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e0:	83 ec 0c             	sub    $0xc,%esp
  8004e3:	56                   	push   %esi
  8004e4:	ff d0                	call   *%eax
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	56                   	push   %esi
  8004ef:	6a 00                	push   $0x0
  8004f1:	e8 f5 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb ba                	jmp    8004b5 <fd_close+0x3c>
			r = 0;
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800500:	eb e9                	jmp    8004eb <fd_close+0x72>

00800502 <close>:

int
close(int fdnum)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	e8 b9 fe ff ff       	call   8003cd <fd_lookup>
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	85 c0                	test   %eax,%eax
  800519:	78 10                	js     80052b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	6a 01                	push   $0x1
  800520:	ff 75 f4             	pushl  -0xc(%ebp)
  800523:	e8 51 ff ff ff       	call   800479 <fd_close>
  800528:	83 c4 10             	add    $0x10,%esp
}
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <close_all>:

void
close_all(void)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	53                   	push   %ebx
  800531:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800539:	83 ec 0c             	sub    $0xc,%esp
  80053c:	53                   	push   %ebx
  80053d:	e8 c0 ff ff ff       	call   800502 <close>
	for (i = 0; i < MAXFD; i++)
  800542:	83 c3 01             	add    $0x1,%ebx
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 fb 20             	cmp    $0x20,%ebx
  80054b:	75 ec                	jne    800539 <close_all+0xc>
}
  80054d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055e:	50                   	push   %eax
  80055f:	ff 75 08             	pushl  0x8(%ebp)
  800562:	e8 66 fe ff ff       	call   8003cd <fd_lookup>
  800567:	89 c3                	mov    %eax,%ebx
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	0f 88 81 00 00 00    	js     8005f5 <dup+0xa3>
		return r;
	close(newfdnum);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	e8 83 ff ff ff       	call   800502 <close>

	newfd = INDEX2FD(newfdnum);
  80057f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800582:	c1 e6 0c             	shl    $0xc,%esi
  800585:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058b:	83 c4 04             	add    $0x4,%esp
  80058e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800591:	e8 d1 fd ff ff       	call   800367 <fd2data>
  800596:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800598:	89 34 24             	mov    %esi,(%esp)
  80059b:	e8 c7 fd ff ff       	call   800367 <fd2data>
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 16             	shr    $0x16,%eax
  8005aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b1:	a8 01                	test   $0x1,%al
  8005b3:	74 11                	je     8005c6 <dup+0x74>
  8005b5:	89 d8                	mov    %ebx,%eax
  8005b7:	c1 e8 0c             	shr    $0xc,%eax
  8005ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c1:	f6 c2 01             	test   $0x1,%dl
  8005c4:	75 39                	jne    8005ff <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	89 d0                	mov    %edx,%eax
  8005cb:	c1 e8 0c             	shr    $0xc,%eax
  8005ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dd:	50                   	push   %eax
  8005de:	56                   	push   %esi
  8005df:	6a 00                	push   $0x0
  8005e1:	52                   	push   %edx
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 c0 fb ff ff       	call   8001a9 <sys_page_map>
  8005e9:	89 c3                	mov    %eax,%ebx
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	78 31                	js     800623 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f5:	89 d8                	mov    %ebx,%eax
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	57                   	push   %edi
  800610:	6a 00                	push   $0x0
  800612:	53                   	push   %ebx
  800613:	6a 00                	push   $0x0
  800615:	e8 8f fb ff ff       	call   8001a9 <sys_page_map>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 a3                	jns    8005c6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	56                   	push   %esi
  800627:	6a 00                	push   $0x0
  800629:	e8 bd fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	57                   	push   %edi
  800632:	6a 00                	push   $0x0
  800634:	e8 b2 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb b7                	jmp    8005f5 <dup+0xa3>

0080063e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
  800641:	53                   	push   %ebx
  800642:	83 ec 14             	sub    $0x14,%esp
  800645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064b:	50                   	push   %eax
  80064c:	53                   	push   %ebx
  80064d:	e8 7b fd ff ff       	call   8003cd <fd_lookup>
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	85 c0                	test   %eax,%eax
  800657:	78 3f                	js     800698 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800663:	ff 30                	pushl  (%eax)
  800665:	e8 b9 fd ff ff       	call   800423 <dev_lookup>
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	85 c0                	test   %eax,%eax
  80066f:	78 27                	js     800698 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800671:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800674:	8b 42 08             	mov    0x8(%edx),%eax
  800677:	83 e0 03             	and    $0x3,%eax
  80067a:	83 f8 01             	cmp    $0x1,%eax
  80067d:	74 1e                	je     80069d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800682:	8b 40 08             	mov    0x8(%eax),%eax
  800685:	85 c0                	test   %eax,%eax
  800687:	74 35                	je     8006be <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	52                   	push   %edx
  800693:	ff d0                	call   *%eax
  800695:	83 c4 10             	add    $0x10,%esp
}
  800698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069d:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a2:	8b 40 48             	mov    0x48(%eax),%eax
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	50                   	push   %eax
  8006aa:	68 59 1e 80 00       	push   $0x801e59
  8006af:	e8 67 0a 00 00       	call   80111b <cprintf>
		return -E_INVAL;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb da                	jmp    800698 <read+0x5a>
		return -E_NOT_SUPP;
  8006be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c3:	eb d3                	jmp    800698 <read+0x5a>

008006c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
  8006ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 25                	jae    800702 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	29 d8                	sub    %ebx,%eax
  8006e4:	50                   	push   %eax
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	57                   	push   %edi
  8006ec:	e8 4d ff ff ff       	call   80063e <read>
		if (m < 0)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 08                	js     800700 <readn+0x3b>
			return m;
		if (m == 0)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 06                	je     800702 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006fc:	01 c3                	add    %eax,%ebx
  8006fe:	eb d9                	jmp    8006d9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800700:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 14             	sub    $0x14,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 ad fc ff ff       	call   8003cd <fd_lookup>
  800720:	83 c4 08             	add    $0x8,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 3a                	js     800761 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 eb fc ff ff       	call   800423 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 22                	js     800761 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	74 1e                	je     800766 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074b:	8b 52 0c             	mov    0xc(%edx),%edx
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 35                	je     800787 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	50                   	push   %eax
  80075c:	ff d2                	call   *%edx
  80075e:	83 c4 10             	add    $0x10,%esp
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 75 1e 80 00       	push   $0x801e75
  800778:	e8 9e 09 00 00       	call   80111b <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb da                	jmp    800761 <write+0x55>
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80078c:	eb d3                	jmp    800761 <write+0x55>

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 2d fc ff ff       	call   8003cd <fd_lookup>
  8007a0:	83 c4 08             	add    $0x8,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 0e                	js     8007b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 14             	sub    $0x14,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	53                   	push   %ebx
  8007c6:	e8 02 fc ff ff       	call   8003cd <fd_lookup>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 37                	js     800809 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	ff 30                	pushl  (%eax)
  8007de:	e8 40 fc ff ff       	call   800423 <dev_lookup>
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 1f                	js     800809 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f1:	74 1b                	je     80080e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f6:	8b 52 18             	mov    0x18(%edx),%edx
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 32                	je     80082f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	50                   	push   %eax
  800804:	ff d2                	call   *%edx
  800806:	83 c4 10             	add    $0x10,%esp
}
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080e:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 38 1e 80 00       	push   $0x801e38
  800820:	e8 f6 08 00 00       	call   80111b <cprintf>
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082d:	eb da                	jmp    800809 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800834:	eb d3                	jmp    800809 <ftruncate+0x52>

00800836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 14             	sub    $0x14,%esp
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 81 fb ff ff       	call   8003cd <fd_lookup>
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 4b                	js     80089e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800859:	50                   	push   %eax
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	ff 30                	pushl  (%eax)
  80085f:	e8 bf fb ff ff       	call   800423 <dev_lookup>
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	85 c0                	test   %eax,%eax
  800869:	78 33                	js     80089e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800872:	74 2f                	je     8008a3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087e:	00 00 00 
	stat->st_isdir = 0;
  800881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800888:	00 00 00 
	stat->st_dev = dev;
  80088b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	ff 75 f0             	pushl  -0x10(%ebp)
  800898:	ff 50 14             	call   *0x14(%eax)
  80089b:	83 c4 10             	add    $0x10,%esp
}
  80089e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a8:	eb f4                	jmp    80089e <fstat+0x68>

008008aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	6a 00                	push   $0x0
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 e7 01 00 00       	call   800aa3 <open>
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 1b                	js     8008e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	50                   	push   %eax
  8008cc:	e8 65 ff ff ff       	call   800836 <fstat>
  8008d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d3:	89 1c 24             	mov    %ebx,(%esp)
  8008d6:	e8 27 fc ff ff       	call   800502 <close>
	return r;
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	89 f3                	mov    %esi,%ebx
}
  8008e0:	89 d8                	mov    %ebx,%eax
  8008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f9:	74 27                	je     800922 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008fb:	6a 07                	push   $0x7
  8008fd:	68 00 50 80 00       	push   $0x805000
  800902:	56                   	push   %esi
  800903:	ff 35 00 40 80 00    	pushl  0x804000
  800909:	e8 ca 11 00 00       	call   801ad8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090e:	83 c4 0c             	add    $0xc,%esp
  800911:	6a 00                	push   $0x0
  800913:	53                   	push   %ebx
  800914:	6a 00                	push   $0x0
  800916:	e8 5c 11 00 00       	call   801a77 <ipc_recv>
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800922:	83 ec 0c             	sub    $0xc,%esp
  800925:	6a 01                	push   $0x1
  800927:	e8 f9 11 00 00       	call   801b25 <ipc_find_env>
  80092c:	a3 00 40 80 00       	mov    %eax,0x804000
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb c5                	jmp    8008fb <fsipc+0x12>

00800936 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 40 0c             	mov    0xc(%eax),%eax
  800942:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094f:	ba 00 00 00 00       	mov    $0x0,%edx
  800954:	b8 02 00 00 00       	mov    $0x2,%eax
  800959:	e8 8b ff ff ff       	call   8008e9 <fsipc>
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <devfile_flush>:
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
  800976:	b8 06 00 00 00       	mov    $0x6,%eax
  80097b:	e8 69 ff ff ff       	call   8008e9 <fsipc>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <devfile_stat>:
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	83 ec 04             	sub    $0x4,%esp
  800989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 40 0c             	mov    0xc(%eax),%eax
  800992:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800997:	ba 00 00 00 00       	mov    $0x0,%edx
  80099c:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a1:	e8 43 ff ff ff       	call   8008e9 <fsipc>
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 2c                	js     8009d6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	68 00 50 80 00       	push   $0x805000
  8009b2:	53                   	push   %ebx
  8009b3:	e8 82 0d 00 00       	call   80173a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_write>:
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ee:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f7:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009fd:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a02:	50                   	push   %eax
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	68 08 50 80 00       	push   $0x805008
  800a0b:	e8 b8 0e 00 00       	call   8018c8 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1a:	e8 ca fe ff ff       	call   8008e9 <fsipc>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <devfile_read>:
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a34:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a44:	e8 a0 fe ff ff       	call   8008e9 <fsipc>
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	78 1f                	js     800a6e <devfile_read+0x4d>
	assert(r <= n);
  800a4f:	39 f0                	cmp    %esi,%eax
  800a51:	77 24                	ja     800a77 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a53:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a58:	7f 33                	jg     800a8d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a5a:	83 ec 04             	sub    $0x4,%esp
  800a5d:	50                   	push   %eax
  800a5e:	68 00 50 80 00       	push   $0x805000
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	e8 5d 0e 00 00       	call   8018c8 <memmove>
	return r;
  800a6b:	83 c4 10             	add    $0x10,%esp
}
  800a6e:	89 d8                	mov    %ebx,%eax
  800a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    
	assert(r <= n);
  800a77:	68 a4 1e 80 00       	push   $0x801ea4
  800a7c:	68 ab 1e 80 00       	push   $0x801eab
  800a81:	6a 7d                	push   $0x7d
  800a83:	68 c0 1e 80 00       	push   $0x801ec0
  800a88:	e8 b3 05 00 00       	call   801040 <_panic>
	assert(r <= PGSIZE);
  800a8d:	68 cb 1e 80 00       	push   $0x801ecb
  800a92:	68 ab 1e 80 00       	push   $0x801eab
  800a97:	6a 7e                	push   $0x7e
  800a99:	68 c0 1e 80 00       	push   $0x801ec0
  800a9e:	e8 9d 05 00 00       	call   801040 <_panic>

00800aa3 <open>:
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 1c             	sub    $0x1c,%esp
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aae:	56                   	push   %esi
  800aaf:	e8 4f 0c 00 00       	call   801703 <strlen>
  800ab4:	83 c4 10             	add    $0x10,%esp
  800ab7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800abc:	0f 8f 96 00 00 00    	jg     800b58 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac8:	50                   	push   %eax
  800ac9:	e8 b0 f8 ff ff       	call   80037e <fd_alloc>
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 66                	js     800b3d <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800ad7:	83 ec 08             	sub    $0x8,%esp
  800ada:	56                   	push   %esi
  800adb:	68 00 50 80 00       	push   $0x805000
  800ae0:	e8 55 0c 00 00       	call   80173a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	e8 ef fd ff ff       	call   8008e9 <fsipc>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 43                	js     800b46 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	ff 75 f4             	pushl  -0xc(%ebp)
  800b09:	e8 49 f8 ff ff       	call   800357 <fd2num>
  800b0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b11:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b17:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b1a:	83 c4 08             	add    $0x8,%esp
  800b1d:	50                   	push   %eax
  800b1e:	52                   	push   %edx
  800b1f:	ff 32                	pushl  (%edx)
  800b21:	56                   	push   %esi
  800b22:	51                   	push   %ecx
  800b23:	68 d8 1e 80 00       	push   $0x801ed8
  800b28:	e8 ee 05 00 00       	call   80111b <cprintf>
	return fd2num(fd);
  800b2d:	83 c4 14             	add    $0x14,%esp
  800b30:	ff 75 f4             	pushl  -0xc(%ebp)
  800b33:	e8 1f f8 ff ff       	call   800357 <fd2num>
  800b38:	89 c3                	mov    %eax,%ebx
  800b3a:	83 c4 10             	add    $0x10,%esp
}
  800b3d:	89 d8                	mov    %ebx,%eax
  800b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
		fd_close(fd, 0);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	6a 00                	push   $0x0
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 26 f9 ff ff       	call   800479 <fd_close>
		return r;
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	eb e5                	jmp    800b3d <open+0x9a>
		return -E_BAD_PATH;
  800b58:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b5d:	eb de                	jmp    800b3d <open+0x9a>

00800b5f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6f:	e8 75 fd ff ff       	call   8008e9 <fsipc>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	ff 75 08             	pushl  0x8(%ebp)
  800b84:	e8 de f7 ff ff       	call   800367 <fd2data>
  800b89:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8b:	83 c4 08             	add    $0x8,%esp
  800b8e:	68 17 1f 80 00       	push   $0x801f17
  800b93:	53                   	push   %ebx
  800b94:	e8 a1 0b 00 00       	call   80173a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b99:	8b 46 04             	mov    0x4(%esi),%eax
  800b9c:	2b 06                	sub    (%esi),%eax
  800b9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bab:	00 00 00 
	stat->st_dev = &devpipe;
  800bae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb5:	30 80 00 
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bce:	53                   	push   %ebx
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 15 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd6:	89 1c 24             	mov    %ebx,(%esp)
  800bd9:	e8 89 f7 ff ff       	call   800367 <fd2data>
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 00                	push   $0x0
  800be4:	e8 02 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <_pipeisclosed>:
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bfb:	a1 04 40 80 00       	mov    0x804004,%eax
  800c00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	57                   	push   %edi
  800c07:	e8 52 0f 00 00       	call   801b5e <pageref>
  800c0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0f:	89 34 24             	mov    %esi,(%esp)
  800c12:	e8 47 0f 00 00       	call   801b5e <pageref>
		nn = thisenv->env_runs;
  800c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	39 cb                	cmp    %ecx,%ebx
  800c25:	74 1b                	je     800c42 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c27:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2a:	75 cf                	jne    800bfb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c2c:	8b 42 58             	mov    0x58(%edx),%eax
  800c2f:	6a 01                	push   $0x1
  800c31:	50                   	push   %eax
  800c32:	53                   	push   %ebx
  800c33:	68 1e 1f 80 00       	push   $0x801f1e
  800c38:	e8 de 04 00 00       	call   80111b <cprintf>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	eb b9                	jmp    800bfb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c42:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c45:	0f 94 c0             	sete   %al
  800c48:	0f b6 c0             	movzbl %al,%eax
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <devpipe_write>:
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 28             	sub    $0x28,%esp
  800c5c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c5f:	56                   	push   %esi
  800c60:	e8 02 f7 ff ff       	call   800367 <fd2data>
  800c65:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c72:	74 4f                	je     800cc3 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c74:	8b 43 04             	mov    0x4(%ebx),%eax
  800c77:	8b 0b                	mov    (%ebx),%ecx
  800c79:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7c:	39 d0                	cmp    %edx,%eax
  800c7e:	72 14                	jb     800c94 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c80:	89 da                	mov    %ebx,%edx
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	e8 65 ff ff ff       	call   800bee <_pipeisclosed>
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	75 3a                	jne    800cc7 <devpipe_write+0x74>
			sys_yield();
  800c8d:	e8 b5 f4 ff ff       	call   800147 <sys_yield>
  800c92:	eb e0                	jmp    800c74 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9e:	89 c2                	mov    %eax,%edx
  800ca0:	c1 fa 1f             	sar    $0x1f,%edx
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cab:	83 e2 1f             	and    $0x1f,%edx
  800cae:	29 ca                	sub    %ecx,%edx
  800cb0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb8:	83 c0 01             	add    $0x1,%eax
  800cbb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cbe:	83 c7 01             	add    $0x1,%edi
  800cc1:	eb ac                	jmp    800c6f <devpipe_write+0x1c>
	return i;
  800cc3:	89 f8                	mov    %edi,%eax
  800cc5:	eb 05                	jmp    800ccc <devpipe_write+0x79>
				return 0;
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <devpipe_read>:
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 18             	sub    $0x18,%esp
  800cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ce0:	57                   	push   %edi
  800ce1:	e8 81 f6 ff ff       	call   800367 <fd2data>
  800ce6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cf3:	74 47                	je     800d3c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cf5:	8b 03                	mov    (%ebx),%eax
  800cf7:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cfa:	75 22                	jne    800d1e <devpipe_read+0x4a>
			if (i > 0)
  800cfc:	85 f6                	test   %esi,%esi
  800cfe:	75 14                	jne    800d14 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800d00:	89 da                	mov    %ebx,%edx
  800d02:	89 f8                	mov    %edi,%eax
  800d04:	e8 e5 fe ff ff       	call   800bee <_pipeisclosed>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	75 33                	jne    800d40 <devpipe_read+0x6c>
			sys_yield();
  800d0d:	e8 35 f4 ff ff       	call   800147 <sys_yield>
  800d12:	eb e1                	jmp    800cf5 <devpipe_read+0x21>
				return i;
  800d14:	89 f0                	mov    %esi,%eax
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1e:	99                   	cltd   
  800d1f:	c1 ea 1b             	shr    $0x1b,%edx
  800d22:	01 d0                	add    %edx,%eax
  800d24:	83 e0 1f             	and    $0x1f,%eax
  800d27:	29 d0                	sub    %edx,%eax
  800d29:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d34:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d37:	83 c6 01             	add    $0x1,%esi
  800d3a:	eb b4                	jmp    800cf0 <devpipe_read+0x1c>
	return i;
  800d3c:	89 f0                	mov    %esi,%eax
  800d3e:	eb d6                	jmp    800d16 <devpipe_read+0x42>
				return 0;
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	eb cf                	jmp    800d16 <devpipe_read+0x42>

00800d47 <pipe>:
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d52:	50                   	push   %eax
  800d53:	e8 26 f6 ff ff       	call   80037e <fd_alloc>
  800d58:	89 c3                	mov    %eax,%ebx
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	78 5b                	js     800dbc <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 07 04 00 00       	push   $0x407
  800d69:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6c:	6a 00                	push   $0x0
  800d6e:	e8 f3 f3 ff ff       	call   800166 <sys_page_alloc>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 40                	js     800dbc <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d82:	50                   	push   %eax
  800d83:	e8 f6 f5 ff ff       	call   80037e <fd_alloc>
  800d88:	89 c3                	mov    %eax,%ebx
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	78 1b                	js     800dac <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	68 07 04 00 00       	push   $0x407
  800d99:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 c3 f3 ff ff       	call   800166 <sys_page_alloc>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	79 19                	jns    800dc5 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800dac:	83 ec 08             	sub    $0x8,%esp
  800daf:	ff 75 f4             	pushl  -0xc(%ebp)
  800db2:	6a 00                	push   $0x0
  800db4:	e8 32 f4 ff ff       	call   8001eb <sys_page_unmap>
  800db9:	83 c4 10             	add    $0x10,%esp
}
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
	va = fd2data(fd0);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcb:	e8 97 f5 ff ff       	call   800367 <fd2data>
  800dd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd2:	83 c4 0c             	add    $0xc,%esp
  800dd5:	68 07 04 00 00       	push   $0x407
  800dda:	50                   	push   %eax
  800ddb:	6a 00                	push   $0x0
  800ddd:	e8 84 f3 ff ff       	call   800166 <sys_page_alloc>
  800de2:	89 c3                	mov    %eax,%ebx
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	0f 88 8c 00 00 00    	js     800e7b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	ff 75 f0             	pushl  -0x10(%ebp)
  800df5:	e8 6d f5 ff ff       	call   800367 <fd2data>
  800dfa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e01:	50                   	push   %eax
  800e02:	6a 00                	push   $0x0
  800e04:	56                   	push   %esi
  800e05:	6a 00                	push   $0x0
  800e07:	e8 9d f3 ff ff       	call   8001a9 <sys_page_map>
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	83 c4 20             	add    $0x20,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 58                	js     800e6d <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	ff 75 f4             	pushl  -0xc(%ebp)
  800e45:	e8 0d f5 ff ff       	call   800357 <fd2num>
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4f:	83 c4 04             	add    $0x4,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	e8 fd f4 ff ff       	call   800357 <fd2num>
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	e9 4f ff ff ff       	jmp    800dbc <pipe+0x75>
	sys_page_unmap(0, va);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 73 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 63 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	e9 1c ff ff ff       	jmp    800dac <pipe+0x65>

00800e90 <pipeisclosed>:
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e99:	50                   	push   %eax
  800e9a:	ff 75 08             	pushl  0x8(%ebp)
  800e9d:	e8 2b f5 ff ff       	call   8003cd <fd_lookup>
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 18                	js     800ec1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaf:	e8 b3 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb9:	e8 30 fd ff ff       	call   800bee <_pipeisclosed>
  800ebe:	83 c4 10             	add    $0x10,%esp
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed3:	68 36 1f 80 00       	push   $0x801f36
  800ed8:	ff 75 0c             	pushl  0xc(%ebp)
  800edb:	e8 5a 08 00 00       	call   80173a <strcpy>
	return 0;
}
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <devcons_write>:
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ef3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ef8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800efe:	eb 2f                	jmp    800f2f <devcons_write+0x48>
		m = n - tot;
  800f00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f03:	29 f3                	sub    %esi,%ebx
  800f05:	83 fb 7f             	cmp    $0x7f,%ebx
  800f08:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f0d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f10:	83 ec 04             	sub    $0x4,%esp
  800f13:	53                   	push   %ebx
  800f14:	89 f0                	mov    %esi,%eax
  800f16:	03 45 0c             	add    0xc(%ebp),%eax
  800f19:	50                   	push   %eax
  800f1a:	57                   	push   %edi
  800f1b:	e8 a8 09 00 00       	call   8018c8 <memmove>
		sys_cputs(buf, m);
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	53                   	push   %ebx
  800f24:	57                   	push   %edi
  800f25:	e8 80 f1 ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f2a:	01 de                	add    %ebx,%esi
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f32:	72 cc                	jb     800f00 <devcons_write+0x19>
}
  800f34:	89 f0                	mov    %esi,%eax
  800f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <devcons_read>:
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4d:	75 07                	jne    800f56 <devcons_read+0x18>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    
		sys_yield();
  800f51:	e8 f1 f1 ff ff       	call   800147 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f56:	e8 6d f1 ff ff       	call   8000c8 <sys_cgetc>
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	74 f2                	je     800f51 <devcons_read+0x13>
	if (c < 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	78 ec                	js     800f4f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f63:	83 f8 04             	cmp    $0x4,%eax
  800f66:	74 0c                	je     800f74 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6b:	88 02                	mov    %al,(%edx)
	return 1;
  800f6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f72:	eb db                	jmp    800f4f <devcons_read+0x11>
		return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	eb d4                	jmp    800f4f <devcons_read+0x11>

00800f7b <cputchar>:
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f87:	6a 01                	push   $0x1
  800f89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	e8 18 f1 ff ff       	call   8000aa <sys_cputs>
}
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <getchar>:
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f9d:	6a 01                	push   $0x1
  800f9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 94 f6 ff ff       	call   80063e <read>
	if (r < 0)
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 08                	js     800fb9 <getchar+0x22>
	if (r < 1)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	7e 06                	jle    800fbb <getchar+0x24>
	return c;
  800fb5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    
		return -E_EOF;
  800fbb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fc0:	eb f7                	jmp    800fb9 <getchar+0x22>

00800fc2 <iscons>:
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 75 08             	pushl  0x8(%ebp)
  800fcf:	e8 f9 f3 ff ff       	call   8003cd <fd_lookup>
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 11                	js     800fec <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fde:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe4:	39 10                	cmp    %edx,(%eax)
  800fe6:	0f 94 c0             	sete   %al
  800fe9:	0f b6 c0             	movzbl %al,%eax
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    

00800fee <opencons>:
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff7:	50                   	push   %eax
  800ff8:	e8 81 f3 ff ff       	call   80037e <fd_alloc>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 3a                	js     80103e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 07 04 00 00       	push   $0x407
  80100c:	ff 75 f4             	pushl  -0xc(%ebp)
  80100f:	6a 00                	push   $0x0
  801011:	e8 50 f1 ff ff       	call   800166 <sys_page_alloc>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 21                	js     80103e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801026:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	e8 1c f3 ff ff       	call   800357 <fd2num>
  80103b:	83 c4 10             	add    $0x10,%esp
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	56                   	push   %esi
  801044:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801045:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801048:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104e:	e8 d5 f0 ff ff       	call   800128 <sys_getenvid>
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	ff 75 0c             	pushl  0xc(%ebp)
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	56                   	push   %esi
  80105d:	50                   	push   %eax
  80105e:	68 44 1f 80 00       	push   $0x801f44
  801063:	e8 b3 00 00 00       	call   80111b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801068:	83 c4 18             	add    $0x18,%esp
  80106b:	53                   	push   %ebx
  80106c:	ff 75 10             	pushl  0x10(%ebp)
  80106f:	e8 56 00 00 00       	call   8010ca <vcprintf>
	cprintf("\n");
  801074:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80107b:	e8 9b 00 00 00       	call   80111b <cprintf>
  801080:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801083:	cc                   	int3   
  801084:	eb fd                	jmp    801083 <_panic+0x43>

00801086 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	53                   	push   %ebx
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801090:	8b 13                	mov    (%ebx),%edx
  801092:	8d 42 01             	lea    0x1(%edx),%eax
  801095:	89 03                	mov    %eax,(%ebx)
  801097:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a3:	74 09                	je     8010ae <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010a5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ac:	c9                   	leave  
  8010ad:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	68 ff 00 00 00       	push   $0xff
  8010b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b9:	50                   	push   %eax
  8010ba:	e8 eb ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	eb db                	jmp    8010a5 <putch+0x1f>

008010ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010da:	00 00 00 
	b.cnt = 0;
  8010dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ea:	ff 75 08             	pushl  0x8(%ebp)
  8010ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f3:	50                   	push   %eax
  8010f4:	68 86 10 80 00       	push   $0x801086
  8010f9:	e8 1a 01 00 00       	call   801218 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801107:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	e8 97 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801113:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801121:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801124:	50                   	push   %eax
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	e8 9d ff ff ff       	call   8010ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 1c             	sub    $0x1c,%esp
  801138:	89 c7                	mov    %eax,%edi
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801142:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801145:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801148:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801150:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801153:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801156:	39 d3                	cmp    %edx,%ebx
  801158:	72 05                	jb     80115f <printnum+0x30>
  80115a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115d:	77 7a                	ja     8011d9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	ff 75 18             	pushl  0x18(%ebp)
  801165:	8b 45 14             	mov    0x14(%ebp),%eax
  801168:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116b:	53                   	push   %ebx
  80116c:	ff 75 10             	pushl  0x10(%ebp)
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	ff 75 e0             	pushl  -0x20(%ebp)
  801178:	ff 75 dc             	pushl  -0x24(%ebp)
  80117b:	ff 75 d8             	pushl  -0x28(%ebp)
  80117e:	e8 1d 0a 00 00       	call   801ba0 <__udivdi3>
  801183:	83 c4 18             	add    $0x18,%esp
  801186:	52                   	push   %edx
  801187:	50                   	push   %eax
  801188:	89 f2                	mov    %esi,%edx
  80118a:	89 f8                	mov    %edi,%eax
  80118c:	e8 9e ff ff ff       	call   80112f <printnum>
  801191:	83 c4 20             	add    $0x20,%esp
  801194:	eb 13                	jmp    8011a9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	56                   	push   %esi
  80119a:	ff 75 18             	pushl  0x18(%ebp)
  80119d:	ff d7                	call   *%edi
  80119f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011a2:	83 eb 01             	sub    $0x1,%ebx
  8011a5:	85 db                	test   %ebx,%ebx
  8011a7:	7f ed                	jg     801196 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	56                   	push   %esi
  8011ad:	83 ec 04             	sub    $0x4,%esp
  8011b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bc:	e8 ff 0a 00 00       	call   801cc0 <__umoddi3>
  8011c1:	83 c4 14             	add    $0x14,%esp
  8011c4:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff d7                	call   *%edi
}
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    
  8011d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011dc:	eb c4                	jmp    8011a2 <printnum+0x73>

008011de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e8:	8b 10                	mov    (%eax),%edx
  8011ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ed:	73 0a                	jae    8011f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f2:	89 08                	mov    %ecx,(%eax)
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	88 02                	mov    %al,(%edx)
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <printfmt>:
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801201:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801204:	50                   	push   %eax
  801205:	ff 75 10             	pushl  0x10(%ebp)
  801208:	ff 75 0c             	pushl  0xc(%ebp)
  80120b:	ff 75 08             	pushl  0x8(%ebp)
  80120e:	e8 05 00 00 00       	call   801218 <vprintfmt>
}
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <vprintfmt>:
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
  80121e:	83 ec 2c             	sub    $0x2c,%esp
  801221:	8b 75 08             	mov    0x8(%ebp),%esi
  801224:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801227:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122a:	e9 c1 03 00 00       	jmp    8015f0 <vprintfmt+0x3d8>
		padc = ' ';
  80122f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801233:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80123a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801241:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801248:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80124d:	8d 47 01             	lea    0x1(%edi),%eax
  801250:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801253:	0f b6 17             	movzbl (%edi),%edx
  801256:	8d 42 dd             	lea    -0x23(%edx),%eax
  801259:	3c 55                	cmp    $0x55,%al
  80125b:	0f 87 12 04 00 00    	ja     801673 <vprintfmt+0x45b>
  801261:	0f b6 c0             	movzbl %al,%eax
  801264:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80126b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80126e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801272:	eb d9                	jmp    80124d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801277:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80127b:	eb d0                	jmp    80124d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80127d:	0f b6 d2             	movzbl %dl,%edx
  801280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
  801288:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80128b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80128e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801292:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801295:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801298:	83 f9 09             	cmp    $0x9,%ecx
  80129b:	77 55                	ja     8012f2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80129d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8012a0:	eb e9                	jmp    80128b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8012a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a5:	8b 00                	mov    (%eax),%eax
  8012a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ad:	8d 40 04             	lea    0x4(%eax),%eax
  8012b0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012ba:	79 91                	jns    80124d <vprintfmt+0x35>
				width = precision, precision = -1;
  8012bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012c9:	eb 82                	jmp    80124d <vprintfmt+0x35>
  8012cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d5:	0f 49 d0             	cmovns %eax,%edx
  8012d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012de:	e9 6a ff ff ff       	jmp    80124d <vprintfmt+0x35>
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ed:	e9 5b ff ff ff       	jmp    80124d <vprintfmt+0x35>
  8012f2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012f8:	eb bc                	jmp    8012b6 <vprintfmt+0x9e>
			lflag++;
  8012fa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801300:	e9 48 ff ff ff       	jmp    80124d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801305:	8b 45 14             	mov    0x14(%ebp),%eax
  801308:	8d 78 04             	lea    0x4(%eax),%edi
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	53                   	push   %ebx
  80130f:	ff 30                	pushl  (%eax)
  801311:	ff d6                	call   *%esi
			break;
  801313:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801316:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801319:	e9 cf 02 00 00       	jmp    8015ed <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80131e:	8b 45 14             	mov    0x14(%ebp),%eax
  801321:	8d 78 04             	lea    0x4(%eax),%edi
  801324:	8b 00                	mov    (%eax),%eax
  801326:	99                   	cltd   
  801327:	31 d0                	xor    %edx,%eax
  801329:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80132b:	83 f8 0f             	cmp    $0xf,%eax
  80132e:	7f 23                	jg     801353 <vprintfmt+0x13b>
  801330:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801337:	85 d2                	test   %edx,%edx
  801339:	74 18                	je     801353 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80133b:	52                   	push   %edx
  80133c:	68 bd 1e 80 00       	push   $0x801ebd
  801341:	53                   	push   %ebx
  801342:	56                   	push   %esi
  801343:	e8 b3 fe ff ff       	call   8011fb <printfmt>
  801348:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80134b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80134e:	e9 9a 02 00 00       	jmp    8015ed <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801353:	50                   	push   %eax
  801354:	68 7f 1f 80 00       	push   $0x801f7f
  801359:	53                   	push   %ebx
  80135a:	56                   	push   %esi
  80135b:	e8 9b fe ff ff       	call   8011fb <printfmt>
  801360:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801363:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801366:	e9 82 02 00 00       	jmp    8015ed <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	83 c0 04             	add    $0x4,%eax
  801371:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801374:	8b 45 14             	mov    0x14(%ebp),%eax
  801377:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801379:	85 ff                	test   %edi,%edi
  80137b:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801380:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801383:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801387:	0f 8e bd 00 00 00    	jle    80144a <vprintfmt+0x232>
  80138d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801391:	75 0e                	jne    8013a1 <vprintfmt+0x189>
  801393:	89 75 08             	mov    %esi,0x8(%ebp)
  801396:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801399:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80139c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80139f:	eb 6d                	jmp    80140e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8013a7:	57                   	push   %edi
  8013a8:	e8 6e 03 00 00       	call   80171b <strnlen>
  8013ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b0:	29 c1                	sub    %eax,%ecx
  8013b2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013c2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	eb 0f                	jmp    8013d5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8013cd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cf:	83 ef 01             	sub    $0x1,%edi
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	85 ff                	test   %edi,%edi
  8013d7:	7f ed                	jg     8013c6 <vprintfmt+0x1ae>
  8013d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013df:	85 c9                	test   %ecx,%ecx
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e6:	0f 49 c1             	cmovns %ecx,%eax
  8013e9:	29 c1                	sub    %eax,%ecx
  8013eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8013ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013f4:	89 cb                	mov    %ecx,%ebx
  8013f6:	eb 16                	jmp    80140e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013fc:	75 31                	jne    80142f <vprintfmt+0x217>
					putch(ch, putdat);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	50                   	push   %eax
  801405:	ff 55 08             	call   *0x8(%ebp)
  801408:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80140b:	83 eb 01             	sub    $0x1,%ebx
  80140e:	83 c7 01             	add    $0x1,%edi
  801411:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801415:	0f be c2             	movsbl %dl,%eax
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 59                	je     801475 <vprintfmt+0x25d>
  80141c:	85 f6                	test   %esi,%esi
  80141e:	78 d8                	js     8013f8 <vprintfmt+0x1e0>
  801420:	83 ee 01             	sub    $0x1,%esi
  801423:	79 d3                	jns    8013f8 <vprintfmt+0x1e0>
  801425:	89 df                	mov    %ebx,%edi
  801427:	8b 75 08             	mov    0x8(%ebp),%esi
  80142a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80142d:	eb 37                	jmp    801466 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80142f:	0f be d2             	movsbl %dl,%edx
  801432:	83 ea 20             	sub    $0x20,%edx
  801435:	83 fa 5e             	cmp    $0x5e,%edx
  801438:	76 c4                	jbe    8013fe <vprintfmt+0x1e6>
					putch('?', putdat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	ff 75 0c             	pushl  0xc(%ebp)
  801440:	6a 3f                	push   $0x3f
  801442:	ff 55 08             	call   *0x8(%ebp)
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	eb c1                	jmp    80140b <vprintfmt+0x1f3>
  80144a:	89 75 08             	mov    %esi,0x8(%ebp)
  80144d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801450:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801453:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801456:	eb b6                	jmp    80140e <vprintfmt+0x1f6>
				putch(' ', putdat);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	53                   	push   %ebx
  80145c:	6a 20                	push   $0x20
  80145e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801460:	83 ef 01             	sub    $0x1,%edi
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 ff                	test   %edi,%edi
  801468:	7f ee                	jg     801458 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80146a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80146d:	89 45 14             	mov    %eax,0x14(%ebp)
  801470:	e9 78 01 00 00       	jmp    8015ed <vprintfmt+0x3d5>
  801475:	89 df                	mov    %ebx,%edi
  801477:	8b 75 08             	mov    0x8(%ebp),%esi
  80147a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147d:	eb e7                	jmp    801466 <vprintfmt+0x24e>
	if (lflag >= 2)
  80147f:	83 f9 01             	cmp    $0x1,%ecx
  801482:	7e 3f                	jle    8014c3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801484:	8b 45 14             	mov    0x14(%ebp),%eax
  801487:	8b 50 04             	mov    0x4(%eax),%edx
  80148a:	8b 00                	mov    (%eax),%eax
  80148c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801492:	8b 45 14             	mov    0x14(%ebp),%eax
  801495:	8d 40 08             	lea    0x8(%eax),%eax
  801498:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80149b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80149f:	79 5c                	jns    8014fd <vprintfmt+0x2e5>
				putch('-', putdat);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	6a 2d                	push   $0x2d
  8014a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8014a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014af:	f7 da                	neg    %edx
  8014b1:	83 d1 00             	adc    $0x0,%ecx
  8014b4:	f7 d9                	neg    %ecx
  8014b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014be:	e9 10 01 00 00       	jmp    8015d3 <vprintfmt+0x3bb>
	else if (lflag)
  8014c3:	85 c9                	test   %ecx,%ecx
  8014c5:	75 1b                	jne    8014e2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ca:	8b 00                	mov    (%eax),%eax
  8014cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cf:	89 c1                	mov    %eax,%ecx
  8014d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8d 40 04             	lea    0x4(%eax),%eax
  8014dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e0:	eb b9                	jmp    80149b <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8b 00                	mov    (%eax),%eax
  8014e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ea:	89 c1                	mov    %eax,%ecx
  8014ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 40 04             	lea    0x4(%eax),%eax
  8014f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014fb:	eb 9e                	jmp    80149b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801500:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801503:	b8 0a 00 00 00       	mov    $0xa,%eax
  801508:	e9 c6 00 00 00       	jmp    8015d3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80150d:	83 f9 01             	cmp    $0x1,%ecx
  801510:	7e 18                	jle    80152a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8b 10                	mov    (%eax),%edx
  801517:	8b 48 04             	mov    0x4(%eax),%ecx
  80151a:	8d 40 08             	lea    0x8(%eax),%eax
  80151d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801520:	b8 0a 00 00 00       	mov    $0xa,%eax
  801525:	e9 a9 00 00 00       	jmp    8015d3 <vprintfmt+0x3bb>
	else if (lflag)
  80152a:	85 c9                	test   %ecx,%ecx
  80152c:	75 1a                	jne    801548 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80152e:	8b 45 14             	mov    0x14(%ebp),%eax
  801531:	8b 10                	mov    (%eax),%edx
  801533:	b9 00 00 00 00       	mov    $0x0,%ecx
  801538:	8d 40 04             	lea    0x4(%eax),%eax
  80153b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80153e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801543:	e9 8b 00 00 00       	jmp    8015d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8b 10                	mov    (%eax),%edx
  80154d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801552:	8d 40 04             	lea    0x4(%eax),%eax
  801555:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801558:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155d:	eb 74                	jmp    8015d3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80155f:	83 f9 01             	cmp    $0x1,%ecx
  801562:	7e 15                	jle    801579 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801564:	8b 45 14             	mov    0x14(%ebp),%eax
  801567:	8b 10                	mov    (%eax),%edx
  801569:	8b 48 04             	mov    0x4(%eax),%ecx
  80156c:	8d 40 08             	lea    0x8(%eax),%eax
  80156f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801572:	b8 08 00 00 00       	mov    $0x8,%eax
  801577:	eb 5a                	jmp    8015d3 <vprintfmt+0x3bb>
	else if (lflag)
  801579:	85 c9                	test   %ecx,%ecx
  80157b:	75 17                	jne    801594 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80157d:	8b 45 14             	mov    0x14(%ebp),%eax
  801580:	8b 10                	mov    (%eax),%edx
  801582:	b9 00 00 00 00       	mov    $0x0,%ecx
  801587:	8d 40 04             	lea    0x4(%eax),%eax
  80158a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80158d:	b8 08 00 00 00       	mov    $0x8,%eax
  801592:	eb 3f                	jmp    8015d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801594:	8b 45 14             	mov    0x14(%ebp),%eax
  801597:	8b 10                	mov    (%eax),%edx
  801599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159e:	8d 40 04             	lea    0x4(%eax),%eax
  8015a1:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8015a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a9:	eb 28                	jmp    8015d3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	6a 30                	push   $0x30
  8015b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b3:	83 c4 08             	add    $0x8,%esp
  8015b6:	53                   	push   %ebx
  8015b7:	6a 78                	push   $0x78
  8015b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015be:	8b 10                	mov    (%eax),%edx
  8015c0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015c5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015c8:	8d 40 04             	lea    0x4(%eax),%eax
  8015cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ce:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015da:	57                   	push   %edi
  8015db:	ff 75 e0             	pushl  -0x20(%ebp)
  8015de:	50                   	push   %eax
  8015df:	51                   	push   %ecx
  8015e0:	52                   	push   %edx
  8015e1:	89 da                	mov    %ebx,%edx
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	e8 45 fb ff ff       	call   80112f <printnum>
			break;
  8015ea:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f0:	83 c7 01             	add    $0x1,%edi
  8015f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015f7:	83 f8 25             	cmp    $0x25,%eax
  8015fa:	0f 84 2f fc ff ff    	je     80122f <vprintfmt+0x17>
			if (ch == '\0')
  801600:	85 c0                	test   %eax,%eax
  801602:	0f 84 8b 00 00 00    	je     801693 <vprintfmt+0x47b>
			putch(ch, putdat);
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	53                   	push   %ebx
  80160c:	50                   	push   %eax
  80160d:	ff d6                	call   *%esi
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb dc                	jmp    8015f0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801614:	83 f9 01             	cmp    $0x1,%ecx
  801617:	7e 15                	jle    80162e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801619:	8b 45 14             	mov    0x14(%ebp),%eax
  80161c:	8b 10                	mov    (%eax),%edx
  80161e:	8b 48 04             	mov    0x4(%eax),%ecx
  801621:	8d 40 08             	lea    0x8(%eax),%eax
  801624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801627:	b8 10 00 00 00       	mov    $0x10,%eax
  80162c:	eb a5                	jmp    8015d3 <vprintfmt+0x3bb>
	else if (lflag)
  80162e:	85 c9                	test   %ecx,%ecx
  801630:	75 17                	jne    801649 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801632:	8b 45 14             	mov    0x14(%ebp),%eax
  801635:	8b 10                	mov    (%eax),%edx
  801637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80163c:	8d 40 04             	lea    0x4(%eax),%eax
  80163f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801642:	b8 10 00 00 00       	mov    $0x10,%eax
  801647:	eb 8a                	jmp    8015d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801649:	8b 45 14             	mov    0x14(%ebp),%eax
  80164c:	8b 10                	mov    (%eax),%edx
  80164e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801653:	8d 40 04             	lea    0x4(%eax),%eax
  801656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801659:	b8 10 00 00 00       	mov    $0x10,%eax
  80165e:	e9 70 ff ff ff       	jmp    8015d3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	6a 25                	push   $0x25
  801669:	ff d6                	call   *%esi
			break;
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	e9 7a ff ff ff       	jmp    8015ed <vprintfmt+0x3d5>
			putch('%', putdat);
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	53                   	push   %ebx
  801677:	6a 25                	push   $0x25
  801679:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	89 f8                	mov    %edi,%eax
  801680:	eb 03                	jmp    801685 <vprintfmt+0x46d>
  801682:	83 e8 01             	sub    $0x1,%eax
  801685:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801689:	75 f7                	jne    801682 <vprintfmt+0x46a>
  80168b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80168e:	e9 5a ff ff ff       	jmp    8015ed <vprintfmt+0x3d5>
}
  801693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 18             	sub    $0x18,%esp
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	74 26                	je     8016e2 <vsnprintf+0x47>
  8016bc:	85 d2                	test   %edx,%edx
  8016be:	7e 22                	jle    8016e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016c0:	ff 75 14             	pushl  0x14(%ebp)
  8016c3:	ff 75 10             	pushl  0x10(%ebp)
  8016c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	68 de 11 80 00       	push   $0x8011de
  8016cf:	e8 44 fb ff ff       	call   801218 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016dd:	83 c4 10             	add    $0x10,%esp
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    
		return -E_INVAL;
  8016e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e7:	eb f7                	jmp    8016e0 <vsnprintf+0x45>

008016e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 10             	pushl  0x10(%ebp)
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 9a ff ff ff       	call   80169b <vsnprintf>
	va_end(ap);

	return rc;
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
  80170e:	eb 03                	jmp    801713 <strlen+0x10>
		n++;
  801710:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801713:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801717:	75 f7                	jne    801710 <strlen+0xd>
	return n;
}
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801721:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801724:	b8 00 00 00 00       	mov    $0x0,%eax
  801729:	eb 03                	jmp    80172e <strnlen+0x13>
		n++;
  80172b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80172e:	39 d0                	cmp    %edx,%eax
  801730:	74 06                	je     801738 <strnlen+0x1d>
  801732:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801736:	75 f3                	jne    80172b <strnlen+0x10>
	return n;
}
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801744:	89 c2                	mov    %eax,%edx
  801746:	83 c1 01             	add    $0x1,%ecx
  801749:	83 c2 01             	add    $0x1,%edx
  80174c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801750:	88 5a ff             	mov    %bl,-0x1(%edx)
  801753:	84 db                	test   %bl,%bl
  801755:	75 ef                	jne    801746 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801757:	5b                   	pop    %ebx
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801761:	53                   	push   %ebx
  801762:	e8 9c ff ff ff       	call   801703 <strlen>
  801767:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	01 d8                	add    %ebx,%eax
  80176f:	50                   	push   %eax
  801770:	e8 c5 ff ff ff       	call   80173a <strcpy>
	return dst;
}
  801775:	89 d8                	mov    %ebx,%eax
  801777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	8b 75 08             	mov    0x8(%ebp),%esi
  801784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801787:	89 f3                	mov    %esi,%ebx
  801789:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80178c:	89 f2                	mov    %esi,%edx
  80178e:	eb 0f                	jmp    80179f <strncpy+0x23>
		*dst++ = *src;
  801790:	83 c2 01             	add    $0x1,%edx
  801793:	0f b6 01             	movzbl (%ecx),%eax
  801796:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801799:	80 39 01             	cmpb   $0x1,(%ecx)
  80179c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80179f:	39 da                	cmp    %ebx,%edx
  8017a1:	75 ed                	jne    801790 <strncpy+0x14>
	}
	return ret;
}
  8017a3:	89 f0                	mov    %esi,%eax
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8017b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017b7:	89 f0                	mov    %esi,%eax
  8017b9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017bd:	85 c9                	test   %ecx,%ecx
  8017bf:	75 0b                	jne    8017cc <strlcpy+0x23>
  8017c1:	eb 17                	jmp    8017da <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017c3:	83 c2 01             	add    $0x1,%edx
  8017c6:	83 c0 01             	add    $0x1,%eax
  8017c9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017cc:	39 d8                	cmp    %ebx,%eax
  8017ce:	74 07                	je     8017d7 <strlcpy+0x2e>
  8017d0:	0f b6 0a             	movzbl (%edx),%ecx
  8017d3:	84 c9                	test   %cl,%cl
  8017d5:	75 ec                	jne    8017c3 <strlcpy+0x1a>
		*dst = '\0';
  8017d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017da:	29 f0                	sub    %esi,%eax
}
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017e9:	eb 06                	jmp    8017f1 <strcmp+0x11>
		p++, q++;
  8017eb:	83 c1 01             	add    $0x1,%ecx
  8017ee:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017f1:	0f b6 01             	movzbl (%ecx),%eax
  8017f4:	84 c0                	test   %al,%al
  8017f6:	74 04                	je     8017fc <strcmp+0x1c>
  8017f8:	3a 02                	cmp    (%edx),%al
  8017fa:	74 ef                	je     8017eb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017fc:	0f b6 c0             	movzbl %al,%eax
  8017ff:	0f b6 12             	movzbl (%edx),%edx
  801802:	29 d0                	sub    %edx,%eax
}
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801810:	89 c3                	mov    %eax,%ebx
  801812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801815:	eb 06                	jmp    80181d <strncmp+0x17>
		n--, p++, q++;
  801817:	83 c0 01             	add    $0x1,%eax
  80181a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80181d:	39 d8                	cmp    %ebx,%eax
  80181f:	74 16                	je     801837 <strncmp+0x31>
  801821:	0f b6 08             	movzbl (%eax),%ecx
  801824:	84 c9                	test   %cl,%cl
  801826:	74 04                	je     80182c <strncmp+0x26>
  801828:	3a 0a                	cmp    (%edx),%cl
  80182a:	74 eb                	je     801817 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80182c:	0f b6 00             	movzbl (%eax),%eax
  80182f:	0f b6 12             	movzbl (%edx),%edx
  801832:	29 d0                	sub    %edx,%eax
}
  801834:	5b                   	pop    %ebx
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    
		return 0;
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
  80183c:	eb f6                	jmp    801834 <strncmp+0x2e>

0080183e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801848:	0f b6 10             	movzbl (%eax),%edx
  80184b:	84 d2                	test   %dl,%dl
  80184d:	74 09                	je     801858 <strchr+0x1a>
		if (*s == c)
  80184f:	38 ca                	cmp    %cl,%dl
  801851:	74 0a                	je     80185d <strchr+0x1f>
	for (; *s; s++)
  801853:	83 c0 01             	add    $0x1,%eax
  801856:	eb f0                	jmp    801848 <strchr+0xa>
			return (char *) s;
	return 0;
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801869:	eb 03                	jmp    80186e <strfind+0xf>
  80186b:	83 c0 01             	add    $0x1,%eax
  80186e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801871:	38 ca                	cmp    %cl,%dl
  801873:	74 04                	je     801879 <strfind+0x1a>
  801875:	84 d2                	test   %dl,%dl
  801877:	75 f2                	jne    80186b <strfind+0xc>
			break;
	return (char *) s;
}
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	57                   	push   %edi
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	8b 7d 08             	mov    0x8(%ebp),%edi
  801884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801887:	85 c9                	test   %ecx,%ecx
  801889:	74 13                	je     80189e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80188b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801891:	75 05                	jne    801898 <memset+0x1d>
  801893:	f6 c1 03             	test   $0x3,%cl
  801896:	74 0d                	je     8018a5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189b:	fc                   	cld    
  80189c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80189e:	89 f8                	mov    %edi,%eax
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    
		c &= 0xFF;
  8018a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018a9:	89 d3                	mov    %edx,%ebx
  8018ab:	c1 e3 08             	shl    $0x8,%ebx
  8018ae:	89 d0                	mov    %edx,%eax
  8018b0:	c1 e0 18             	shl    $0x18,%eax
  8018b3:	89 d6                	mov    %edx,%esi
  8018b5:	c1 e6 10             	shl    $0x10,%esi
  8018b8:	09 f0                	or     %esi,%eax
  8018ba:	09 c2                	or     %eax,%edx
  8018bc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018be:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018c1:	89 d0                	mov    %edx,%eax
  8018c3:	fc                   	cld    
  8018c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8018c6:	eb d6                	jmp    80189e <memset+0x23>

008018c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	57                   	push   %edi
  8018cc:	56                   	push   %esi
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018d6:	39 c6                	cmp    %eax,%esi
  8018d8:	73 35                	jae    80190f <memmove+0x47>
  8018da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018dd:	39 c2                	cmp    %eax,%edx
  8018df:	76 2e                	jbe    80190f <memmove+0x47>
		s += n;
		d += n;
  8018e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e4:	89 d6                	mov    %edx,%esi
  8018e6:	09 fe                	or     %edi,%esi
  8018e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ee:	74 0c                	je     8018fc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018f0:	83 ef 01             	sub    $0x1,%edi
  8018f3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018f6:	fd                   	std    
  8018f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f9:	fc                   	cld    
  8018fa:	eb 21                	jmp    80191d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fc:	f6 c1 03             	test   $0x3,%cl
  8018ff:	75 ef                	jne    8018f0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801901:	83 ef 04             	sub    $0x4,%edi
  801904:	8d 72 fc             	lea    -0x4(%edx),%esi
  801907:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80190a:	fd                   	std    
  80190b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190d:	eb ea                	jmp    8018f9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80190f:	89 f2                	mov    %esi,%edx
  801911:	09 c2                	or     %eax,%edx
  801913:	f6 c2 03             	test   $0x3,%dl
  801916:	74 09                	je     801921 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801918:	89 c7                	mov    %eax,%edi
  80191a:	fc                   	cld    
  80191b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80191d:	5e                   	pop    %esi
  80191e:	5f                   	pop    %edi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801921:	f6 c1 03             	test   $0x3,%cl
  801924:	75 f2                	jne    801918 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801926:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801929:	89 c7                	mov    %eax,%edi
  80192b:	fc                   	cld    
  80192c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80192e:	eb ed                	jmp    80191d <memmove+0x55>

00801930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801933:	ff 75 10             	pushl  0x10(%ebp)
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	ff 75 08             	pushl  0x8(%ebp)
  80193c:	e8 87 ff ff ff       	call   8018c8 <memmove>
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	56                   	push   %esi
  801947:	53                   	push   %ebx
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194e:	89 c6                	mov    %eax,%esi
  801950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801953:	39 f0                	cmp    %esi,%eax
  801955:	74 1c                	je     801973 <memcmp+0x30>
		if (*s1 != *s2)
  801957:	0f b6 08             	movzbl (%eax),%ecx
  80195a:	0f b6 1a             	movzbl (%edx),%ebx
  80195d:	38 d9                	cmp    %bl,%cl
  80195f:	75 08                	jne    801969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801961:	83 c0 01             	add    $0x1,%eax
  801964:	83 c2 01             	add    $0x1,%edx
  801967:	eb ea                	jmp    801953 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801969:	0f b6 c1             	movzbl %cl,%eax
  80196c:	0f b6 db             	movzbl %bl,%ebx
  80196f:	29 d8                	sub    %ebx,%eax
  801971:	eb 05                	jmp    801978 <memcmp+0x35>
	}

	return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801985:	89 c2                	mov    %eax,%edx
  801987:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80198a:	39 d0                	cmp    %edx,%eax
  80198c:	73 09                	jae    801997 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80198e:	38 08                	cmp    %cl,(%eax)
  801990:	74 05                	je     801997 <memfind+0x1b>
	for (; s < ends; s++)
  801992:	83 c0 01             	add    $0x1,%eax
  801995:	eb f3                	jmp    80198a <memfind+0xe>
			break;
	return (void *) s;
}
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	57                   	push   %edi
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a5:	eb 03                	jmp    8019aa <strtol+0x11>
		s++;
  8019a7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019aa:	0f b6 01             	movzbl (%ecx),%eax
  8019ad:	3c 20                	cmp    $0x20,%al
  8019af:	74 f6                	je     8019a7 <strtol+0xe>
  8019b1:	3c 09                	cmp    $0x9,%al
  8019b3:	74 f2                	je     8019a7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019b5:	3c 2b                	cmp    $0x2b,%al
  8019b7:	74 2e                	je     8019e7 <strtol+0x4e>
	int neg = 0;
  8019b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019be:	3c 2d                	cmp    $0x2d,%al
  8019c0:	74 2f                	je     8019f1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c8:	75 05                	jne    8019cf <strtol+0x36>
  8019ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cd:	74 2c                	je     8019fb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019cf:	85 db                	test   %ebx,%ebx
  8019d1:	75 0a                	jne    8019dd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019db:	74 28                	je     801a05 <strtol+0x6c>
		base = 10;
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019e5:	eb 50                	jmp    801a37 <strtol+0x9e>
		s++;
  8019e7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ef:	eb d1                	jmp    8019c2 <strtol+0x29>
		s++, neg = 1;
  8019f1:	83 c1 01             	add    $0x1,%ecx
  8019f4:	bf 01 00 00 00       	mov    $0x1,%edi
  8019f9:	eb c7                	jmp    8019c2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019fb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ff:	74 0e                	je     801a0f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a01:	85 db                	test   %ebx,%ebx
  801a03:	75 d8                	jne    8019dd <strtol+0x44>
		s++, base = 8;
  801a05:	83 c1 01             	add    $0x1,%ecx
  801a08:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a0d:	eb ce                	jmp    8019dd <strtol+0x44>
		s += 2, base = 16;
  801a0f:	83 c1 02             	add    $0x2,%ecx
  801a12:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a17:	eb c4                	jmp    8019dd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a19:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a1c:	89 f3                	mov    %esi,%ebx
  801a1e:	80 fb 19             	cmp    $0x19,%bl
  801a21:	77 29                	ja     801a4c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a23:	0f be d2             	movsbl %dl,%edx
  801a26:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a29:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2c:	7d 30                	jge    801a5e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a2e:	83 c1 01             	add    $0x1,%ecx
  801a31:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a35:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a37:	0f b6 11             	movzbl (%ecx),%edx
  801a3a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a3d:	89 f3                	mov    %esi,%ebx
  801a3f:	80 fb 09             	cmp    $0x9,%bl
  801a42:	77 d5                	ja     801a19 <strtol+0x80>
			dig = *s - '0';
  801a44:	0f be d2             	movsbl %dl,%edx
  801a47:	83 ea 30             	sub    $0x30,%edx
  801a4a:	eb dd                	jmp    801a29 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a4f:	89 f3                	mov    %esi,%ebx
  801a51:	80 fb 19             	cmp    $0x19,%bl
  801a54:	77 08                	ja     801a5e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a56:	0f be d2             	movsbl %dl,%edx
  801a59:	83 ea 37             	sub    $0x37,%edx
  801a5c:	eb cb                	jmp    801a29 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a62:	74 05                	je     801a69 <strtol+0xd0>
		*endptr = (char *) s;
  801a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a67:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	f7 da                	neg    %edx
  801a6d:	85 ff                	test   %edi,%edi
  801a6f:	0f 45 c2             	cmovne %edx,%eax
}
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a85:	85 c0                	test   %eax,%eax
  801a87:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a8c:	0f 44 c2             	cmove  %edx,%eax
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	50                   	push   %eax
  801a93:	e8 7e e8 ff ff       	call   800316 <sys_ipc_recv>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 2b                	js     801aca <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a9f:	85 f6                	test   %esi,%esi
  801aa1:	74 0a                	je     801aad <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801aa3:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa8:	8b 40 74             	mov    0x74(%eax),%eax
  801aab:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	74 0a                	je     801abb <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab6:	8b 40 78             	mov    0x78(%eax),%eax
  801ab9:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    
        *from_env_store = 0;
  801aca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ad0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ad6:	eb eb                	jmp    801ac3 <ipc_recv+0x4c>

00801ad8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801aea:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801aec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801af4:	ff 75 14             	pushl  0x14(%ebp)
  801af7:	53                   	push   %ebx
  801af8:	56                   	push   %esi
  801af9:	57                   	push   %edi
  801afa:	e8 f4 e7 ff ff       	call   8002f3 <sys_ipc_try_send>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	74 17                	je     801b1d <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801b06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b09:	74 e9                	je     801af4 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801b0b:	50                   	push   %eax
  801b0c:	68 60 22 80 00       	push   $0x802260
  801b11:	6a 3e                	push   $0x3e
  801b13:	68 72 22 80 00       	push   $0x802272
  801b18:	e8 23 f5 ff ff       	call   801040 <_panic>
        }
    }
}
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b30:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b33:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b39:	8b 52 50             	mov    0x50(%edx),%edx
  801b3c:	39 ca                	cmp    %ecx,%edx
  801b3e:	74 11                	je     801b51 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b40:	83 c0 01             	add    $0x1,%eax
  801b43:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b48:	75 e6                	jne    801b30 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4f:	eb 0b                	jmp    801b5c <ipc_find_env+0x37>
			return envs[i].env_id;
  801b51:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b59:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b64:	89 d0                	mov    %edx,%eax
  801b66:	c1 e8 16             	shr    $0x16,%eax
  801b69:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b75:	f6 c1 01             	test   $0x1,%cl
  801b78:	74 1d                	je     801b97 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b7a:	c1 ea 0c             	shr    $0xc,%edx
  801b7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b84:	f6 c2 01             	test   $0x1,%dl
  801b87:	74 0e                	je     801b97 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b89:	c1 ea 0c             	shr    $0xc,%edx
  801b8c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b93:	ef 
  801b94:	0f b7 c0             	movzwl %ax,%eax
}
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    
  801b99:	66 90                	xchg   %ax,%ax
  801b9b:	66 90                	xchg   %ax,%ax
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
