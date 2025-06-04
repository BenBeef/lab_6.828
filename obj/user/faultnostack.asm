
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 33 08 00 00       	call   8008d8 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	b8 03 00 00 00       	mov    $0x3,%eax
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7f 08                	jg     80011b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	50                   	push   %eax
  80011f:	6a 03                	push   $0x3
  800121:	68 aa 21 80 00       	push   $0x8021aa
  800126:	6a 23                	push   $0x23
  800128:	68 c7 21 80 00       	push   $0x8021c7
  80012d:	e8 b9 12 00 00       	call   8013eb <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7f 08                	jg     80019c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	50                   	push   %eax
  8001a0:	6a 04                	push   $0x4
  8001a2:	68 aa 21 80 00       	push   $0x8021aa
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 c7 21 80 00       	push   $0x8021c7
  8001ae:	e8 38 12 00 00       	call   8013eb <_panic>

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7f 08                	jg     8001de <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	50                   	push   %eax
  8001e2:	6a 05                	push   $0x5
  8001e4:	68 aa 21 80 00       	push   $0x8021aa
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 c7 21 80 00       	push   $0x8021c7
  8001f0:	e8 f6 11 00 00       	call   8013eb <_panic>

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	b8 06 00 00 00       	mov    $0x6,%eax
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7f 08                	jg     800220 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 06                	push   $0x6
  800226:	68 aa 21 80 00       	push   $0x8021aa
  80022b:	6a 23                	push   $0x23
  80022d:	68 c7 21 80 00       	push   $0x8021c7
  800232:	e8 b4 11 00 00       	call   8013eb <_panic>

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	b8 08 00 00 00       	mov    $0x8,%eax
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7f 08                	jg     800262 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5f                   	pop    %edi
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	50                   	push   %eax
  800266:	6a 08                	push   $0x8
  800268:	68 aa 21 80 00       	push   $0x8021aa
  80026d:	6a 23                	push   $0x23
  80026f:	68 c7 21 80 00       	push   $0x8021c7
  800274:	e8 72 11 00 00       	call   8013eb <_panic>

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	b8 09 00 00 00       	mov    $0x9,%eax
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7f 08                	jg     8002a4 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	50                   	push   %eax
  8002a8:	6a 09                	push   $0x9
  8002aa:	68 aa 21 80 00       	push   $0x8021aa
  8002af:	6a 23                	push   $0x23
  8002b1:	68 c7 21 80 00       	push   $0x8021c7
  8002b6:	e8 30 11 00 00       	call   8013eb <_panic>

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0a                	push   $0xa
  8002ec:	68 aa 21 80 00       	push   $0x8021aa
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 c7 21 80 00       	push   $0x8021c7
  8002f8:	e8 ee 10 00 00       	call   8013eb <_panic>

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	asm volatile("int %1\n"
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	be 00 00 00 00       	mov    $0x0,%esi
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	b8 0d 00 00 00       	mov    $0xd,%eax
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7f 08                	jg     80034a <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	50                   	push   %eax
  80034e:	6a 0d                	push   $0xd
  800350:	68 aa 21 80 00       	push   $0x8021aa
  800355:	6a 23                	push   $0x23
  800357:	68 c7 21 80 00       	push   $0x8021c7
  80035c:	e8 8a 10 00 00       	call   8013eb <_panic>

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  80036c:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  80036f:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  800373:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  800377:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  80037a:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  80037e:	89 18                	mov    %ebx,(%eax)

    popal
  800380:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  800381:	83 c4 04             	add    $0x4,%esp
    popfl
  800384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  800385:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  800386:	c3                   	ret    

00800387 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	53                   	push   %ebx
  80038b:	83 ec 04             	sub    $0x4,%esp
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800391:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800393:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800396:	a8 02                	test   $0x2,%al
  800398:	0f 84 89 00 00 00    	je     800427 <pgfault+0xa0>
  80039e:	89 da                	mov    %ebx,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c6 08             	test   $0x8,%dh
  8003ad:	74 78                	je     800427 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	6a 07                	push   $0x7
  8003b4:	68 00 f0 7f 00       	push   $0x7ff000
  8003b9:	6a 00                	push   $0x0
  8003bb:	e8 b0 fd ff ff       	call   800170 <sys_page_alloc>
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 88 8b 00 00 00    	js     800456 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  8003cb:	83 ec 04             	sub    $0x4,%esp
  8003ce:	68 00 10 00 00       	push   $0x1000
  8003d3:	53                   	push   %ebx
  8003d4:	68 00 f0 7f 00       	push   $0x7ff000
  8003d9:	e8 95 18 00 00       	call   801c73 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8003de:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8003e5:	53                   	push   %ebx
  8003e6:	6a 00                	push   $0x0
  8003e8:	68 00 f0 7f 00       	push   $0x7ff000
  8003ed:	6a 00                	push   $0x0
  8003ef:	e8 bf fd ff ff       	call   8001b3 <sys_page_map>
  8003f4:	83 c4 20             	add    $0x20,%esp
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	78 6d                	js     800468 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	68 00 f0 7f 00       	push   $0x7ff000
  800403:	6a 00                	push   $0x0
  800405:	e8 eb fd ff ff       	call   8001f5 <sys_page_unmap>
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	85 c0                	test   %eax,%eax
  80040f:	78 69                	js     80047a <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	68 34 22 80 00       	push   $0x802234
  80041a:	e8 a7 10 00 00       	call   8014c6 <cprintf>

}
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800425:	c9                   	leave  
  800426:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800427:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80042d:	8b 4a 48             	mov    0x48(%edx),%ecx
  800430:	89 da                	mov    %ebx,%edx
  800432:	c1 ea 0c             	shr    $0xc,%edx
  800435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043c:	51                   	push   %ecx
  80043d:	53                   	push   %ebx
  80043e:	68 00 00 40 ef       	push   $0xef400000
  800443:	52                   	push   %edx
  800444:	50                   	push   %eax
  800445:	68 d8 21 80 00       	push   $0x8021d8
  80044a:	6a 1e                	push   $0x1e
  80044c:	68 55 22 80 00       	push   $0x802255
  800451:	e8 95 0f 00 00       	call   8013eb <_panic>
        panic("sys_page_alloc error %e", r);
  800456:	50                   	push   %eax
  800457:	68 60 22 80 00       	push   $0x802260
  80045c:	6a 28                	push   $0x28
  80045e:	68 55 22 80 00       	push   $0x802255
  800463:	e8 83 0f 00 00       	call   8013eb <_panic>
        panic("sys_page_map error %e", r);
  800468:	50                   	push   %eax
  800469:	68 78 22 80 00       	push   $0x802278
  80046e:	6a 2b                	push   $0x2b
  800470:	68 55 22 80 00       	push   $0x802255
  800475:	e8 71 0f 00 00       	call   8013eb <_panic>
        panic("sys_page_unmap error %e", r);
  80047a:	50                   	push   %eax
  80047b:	68 8e 22 80 00       	push   $0x80228e
  800480:	6a 2d                	push   $0x2d
  800482:	68 55 22 80 00       	push   $0x802255
  800487:	e8 5f 0f 00 00       	call   8013eb <_panic>

0080048c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800492:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800499:	74 23                	je     8004be <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80049b:	8b 45 08             	mov    0x8(%ebp),%eax
  80049e:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8004a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8004a8:	8b 40 48             	mov    0x48(%eax),%eax
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	68 61 03 80 00       	push   $0x800361
  8004b3:	50                   	push   %eax
  8004b4:	e8 02 fe ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
}
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	c9                   	leave  
  8004bd:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  8004be:	a1 04 40 80 00       	mov    0x804004,%eax
  8004c3:	8b 40 48             	mov    0x48(%eax),%eax
  8004c6:	83 ec 04             	sub    $0x4,%esp
  8004c9:	6a 07                	push   $0x7
  8004cb:	68 00 f0 bf ee       	push   $0xeebff000
  8004d0:	50                   	push   %eax
  8004d1:	e8 9a fc ff ff       	call   800170 <sys_page_alloc>
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	79 be                	jns    80049b <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  8004dd:	50                   	push   %eax
  8004de:	68 a6 22 80 00       	push   $0x8022a6
  8004e3:	6a 21                	push   $0x21
  8004e5:	68 b9 22 80 00       	push   $0x8022b9
  8004ea:	e8 fc 0e 00 00       	call   8013eb <_panic>

008004ef <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8004fa:	83 ec 04             	sub    $0x4,%esp
  8004fd:	6a 07                	push   $0x7
  8004ff:	53                   	push   %ebx
  800500:	56                   	push   %esi
  800501:	e8 6a fc ff ff       	call   800170 <sys_page_alloc>
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 4a                	js     800557 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80050d:	83 ec 0c             	sub    $0xc,%esp
  800510:	6a 07                	push   $0x7
  800512:	68 00 00 40 00       	push   $0x400000
  800517:	6a 00                	push   $0x0
  800519:	53                   	push   %ebx
  80051a:	56                   	push   %esi
  80051b:	e8 93 fc ff ff       	call   8001b3 <sys_page_map>
  800520:	83 c4 20             	add    $0x20,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	78 42                	js     800569 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800527:	83 ec 04             	sub    $0x4,%esp
  80052a:	68 00 10 00 00       	push   $0x1000
  80052f:	53                   	push   %ebx
  800530:	68 00 00 40 00       	push   $0x400000
  800535:	e8 39 17 00 00       	call   801c73 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80053a:	83 c4 08             	add    $0x8,%esp
  80053d:	68 00 00 40 00       	push   $0x400000
  800542:	6a 00                	push   $0x0
  800544:	e8 ac fc ff ff       	call   8001f5 <sys_page_unmap>
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 2b                	js     80057b <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800553:	5b                   	pop    %ebx
  800554:	5e                   	pop    %esi
  800555:	5d                   	pop    %ebp
  800556:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800557:	50                   	push   %eax
  800558:	68 a6 22 80 00       	push   $0x8022a6
  80055d:	6a 63                	push   $0x63
  80055f:	68 55 22 80 00       	push   $0x802255
  800564:	e8 82 0e 00 00       	call   8013eb <_panic>
        panic("sys_page_map: %e", r);
  800569:	50                   	push   %eax
  80056a:	68 c9 22 80 00       	push   $0x8022c9
  80056f:	6a 65                	push   $0x65
  800571:	68 55 22 80 00       	push   $0x802255
  800576:	e8 70 0e 00 00       	call   8013eb <_panic>
        panic("sys_page_unmap: %e", r);
  80057b:	50                   	push   %eax
  80057c:	68 da 22 80 00       	push   $0x8022da
  800581:	6a 68                	push   $0x68
  800583:	68 55 22 80 00       	push   $0x802255
  800588:	e8 5e 0e 00 00       	call   8013eb <_panic>

0080058d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	57                   	push   %edi
  800591:	56                   	push   %esi
  800592:	53                   	push   %ebx
  800593:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  800596:	a1 04 40 80 00       	mov    0x804004,%eax
  80059b:	8b 40 64             	mov    0x64(%eax),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 1f                	je     8005c1 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8005a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8005a7:	cd 30                	int    $0x30
  8005a9:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	74 21                	je     8005d3 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  8005b2:	be 08 40 80 00       	mov    $0x804008,%esi
  8005b7:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8005ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005bf:	eb 7b                	jmp    80063c <fork+0xaf>
        set_pgfault_handler(pgfault);
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	68 87 03 80 00       	push   $0x800387
  8005c9:	e8 be fe ff ff       	call   80048c <set_pgfault_handler>
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	eb cf                	jmp    8005a2 <fork+0x15>
        set_pgfault_handler(pgfault);
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	68 87 03 80 00       	push   $0x800387
  8005db:	e8 ac fe ff ff       	call   80048c <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  8005e0:	e8 4d fb ff ff       	call   800132 <sys_getenvid>
  8005e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005f2:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	e9 ca 00 00 00       	jmp    8006c9 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  8005ff:	89 d1                	mov    %edx,%ecx
  800601:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  800607:	81 e2 02 08 00 00    	and    $0x802,%edx
  80060d:	89 cf                	mov    %ecx,%edi
  80060f:	81 cf 00 08 00 00    	or     $0x800,%edi
  800615:	85 d2                	test   %edx,%edx
  800617:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	51                   	push   %ecx
  80061e:	50                   	push   %eax
  80061f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800622:	50                   	push   %eax
  800623:	6a 00                	push   $0x0
  800625:	e8 89 fb ff ff       	call   8001b3 <sys_page_map>
  80062a:	83 c4 20             	add    $0x20,%esp
  80062d:	85 c0                	test   %eax,%eax
  80062f:	78 45                	js     800676 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  800631:	83 c3 01             	add    $0x1,%ebx
  800634:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  80063a:	74 4c                	je     800688 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  80063c:	39 de                	cmp    %ebx,%esi
  80063e:	74 f1                	je     800631 <fork+0xa4>
  800640:	89 d8                	mov    %ebx,%eax
  800642:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  800645:	89 c2                	mov    %eax,%edx
  800647:	c1 ea 16             	shr    $0x16,%edx
  80064a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  800651:	f6 c2 05             	test   $0x5,%dl
  800654:	74 db                	je     800631 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  800656:	89 c2                	mov    %eax,%edx
  800658:	c1 ea 0c             	shr    $0xc,%edx
  80065b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  800662:	f6 c2 04             	test   $0x4,%dl
  800665:	74 ca                	je     800631 <fork+0xa4>
    if (perm & PTE_SHARE) {
  800667:	f6 c6 04             	test   $0x4,%dh
  80066a:	74 93                	je     8005ff <fork+0x72>
        perm &= ~PTE_COW;
  80066c:	89 d1                	mov    %edx,%ecx
  80066e:	81 e1 07 06 00 00    	and    $0x607,%ecx
  800674:	eb a4                	jmp    80061a <fork+0x8d>
        panic("sys_page_map error %e", r);
  800676:	50                   	push   %eax
  800677:	68 78 22 80 00       	push   $0x802278
  80067c:	6a 57                	push   $0x57
  80067e:	68 55 22 80 00       	push   $0x802255
  800683:	e8 63 0d 00 00       	call   8013eb <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	b8 08 40 80 00       	mov    $0x804008,%eax
  800690:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800695:	50                   	push   %eax
  800696:	ff 75 e4             	pushl  -0x1c(%ebp)
  800699:	e8 51 fe ff ff       	call   8004ef <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006a9:	50                   	push   %eax
  8006aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ad:	e8 3d fe ff ff       	call   8004ef <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	6a 02                	push   $0x2
  8006b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ba:	e8 78 fb ff ff       	call   800237 <sys_env_set_status>
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	78 0d                	js     8006d3 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8006c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  8006c9:	89 d8                	mov    %ebx,%eax
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  8006d3:	50                   	push   %eax
  8006d4:	68 ed 22 80 00       	push   $0x8022ed
  8006d9:	68 a0 00 00 00       	push   $0xa0
  8006de:	68 55 22 80 00       	push   $0x802255
  8006e3:	e8 03 0d 00 00       	call   8013eb <_panic>

008006e8 <sfork>:

// Challenge!
int
sfork(void)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8006ee:	68 04 23 80 00       	push   $0x802304
  8006f3:	68 a9 00 00 00       	push   $0xa9
  8006f8:	68 55 22 80 00       	push   $0x802255
  8006fd:	e8 e9 0c 00 00       	call   8013eb <_panic>

00800702 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	05 00 00 00 30       	add    $0x30000000,%eax
  80070d:	c1 e8 0c             	shr    $0xc,%eax
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80071d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800722:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800734:	89 c2                	mov    %eax,%edx
  800736:	c1 ea 16             	shr    $0x16,%edx
  800739:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800740:	f6 c2 01             	test   $0x1,%dl
  800743:	74 2a                	je     80076f <fd_alloc+0x46>
  800745:	89 c2                	mov    %eax,%edx
  800747:	c1 ea 0c             	shr    $0xc,%edx
  80074a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800751:	f6 c2 01             	test   $0x1,%dl
  800754:	74 19                	je     80076f <fd_alloc+0x46>
  800756:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80075b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800760:	75 d2                	jne    800734 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800762:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800768:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80076d:	eb 07                	jmp    800776 <fd_alloc+0x4d>
			*fd_store = fd;
  80076f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80077e:	83 f8 1f             	cmp    $0x1f,%eax
  800781:	77 36                	ja     8007b9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800783:	c1 e0 0c             	shl    $0xc,%eax
  800786:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80078b:	89 c2                	mov    %eax,%edx
  80078d:	c1 ea 16             	shr    $0x16,%edx
  800790:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800797:	f6 c2 01             	test   $0x1,%dl
  80079a:	74 24                	je     8007c0 <fd_lookup+0x48>
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	c1 ea 0c             	shr    $0xc,%edx
  8007a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007a8:	f6 c2 01             	test   $0x1,%dl
  8007ab:	74 1a                	je     8007c7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 02                	mov    %eax,(%edx)
	return 0;
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    
		return -E_INVAL;
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007be:	eb f7                	jmp    8007b7 <fd_lookup+0x3f>
		return -E_INVAL;
  8007c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c5:	eb f0                	jmp    8007b7 <fd_lookup+0x3f>
  8007c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cc:	eb e9                	jmp    8007b7 <fd_lookup+0x3f>

008007ce <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	ba 98 23 80 00       	mov    $0x802398,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007dc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8007e1:	39 08                	cmp    %ecx,(%eax)
  8007e3:	74 33                	je     800818 <dev_lookup+0x4a>
  8007e5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8007e8:	8b 02                	mov    (%edx),%eax
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	75 f3                	jne    8007e1 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8007f3:	8b 40 48             	mov    0x48(%eax),%eax
  8007f6:	83 ec 04             	sub    $0x4,%esp
  8007f9:	51                   	push   %ecx
  8007fa:	50                   	push   %eax
  8007fb:	68 1c 23 80 00       	push   $0x80231c
  800800:	e8 c1 0c 00 00       	call   8014c6 <cprintf>
	*dev = 0;
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
  800808:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    
			*dev = devtab[i];
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
  800822:	eb f2                	jmp    800816 <dev_lookup+0x48>

00800824 <fd_close>:
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	57                   	push   %edi
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	83 ec 1c             	sub    $0x1c,%esp
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800833:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800836:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800837:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80083d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800840:	50                   	push   %eax
  800841:	e8 32 ff ff ff       	call   800778 <fd_lookup>
  800846:	89 c3                	mov    %eax,%ebx
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	85 c0                	test   %eax,%eax
  80084d:	78 05                	js     800854 <fd_close+0x30>
	    || fd != fd2)
  80084f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800852:	74 16                	je     80086a <fd_close+0x46>
		return (must_exist ? r : 0);
  800854:	89 f8                	mov    %edi,%eax
  800856:	84 c0                	test   %al,%al
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	0f 44 d8             	cmove  %eax,%ebx
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	ff 36                	pushl  (%esi)
  800873:	e8 56 ff ff ff       	call   8007ce <dev_lookup>
  800878:	89 c3                	mov    %eax,%ebx
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 15                	js     800896 <fd_close+0x72>
		if (dev->dev_close)
  800881:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800884:	8b 40 10             	mov    0x10(%eax),%eax
  800887:	85 c0                	test   %eax,%eax
  800889:	74 1b                	je     8008a6 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80088b:	83 ec 0c             	sub    $0xc,%esp
  80088e:	56                   	push   %esi
  80088f:	ff d0                	call   *%eax
  800891:	89 c3                	mov    %eax,%ebx
  800893:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	56                   	push   %esi
  80089a:	6a 00                	push   $0x0
  80089c:	e8 54 f9 ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	eb ba                	jmp    800860 <fd_close+0x3c>
			r = 0;
  8008a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ab:	eb e9                	jmp    800896 <fd_close+0x72>

008008ad <close>:

int
close(int fdnum)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 b9 fe ff ff       	call   800778 <fd_lookup>
  8008bf:	83 c4 08             	add    $0x8,%esp
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	78 10                	js     8008d6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 01                	push   $0x1
  8008cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8008ce:	e8 51 ff ff ff       	call   800824 <fd_close>
  8008d3:	83 c4 10             	add    $0x10,%esp
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <close_all>:

void
close_all(void)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008df:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008e4:	83 ec 0c             	sub    $0xc,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	e8 c0 ff ff ff       	call   8008ad <close>
	for (i = 0; i < MAXFD; i++)
  8008ed:	83 c3 01             	add    $0x1,%ebx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	83 fb 20             	cmp    $0x20,%ebx
  8008f6:	75 ec                	jne    8008e4 <close_all+0xc>
}
  8008f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800909:	50                   	push   %eax
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 66 fe ff ff       	call   800778 <fd_lookup>
  800912:	89 c3                	mov    %eax,%ebx
  800914:	83 c4 08             	add    $0x8,%esp
  800917:	85 c0                	test   %eax,%eax
  800919:	0f 88 81 00 00 00    	js     8009a0 <dup+0xa3>
		return r;
	close(newfdnum);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	e8 83 ff ff ff       	call   8008ad <close>

	newfd = INDEX2FD(newfdnum);
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	c1 e6 0c             	shl    $0xc,%esi
  800930:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800936:	83 c4 04             	add    $0x4,%esp
  800939:	ff 75 e4             	pushl  -0x1c(%ebp)
  80093c:	e8 d1 fd ff ff       	call   800712 <fd2data>
  800941:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800943:	89 34 24             	mov    %esi,(%esp)
  800946:	e8 c7 fd ff ff       	call   800712 <fd2data>
  80094b:	83 c4 10             	add    $0x10,%esp
  80094e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800950:	89 d8                	mov    %ebx,%eax
  800952:	c1 e8 16             	shr    $0x16,%eax
  800955:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80095c:	a8 01                	test   $0x1,%al
  80095e:	74 11                	je     800971 <dup+0x74>
  800960:	89 d8                	mov    %ebx,%eax
  800962:	c1 e8 0c             	shr    $0xc,%eax
  800965:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80096c:	f6 c2 01             	test   $0x1,%dl
  80096f:	75 39                	jne    8009aa <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 d0                	mov    %edx,%eax
  800976:	c1 e8 0c             	shr    $0xc,%eax
  800979:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800980:	83 ec 0c             	sub    $0xc,%esp
  800983:	25 07 0e 00 00       	and    $0xe07,%eax
  800988:	50                   	push   %eax
  800989:	56                   	push   %esi
  80098a:	6a 00                	push   $0x0
  80098c:	52                   	push   %edx
  80098d:	6a 00                	push   $0x0
  80098f:	e8 1f f8 ff ff       	call   8001b3 <sys_page_map>
  800994:	89 c3                	mov    %eax,%ebx
  800996:	83 c4 20             	add    $0x20,%esp
  800999:	85 c0                	test   %eax,%eax
  80099b:	78 31                	js     8009ce <dup+0xd1>
		goto err;

	return newfdnum;
  80099d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8009a0:	89 d8                	mov    %ebx,%eax
  8009a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009b1:	83 ec 0c             	sub    $0xc,%esp
  8009b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8009b9:	50                   	push   %eax
  8009ba:	57                   	push   %edi
  8009bb:	6a 00                	push   $0x0
  8009bd:	53                   	push   %ebx
  8009be:	6a 00                	push   $0x0
  8009c0:	e8 ee f7 ff ff       	call   8001b3 <sys_page_map>
  8009c5:	89 c3                	mov    %eax,%ebx
  8009c7:	83 c4 20             	add    $0x20,%esp
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	79 a3                	jns    800971 <dup+0x74>
	sys_page_unmap(0, newfd);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	56                   	push   %esi
  8009d2:	6a 00                	push   $0x0
  8009d4:	e8 1c f8 ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009d9:	83 c4 08             	add    $0x8,%esp
  8009dc:	57                   	push   %edi
  8009dd:	6a 00                	push   $0x0
  8009df:	e8 11 f8 ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8009e4:	83 c4 10             	add    $0x10,%esp
  8009e7:	eb b7                	jmp    8009a0 <dup+0xa3>

008009e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 14             	sub    $0x14,%esp
  8009f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009f6:	50                   	push   %eax
  8009f7:	53                   	push   %ebx
  8009f8:	e8 7b fd ff ff       	call   800778 <fd_lookup>
  8009fd:	83 c4 08             	add    $0x8,%esp
  800a00:	85 c0                	test   %eax,%eax
  800a02:	78 3f                	js     800a43 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a0a:	50                   	push   %eax
  800a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0e:	ff 30                	pushl  (%eax)
  800a10:	e8 b9 fd ff ff       	call   8007ce <dev_lookup>
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	85 c0                	test   %eax,%eax
  800a1a:	78 27                	js     800a43 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a1f:	8b 42 08             	mov    0x8(%edx),%eax
  800a22:	83 e0 03             	and    $0x3,%eax
  800a25:	83 f8 01             	cmp    $0x1,%eax
  800a28:	74 1e                	je     800a48 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2d:	8b 40 08             	mov    0x8(%eax),%eax
  800a30:	85 c0                	test   %eax,%eax
  800a32:	74 35                	je     800a69 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	52                   	push   %edx
  800a3e:	ff d0                	call   *%eax
  800a40:	83 c4 10             	add    $0x10,%esp
}
  800a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a48:	a1 04 40 80 00       	mov    0x804004,%eax
  800a4d:	8b 40 48             	mov    0x48(%eax),%eax
  800a50:	83 ec 04             	sub    $0x4,%esp
  800a53:	53                   	push   %ebx
  800a54:	50                   	push   %eax
  800a55:	68 5d 23 80 00       	push   $0x80235d
  800a5a:	e8 67 0a 00 00       	call   8014c6 <cprintf>
		return -E_INVAL;
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a67:	eb da                	jmp    800a43 <read+0x5a>
		return -E_NOT_SUPP;
  800a69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a6e:	eb d3                	jmp    800a43 <read+0x5a>

00800a70 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	83 ec 0c             	sub    $0xc,%esp
  800a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a84:	39 f3                	cmp    %esi,%ebx
  800a86:	73 25                	jae    800aad <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a88:	83 ec 04             	sub    $0x4,%esp
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	29 d8                	sub    %ebx,%eax
  800a8f:	50                   	push   %eax
  800a90:	89 d8                	mov    %ebx,%eax
  800a92:	03 45 0c             	add    0xc(%ebp),%eax
  800a95:	50                   	push   %eax
  800a96:	57                   	push   %edi
  800a97:	e8 4d ff ff ff       	call   8009e9 <read>
		if (m < 0)
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	78 08                	js     800aab <readn+0x3b>
			return m;
		if (m == 0)
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	74 06                	je     800aad <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800aa7:	01 c3                	add    %eax,%ebx
  800aa9:	eb d9                	jmp    800a84 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aab:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800aad:	89 d8                	mov    %ebx,%eax
  800aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 14             	sub    $0x14,%esp
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ac1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ac4:	50                   	push   %eax
  800ac5:	53                   	push   %ebx
  800ac6:	e8 ad fc ff ff       	call   800778 <fd_lookup>
  800acb:	83 c4 08             	add    $0x8,%esp
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	78 3a                	js     800b0c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad8:	50                   	push   %eax
  800ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800adc:	ff 30                	pushl  (%eax)
  800ade:	e8 eb fc ff ff       	call   8007ce <dev_lookup>
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 22                	js     800b0c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800af1:	74 1e                	je     800b11 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af6:	8b 52 0c             	mov    0xc(%edx),%edx
  800af9:	85 d2                	test   %edx,%edx
  800afb:	74 35                	je     800b32 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800afd:	83 ec 04             	sub    $0x4,%esp
  800b00:	ff 75 10             	pushl  0x10(%ebp)
  800b03:	ff 75 0c             	pushl  0xc(%ebp)
  800b06:	50                   	push   %eax
  800b07:	ff d2                	call   *%edx
  800b09:	83 c4 10             	add    $0x10,%esp
}
  800b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b11:	a1 04 40 80 00       	mov    0x804004,%eax
  800b16:	8b 40 48             	mov    0x48(%eax),%eax
  800b19:	83 ec 04             	sub    $0x4,%esp
  800b1c:	53                   	push   %ebx
  800b1d:	50                   	push   %eax
  800b1e:	68 79 23 80 00       	push   $0x802379
  800b23:	e8 9e 09 00 00       	call   8014c6 <cprintf>
		return -E_INVAL;
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b30:	eb da                	jmp    800b0c <write+0x55>
		return -E_NOT_SUPP;
  800b32:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b37:	eb d3                	jmp    800b0c <write+0x55>

00800b39 <seek>:

int
seek(int fdnum, off_t offset)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b3f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b42:	50                   	push   %eax
  800b43:	ff 75 08             	pushl  0x8(%ebp)
  800b46:	e8 2d fc ff ff       	call   800778 <fd_lookup>
  800b4b:	83 c4 08             	add    $0x8,%esp
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	78 0e                	js     800b60 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b58:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	83 ec 14             	sub    $0x14,%esp
  800b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b6f:	50                   	push   %eax
  800b70:	53                   	push   %ebx
  800b71:	e8 02 fc ff ff       	call   800778 <fd_lookup>
  800b76:	83 c4 08             	add    $0x8,%esp
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	78 37                	js     800bb4 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b83:	50                   	push   %eax
  800b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b87:	ff 30                	pushl  (%eax)
  800b89:	e8 40 fc ff ff       	call   8007ce <dev_lookup>
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	85 c0                	test   %eax,%eax
  800b93:	78 1f                	js     800bb4 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b98:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b9c:	74 1b                	je     800bb9 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800b9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba1:	8b 52 18             	mov    0x18(%edx),%edx
  800ba4:	85 d2                	test   %edx,%edx
  800ba6:	74 32                	je     800bda <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800ba8:	83 ec 08             	sub    $0x8,%esp
  800bab:	ff 75 0c             	pushl  0xc(%ebp)
  800bae:	50                   	push   %eax
  800baf:	ff d2                	call   *%edx
  800bb1:	83 c4 10             	add    $0x10,%esp
}
  800bb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    
			thisenv->env_id, fdnum);
  800bb9:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800bbe:	8b 40 48             	mov    0x48(%eax),%eax
  800bc1:	83 ec 04             	sub    $0x4,%esp
  800bc4:	53                   	push   %ebx
  800bc5:	50                   	push   %eax
  800bc6:	68 3c 23 80 00       	push   $0x80233c
  800bcb:	e8 f6 08 00 00       	call   8014c6 <cprintf>
		return -E_INVAL;
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd8:	eb da                	jmp    800bb4 <ftruncate+0x52>
		return -E_NOT_SUPP;
  800bda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bdf:	eb d3                	jmp    800bb4 <ftruncate+0x52>

00800be1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	53                   	push   %ebx
  800be5:	83 ec 14             	sub    $0x14,%esp
  800be8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800beb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bee:	50                   	push   %eax
  800bef:	ff 75 08             	pushl  0x8(%ebp)
  800bf2:	e8 81 fb ff ff       	call   800778 <fd_lookup>
  800bf7:	83 c4 08             	add    $0x8,%esp
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	78 4b                	js     800c49 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c04:	50                   	push   %eax
  800c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c08:	ff 30                	pushl  (%eax)
  800c0a:	e8 bf fb ff ff       	call   8007ce <dev_lookup>
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	85 c0                	test   %eax,%eax
  800c14:	78 33                	js     800c49 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c19:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c1d:	74 2f                	je     800c4e <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c1f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c22:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c29:	00 00 00 
	stat->st_isdir = 0;
  800c2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c33:	00 00 00 
	stat->st_dev = dev;
  800c36:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c3c:	83 ec 08             	sub    $0x8,%esp
  800c3f:	53                   	push   %ebx
  800c40:	ff 75 f0             	pushl  -0x10(%ebp)
  800c43:	ff 50 14             	call   *0x14(%eax)
  800c46:	83 c4 10             	add    $0x10,%esp
}
  800c49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    
		return -E_NOT_SUPP;
  800c4e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c53:	eb f4                	jmp    800c49 <fstat+0x68>

00800c55 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c5a:	83 ec 08             	sub    $0x8,%esp
  800c5d:	6a 00                	push   $0x0
  800c5f:	ff 75 08             	pushl  0x8(%ebp)
  800c62:	e8 e7 01 00 00       	call   800e4e <open>
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	78 1b                	js     800c8b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c70:	83 ec 08             	sub    $0x8,%esp
  800c73:	ff 75 0c             	pushl  0xc(%ebp)
  800c76:	50                   	push   %eax
  800c77:	e8 65 ff ff ff       	call   800be1 <fstat>
  800c7c:	89 c6                	mov    %eax,%esi
	close(fd);
  800c7e:	89 1c 24             	mov    %ebx,(%esp)
  800c81:	e8 27 fc ff ff       	call   8008ad <close>
	return r;
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	89 f3                	mov    %esi,%ebx
}
  800c8b:	89 d8                	mov    %ebx,%eax
  800c8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c9d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ca4:	74 27                	je     800ccd <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ca6:	6a 07                	push   $0x7
  800ca8:	68 00 50 80 00       	push   $0x805000
  800cad:	56                   	push   %esi
  800cae:	ff 35 00 40 80 00    	pushl  0x804000
  800cb4:	e8 ca 11 00 00       	call   801e83 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cb9:	83 c4 0c             	add    $0xc,%esp
  800cbc:	6a 00                	push   $0x0
  800cbe:	53                   	push   %ebx
  800cbf:	6a 00                	push   $0x0
  800cc1:	e8 5c 11 00 00       	call   801e22 <ipc_recv>
}
  800cc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	6a 01                	push   $0x1
  800cd2:	e8 f9 11 00 00       	call   801ed0 <ipc_find_env>
  800cd7:	a3 00 40 80 00       	mov    %eax,0x804000
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	eb c5                	jmp    800ca6 <fsipc+0x12>

00800ce1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	8b 40 0c             	mov    0xc(%eax),%eax
  800ced:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800cff:	b8 02 00 00 00       	mov    $0x2,%eax
  800d04:	e8 8b ff ff ff       	call   800c94 <fsipc>
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <devfile_flush>:
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	8b 40 0c             	mov    0xc(%eax),%eax
  800d17:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d21:	b8 06 00 00 00       	mov    $0x6,%eax
  800d26:	e8 69 ff ff ff       	call   800c94 <fsipc>
}
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    

00800d2d <devfile_stat>:
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	53                   	push   %ebx
  800d31:	83 ec 04             	sub    $0x4,%esp
  800d34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d3d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4c:	e8 43 ff ff ff       	call   800c94 <fsipc>
  800d51:	85 c0                	test   %eax,%eax
  800d53:	78 2c                	js     800d81 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d55:	83 ec 08             	sub    $0x8,%esp
  800d58:	68 00 50 80 00       	push   $0x805000
  800d5d:	53                   	push   %ebx
  800d5e:	e8 82 0d 00 00       	call   801ae5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d63:	a1 80 50 80 00       	mov    0x805080,%eax
  800d68:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d6e:	a1 84 50 80 00       	mov    0x805084,%eax
  800d73:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <devfile_write>:
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  800d8f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d94:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d99:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	8b 52 0c             	mov    0xc(%edx),%edx
  800da2:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800da8:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  800dad:	50                   	push   %eax
  800dae:	ff 75 0c             	pushl  0xc(%ebp)
  800db1:	68 08 50 80 00       	push   $0x805008
  800db6:	e8 b8 0e 00 00       	call   801c73 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc5:	e8 ca fe ff ff       	call   800c94 <fsipc>
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <devfile_read>:
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	8b 40 0c             	mov    0xc(%eax),%eax
  800dda:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ddf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800de5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dea:	b8 03 00 00 00       	mov    $0x3,%eax
  800def:	e8 a0 fe ff ff       	call   800c94 <fsipc>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 1f                	js     800e19 <devfile_read+0x4d>
	assert(r <= n);
  800dfa:	39 f0                	cmp    %esi,%eax
  800dfc:	77 24                	ja     800e22 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800dfe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e03:	7f 33                	jg     800e38 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	50                   	push   %eax
  800e09:	68 00 50 80 00       	push   $0x805000
  800e0e:	ff 75 0c             	pushl  0xc(%ebp)
  800e11:	e8 5d 0e 00 00       	call   801c73 <memmove>
	return r;
  800e16:	83 c4 10             	add    $0x10,%esp
}
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
	assert(r <= n);
  800e22:	68 a8 23 80 00       	push   $0x8023a8
  800e27:	68 af 23 80 00       	push   $0x8023af
  800e2c:	6a 7d                	push   $0x7d
  800e2e:	68 c4 23 80 00       	push   $0x8023c4
  800e33:	e8 b3 05 00 00       	call   8013eb <_panic>
	assert(r <= PGSIZE);
  800e38:	68 cf 23 80 00       	push   $0x8023cf
  800e3d:	68 af 23 80 00       	push   $0x8023af
  800e42:	6a 7e                	push   $0x7e
  800e44:	68 c4 23 80 00       	push   $0x8023c4
  800e49:	e8 9d 05 00 00       	call   8013eb <_panic>

00800e4e <open>:
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 1c             	sub    $0x1c,%esp
  800e56:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800e59:	56                   	push   %esi
  800e5a:	e8 4f 0c 00 00       	call   801aae <strlen>
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e67:	0f 8f 96 00 00 00    	jg     800f03 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e73:	50                   	push   %eax
  800e74:	e8 b0 f8 ff ff       	call   800729 <fd_alloc>
  800e79:	89 c3                	mov    %eax,%ebx
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	78 66                	js     800ee8 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	56                   	push   %esi
  800e86:	68 00 50 80 00       	push   $0x805000
  800e8b:	e8 55 0c 00 00       	call   801ae5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea0:	e8 ef fd ff ff       	call   800c94 <fsipc>
  800ea5:	89 c3                	mov    %eax,%ebx
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 43                	js     800ef1 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb4:	e8 49 f8 ff ff       	call   800702 <fd2num>
  800eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ebc:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800ec2:	8b 49 48             	mov    0x48(%ecx),%ecx
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	50                   	push   %eax
  800ec9:	52                   	push   %edx
  800eca:	ff 32                	pushl  (%edx)
  800ecc:	56                   	push   %esi
  800ecd:	51                   	push   %ecx
  800ece:	68 dc 23 80 00       	push   $0x8023dc
  800ed3:	e8 ee 05 00 00       	call   8014c6 <cprintf>
	return fd2num(fd);
  800ed8:	83 c4 14             	add    $0x14,%esp
  800edb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ede:	e8 1f f8 ff ff       	call   800702 <fd2num>
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	83 c4 10             	add    $0x10,%esp
}
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    
		fd_close(fd, 0);
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	6a 00                	push   $0x0
  800ef6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef9:	e8 26 f9 ff ff       	call   800824 <fd_close>
		return r;
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	eb e5                	jmp    800ee8 <open+0x9a>
		return -E_BAD_PATH;
  800f03:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f08:	eb de                	jmp    800ee8 <open+0x9a>

00800f0a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f10:	ba 00 00 00 00       	mov    $0x0,%edx
  800f15:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1a:	e8 75 fd ff ff       	call   800c94 <fsipc>
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	ff 75 08             	pushl  0x8(%ebp)
  800f2f:	e8 de f7 ff ff       	call   800712 <fd2data>
  800f34:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	68 1b 24 80 00       	push   $0x80241b
  800f3e:	53                   	push   %ebx
  800f3f:	e8 a1 0b 00 00       	call   801ae5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f44:	8b 46 04             	mov    0x4(%esi),%eax
  800f47:	2b 06                	sub    (%esi),%eax
  800f49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f56:	00 00 00 
	stat->st_dev = &devpipe;
  800f59:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f60:	30 80 00 
	return 0;
}
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 74 f2 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f81:	89 1c 24             	mov    %ebx,(%esp)
  800f84:	e8 89 f7 ff ff       	call   800712 <fd2data>
  800f89:	83 c4 08             	add    $0x8,%esp
  800f8c:	50                   	push   %eax
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 61 f2 ff ff       	call   8001f5 <sys_page_unmap>
}
  800f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <_pipeisclosed>:
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 1c             	sub    $0x1c,%esp
  800fa2:	89 c7                	mov    %eax,%edi
  800fa4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800fa6:	a1 04 40 80 00       	mov    0x804004,%eax
  800fab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	57                   	push   %edi
  800fb2:	e8 52 0f 00 00       	call   801f09 <pageref>
  800fb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fba:	89 34 24             	mov    %esi,(%esp)
  800fbd:	e8 47 0f 00 00       	call   801f09 <pageref>
		nn = thisenv->env_runs;
  800fc2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fc8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	39 cb                	cmp    %ecx,%ebx
  800fd0:	74 1b                	je     800fed <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800fd2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fd5:	75 cf                	jne    800fa6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fd7:	8b 42 58             	mov    0x58(%edx),%eax
  800fda:	6a 01                	push   $0x1
  800fdc:	50                   	push   %eax
  800fdd:	53                   	push   %ebx
  800fde:	68 22 24 80 00       	push   $0x802422
  800fe3:	e8 de 04 00 00       	call   8014c6 <cprintf>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	eb b9                	jmp    800fa6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800fed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ff0:	0f 94 c0             	sete   %al
  800ff3:	0f b6 c0             	movzbl %al,%eax
}
  800ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff9:	5b                   	pop    %ebx
  800ffa:	5e                   	pop    %esi
  800ffb:	5f                   	pop    %edi
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <devpipe_write>:
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 28             	sub    $0x28,%esp
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80100a:	56                   	push   %esi
  80100b:	e8 02 f7 ff ff       	call   800712 <fd2data>
  801010:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	bf 00 00 00 00       	mov    $0x0,%edi
  80101a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80101d:	74 4f                	je     80106e <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80101f:	8b 43 04             	mov    0x4(%ebx),%eax
  801022:	8b 0b                	mov    (%ebx),%ecx
  801024:	8d 51 20             	lea    0x20(%ecx),%edx
  801027:	39 d0                	cmp    %edx,%eax
  801029:	72 14                	jb     80103f <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80102b:	89 da                	mov    %ebx,%edx
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	e8 65 ff ff ff       	call   800f99 <_pipeisclosed>
  801034:	85 c0                	test   %eax,%eax
  801036:	75 3a                	jne    801072 <devpipe_write+0x74>
			sys_yield();
  801038:	e8 14 f1 ff ff       	call   800151 <sys_yield>
  80103d:	eb e0                	jmp    80101f <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801046:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801049:	89 c2                	mov    %eax,%edx
  80104b:	c1 fa 1f             	sar    $0x1f,%edx
  80104e:	89 d1                	mov    %edx,%ecx
  801050:	c1 e9 1b             	shr    $0x1b,%ecx
  801053:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801056:	83 e2 1f             	and    $0x1f,%edx
  801059:	29 ca                	sub    %ecx,%edx
  80105b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80105f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801063:	83 c0 01             	add    $0x1,%eax
  801066:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801069:	83 c7 01             	add    $0x1,%edi
  80106c:	eb ac                	jmp    80101a <devpipe_write+0x1c>
	return i;
  80106e:	89 f8                	mov    %edi,%eax
  801070:	eb 05                	jmp    801077 <devpipe_write+0x79>
				return 0;
  801072:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5f                   	pop    %edi
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <devpipe_read>:
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 18             	sub    $0x18,%esp
  801088:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80108b:	57                   	push   %edi
  80108c:	e8 81 f6 ff ff       	call   800712 <fd2data>
  801091:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	be 00 00 00 00       	mov    $0x0,%esi
  80109b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80109e:	74 47                	je     8010e7 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8010a0:	8b 03                	mov    (%ebx),%eax
  8010a2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010a5:	75 22                	jne    8010c9 <devpipe_read+0x4a>
			if (i > 0)
  8010a7:	85 f6                	test   %esi,%esi
  8010a9:	75 14                	jne    8010bf <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8010ab:	89 da                	mov    %ebx,%edx
  8010ad:	89 f8                	mov    %edi,%eax
  8010af:	e8 e5 fe ff ff       	call   800f99 <_pipeisclosed>
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	75 33                	jne    8010eb <devpipe_read+0x6c>
			sys_yield();
  8010b8:	e8 94 f0 ff ff       	call   800151 <sys_yield>
  8010bd:	eb e1                	jmp    8010a0 <devpipe_read+0x21>
				return i;
  8010bf:	89 f0                	mov    %esi,%eax
}
  8010c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5f                   	pop    %edi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010c9:	99                   	cltd   
  8010ca:	c1 ea 1b             	shr    $0x1b,%edx
  8010cd:	01 d0                	add    %edx,%eax
  8010cf:	83 e0 1f             	and    $0x1f,%eax
  8010d2:	29 d0                	sub    %edx,%eax
  8010d4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8010d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8010df:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8010e2:	83 c6 01             	add    $0x1,%esi
  8010e5:	eb b4                	jmp    80109b <devpipe_read+0x1c>
	return i;
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	eb d6                	jmp    8010c1 <devpipe_read+0x42>
				return 0;
  8010eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f0:	eb cf                	jmp    8010c1 <devpipe_read+0x42>

008010f2 <pipe>:
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8010fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 26 f6 ff ff       	call   800729 <fd_alloc>
  801103:	89 c3                	mov    %eax,%ebx
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 5b                	js     801167 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	68 07 04 00 00       	push   $0x407
  801114:	ff 75 f4             	pushl  -0xc(%ebp)
  801117:	6a 00                	push   $0x0
  801119:	e8 52 f0 ff ff       	call   800170 <sys_page_alloc>
  80111e:	89 c3                	mov    %eax,%ebx
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 40                	js     801167 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	e8 f6 f5 ff ff       	call   800729 <fd_alloc>
  801133:	89 c3                	mov    %eax,%ebx
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 1b                	js     801157 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	68 07 04 00 00       	push   $0x407
  801144:	ff 75 f0             	pushl  -0x10(%ebp)
  801147:	6a 00                	push   $0x0
  801149:	e8 22 f0 ff ff       	call   800170 <sys_page_alloc>
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	79 19                	jns    801170 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	ff 75 f4             	pushl  -0xc(%ebp)
  80115d:	6a 00                	push   $0x0
  80115f:	e8 91 f0 ff ff       	call   8001f5 <sys_page_unmap>
  801164:	83 c4 10             	add    $0x10,%esp
}
  801167:	89 d8                	mov    %ebx,%eax
  801169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
	va = fd2data(fd0);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	ff 75 f4             	pushl  -0xc(%ebp)
  801176:	e8 97 f5 ff ff       	call   800712 <fd2data>
  80117b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80117d:	83 c4 0c             	add    $0xc,%esp
  801180:	68 07 04 00 00       	push   $0x407
  801185:	50                   	push   %eax
  801186:	6a 00                	push   $0x0
  801188:	e8 e3 ef ff ff       	call   800170 <sys_page_alloc>
  80118d:	89 c3                	mov    %eax,%ebx
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	0f 88 8c 00 00 00    	js     801226 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	ff 75 f0             	pushl  -0x10(%ebp)
  8011a0:	e8 6d f5 ff ff       	call   800712 <fd2data>
  8011a5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011ac:	50                   	push   %eax
  8011ad:	6a 00                	push   $0x0
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 fc ef ff ff       	call   8001b3 <sys_page_map>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 58                	js     801218 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8011c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011c9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011de:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 0d f5 ff ff       	call   800702 <fd2num>
  8011f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011fa:	83 c4 04             	add    $0x4,%esp
  8011fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801200:	e8 fd f4 ff ff       	call   800702 <fd2num>
  801205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801208:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801213:	e9 4f ff ff ff       	jmp    801167 <pipe+0x75>
	sys_page_unmap(0, va);
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	56                   	push   %esi
  80121c:	6a 00                	push   $0x0
  80121e:	e8 d2 ef ff ff       	call   8001f5 <sys_page_unmap>
  801223:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	ff 75 f0             	pushl  -0x10(%ebp)
  80122c:	6a 00                	push   $0x0
  80122e:	e8 c2 ef ff ff       	call   8001f5 <sys_page_unmap>
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	e9 1c ff ff ff       	jmp    801157 <pipe+0x65>

0080123b <pipeisclosed>:
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	ff 75 08             	pushl  0x8(%ebp)
  801248:	e8 2b f5 ff ff       	call   800778 <fd_lookup>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 18                	js     80126c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	ff 75 f4             	pushl  -0xc(%ebp)
  80125a:	e8 b3 f4 ff ff       	call   800712 <fd2data>
	return _pipeisclosed(fd, p);
  80125f:	89 c2                	mov    %eax,%edx
  801261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801264:	e8 30 fd ff ff       	call   800f99 <_pipeisclosed>
  801269:	83 c4 10             	add    $0x10,%esp
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80127e:	68 3a 24 80 00       	push   $0x80243a
  801283:	ff 75 0c             	pushl  0xc(%ebp)
  801286:	e8 5a 08 00 00       	call   801ae5 <strcpy>
	return 0;
}
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <devcons_write>:
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80129e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8012a3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8012a9:	eb 2f                	jmp    8012da <devcons_write+0x48>
		m = n - tot;
  8012ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ae:	29 f3                	sub    %esi,%ebx
  8012b0:	83 fb 7f             	cmp    $0x7f,%ebx
  8012b3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8012b8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	53                   	push   %ebx
  8012bf:	89 f0                	mov    %esi,%eax
  8012c1:	03 45 0c             	add    0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	57                   	push   %edi
  8012c6:	e8 a8 09 00 00       	call   801c73 <memmove>
		sys_cputs(buf, m);
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	57                   	push   %edi
  8012d0:	e8 df ed ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8012d5:	01 de                	add    %ebx,%esi
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012dd:	72 cc                	jb     8012ab <devcons_write+0x19>
}
  8012df:	89 f0                	mov    %esi,%eax
  8012e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <devcons_read>:
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8012f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f8:	75 07                	jne    801301 <devcons_read+0x18>
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    
		sys_yield();
  8012fc:	e8 50 ee ff ff       	call   800151 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801301:	e8 cc ed ff ff       	call   8000d2 <sys_cgetc>
  801306:	85 c0                	test   %eax,%eax
  801308:	74 f2                	je     8012fc <devcons_read+0x13>
	if (c < 0)
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 ec                	js     8012fa <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80130e:	83 f8 04             	cmp    $0x4,%eax
  801311:	74 0c                	je     80131f <devcons_read+0x36>
	*(char*)vbuf = c;
  801313:	8b 55 0c             	mov    0xc(%ebp),%edx
  801316:	88 02                	mov    %al,(%edx)
	return 1;
  801318:	b8 01 00 00 00       	mov    $0x1,%eax
  80131d:	eb db                	jmp    8012fa <devcons_read+0x11>
		return 0;
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	eb d4                	jmp    8012fa <devcons_read+0x11>

00801326 <cputchar>:
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801332:	6a 01                	push   $0x1
  801334:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	e8 77 ed ff ff       	call   8000b4 <sys_cputs>
}
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <getchar>:
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801348:	6a 01                	push   $0x1
  80134a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	6a 00                	push   $0x0
  801350:	e8 94 f6 ff ff       	call   8009e9 <read>
	if (r < 0)
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 08                	js     801364 <getchar+0x22>
	if (r < 1)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	7e 06                	jle    801366 <getchar+0x24>
	return c;
  801360:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801364:	c9                   	leave  
  801365:	c3                   	ret    
		return -E_EOF;
  801366:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80136b:	eb f7                	jmp    801364 <getchar+0x22>

0080136d <iscons>:
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 f9 f3 ff ff       	call   800778 <fd_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 11                	js     801397 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801389:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80138f:	39 10                	cmp    %edx,(%eax)
  801391:	0f 94 c0             	sete   %al
  801394:	0f b6 c0             	movzbl %al,%eax
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <opencons>:
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	e8 81 f3 ff ff       	call   800729 <fd_alloc>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 3a                	js     8013e9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	68 07 04 00 00       	push   $0x407
  8013b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 af ed ff ff       	call   800170 <sys_page_alloc>
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 21                	js     8013e9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8013c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013d1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013dd:	83 ec 0c             	sub    $0xc,%esp
  8013e0:	50                   	push   %eax
  8013e1:	e8 1c f3 ff ff       	call   800702 <fd2num>
  8013e6:	83 c4 10             	add    $0x10,%esp
}
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013f9:	e8 34 ed ff ff       	call   800132 <sys_getenvid>
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	ff 75 08             	pushl  0x8(%ebp)
  801407:	56                   	push   %esi
  801408:	50                   	push   %eax
  801409:	68 48 24 80 00       	push   $0x802448
  80140e:	e8 b3 00 00 00       	call   8014c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801413:	83 c4 18             	add    $0x18,%esp
  801416:	53                   	push   %ebx
  801417:	ff 75 10             	pushl  0x10(%ebp)
  80141a:	e8 56 00 00 00       	call   801475 <vcprintf>
	cprintf("\n");
  80141f:	c7 04 24 33 24 80 00 	movl   $0x802433,(%esp)
  801426:	e8 9b 00 00 00       	call   8014c6 <cprintf>
  80142b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142e:	cc                   	int3   
  80142f:	eb fd                	jmp    80142e <_panic+0x43>

00801431 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80143b:	8b 13                	mov    (%ebx),%edx
  80143d:	8d 42 01             	lea    0x1(%edx),%eax
  801440:	89 03                	mov    %eax,(%ebx)
  801442:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801445:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801449:	3d ff 00 00 00       	cmp    $0xff,%eax
  80144e:	74 09                	je     801459 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801450:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801454:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801457:	c9                   	leave  
  801458:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	68 ff 00 00 00       	push   $0xff
  801461:	8d 43 08             	lea    0x8(%ebx),%eax
  801464:	50                   	push   %eax
  801465:	e8 4a ec ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80146a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	eb db                	jmp    801450 <putch+0x1f>

00801475 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80147e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801485:	00 00 00 
	b.cnt = 0;
  801488:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80148f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801492:	ff 75 0c             	pushl  0xc(%ebp)
  801495:	ff 75 08             	pushl  0x8(%ebp)
  801498:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	68 31 14 80 00       	push   $0x801431
  8014a4:	e8 1a 01 00 00       	call   8015c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014a9:	83 c4 08             	add    $0x8,%esp
  8014ac:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	e8 f6 eb ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8014be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	e8 9d ff ff ff       	call   801475 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	57                   	push   %edi
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 1c             	sub    $0x1c,%esp
  8014e3:	89 c7                	mov    %eax,%edi
  8014e5:	89 d6                	mov    %edx,%esi
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014fe:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801501:	39 d3                	cmp    %edx,%ebx
  801503:	72 05                	jb     80150a <printnum+0x30>
  801505:	39 45 10             	cmp    %eax,0x10(%ebp)
  801508:	77 7a                	ja     801584 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	ff 75 18             	pushl  0x18(%ebp)
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801516:	53                   	push   %ebx
  801517:	ff 75 10             	pushl  0x10(%ebp)
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801520:	ff 75 e0             	pushl  -0x20(%ebp)
  801523:	ff 75 dc             	pushl  -0x24(%ebp)
  801526:	ff 75 d8             	pushl  -0x28(%ebp)
  801529:	e8 22 0a 00 00       	call   801f50 <__udivdi3>
  80152e:	83 c4 18             	add    $0x18,%esp
  801531:	52                   	push   %edx
  801532:	50                   	push   %eax
  801533:	89 f2                	mov    %esi,%edx
  801535:	89 f8                	mov    %edi,%eax
  801537:	e8 9e ff ff ff       	call   8014da <printnum>
  80153c:	83 c4 20             	add    $0x20,%esp
  80153f:	eb 13                	jmp    801554 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	56                   	push   %esi
  801545:	ff 75 18             	pushl  0x18(%ebp)
  801548:	ff d7                	call   *%edi
  80154a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80154d:	83 eb 01             	sub    $0x1,%ebx
  801550:	85 db                	test   %ebx,%ebx
  801552:	7f ed                	jg     801541 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	56                   	push   %esi
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155e:	ff 75 e0             	pushl  -0x20(%ebp)
  801561:	ff 75 dc             	pushl  -0x24(%ebp)
  801564:	ff 75 d8             	pushl  -0x28(%ebp)
  801567:	e8 04 0b 00 00       	call   802070 <__umoddi3>
  80156c:	83 c4 14             	add    $0x14,%esp
  80156f:	0f be 80 6b 24 80 00 	movsbl 0x80246b(%eax),%eax
  801576:	50                   	push   %eax
  801577:	ff d7                	call   *%edi
}
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    
  801584:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801587:	eb c4                	jmp    80154d <printnum+0x73>

00801589 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80158f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801593:	8b 10                	mov    (%eax),%edx
  801595:	3b 50 04             	cmp    0x4(%eax),%edx
  801598:	73 0a                	jae    8015a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80159a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80159d:	89 08                	mov    %ecx,(%eax)
  80159f:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a2:	88 02                	mov    %al,(%edx)
}
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    

008015a6 <printfmt>:
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8015ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015af:	50                   	push   %eax
  8015b0:	ff 75 10             	pushl  0x10(%ebp)
  8015b3:	ff 75 0c             	pushl  0xc(%ebp)
  8015b6:	ff 75 08             	pushl  0x8(%ebp)
  8015b9:	e8 05 00 00 00       	call   8015c3 <vprintfmt>
}
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <vprintfmt>:
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 2c             	sub    $0x2c,%esp
  8015cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8015cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015d5:	e9 c1 03 00 00       	jmp    80199b <vprintfmt+0x3d8>
		padc = ' ';
  8015da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8015de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8015e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8015ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8015f3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8015f8:	8d 47 01             	lea    0x1(%edi),%eax
  8015fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fe:	0f b6 17             	movzbl (%edi),%edx
  801601:	8d 42 dd             	lea    -0x23(%edx),%eax
  801604:	3c 55                	cmp    $0x55,%al
  801606:	0f 87 12 04 00 00    	ja     801a1e <vprintfmt+0x45b>
  80160c:	0f b6 c0             	movzbl %al,%eax
  80160f:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  801616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801619:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80161d:	eb d9                	jmp    8015f8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80161f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801622:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801626:	eb d0                	jmp    8015f8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801628:	0f b6 d2             	movzbl %dl,%edx
  80162b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80162e:	b8 00 00 00 00       	mov    $0x0,%eax
  801633:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801636:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801639:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80163d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801640:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801643:	83 f9 09             	cmp    $0x9,%ecx
  801646:	77 55                	ja     80169d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801648:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80164b:	eb e9                	jmp    801636 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8b 00                	mov    (%eax),%eax
  801652:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801655:	8b 45 14             	mov    0x14(%ebp),%eax
  801658:	8d 40 04             	lea    0x4(%eax),%eax
  80165b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80165e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801661:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801665:	79 91                	jns    8015f8 <vprintfmt+0x35>
				width = precision, precision = -1;
  801667:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80166a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80166d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801674:	eb 82                	jmp    8015f8 <vprintfmt+0x35>
  801676:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801679:	85 c0                	test   %eax,%eax
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	0f 49 d0             	cmovns %eax,%edx
  801683:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801689:	e9 6a ff ff ff       	jmp    8015f8 <vprintfmt+0x35>
  80168e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801691:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801698:	e9 5b ff ff ff       	jmp    8015f8 <vprintfmt+0x35>
  80169d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8016a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016a3:	eb bc                	jmp    801661 <vprintfmt+0x9e>
			lflag++;
  8016a5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8016ab:	e9 48 ff ff ff       	jmp    8015f8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8016b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b3:	8d 78 04             	lea    0x4(%eax),%edi
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	53                   	push   %ebx
  8016ba:	ff 30                	pushl  (%eax)
  8016bc:	ff d6                	call   *%esi
			break;
  8016be:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8016c1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8016c4:	e9 cf 02 00 00       	jmp    801998 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8016c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cc:	8d 78 04             	lea    0x4(%eax),%edi
  8016cf:	8b 00                	mov    (%eax),%eax
  8016d1:	99                   	cltd   
  8016d2:	31 d0                	xor    %edx,%eax
  8016d4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d6:	83 f8 0f             	cmp    $0xf,%eax
  8016d9:	7f 23                	jg     8016fe <vprintfmt+0x13b>
  8016db:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	74 18                	je     8016fe <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8016e6:	52                   	push   %edx
  8016e7:	68 c1 23 80 00       	push   $0x8023c1
  8016ec:	53                   	push   %ebx
  8016ed:	56                   	push   %esi
  8016ee:	e8 b3 fe ff ff       	call   8015a6 <printfmt>
  8016f3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8016f6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8016f9:	e9 9a 02 00 00       	jmp    801998 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8016fe:	50                   	push   %eax
  8016ff:	68 83 24 80 00       	push   $0x802483
  801704:	53                   	push   %ebx
  801705:	56                   	push   %esi
  801706:	e8 9b fe ff ff       	call   8015a6 <printfmt>
  80170b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80170e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801711:	e9 82 02 00 00       	jmp    801998 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801716:	8b 45 14             	mov    0x14(%ebp),%eax
  801719:	83 c0 04             	add    $0x4,%eax
  80171c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80171f:	8b 45 14             	mov    0x14(%ebp),%eax
  801722:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801724:	85 ff                	test   %edi,%edi
  801726:	b8 7c 24 80 00       	mov    $0x80247c,%eax
  80172b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80172e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801732:	0f 8e bd 00 00 00    	jle    8017f5 <vprintfmt+0x232>
  801738:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80173c:	75 0e                	jne    80174c <vprintfmt+0x189>
  80173e:	89 75 08             	mov    %esi,0x8(%ebp)
  801741:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801744:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801747:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80174a:	eb 6d                	jmp    8017b9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	ff 75 d0             	pushl  -0x30(%ebp)
  801752:	57                   	push   %edi
  801753:	e8 6e 03 00 00       	call   801ac6 <strnlen>
  801758:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80175b:	29 c1                	sub    %eax,%ecx
  80175d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801760:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801763:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801767:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80176a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80176d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80176f:	eb 0f                	jmp    801780 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	53                   	push   %ebx
  801775:	ff 75 e0             	pushl  -0x20(%ebp)
  801778:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80177a:	83 ef 01             	sub    $0x1,%edi
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 ff                	test   %edi,%edi
  801782:	7f ed                	jg     801771 <vprintfmt+0x1ae>
  801784:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801787:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80178a:	85 c9                	test   %ecx,%ecx
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	0f 49 c1             	cmovns %ecx,%eax
  801794:	29 c1                	sub    %eax,%ecx
  801796:	89 75 08             	mov    %esi,0x8(%ebp)
  801799:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80179c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80179f:	89 cb                	mov    %ecx,%ebx
  8017a1:	eb 16                	jmp    8017b9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8017a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017a7:	75 31                	jne    8017da <vprintfmt+0x217>
					putch(ch, putdat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	50                   	push   %eax
  8017b0:	ff 55 08             	call   *0x8(%ebp)
  8017b3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017b6:	83 eb 01             	sub    $0x1,%ebx
  8017b9:	83 c7 01             	add    $0x1,%edi
  8017bc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8017c0:	0f be c2             	movsbl %dl,%eax
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	74 59                	je     801820 <vprintfmt+0x25d>
  8017c7:	85 f6                	test   %esi,%esi
  8017c9:	78 d8                	js     8017a3 <vprintfmt+0x1e0>
  8017cb:	83 ee 01             	sub    $0x1,%esi
  8017ce:	79 d3                	jns    8017a3 <vprintfmt+0x1e0>
  8017d0:	89 df                	mov    %ebx,%edi
  8017d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017d8:	eb 37                	jmp    801811 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8017da:	0f be d2             	movsbl %dl,%edx
  8017dd:	83 ea 20             	sub    $0x20,%edx
  8017e0:	83 fa 5e             	cmp    $0x5e,%edx
  8017e3:	76 c4                	jbe    8017a9 <vprintfmt+0x1e6>
					putch('?', putdat);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	6a 3f                	push   $0x3f
  8017ed:	ff 55 08             	call   *0x8(%ebp)
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	eb c1                	jmp    8017b6 <vprintfmt+0x1f3>
  8017f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8017f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801801:	eb b6                	jmp    8017b9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	53                   	push   %ebx
  801807:	6a 20                	push   $0x20
  801809:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80180b:	83 ef 01             	sub    $0x1,%edi
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 ff                	test   %edi,%edi
  801813:	7f ee                	jg     801803 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801815:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801818:	89 45 14             	mov    %eax,0x14(%ebp)
  80181b:	e9 78 01 00 00       	jmp    801998 <vprintfmt+0x3d5>
  801820:	89 df                	mov    %ebx,%edi
  801822:	8b 75 08             	mov    0x8(%ebp),%esi
  801825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801828:	eb e7                	jmp    801811 <vprintfmt+0x24e>
	if (lflag >= 2)
  80182a:	83 f9 01             	cmp    $0x1,%ecx
  80182d:	7e 3f                	jle    80186e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80182f:	8b 45 14             	mov    0x14(%ebp),%eax
  801832:	8b 50 04             	mov    0x4(%eax),%edx
  801835:	8b 00                	mov    (%eax),%eax
  801837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80183a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80183d:	8b 45 14             	mov    0x14(%ebp),%eax
  801840:	8d 40 08             	lea    0x8(%eax),%eax
  801843:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801846:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80184a:	79 5c                	jns    8018a8 <vprintfmt+0x2e5>
				putch('-', putdat);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	53                   	push   %ebx
  801850:	6a 2d                	push   $0x2d
  801852:	ff d6                	call   *%esi
				num = -(long long) num;
  801854:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801857:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80185a:	f7 da                	neg    %edx
  80185c:	83 d1 00             	adc    $0x0,%ecx
  80185f:	f7 d9                	neg    %ecx
  801861:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801864:	b8 0a 00 00 00       	mov    $0xa,%eax
  801869:	e9 10 01 00 00       	jmp    80197e <vprintfmt+0x3bb>
	else if (lflag)
  80186e:	85 c9                	test   %ecx,%ecx
  801870:	75 1b                	jne    80188d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801872:	8b 45 14             	mov    0x14(%ebp),%eax
  801875:	8b 00                	mov    (%eax),%eax
  801877:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80187a:	89 c1                	mov    %eax,%ecx
  80187c:	c1 f9 1f             	sar    $0x1f,%ecx
  80187f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801882:	8b 45 14             	mov    0x14(%ebp),%eax
  801885:	8d 40 04             	lea    0x4(%eax),%eax
  801888:	89 45 14             	mov    %eax,0x14(%ebp)
  80188b:	eb b9                	jmp    801846 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80188d:	8b 45 14             	mov    0x14(%ebp),%eax
  801890:	8b 00                	mov    (%eax),%eax
  801892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801895:	89 c1                	mov    %eax,%ecx
  801897:	c1 f9 1f             	sar    $0x1f,%ecx
  80189a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80189d:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a0:	8d 40 04             	lea    0x4(%eax),%eax
  8018a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8018a6:	eb 9e                	jmp    801846 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8018a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8018ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018b3:	e9 c6 00 00 00       	jmp    80197e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8018b8:	83 f9 01             	cmp    $0x1,%ecx
  8018bb:	7e 18                	jle    8018d5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8018bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c0:	8b 10                	mov    (%eax),%edx
  8018c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8018c5:	8d 40 08             	lea    0x8(%eax),%eax
  8018c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8018cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018d0:	e9 a9 00 00 00       	jmp    80197e <vprintfmt+0x3bb>
	else if (lflag)
  8018d5:	85 c9                	test   %ecx,%ecx
  8018d7:	75 1a                	jne    8018f3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8018d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dc:	8b 10                	mov    (%eax),%edx
  8018de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018e3:	8d 40 04             	lea    0x4(%eax),%eax
  8018e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8018e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018ee:	e9 8b 00 00 00       	jmp    80197e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8018f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f6:	8b 10                	mov    (%eax),%edx
  8018f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018fd:	8d 40 04             	lea    0x4(%eax),%eax
  801900:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801903:	b8 0a 00 00 00       	mov    $0xa,%eax
  801908:	eb 74                	jmp    80197e <vprintfmt+0x3bb>
	if (lflag >= 2)
  80190a:	83 f9 01             	cmp    $0x1,%ecx
  80190d:	7e 15                	jle    801924 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80190f:	8b 45 14             	mov    0x14(%ebp),%eax
  801912:	8b 10                	mov    (%eax),%edx
  801914:	8b 48 04             	mov    0x4(%eax),%ecx
  801917:	8d 40 08             	lea    0x8(%eax),%eax
  80191a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80191d:	b8 08 00 00 00       	mov    $0x8,%eax
  801922:	eb 5a                	jmp    80197e <vprintfmt+0x3bb>
	else if (lflag)
  801924:	85 c9                	test   %ecx,%ecx
  801926:	75 17                	jne    80193f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801928:	8b 45 14             	mov    0x14(%ebp),%eax
  80192b:	8b 10                	mov    (%eax),%edx
  80192d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801932:	8d 40 04             	lea    0x4(%eax),%eax
  801935:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801938:	b8 08 00 00 00       	mov    $0x8,%eax
  80193d:	eb 3f                	jmp    80197e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80193f:	8b 45 14             	mov    0x14(%ebp),%eax
  801942:	8b 10                	mov    (%eax),%edx
  801944:	b9 00 00 00 00       	mov    $0x0,%ecx
  801949:	8d 40 04             	lea    0x4(%eax),%eax
  80194c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80194f:	b8 08 00 00 00       	mov    $0x8,%eax
  801954:	eb 28                	jmp    80197e <vprintfmt+0x3bb>
			putch('0', putdat);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	53                   	push   %ebx
  80195a:	6a 30                	push   $0x30
  80195c:	ff d6                	call   *%esi
			putch('x', putdat);
  80195e:	83 c4 08             	add    $0x8,%esp
  801961:	53                   	push   %ebx
  801962:	6a 78                	push   $0x78
  801964:	ff d6                	call   *%esi
			num = (unsigned long long)
  801966:	8b 45 14             	mov    0x14(%ebp),%eax
  801969:	8b 10                	mov    (%eax),%edx
  80196b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801970:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801973:	8d 40 04             	lea    0x4(%eax),%eax
  801976:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801979:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801985:	57                   	push   %edi
  801986:	ff 75 e0             	pushl  -0x20(%ebp)
  801989:	50                   	push   %eax
  80198a:	51                   	push   %ecx
  80198b:	52                   	push   %edx
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	89 f0                	mov    %esi,%eax
  801990:	e8 45 fb ff ff       	call   8014da <printnum>
			break;
  801995:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801998:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80199b:	83 c7 01             	add    $0x1,%edi
  80199e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019a2:	83 f8 25             	cmp    $0x25,%eax
  8019a5:	0f 84 2f fc ff ff    	je     8015da <vprintfmt+0x17>
			if (ch == '\0')
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	0f 84 8b 00 00 00    	je     801a3e <vprintfmt+0x47b>
			putch(ch, putdat);
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	53                   	push   %ebx
  8019b7:	50                   	push   %eax
  8019b8:	ff d6                	call   *%esi
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb dc                	jmp    80199b <vprintfmt+0x3d8>
	if (lflag >= 2)
  8019bf:	83 f9 01             	cmp    $0x1,%ecx
  8019c2:	7e 15                	jle    8019d9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8b 10                	mov    (%eax),%edx
  8019c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8019cc:	8d 40 08             	lea    0x8(%eax),%eax
  8019cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8019d7:	eb a5                	jmp    80197e <vprintfmt+0x3bb>
	else if (lflag)
  8019d9:	85 c9                	test   %ecx,%ecx
  8019db:	75 17                	jne    8019f4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8019dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e0:	8b 10                	mov    (%eax),%edx
  8019e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e7:	8d 40 04             	lea    0x4(%eax),%eax
  8019ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8019f2:	eb 8a                	jmp    80197e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8019f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f7:	8b 10                	mov    (%eax),%edx
  8019f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fe:	8d 40 04             	lea    0x4(%eax),%eax
  801a01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a04:	b8 10 00 00 00       	mov    $0x10,%eax
  801a09:	e9 70 ff ff ff       	jmp    80197e <vprintfmt+0x3bb>
			putch(ch, putdat);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	53                   	push   %ebx
  801a12:	6a 25                	push   $0x25
  801a14:	ff d6                	call   *%esi
			break;
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	e9 7a ff ff ff       	jmp    801998 <vprintfmt+0x3d5>
			putch('%', putdat);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	53                   	push   %ebx
  801a22:	6a 25                	push   $0x25
  801a24:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	89 f8                	mov    %edi,%eax
  801a2b:	eb 03                	jmp    801a30 <vprintfmt+0x46d>
  801a2d:	83 e8 01             	sub    $0x1,%eax
  801a30:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801a34:	75 f7                	jne    801a2d <vprintfmt+0x46a>
  801a36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a39:	e9 5a ff ff ff       	jmp    801998 <vprintfmt+0x3d5>
}
  801a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 18             	sub    $0x18,%esp
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a63:	85 c0                	test   %eax,%eax
  801a65:	74 26                	je     801a8d <vsnprintf+0x47>
  801a67:	85 d2                	test   %edx,%edx
  801a69:	7e 22                	jle    801a8d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a6b:	ff 75 14             	pushl  0x14(%ebp)
  801a6e:	ff 75 10             	pushl  0x10(%ebp)
  801a71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a74:	50                   	push   %eax
  801a75:	68 89 15 80 00       	push   $0x801589
  801a7a:	e8 44 fb ff ff       	call   8015c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a82:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	83 c4 10             	add    $0x10,%esp
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    
		return -E_INVAL;
  801a8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a92:	eb f7                	jmp    801a8b <vsnprintf+0x45>

00801a94 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a9a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a9d:	50                   	push   %eax
  801a9e:	ff 75 10             	pushl  0x10(%ebp)
  801aa1:	ff 75 0c             	pushl  0xc(%ebp)
  801aa4:	ff 75 08             	pushl  0x8(%ebp)
  801aa7:	e8 9a ff ff ff       	call   801a46 <vsnprintf>
	va_end(ap);

	return rc;
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	eb 03                	jmp    801abe <strlen+0x10>
		n++;
  801abb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801abe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ac2:	75 f7                	jne    801abb <strlen+0xd>
	return n;
}
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801acc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	eb 03                	jmp    801ad9 <strnlen+0x13>
		n++;
  801ad6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ad9:	39 d0                	cmp    %edx,%eax
  801adb:	74 06                	je     801ae3 <strnlen+0x1d>
  801add:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801ae1:	75 f3                	jne    801ad6 <strnlen+0x10>
	return n;
}
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	83 c1 01             	add    $0x1,%ecx
  801af4:	83 c2 01             	add    $0x1,%edx
  801af7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801afb:	88 5a ff             	mov    %bl,-0x1(%edx)
  801afe:	84 db                	test   %bl,%bl
  801b00:	75 ef                	jne    801af1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b02:	5b                   	pop    %ebx
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	53                   	push   %ebx
  801b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b0c:	53                   	push   %ebx
  801b0d:	e8 9c ff ff ff       	call   801aae <strlen>
  801b12:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b15:	ff 75 0c             	pushl  0xc(%ebp)
  801b18:	01 d8                	add    %ebx,%eax
  801b1a:	50                   	push   %eax
  801b1b:	e8 c5 ff ff ff       	call   801ae5 <strcpy>
	return dst;
}
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b32:	89 f3                	mov    %esi,%ebx
  801b34:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b37:	89 f2                	mov    %esi,%edx
  801b39:	eb 0f                	jmp    801b4a <strncpy+0x23>
		*dst++ = *src;
  801b3b:	83 c2 01             	add    $0x1,%edx
  801b3e:	0f b6 01             	movzbl (%ecx),%eax
  801b41:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b44:	80 39 01             	cmpb   $0x1,(%ecx)
  801b47:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801b4a:	39 da                	cmp    %ebx,%edx
  801b4c:	75 ed                	jne    801b3b <strncpy+0x14>
	}
	return ret;
}
  801b4e:	89 f0                	mov    %esi,%eax
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b62:	89 f0                	mov    %esi,%eax
  801b64:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b68:	85 c9                	test   %ecx,%ecx
  801b6a:	75 0b                	jne    801b77 <strlcpy+0x23>
  801b6c:	eb 17                	jmp    801b85 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b6e:	83 c2 01             	add    $0x1,%edx
  801b71:	83 c0 01             	add    $0x1,%eax
  801b74:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801b77:	39 d8                	cmp    %ebx,%eax
  801b79:	74 07                	je     801b82 <strlcpy+0x2e>
  801b7b:	0f b6 0a             	movzbl (%edx),%ecx
  801b7e:	84 c9                	test   %cl,%cl
  801b80:	75 ec                	jne    801b6e <strlcpy+0x1a>
		*dst = '\0';
  801b82:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801b85:	29 f0                	sub    %esi,%eax
}
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b94:	eb 06                	jmp    801b9c <strcmp+0x11>
		p++, q++;
  801b96:	83 c1 01             	add    $0x1,%ecx
  801b99:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801b9c:	0f b6 01             	movzbl (%ecx),%eax
  801b9f:	84 c0                	test   %al,%al
  801ba1:	74 04                	je     801ba7 <strcmp+0x1c>
  801ba3:	3a 02                	cmp    (%edx),%al
  801ba5:	74 ef                	je     801b96 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ba7:	0f b6 c0             	movzbl %al,%eax
  801baa:	0f b6 12             	movzbl (%edx),%edx
  801bad:	29 d0                	sub    %edx,%eax
}
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801bc0:	eb 06                	jmp    801bc8 <strncmp+0x17>
		n--, p++, q++;
  801bc2:	83 c0 01             	add    $0x1,%eax
  801bc5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801bc8:	39 d8                	cmp    %ebx,%eax
  801bca:	74 16                	je     801be2 <strncmp+0x31>
  801bcc:	0f b6 08             	movzbl (%eax),%ecx
  801bcf:	84 c9                	test   %cl,%cl
  801bd1:	74 04                	je     801bd7 <strncmp+0x26>
  801bd3:	3a 0a                	cmp    (%edx),%cl
  801bd5:	74 eb                	je     801bc2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801bd7:	0f b6 00             	movzbl (%eax),%eax
  801bda:	0f b6 12             	movzbl (%edx),%edx
  801bdd:	29 d0                	sub    %edx,%eax
}
  801bdf:	5b                   	pop    %ebx
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
		return 0;
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
  801be7:	eb f6                	jmp    801bdf <strncmp+0x2e>

00801be9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801bf3:	0f b6 10             	movzbl (%eax),%edx
  801bf6:	84 d2                	test   %dl,%dl
  801bf8:	74 09                	je     801c03 <strchr+0x1a>
		if (*s == c)
  801bfa:	38 ca                	cmp    %cl,%dl
  801bfc:	74 0a                	je     801c08 <strchr+0x1f>
	for (; *s; s++)
  801bfe:	83 c0 01             	add    $0x1,%eax
  801c01:	eb f0                	jmp    801bf3 <strchr+0xa>
			return (char *) s;
	return 0;
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c14:	eb 03                	jmp    801c19 <strfind+0xf>
  801c16:	83 c0 01             	add    $0x1,%eax
  801c19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c1c:	38 ca                	cmp    %cl,%dl
  801c1e:	74 04                	je     801c24 <strfind+0x1a>
  801c20:	84 d2                	test   %dl,%dl
  801c22:	75 f2                	jne    801c16 <strfind+0xc>
			break;
	return (char *) s;
}
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	57                   	push   %edi
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c32:	85 c9                	test   %ecx,%ecx
  801c34:	74 13                	je     801c49 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c3c:	75 05                	jne    801c43 <memset+0x1d>
  801c3e:	f6 c1 03             	test   $0x3,%cl
  801c41:	74 0d                	je     801c50 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c46:	fc                   	cld    
  801c47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c49:	89 f8                	mov    %edi,%eax
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    
		c &= 0xFF;
  801c50:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c54:	89 d3                	mov    %edx,%ebx
  801c56:	c1 e3 08             	shl    $0x8,%ebx
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	c1 e0 18             	shl    $0x18,%eax
  801c5e:	89 d6                	mov    %edx,%esi
  801c60:	c1 e6 10             	shl    $0x10,%esi
  801c63:	09 f0                	or     %esi,%eax
  801c65:	09 c2                	or     %eax,%edx
  801c67:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801c69:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801c6c:	89 d0                	mov    %edx,%eax
  801c6e:	fc                   	cld    
  801c6f:	f3 ab                	rep stos %eax,%es:(%edi)
  801c71:	eb d6                	jmp    801c49 <memset+0x23>

00801c73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801c81:	39 c6                	cmp    %eax,%esi
  801c83:	73 35                	jae    801cba <memmove+0x47>
  801c85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801c88:	39 c2                	cmp    %eax,%edx
  801c8a:	76 2e                	jbe    801cba <memmove+0x47>
		s += n;
		d += n;
  801c8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c8f:	89 d6                	mov    %edx,%esi
  801c91:	09 fe                	or     %edi,%esi
  801c93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c99:	74 0c                	je     801ca7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801c9b:	83 ef 01             	sub    $0x1,%edi
  801c9e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801ca1:	fd                   	std    
  801ca2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ca4:	fc                   	cld    
  801ca5:	eb 21                	jmp    801cc8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ca7:	f6 c1 03             	test   $0x3,%cl
  801caa:	75 ef                	jne    801c9b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801cac:	83 ef 04             	sub    $0x4,%edi
  801caf:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cb2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801cb5:	fd                   	std    
  801cb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cb8:	eb ea                	jmp    801ca4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cba:	89 f2                	mov    %esi,%edx
  801cbc:	09 c2                	or     %eax,%edx
  801cbe:	f6 c2 03             	test   $0x3,%dl
  801cc1:	74 09                	je     801ccc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801cc3:	89 c7                	mov    %eax,%edi
  801cc5:	fc                   	cld    
  801cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ccc:	f6 c1 03             	test   $0x3,%cl
  801ccf:	75 f2                	jne    801cc3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801cd1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801cd4:	89 c7                	mov    %eax,%edi
  801cd6:	fc                   	cld    
  801cd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cd9:	eb ed                	jmp    801cc8 <memmove+0x55>

00801cdb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801cde:	ff 75 10             	pushl  0x10(%ebp)
  801ce1:	ff 75 0c             	pushl  0xc(%ebp)
  801ce4:	ff 75 08             	pushl  0x8(%ebp)
  801ce7:	e8 87 ff ff ff       	call   801c73 <memmove>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	56                   	push   %esi
  801cf2:	53                   	push   %ebx
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf9:	89 c6                	mov    %eax,%esi
  801cfb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cfe:	39 f0                	cmp    %esi,%eax
  801d00:	74 1c                	je     801d1e <memcmp+0x30>
		if (*s1 != *s2)
  801d02:	0f b6 08             	movzbl (%eax),%ecx
  801d05:	0f b6 1a             	movzbl (%edx),%ebx
  801d08:	38 d9                	cmp    %bl,%cl
  801d0a:	75 08                	jne    801d14 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d0c:	83 c0 01             	add    $0x1,%eax
  801d0f:	83 c2 01             	add    $0x1,%edx
  801d12:	eb ea                	jmp    801cfe <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801d14:	0f b6 c1             	movzbl %cl,%eax
  801d17:	0f b6 db             	movzbl %bl,%ebx
  801d1a:	29 d8                	sub    %ebx,%eax
  801d1c:	eb 05                	jmp    801d23 <memcmp+0x35>
	}

	return 0;
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801d30:	89 c2                	mov    %eax,%edx
  801d32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801d35:	39 d0                	cmp    %edx,%eax
  801d37:	73 09                	jae    801d42 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d39:	38 08                	cmp    %cl,(%eax)
  801d3b:	74 05                	je     801d42 <memfind+0x1b>
	for (; s < ends; s++)
  801d3d:	83 c0 01             	add    $0x1,%eax
  801d40:	eb f3                	jmp    801d35 <memfind+0xe>
			break;
	return (void *) s;
}
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	57                   	push   %edi
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d50:	eb 03                	jmp    801d55 <strtol+0x11>
		s++;
  801d52:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801d55:	0f b6 01             	movzbl (%ecx),%eax
  801d58:	3c 20                	cmp    $0x20,%al
  801d5a:	74 f6                	je     801d52 <strtol+0xe>
  801d5c:	3c 09                	cmp    $0x9,%al
  801d5e:	74 f2                	je     801d52 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801d60:	3c 2b                	cmp    $0x2b,%al
  801d62:	74 2e                	je     801d92 <strtol+0x4e>
	int neg = 0;
  801d64:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801d69:	3c 2d                	cmp    $0x2d,%al
  801d6b:	74 2f                	je     801d9c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801d73:	75 05                	jne    801d7a <strtol+0x36>
  801d75:	80 39 30             	cmpb   $0x30,(%ecx)
  801d78:	74 2c                	je     801da6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d7a:	85 db                	test   %ebx,%ebx
  801d7c:	75 0a                	jne    801d88 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801d83:	80 39 30             	cmpb   $0x30,(%ecx)
  801d86:	74 28                	je     801db0 <strtol+0x6c>
		base = 10;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801d90:	eb 50                	jmp    801de2 <strtol+0x9e>
		s++;
  801d92:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801d95:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9a:	eb d1                	jmp    801d6d <strtol+0x29>
		s++, neg = 1;
  801d9c:	83 c1 01             	add    $0x1,%ecx
  801d9f:	bf 01 00 00 00       	mov    $0x1,%edi
  801da4:	eb c7                	jmp    801d6d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801da6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801daa:	74 0e                	je     801dba <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801dac:	85 db                	test   %ebx,%ebx
  801dae:	75 d8                	jne    801d88 <strtol+0x44>
		s++, base = 8;
  801db0:	83 c1 01             	add    $0x1,%ecx
  801db3:	bb 08 00 00 00       	mov    $0x8,%ebx
  801db8:	eb ce                	jmp    801d88 <strtol+0x44>
		s += 2, base = 16;
  801dba:	83 c1 02             	add    $0x2,%ecx
  801dbd:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dc2:	eb c4                	jmp    801d88 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801dc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  801dc7:	89 f3                	mov    %esi,%ebx
  801dc9:	80 fb 19             	cmp    $0x19,%bl
  801dcc:	77 29                	ja     801df7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801dce:	0f be d2             	movsbl %dl,%edx
  801dd1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801dd4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801dd7:	7d 30                	jge    801e09 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801dd9:	83 c1 01             	add    $0x1,%ecx
  801ddc:	0f af 45 10          	imul   0x10(%ebp),%eax
  801de0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801de2:	0f b6 11             	movzbl (%ecx),%edx
  801de5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801de8:	89 f3                	mov    %esi,%ebx
  801dea:	80 fb 09             	cmp    $0x9,%bl
  801ded:	77 d5                	ja     801dc4 <strtol+0x80>
			dig = *s - '0';
  801def:	0f be d2             	movsbl %dl,%edx
  801df2:	83 ea 30             	sub    $0x30,%edx
  801df5:	eb dd                	jmp    801dd4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801df7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801dfa:	89 f3                	mov    %esi,%ebx
  801dfc:	80 fb 19             	cmp    $0x19,%bl
  801dff:	77 08                	ja     801e09 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801e01:	0f be d2             	movsbl %dl,%edx
  801e04:	83 ea 37             	sub    $0x37,%edx
  801e07:	eb cb                	jmp    801dd4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e0d:	74 05                	je     801e14 <strtol+0xd0>
		*endptr = (char *) s;
  801e0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e12:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	f7 da                	neg    %edx
  801e18:	85 ff                	test   %edi,%edi
  801e1a:	0f 45 c2             	cmovne %edx,%eax
}
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    

00801e22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801e30:	85 c0                	test   %eax,%eax
  801e32:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e37:	0f 44 c2             	cmove  %edx,%eax
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	50                   	push   %eax
  801e3e:	e8 dd e4 ff ff       	call   800320 <sys_ipc_recv>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 2b                	js     801e75 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801e4a:	85 f6                	test   %esi,%esi
  801e4c:	74 0a                	je     801e58 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801e4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e53:	8b 40 74             	mov    0x74(%eax),%eax
  801e56:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801e58:	85 db                	test   %ebx,%ebx
  801e5a:	74 0a                	je     801e66 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801e5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e61:	8b 40 78             	mov    0x78(%eax),%eax
  801e64:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801e66:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
        *from_env_store = 0;
  801e75:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801e7b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801e81:	eb eb                	jmp    801e6e <ipc_recv+0x4c>

00801e83 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	57                   	push   %edi
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801e95:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801e97:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e9c:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801e9f:	ff 75 14             	pushl  0x14(%ebp)
  801ea2:	53                   	push   %ebx
  801ea3:	56                   	push   %esi
  801ea4:	57                   	push   %edi
  801ea5:	e8 53 e4 ff ff       	call   8002fd <sys_ipc_try_send>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	74 17                	je     801ec8 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801eb1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb4:	74 e9                	je     801e9f <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801eb6:	50                   	push   %eax
  801eb7:	68 60 27 80 00       	push   $0x802760
  801ebc:	6a 3e                	push   $0x3e
  801ebe:	68 72 27 80 00       	push   $0x802772
  801ec3:	e8 23 f5 ff ff       	call   8013eb <_panic>
        }
    }
}
  801ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecb:	5b                   	pop    %ebx
  801ecc:	5e                   	pop    %esi
  801ecd:	5f                   	pop    %edi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801edb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ede:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ee4:	8b 52 50             	mov    0x50(%edx),%edx
  801ee7:	39 ca                	cmp    %ecx,%edx
  801ee9:	74 11                	je     801efc <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801eeb:	83 c0 01             	add    $0x1,%eax
  801eee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef3:	75 e6                	jne    801edb <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  801efa:	eb 0b                	jmp    801f07 <ipc_find_env+0x37>
			return envs[i].env_id;
  801efc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801eff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f04:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0f:	89 d0                	mov    %edx,%eax
  801f11:	c1 e8 16             	shr    $0x16,%eax
  801f14:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f20:	f6 c1 01             	test   $0x1,%cl
  801f23:	74 1d                	je     801f42 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f25:	c1 ea 0c             	shr    $0xc,%edx
  801f28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f2f:	f6 c2 01             	test   $0x1,%dl
  801f32:	74 0e                	je     801f42 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f34:	c1 ea 0c             	shr    $0xc,%edx
  801f37:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3e:	ef 
  801f3f:	0f b7 c0             	movzwl %ax,%eax
}
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    
  801f44:	66 90                	xchg   %ax,%ax
  801f46:	66 90                	xchg   %ax,%ax
  801f48:	66 90                	xchg   %ax,%ax
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f67:	85 d2                	test   %edx,%edx
  801f69:	75 35                	jne    801fa0 <__udivdi3+0x50>
  801f6b:	39 f3                	cmp    %esi,%ebx
  801f6d:	0f 87 bd 00 00 00    	ja     802030 <__udivdi3+0xe0>
  801f73:	85 db                	test   %ebx,%ebx
  801f75:	89 d9                	mov    %ebx,%ecx
  801f77:	75 0b                	jne    801f84 <__udivdi3+0x34>
  801f79:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f3                	div    %ebx
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	31 d2                	xor    %edx,%edx
  801f86:	89 f0                	mov    %esi,%eax
  801f88:	f7 f1                	div    %ecx
  801f8a:	89 c6                	mov    %eax,%esi
  801f8c:	89 e8                	mov    %ebp,%eax
  801f8e:	89 f7                	mov    %esi,%edi
  801f90:	f7 f1                	div    %ecx
  801f92:	89 fa                	mov    %edi,%edx
  801f94:	83 c4 1c             	add    $0x1c,%esp
  801f97:	5b                   	pop    %ebx
  801f98:	5e                   	pop    %esi
  801f99:	5f                   	pop    %edi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    
  801f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 f2                	cmp    %esi,%edx
  801fa2:	77 7c                	ja     802020 <__udivdi3+0xd0>
  801fa4:	0f bd fa             	bsr    %edx,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0xf8>
  801fb0:	89 f9                	mov    %edi,%ecx
  801fb2:	b8 20 00 00 00       	mov    $0x20,%eax
  801fb7:	29 f8                	sub    %edi,%eax
  801fb9:	d3 e2                	shl    %cl,%edx
  801fbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fbf:	89 c1                	mov    %eax,%ecx
  801fc1:	89 da                	mov    %ebx,%edx
  801fc3:	d3 ea                	shr    %cl,%edx
  801fc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801fc9:	09 d1                	or     %edx,%ecx
  801fcb:	89 f2                	mov    %esi,%edx
  801fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e3                	shl    %cl,%ebx
  801fd5:	89 c1                	mov    %eax,%ecx
  801fd7:	d3 ea                	shr    %cl,%edx
  801fd9:	89 f9                	mov    %edi,%ecx
  801fdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fdf:	d3 e6                	shl    %cl,%esi
  801fe1:	89 eb                	mov    %ebp,%ebx
  801fe3:	89 c1                	mov    %eax,%ecx
  801fe5:	d3 eb                	shr    %cl,%ebx
  801fe7:	09 de                	or     %ebx,%esi
  801fe9:	89 f0                	mov    %esi,%eax
  801feb:	f7 74 24 08          	divl   0x8(%esp)
  801fef:	89 d6                	mov    %edx,%esi
  801ff1:	89 c3                	mov    %eax,%ebx
  801ff3:	f7 64 24 0c          	mull   0xc(%esp)
  801ff7:	39 d6                	cmp    %edx,%esi
  801ff9:	72 0c                	jb     802007 <__udivdi3+0xb7>
  801ffb:	89 f9                	mov    %edi,%ecx
  801ffd:	d3 e5                	shl    %cl,%ebp
  801fff:	39 c5                	cmp    %eax,%ebp
  802001:	73 5d                	jae    802060 <__udivdi3+0x110>
  802003:	39 d6                	cmp    %edx,%esi
  802005:	75 59                	jne    802060 <__udivdi3+0x110>
  802007:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80200a:	31 ff                	xor    %edi,%edi
  80200c:	89 fa                	mov    %edi,%edx
  80200e:	83 c4 1c             	add    $0x1c,%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
  802016:	8d 76 00             	lea    0x0(%esi),%esi
  802019:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802020:	31 ff                	xor    %edi,%edi
  802022:	31 c0                	xor    %eax,%eax
  802024:	89 fa                	mov    %edi,%edx
  802026:	83 c4 1c             	add    $0x1c,%esp
  802029:	5b                   	pop    %ebx
  80202a:	5e                   	pop    %esi
  80202b:	5f                   	pop    %edi
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    
  80202e:	66 90                	xchg   %ax,%ax
  802030:	31 ff                	xor    %edi,%edi
  802032:	89 e8                	mov    %ebp,%eax
  802034:	89 f2                	mov    %esi,%edx
  802036:	f7 f3                	div    %ebx
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	72 06                	jb     802052 <__udivdi3+0x102>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 d2                	ja     802024 <__udivdi3+0xd4>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb cb                	jmp    802024 <__udivdi3+0xd4>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	31 ff                	xor    %edi,%edi
  802064:	eb be                	jmp    802024 <__udivdi3+0xd4>
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80207b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80207f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 ed                	test   %ebp,%ebp
  802089:	89 f0                	mov    %esi,%eax
  80208b:	89 da                	mov    %ebx,%edx
  80208d:	75 19                	jne    8020a8 <__umoddi3+0x38>
  80208f:	39 df                	cmp    %ebx,%edi
  802091:	0f 86 b1 00 00 00    	jbe    802148 <__umoddi3+0xd8>
  802097:	f7 f7                	div    %edi
  802099:	89 d0                	mov    %edx,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	83 c4 1c             	add    $0x1c,%esp
  8020a0:	5b                   	pop    %ebx
  8020a1:	5e                   	pop    %esi
  8020a2:	5f                   	pop    %edi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    
  8020a5:	8d 76 00             	lea    0x0(%esi),%esi
  8020a8:	39 dd                	cmp    %ebx,%ebp
  8020aa:	77 f1                	ja     80209d <__umoddi3+0x2d>
  8020ac:	0f bd cd             	bsr    %ebp,%ecx
  8020af:	83 f1 1f             	xor    $0x1f,%ecx
  8020b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020b6:	0f 84 b4 00 00 00    	je     802170 <__umoddi3+0x100>
  8020bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020c7:	29 c2                	sub    %eax,%edx
  8020c9:	89 c1                	mov    %eax,%ecx
  8020cb:	89 f8                	mov    %edi,%eax
  8020cd:	d3 e5                	shl    %cl,%ebp
  8020cf:	89 d1                	mov    %edx,%ecx
  8020d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020d5:	d3 e8                	shr    %cl,%eax
  8020d7:	09 c5                	or     %eax,%ebp
  8020d9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020dd:	89 c1                	mov    %eax,%ecx
  8020df:	d3 e7                	shl    %cl,%edi
  8020e1:	89 d1                	mov    %edx,%ecx
  8020e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020e7:	89 df                	mov    %ebx,%edi
  8020e9:	d3 ef                	shr    %cl,%edi
  8020eb:	89 c1                	mov    %eax,%ecx
  8020ed:	89 f0                	mov    %esi,%eax
  8020ef:	d3 e3                	shl    %cl,%ebx
  8020f1:	89 d1                	mov    %edx,%ecx
  8020f3:	89 fa                	mov    %edi,%edx
  8020f5:	d3 e8                	shr    %cl,%eax
  8020f7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020fc:	09 d8                	or     %ebx,%eax
  8020fe:	f7 f5                	div    %ebp
  802100:	d3 e6                	shl    %cl,%esi
  802102:	89 d1                	mov    %edx,%ecx
  802104:	f7 64 24 08          	mull   0x8(%esp)
  802108:	39 d1                	cmp    %edx,%ecx
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d7                	mov    %edx,%edi
  80210e:	72 06                	jb     802116 <__umoddi3+0xa6>
  802110:	75 0e                	jne    802120 <__umoddi3+0xb0>
  802112:	39 c6                	cmp    %eax,%esi
  802114:	73 0a                	jae    802120 <__umoddi3+0xb0>
  802116:	2b 44 24 08          	sub    0x8(%esp),%eax
  80211a:	19 ea                	sbb    %ebp,%edx
  80211c:	89 d7                	mov    %edx,%edi
  80211e:	89 c3                	mov    %eax,%ebx
  802120:	89 ca                	mov    %ecx,%edx
  802122:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802127:	29 de                	sub    %ebx,%esi
  802129:	19 fa                	sbb    %edi,%edx
  80212b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	d3 e0                	shl    %cl,%eax
  802133:	89 d9                	mov    %ebx,%ecx
  802135:	d3 ee                	shr    %cl,%esi
  802137:	d3 ea                	shr    %cl,%edx
  802139:	09 f0                	or     %esi,%eax
  80213b:	83 c4 1c             	add    $0x1c,%esp
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    
  802143:	90                   	nop
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	85 ff                	test   %edi,%edi
  80214a:	89 f9                	mov    %edi,%ecx
  80214c:	75 0b                	jne    802159 <__umoddi3+0xe9>
  80214e:	b8 01 00 00 00       	mov    $0x1,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f7                	div    %edi
  802157:	89 c1                	mov    %eax,%ecx
  802159:	89 d8                	mov    %ebx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f1                	div    %ecx
  80215f:	89 f0                	mov    %esi,%eax
  802161:	f7 f1                	div    %ecx
  802163:	e9 31 ff ff ff       	jmp    802099 <__umoddi3+0x29>
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 dd                	cmp    %ebx,%ebp
  802172:	72 08                	jb     80217c <__umoddi3+0x10c>
  802174:	39 f7                	cmp    %esi,%edi
  802176:	0f 87 21 ff ff ff    	ja     80209d <__umoddi3+0x2d>
  80217c:	89 da                	mov    %ebx,%edx
  80217e:	89 f0                	mov    %esi,%eax
  802180:	29 f8                	sub    %edi,%eax
  802182:	19 ea                	sbb    %ebp,%edx
  802184:	e9 14 ff ff ff       	jmp    80209d <__umoddi3+0x2d>
