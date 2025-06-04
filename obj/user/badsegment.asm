
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 92 04 00 00       	call   800521 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7f 08                	jg     800105 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 ea 1d 80 00       	push   $0x801dea
  800110:	6a 23                	push   $0x23
  800112:	68 07 1e 80 00       	push   $0x801e07
  800117:	e8 18 0f 00 00       	call   801034 <_panic>

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7f 08                	jg     800186 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 ea 1d 80 00       	push   $0x801dea
  800191:	6a 23                	push   $0x23
  800193:	68 07 1e 80 00       	push   $0x801e07
  800198:	e8 97 0e 00 00       	call   801034 <_panic>

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7f 08                	jg     8001c8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c3:	5b                   	pop    %ebx
  8001c4:	5e                   	pop    %esi
  8001c5:	5f                   	pop    %edi
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 ea 1d 80 00       	push   $0x801dea
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 07 1e 80 00       	push   $0x801e07
  8001da:	e8 55 0e 00 00       	call   801034 <_panic>

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7f 08                	jg     80020a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 ea 1d 80 00       	push   $0x801dea
  800215:	6a 23                	push   $0x23
  800217:	68 07 1e 80 00       	push   $0x801e07
  80021c:	e8 13 0e 00 00       	call   801034 <_panic>

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7f 08                	jg     80024c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 ea 1d 80 00       	push   $0x801dea
  800257:	6a 23                	push   $0x23
  800259:	68 07 1e 80 00       	push   $0x801e07
  80025e:	e8 d1 0d 00 00       	call   801034 <_panic>

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 ea 1d 80 00       	push   $0x801dea
  800299:	6a 23                	push   $0x23
  80029b:	68 07 1e 80 00       	push   $0x801e07
  8002a0:	e8 8f 0d 00 00       	call   801034 <_panic>

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 0a                	push   $0xa
  8002d6:	68 ea 1d 80 00       	push   $0x801dea
  8002db:	6a 23                	push   $0x23
  8002dd:	68 07 1e 80 00       	push   $0x801e07
  8002e2:	e8 4d 0d 00 00       	call   801034 <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f8:	be 00 00 00 00       	mov    $0x0,%esi
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7f 08                	jg     800334 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 0d                	push   $0xd
  80033a:	68 ea 1d 80 00       	push   $0x801dea
  80033f:	6a 23                	push   $0x23
  800341:	68 07 1e 80 00       	push   $0x801e07
  800346:	e8 e9 0c 00 00       	call   801034 <_panic>

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 2a                	je     8003b8 <fd_alloc+0x46>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	74 19                	je     8003b8 <fd_alloc+0x46>
  80039f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a9:	75 d2                	jne    80037d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ab:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b6:	eb 07                	jmp    8003bf <fd_alloc+0x4d>
			*fd_store = fd;
  8003b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb f7                	jmp    800400 <fd_lookup+0x3f>
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb f0                	jmp    800400 <fd_lookup+0x3f>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800415:	eb e9                	jmp    800400 <fd_lookup+0x3f>

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	74 33                	je     800461 <dev_lookup+0x4a>
  80042e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	75 f3                	jne    80042a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800437:	a1 04 40 80 00       	mov    0x804004,%eax
  80043c:	8b 40 48             	mov    0x48(%eax),%eax
  80043f:	83 ec 04             	sub    $0x4,%esp
  800442:	51                   	push   %ecx
  800443:	50                   	push   %eax
  800444:	68 18 1e 80 00       	push   $0x801e18
  800449:	e8 c1 0c 00 00       	call   80110f <cprintf>
	*dev = 0;
  80044e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800451:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045f:	c9                   	leave  
  800460:	c3                   	ret    
			*dev = devtab[i];
  800461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800464:	89 01                	mov    %eax,(%ecx)
			return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb f2                	jmp    80045f <dev_lookup+0x48>

0080046d <fd_close>:
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 1c             	sub    $0x1c,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800489:	50                   	push   %eax
  80048a:	e8 32 ff ff ff       	call   8003c1 <fd_lookup>
  80048f:	89 c3                	mov    %eax,%ebx
  800491:	83 c4 08             	add    $0x8,%esp
  800494:	85 c0                	test   %eax,%eax
  800496:	78 05                	js     80049d <fd_close+0x30>
	    || fd != fd2)
  800498:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049b:	74 16                	je     8004b3 <fd_close+0x46>
		return (must_exist ? r : 0);
  80049d:	89 f8                	mov    %edi,%eax
  80049f:	84 c0                	test   %al,%al
  8004a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a6:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a9:	89 d8                	mov    %ebx,%eax
  8004ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5f                   	pop    %edi
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 56 ff ff ff       	call   800417 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 15                	js     8004df <fd_close+0x72>
		if (dev->dev_close)
  8004ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	74 1b                	je     8004ef <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d4:	83 ec 0c             	sub    $0xc,%esp
  8004d7:	56                   	push   %esi
  8004d8:	ff d0                	call   *%eax
  8004da:	89 c3                	mov    %eax,%ebx
  8004dc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	6a 00                	push   $0x0
  8004e5:	e8 f5 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	eb ba                	jmp    8004a9 <fd_close+0x3c>
			r = 0;
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f4:	eb e9                	jmp    8004df <fd_close+0x72>

008004f6 <close>:

int
close(int fdnum)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 b9 fe ff ff       	call   8003c1 <fd_lookup>
  800508:	83 c4 08             	add    $0x8,%esp
  80050b:	85 c0                	test   %eax,%eax
  80050d:	78 10                	js     80051f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	6a 01                	push   $0x1
  800514:	ff 75 f4             	pushl  -0xc(%ebp)
  800517:	e8 51 ff ff ff       	call   80046d <fd_close>
  80051c:	83 c4 10             	add    $0x10,%esp
}
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <close_all>:

void
close_all(void)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	53                   	push   %ebx
  800525:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800528:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052d:	83 ec 0c             	sub    $0xc,%esp
  800530:	53                   	push   %ebx
  800531:	e8 c0 ff ff ff       	call   8004f6 <close>
	for (i = 0; i < MAXFD; i++)
  800536:	83 c3 01             	add    $0x1,%ebx
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	83 fb 20             	cmp    $0x20,%ebx
  80053f:	75 ec                	jne    80052d <close_all+0xc>
}
  800541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 66 fe ff ff       	call   8003c1 <fd_lookup>
  80055b:	89 c3                	mov    %eax,%ebx
  80055d:	83 c4 08             	add    $0x8,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 88 81 00 00 00    	js     8005e9 <dup+0xa3>
		return r;
	close(newfdnum);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	e8 83 ff ff ff       	call   8004f6 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
  800576:	c1 e6 0c             	shl    $0xc,%esi
  800579:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057f:	83 c4 04             	add    $0x4,%esp
  800582:	ff 75 e4             	pushl  -0x1c(%ebp)
  800585:	e8 d1 fd ff ff       	call   80035b <fd2data>
  80058a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058c:	89 34 24             	mov    %esi,(%esp)
  80058f:	e8 c7 fd ff ff       	call   80035b <fd2data>
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 d8                	mov    %ebx,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 11                	je     8005ba <dup+0x74>
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	75 39                	jne    8005f3 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bd:	89 d0                	mov    %edx,%eax
  8005bf:	c1 e8 0c             	shr    $0xc,%eax
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	56                   	push   %esi
  8005d3:	6a 00                	push   $0x0
  8005d5:	52                   	push   %edx
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 c0 fb ff ff       	call   80019d <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 31                	js     800617 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	6a 00                	push   $0x0
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	e8 8f fb ff ff       	call   80019d <sys_page_map>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	79 a3                	jns    8005ba <dup+0x74>
	sys_page_unmap(0, newfd);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 00                	push   $0x0
  80061d:	e8 bd fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 00                	push   $0x0
  800628:	e8 b2 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb b7                	jmp    8005e9 <dup+0xa3>

00800632 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	53                   	push   %ebx
  800636:	83 ec 14             	sub    $0x14,%esp
  800639:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063f:	50                   	push   %eax
  800640:	53                   	push   %ebx
  800641:	e8 7b fd ff ff       	call   8003c1 <fd_lookup>
  800646:	83 c4 08             	add    $0x8,%esp
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 3f                	js     80068c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 b9 fd ff ff       	call   800417 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 27                	js     80068c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	74 1e                	je     800691 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800676:	8b 40 08             	mov    0x8(%eax),%eax
  800679:	85 c0                	test   %eax,%eax
  80067b:	74 35                	je     8006b2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80067d:	83 ec 04             	sub    $0x4,%esp
  800680:	ff 75 10             	pushl  0x10(%ebp)
  800683:	ff 75 0c             	pushl  0xc(%ebp)
  800686:	52                   	push   %edx
  800687:	ff d0                	call   *%eax
  800689:	83 c4 10             	add    $0x10,%esp
}
  80068c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068f:	c9                   	leave  
  800690:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 59 1e 80 00       	push   $0x801e59
  8006a3:	e8 67 0a 00 00       	call   80110f <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b0:	eb da                	jmp    80068c <read+0x5a>
		return -E_NOT_SUPP;
  8006b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b7:	eb d3                	jmp    80068c <read+0x5a>

008006b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	57                   	push   %edi
  8006bd:	56                   	push   %esi
  8006be:	53                   	push   %ebx
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	39 f3                	cmp    %esi,%ebx
  8006cf:	73 25                	jae    8006f6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	29 d8                	sub    %ebx,%eax
  8006d8:	50                   	push   %eax
  8006d9:	89 d8                	mov    %ebx,%eax
  8006db:	03 45 0c             	add    0xc(%ebp),%eax
  8006de:	50                   	push   %eax
  8006df:	57                   	push   %edi
  8006e0:	e8 4d ff ff ff       	call   800632 <read>
		if (m < 0)
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	78 08                	js     8006f4 <readn+0x3b>
			return m;
		if (m == 0)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 06                	je     8006f6 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f0:	01 c3                	add    %eax,%ebx
  8006f2:	eb d9                	jmp    8006cd <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f6:	89 d8                	mov    %ebx,%eax
  8006f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	53                   	push   %ebx
  800704:	83 ec 14             	sub    $0x14,%esp
  800707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	53                   	push   %ebx
  80070f:	e8 ad fc ff ff       	call   8003c1 <fd_lookup>
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	85 c0                	test   %eax,%eax
  800719:	78 3a                	js     800755 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800725:	ff 30                	pushl  (%eax)
  800727:	e8 eb fc ff ff       	call   800417 <dev_lookup>
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 22                	js     800755 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073a:	74 1e                	je     80075a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80073c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073f:	8b 52 0c             	mov    0xc(%edx),%edx
  800742:	85 d2                	test   %edx,%edx
  800744:	74 35                	je     80077b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800746:	83 ec 04             	sub    $0x4,%esp
  800749:	ff 75 10             	pushl  0x10(%ebp)
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	50                   	push   %eax
  800750:	ff d2                	call   *%edx
  800752:	83 c4 10             	add    $0x10,%esp
}
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 04 40 80 00       	mov    0x804004,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 75 1e 80 00       	push   $0x801e75
  80076c:	e8 9e 09 00 00       	call   80110f <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb da                	jmp    800755 <write+0x55>
		return -E_NOT_SUPP;
  80077b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800780:	eb d3                	jmp    800755 <write+0x55>

00800782 <seek>:

int
seek(int fdnum, off_t offset)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800788:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 2d fc ff ff       	call   8003c1 <fd_lookup>
  800794:	83 c4 08             	add    $0x8,%esp
  800797:	85 c0                	test   %eax,%eax
  800799:	78 0e                	js     8007a9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 14             	sub    $0x14,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	53                   	push   %ebx
  8007ba:	e8 02 fc ff ff       	call   8003c1 <fd_lookup>
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	78 37                	js     8007fd <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d0:	ff 30                	pushl  (%eax)
  8007d2:	e8 40 fc ff ff       	call   800417 <dev_lookup>
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	78 1f                	js     8007fd <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e5:	74 1b                	je     800802 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ea:	8b 52 18             	mov    0x18(%edx),%edx
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 32                	je     800823 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	50                   	push   %eax
  8007f8:	ff d2                	call   *%edx
  8007fa:	83 c4 10             	add    $0x10,%esp
}
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    
			thisenv->env_id, fdnum);
  800802:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800807:	8b 40 48             	mov    0x48(%eax),%eax
  80080a:	83 ec 04             	sub    $0x4,%esp
  80080d:	53                   	push   %ebx
  80080e:	50                   	push   %eax
  80080f:	68 38 1e 80 00       	push   $0x801e38
  800814:	e8 f6 08 00 00       	call   80110f <cprintf>
		return -E_INVAL;
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb da                	jmp    8007fd <ftruncate+0x52>
		return -E_NOT_SUPP;
  800823:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800828:	eb d3                	jmp    8007fd <ftruncate+0x52>

0080082a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 14             	sub    $0x14,%esp
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800834:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	ff 75 08             	pushl  0x8(%ebp)
  80083b:	e8 81 fb ff ff       	call   8003c1 <fd_lookup>
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 4b                	js     800892 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800851:	ff 30                	pushl  (%eax)
  800853:	e8 bf fb ff ff       	call   800417 <dev_lookup>
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 33                	js     800892 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800862:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800866:	74 2f                	je     800897 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800868:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800872:	00 00 00 
	stat->st_isdir = 0;
  800875:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087c:	00 00 00 
	stat->st_dev = dev;
  80087f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	ff 75 f0             	pushl  -0x10(%ebp)
  80088c:	ff 50 14             	call   *0x14(%eax)
  80088f:	83 c4 10             	add    $0x10,%esp
}
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    
		return -E_NOT_SUPP;
  800897:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089c:	eb f4                	jmp    800892 <fstat+0x68>

0080089e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	6a 00                	push   $0x0
  8008a8:	ff 75 08             	pushl  0x8(%ebp)
  8008ab:	e8 e7 01 00 00       	call   800a97 <open>
  8008b0:	89 c3                	mov    %eax,%ebx
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	78 1b                	js     8008d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	50                   	push   %eax
  8008c0:	e8 65 ff ff ff       	call   80082a <fstat>
  8008c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c7:	89 1c 24             	mov    %ebx,(%esp)
  8008ca:	e8 27 fc ff ff       	call   8004f6 <close>
	return r;
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	89 f3                	mov    %esi,%ebx
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	89 c6                	mov    %eax,%esi
  8008e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008ed:	74 27                	je     800916 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ef:	6a 07                	push   $0x7
  8008f1:	68 00 50 80 00       	push   $0x805000
  8008f6:	56                   	push   %esi
  8008f7:	ff 35 00 40 80 00    	pushl  0x804000
  8008fd:	e8 ca 11 00 00       	call   801acc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800902:	83 c4 0c             	add    $0xc,%esp
  800905:	6a 00                	push   $0x0
  800907:	53                   	push   %ebx
  800908:	6a 00                	push   $0x0
  80090a:	e8 5c 11 00 00       	call   801a6b <ipc_recv>
}
  80090f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800916:	83 ec 0c             	sub    $0xc,%esp
  800919:	6a 01                	push   $0x1
  80091b:	e8 f9 11 00 00       	call   801b19 <ipc_find_env>
  800920:	a3 00 40 80 00       	mov    %eax,0x804000
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	eb c5                	jmp    8008ef <fsipc+0x12>

0080092a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 40 0c             	mov    0xc(%eax),%eax
  800936:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800943:	ba 00 00 00 00       	mov    $0x0,%edx
  800948:	b8 02 00 00 00       	mov    $0x2,%eax
  80094d:	e8 8b ff ff ff       	call   8008dd <fsipc>
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <devfile_flush>:
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 40 0c             	mov    0xc(%eax),%eax
  800960:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	b8 06 00 00 00       	mov    $0x6,%eax
  80096f:	e8 69 ff ff ff       	call   8008dd <fsipc>
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <devfile_stat>:
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	83 ec 04             	sub    $0x4,%esp
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 40 0c             	mov    0xc(%eax),%eax
  800986:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098b:	ba 00 00 00 00       	mov    $0x0,%edx
  800990:	b8 05 00 00 00       	mov    $0x5,%eax
  800995:	e8 43 ff ff ff       	call   8008dd <fsipc>
  80099a:	85 c0                	test   %eax,%eax
  80099c:	78 2c                	js     8009ca <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	68 00 50 80 00       	push   $0x805000
  8009a6:	53                   	push   %ebx
  8009a7:	e8 82 0d 00 00       	call   80172e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c2:	83 c4 10             	add    $0x10,%esp
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <devfile_write>:
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
  8009d5:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e2:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009eb:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009f1:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8009f6:	50                   	push   %eax
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	68 08 50 80 00       	push   $0x805008
  8009ff:	e8 b8 0e 00 00       	call   8018bc <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0e:	e8 ca fe ff ff       	call   8008dd <fsipc>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_read>:
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 40 0c             	mov    0xc(%eax),%eax
  800a23:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a28:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	b8 03 00 00 00       	mov    $0x3,%eax
  800a38:	e8 a0 fe ff ff       	call   8008dd <fsipc>
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 1f                	js     800a62 <devfile_read+0x4d>
	assert(r <= n);
  800a43:	39 f0                	cmp    %esi,%eax
  800a45:	77 24                	ja     800a6b <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4c:	7f 33                	jg     800a81 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4e:	83 ec 04             	sub    $0x4,%esp
  800a51:	50                   	push   %eax
  800a52:	68 00 50 80 00       	push   $0x805000
  800a57:	ff 75 0c             	pushl  0xc(%ebp)
  800a5a:	e8 5d 0e 00 00       	call   8018bc <memmove>
	return r;
  800a5f:	83 c4 10             	add    $0x10,%esp
}
  800a62:	89 d8                	mov    %ebx,%eax
  800a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    
	assert(r <= n);
  800a6b:	68 a4 1e 80 00       	push   $0x801ea4
  800a70:	68 ab 1e 80 00       	push   $0x801eab
  800a75:	6a 7d                	push   $0x7d
  800a77:	68 c0 1e 80 00       	push   $0x801ec0
  800a7c:	e8 b3 05 00 00       	call   801034 <_panic>
	assert(r <= PGSIZE);
  800a81:	68 cb 1e 80 00       	push   $0x801ecb
  800a86:	68 ab 1e 80 00       	push   $0x801eab
  800a8b:	6a 7e                	push   $0x7e
  800a8d:	68 c0 1e 80 00       	push   $0x801ec0
  800a92:	e8 9d 05 00 00       	call   801034 <_panic>

00800a97 <open>:
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 1c             	sub    $0x1c,%esp
  800a9f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa2:	56                   	push   %esi
  800aa3:	e8 4f 0c 00 00       	call   8016f7 <strlen>
  800aa8:	83 c4 10             	add    $0x10,%esp
  800aab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab0:	0f 8f 96 00 00 00    	jg     800b4c <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abc:	50                   	push   %eax
  800abd:	e8 b0 f8 ff ff       	call   800372 <fd_alloc>
  800ac2:	89 c3                	mov    %eax,%ebx
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	78 66                	js     800b31 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800acb:	83 ec 08             	sub    $0x8,%esp
  800ace:	56                   	push   %esi
  800acf:	68 00 50 80 00       	push   $0x805000
  800ad4:	e8 55 0c 00 00       	call   80172e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae9:	e8 ef fd ff ff       	call   8008dd <fsipc>
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 43                	js     800b3a <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	ff 75 f4             	pushl  -0xc(%ebp)
  800afd:	e8 49 f8 ff ff       	call   80034b <fd2num>
  800b02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b05:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b0b:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b0e:	83 c4 08             	add    $0x8,%esp
  800b11:	50                   	push   %eax
  800b12:	52                   	push   %edx
  800b13:	ff 32                	pushl  (%edx)
  800b15:	56                   	push   %esi
  800b16:	51                   	push   %ecx
  800b17:	68 d8 1e 80 00       	push   $0x801ed8
  800b1c:	e8 ee 05 00 00       	call   80110f <cprintf>
	return fd2num(fd);
  800b21:	83 c4 14             	add    $0x14,%esp
  800b24:	ff 75 f4             	pushl  -0xc(%ebp)
  800b27:	e8 1f f8 ff ff       	call   80034b <fd2num>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	83 c4 10             	add    $0x10,%esp
}
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
		fd_close(fd, 0);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	6a 00                	push   $0x0
  800b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b42:	e8 26 f9 ff ff       	call   80046d <fd_close>
		return r;
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	eb e5                	jmp    800b31 <open+0x9a>
		return -E_BAD_PATH;
  800b4c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b51:	eb de                	jmp    800b31 <open+0x9a>

00800b53 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b63:	e8 75 fd ff ff       	call   8008dd <fsipc>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 08             	pushl  0x8(%ebp)
  800b78:	e8 de f7 ff ff       	call   80035b <fd2data>
  800b7d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7f:	83 c4 08             	add    $0x8,%esp
  800b82:	68 17 1f 80 00       	push   $0x801f17
  800b87:	53                   	push   %ebx
  800b88:	e8 a1 0b 00 00       	call   80172e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b8d:	8b 46 04             	mov    0x4(%esi),%eax
  800b90:	2b 06                	sub    (%esi),%eax
  800b92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b98:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9f:	00 00 00 
	stat->st_dev = &devpipe;
  800ba2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba9:	30 80 00 
	return 0;
}
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc2:	53                   	push   %ebx
  800bc3:	6a 00                	push   $0x0
  800bc5:	e8 15 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bca:	89 1c 24             	mov    %ebx,(%esp)
  800bcd:	e8 89 f7 ff ff       	call   80035b <fd2data>
  800bd2:	83 c4 08             	add    $0x8,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 02 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <_pipeisclosed>:
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bef:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	57                   	push   %edi
  800bfb:	e8 52 0f 00 00       	call   801b52 <pageref>
  800c00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c03:	89 34 24             	mov    %esi,(%esp)
  800c06:	e8 47 0f 00 00       	call   801b52 <pageref>
		nn = thisenv->env_runs;
  800c0b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	39 cb                	cmp    %ecx,%ebx
  800c19:	74 1b                	je     800c36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1e:	75 cf                	jne    800bef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c20:	8b 42 58             	mov    0x58(%edx),%eax
  800c23:	6a 01                	push   $0x1
  800c25:	50                   	push   %eax
  800c26:	53                   	push   %ebx
  800c27:	68 1e 1f 80 00       	push   $0x801f1e
  800c2c:	e8 de 04 00 00       	call   80110f <cprintf>
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	eb b9                	jmp    800bef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c39:	0f 94 c0             	sete   %al
  800c3c:	0f b6 c0             	movzbl %al,%eax
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <devpipe_write>:
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 28             	sub    $0x28,%esp
  800c50:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c53:	56                   	push   %esi
  800c54:	e8 02 f7 ff ff       	call   80035b <fd2data>
  800c59:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c66:	74 4f                	je     800cb7 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c68:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6b:	8b 0b                	mov    (%ebx),%ecx
  800c6d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c70:	39 d0                	cmp    %edx,%eax
  800c72:	72 14                	jb     800c88 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c74:	89 da                	mov    %ebx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	e8 65 ff ff ff       	call   800be2 <_pipeisclosed>
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	75 3a                	jne    800cbb <devpipe_write+0x74>
			sys_yield();
  800c81:	e8 b5 f4 ff ff       	call   80013b <sys_yield>
  800c86:	eb e0                	jmp    800c68 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	c1 fa 1f             	sar    $0x1f,%edx
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9f:	83 e2 1f             	and    $0x1f,%edx
  800ca2:	29 ca                	sub    %ecx,%edx
  800ca4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cac:	83 c0 01             	add    $0x1,%eax
  800caf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cb2:	83 c7 01             	add    $0x1,%edi
  800cb5:	eb ac                	jmp    800c63 <devpipe_write+0x1c>
	return i;
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	eb 05                	jmp    800cc0 <devpipe_write+0x79>
				return 0;
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <devpipe_read>:
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 18             	sub    $0x18,%esp
  800cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd4:	57                   	push   %edi
  800cd5:	e8 81 f6 ff ff       	call   80035b <fd2data>
  800cda:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce7:	74 47                	je     800d30 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ce9:	8b 03                	mov    (%ebx),%eax
  800ceb:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cee:	75 22                	jne    800d12 <devpipe_read+0x4a>
			if (i > 0)
  800cf0:	85 f6                	test   %esi,%esi
  800cf2:	75 14                	jne    800d08 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cf4:	89 da                	mov    %ebx,%edx
  800cf6:	89 f8                	mov    %edi,%eax
  800cf8:	e8 e5 fe ff ff       	call   800be2 <_pipeisclosed>
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	75 33                	jne    800d34 <devpipe_read+0x6c>
			sys_yield();
  800d01:	e8 35 f4 ff ff       	call   80013b <sys_yield>
  800d06:	eb e1                	jmp    800ce9 <devpipe_read+0x21>
				return i;
  800d08:	89 f0                	mov    %esi,%eax
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d12:	99                   	cltd   
  800d13:	c1 ea 1b             	shr    $0x1b,%edx
  800d16:	01 d0                	add    %edx,%eax
  800d18:	83 e0 1f             	and    $0x1f,%eax
  800d1b:	29 d0                	sub    %edx,%eax
  800d1d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d28:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d2b:	83 c6 01             	add    $0x1,%esi
  800d2e:	eb b4                	jmp    800ce4 <devpipe_read+0x1c>
	return i;
  800d30:	89 f0                	mov    %esi,%eax
  800d32:	eb d6                	jmp    800d0a <devpipe_read+0x42>
				return 0;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	eb cf                	jmp    800d0a <devpipe_read+0x42>

00800d3b <pipe>:
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d46:	50                   	push   %eax
  800d47:	e8 26 f6 ff ff       	call   800372 <fd_alloc>
  800d4c:	89 c3                	mov    %eax,%ebx
  800d4e:	83 c4 10             	add    $0x10,%esp
  800d51:	85 c0                	test   %eax,%eax
  800d53:	78 5b                	js     800db0 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	68 07 04 00 00       	push   $0x407
  800d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d60:	6a 00                	push   $0x0
  800d62:	e8 f3 f3 ff ff       	call   80015a <sys_page_alloc>
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	78 40                	js     800db0 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d76:	50                   	push   %eax
  800d77:	e8 f6 f5 ff ff       	call   800372 <fd_alloc>
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 1b                	js     800da0 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	68 07 04 00 00       	push   $0x407
  800d8d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d90:	6a 00                	push   $0x0
  800d92:	e8 c3 f3 ff ff       	call   80015a <sys_page_alloc>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	79 19                	jns    800db9 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800da0:	83 ec 08             	sub    $0x8,%esp
  800da3:	ff 75 f4             	pushl  -0xc(%ebp)
  800da6:	6a 00                	push   $0x0
  800da8:	e8 32 f4 ff ff       	call   8001df <sys_page_unmap>
  800dad:	83 c4 10             	add    $0x10,%esp
}
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
	va = fd2data(fd0);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbf:	e8 97 f5 ff ff       	call   80035b <fd2data>
  800dc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 c4 0c             	add    $0xc,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	50                   	push   %eax
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 84 f3 ff ff       	call   80015a <sys_page_alloc>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	0f 88 8c 00 00 00    	js     800e6f <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	ff 75 f0             	pushl  -0x10(%ebp)
  800de9:	e8 6d f5 ff ff       	call   80035b <fd2data>
  800dee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df5:	50                   	push   %eax
  800df6:	6a 00                	push   $0x0
  800df8:	56                   	push   %esi
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 9d f3 ff ff       	call   80019d <sys_page_map>
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	83 c4 20             	add    $0x20,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	78 58                	js     800e61 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	ff 75 f4             	pushl  -0xc(%ebp)
  800e39:	e8 0d f5 ff ff       	call   80034b <fd2num>
  800e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e43:	83 c4 04             	add    $0x4,%esp
  800e46:	ff 75 f0             	pushl  -0x10(%ebp)
  800e49:	e8 fd f4 ff ff       	call   80034b <fd2num>
  800e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	e9 4f ff ff ff       	jmp    800db0 <pipe+0x75>
	sys_page_unmap(0, va);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	56                   	push   %esi
  800e65:	6a 00                	push   $0x0
  800e67:	e8 73 f3 ff ff       	call   8001df <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	6a 00                	push   $0x0
  800e77:	e8 63 f3 ff ff       	call   8001df <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	e9 1c ff ff ff       	jmp    800da0 <pipe+0x65>

00800e84 <pipeisclosed>:
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8d:	50                   	push   %eax
  800e8e:	ff 75 08             	pushl  0x8(%ebp)
  800e91:	e8 2b f5 ff ff       	call   8003c1 <fd_lookup>
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 18                	js     800eb5 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea3:	e8 b3 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ead:	e8 30 fd ff ff       	call   800be2 <_pipeisclosed>
  800eb2:	83 c4 10             	add    $0x10,%esp
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec7:	68 36 1f 80 00       	push   $0x801f36
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	e8 5a 08 00 00       	call   80172e <strcpy>
	return 0;
}
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <devcons_write>:
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ef2:	eb 2f                	jmp    800f23 <devcons_write+0x48>
		m = n - tot;
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	29 f3                	sub    %esi,%ebx
  800ef9:	83 fb 7f             	cmp    $0x7f,%ebx
  800efc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f01:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	53                   	push   %ebx
  800f08:	89 f0                	mov    %esi,%eax
  800f0a:	03 45 0c             	add    0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	57                   	push   %edi
  800f0f:	e8 a8 09 00 00       	call   8018bc <memmove>
		sys_cputs(buf, m);
  800f14:	83 c4 08             	add    $0x8,%esp
  800f17:	53                   	push   %ebx
  800f18:	57                   	push   %edi
  800f19:	e8 80 f1 ff ff       	call   80009e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f1e:	01 de                	add    %ebx,%esi
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f26:	72 cc                	jb     800ef4 <devcons_write+0x19>
}
  800f28:	89 f0                	mov    %esi,%eax
  800f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <devcons_read>:
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f41:	75 07                	jne    800f4a <devcons_read+0x18>
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    
		sys_yield();
  800f45:	e8 f1 f1 ff ff       	call   80013b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f4a:	e8 6d f1 ff ff       	call   8000bc <sys_cgetc>
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	74 f2                	je     800f45 <devcons_read+0x13>
	if (c < 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 ec                	js     800f43 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f57:	83 f8 04             	cmp    $0x4,%eax
  800f5a:	74 0c                	je     800f68 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5f:	88 02                	mov    %al,(%edx)
	return 1;
  800f61:	b8 01 00 00 00       	mov    $0x1,%eax
  800f66:	eb db                	jmp    800f43 <devcons_read+0x11>
		return 0;
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6d:	eb d4                	jmp    800f43 <devcons_read+0x11>

00800f6f <cputchar>:
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f7b:	6a 01                	push   $0x1
  800f7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	e8 18 f1 ff ff       	call   80009e <sys_cputs>
}
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <getchar>:
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f91:	6a 01                	push   $0x1
  800f93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	6a 00                	push   $0x0
  800f99:	e8 94 f6 ff ff       	call   800632 <read>
	if (r < 0)
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 08                	js     800fad <getchar+0x22>
	if (r < 1)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7e 06                	jle    800faf <getchar+0x24>
	return c;
  800fa9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    
		return -E_EOF;
  800faf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb4:	eb f7                	jmp    800fad <getchar+0x22>

00800fb6 <iscons>:
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	ff 75 08             	pushl  0x8(%ebp)
  800fc3:	e8 f9 f3 ff ff       	call   8003c1 <fd_lookup>
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 11                	js     800fe0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd8:	39 10                	cmp    %edx,(%eax)
  800fda:	0f 94 c0             	sete   %al
  800fdd:	0f b6 c0             	movzbl %al,%eax
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <opencons>:
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	e8 81 f3 ff ff       	call   800372 <fd_alloc>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 3a                	js     801032 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 07 04 00 00       	push   $0x407
  801000:	ff 75 f4             	pushl  -0xc(%ebp)
  801003:	6a 00                	push   $0x0
  801005:	e8 50 f1 ff ff       	call   80015a <sys_page_alloc>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 21                	js     801032 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	50                   	push   %eax
  80102a:	e8 1c f3 ff ff       	call   80034b <fd2num>
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801039:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801042:	e8 d5 f0 ff ff       	call   80011c <sys_getenvid>
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	ff 75 0c             	pushl  0xc(%ebp)
  80104d:	ff 75 08             	pushl  0x8(%ebp)
  801050:	56                   	push   %esi
  801051:	50                   	push   %eax
  801052:	68 44 1f 80 00       	push   $0x801f44
  801057:	e8 b3 00 00 00       	call   80110f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105c:	83 c4 18             	add    $0x18,%esp
  80105f:	53                   	push   %ebx
  801060:	ff 75 10             	pushl  0x10(%ebp)
  801063:	e8 56 00 00 00       	call   8010be <vcprintf>
	cprintf("\n");
  801068:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80106f:	e8 9b 00 00 00       	call   80110f <cprintf>
  801074:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801077:	cc                   	int3   
  801078:	eb fd                	jmp    801077 <_panic+0x43>

0080107a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801084:	8b 13                	mov    (%ebx),%edx
  801086:	8d 42 01             	lea    0x1(%edx),%eax
  801089:	89 03                	mov    %eax,(%ebx)
  80108b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801092:	3d ff 00 00 00       	cmp    $0xff,%eax
  801097:	74 09                	je     8010a2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801099:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80109d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	68 ff 00 00 00       	push   $0xff
  8010aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ad:	50                   	push   %eax
  8010ae:	e8 eb ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	eb db                	jmp    801099 <putch+0x1f>

008010be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ce:	00 00 00 
	b.cnt = 0;
  8010d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010db:	ff 75 0c             	pushl  0xc(%ebp)
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	68 7a 10 80 00       	push   $0x80107a
  8010ed:	e8 1a 01 00 00       	call   80120c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801101:	50                   	push   %eax
  801102:	e8 97 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801107:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801115:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801118:	50                   	push   %eax
  801119:	ff 75 08             	pushl  0x8(%ebp)
  80111c:	e8 9d ff ff ff       	call   8010be <vcprintf>
	va_end(ap);

	return cnt;
}
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 1c             	sub    $0x1c,%esp
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	89 d6                	mov    %edx,%esi
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	8b 55 0c             	mov    0xc(%ebp),%edx
  801136:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801139:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801144:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801147:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114a:	39 d3                	cmp    %edx,%ebx
  80114c:	72 05                	jb     801153 <printnum+0x30>
  80114e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801151:	77 7a                	ja     8011cd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	ff 75 18             	pushl  0x18(%ebp)
  801159:	8b 45 14             	mov    0x14(%ebp),%eax
  80115c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115f:	53                   	push   %ebx
  801160:	ff 75 10             	pushl  0x10(%ebp)
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	ff 75 e4             	pushl  -0x1c(%ebp)
  801169:	ff 75 e0             	pushl  -0x20(%ebp)
  80116c:	ff 75 dc             	pushl  -0x24(%ebp)
  80116f:	ff 75 d8             	pushl  -0x28(%ebp)
  801172:	e8 19 0a 00 00       	call   801b90 <__udivdi3>
  801177:	83 c4 18             	add    $0x18,%esp
  80117a:	52                   	push   %edx
  80117b:	50                   	push   %eax
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	89 f8                	mov    %edi,%eax
  801180:	e8 9e ff ff ff       	call   801123 <printnum>
  801185:	83 c4 20             	add    $0x20,%esp
  801188:	eb 13                	jmp    80119d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	56                   	push   %esi
  80118e:	ff 75 18             	pushl  0x18(%ebp)
  801191:	ff d7                	call   *%edi
  801193:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801196:	83 eb 01             	sub    $0x1,%ebx
  801199:	85 db                	test   %ebx,%ebx
  80119b:	7f ed                	jg     80118a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	56                   	push   %esi
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b0:	e8 fb 0a 00 00       	call   801cb0 <__umoddi3>
  8011b5:	83 c4 14             	add    $0x14,%esp
  8011b8:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff d7                	call   *%edi
}
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    
  8011cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011d0:	eb c4                	jmp    801196 <printnum+0x73>

008011d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011dc:	8b 10                	mov    (%eax),%edx
  8011de:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e1:	73 0a                	jae    8011ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e6:	89 08                	mov    %ecx,(%eax)
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	88 02                	mov    %al,(%edx)
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <printfmt>:
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 10             	pushl  0x10(%ebp)
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	ff 75 08             	pushl  0x8(%ebp)
  801202:	e8 05 00 00 00       	call   80120c <vprintfmt>
}
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <vprintfmt>:
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 2c             	sub    $0x2c,%esp
  801215:	8b 75 08             	mov    0x8(%ebp),%esi
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80121e:	e9 c1 03 00 00       	jmp    8015e4 <vprintfmt+0x3d8>
		padc = ' ';
  801223:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801227:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80122e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801235:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80123c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801241:	8d 47 01             	lea    0x1(%edi),%eax
  801244:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801247:	0f b6 17             	movzbl (%edi),%edx
  80124a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80124d:	3c 55                	cmp    $0x55,%al
  80124f:	0f 87 12 04 00 00    	ja     801667 <vprintfmt+0x45b>
  801255:	0f b6 c0             	movzbl %al,%eax
  801258:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80125f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801262:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801266:	eb d9                	jmp    801241 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801268:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80126b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80126f:	eb d0                	jmp    801241 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801271:	0f b6 d2             	movzbl %dl,%edx
  801274:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80127f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801282:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801286:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801289:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80128c:	83 f9 09             	cmp    $0x9,%ecx
  80128f:	77 55                	ja     8012e6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801291:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801294:	eb e9                	jmp    80127f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801296:	8b 45 14             	mov    0x14(%ebp),%eax
  801299:	8b 00                	mov    (%eax),%eax
  80129b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80129e:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a1:	8d 40 04             	lea    0x4(%eax),%eax
  8012a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012ae:	79 91                	jns    801241 <vprintfmt+0x35>
				width = precision, precision = -1;
  8012b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012bd:	eb 82                	jmp    801241 <vprintfmt+0x35>
  8012bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c9:	0f 49 d0             	cmovns %eax,%edx
  8012cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d2:	e9 6a ff ff ff       	jmp    801241 <vprintfmt+0x35>
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e1:	e9 5b ff ff ff       	jmp    801241 <vprintfmt+0x35>
  8012e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ec:	eb bc                	jmp    8012aa <vprintfmt+0x9e>
			lflag++;
  8012ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012f4:	e9 48 ff ff ff       	jmp    801241 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fc:	8d 78 04             	lea    0x4(%eax),%edi
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	53                   	push   %ebx
  801303:	ff 30                	pushl  (%eax)
  801305:	ff d6                	call   *%esi
			break;
  801307:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80130a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80130d:	e9 cf 02 00 00       	jmp    8015e1 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801312:	8b 45 14             	mov    0x14(%ebp),%eax
  801315:	8d 78 04             	lea    0x4(%eax),%edi
  801318:	8b 00                	mov    (%eax),%eax
  80131a:	99                   	cltd   
  80131b:	31 d0                	xor    %edx,%eax
  80131d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131f:	83 f8 0f             	cmp    $0xf,%eax
  801322:	7f 23                	jg     801347 <vprintfmt+0x13b>
  801324:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80132b:	85 d2                	test   %edx,%edx
  80132d:	74 18                	je     801347 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80132f:	52                   	push   %edx
  801330:	68 bd 1e 80 00       	push   $0x801ebd
  801335:	53                   	push   %ebx
  801336:	56                   	push   %esi
  801337:	e8 b3 fe ff ff       	call   8011ef <printfmt>
  80133c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80133f:	89 7d 14             	mov    %edi,0x14(%ebp)
  801342:	e9 9a 02 00 00       	jmp    8015e1 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801347:	50                   	push   %eax
  801348:	68 7f 1f 80 00       	push   $0x801f7f
  80134d:	53                   	push   %ebx
  80134e:	56                   	push   %esi
  80134f:	e8 9b fe ff ff       	call   8011ef <printfmt>
  801354:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801357:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80135a:	e9 82 02 00 00       	jmp    8015e1 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	83 c0 04             	add    $0x4,%eax
  801365:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801368:	8b 45 14             	mov    0x14(%ebp),%eax
  80136b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80136d:	85 ff                	test   %edi,%edi
  80136f:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801374:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801377:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137b:	0f 8e bd 00 00 00    	jle    80143e <vprintfmt+0x232>
  801381:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801385:	75 0e                	jne    801395 <vprintfmt+0x189>
  801387:	89 75 08             	mov    %esi,0x8(%ebp)
  80138a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80138d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801390:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801393:	eb 6d                	jmp    801402 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	ff 75 d0             	pushl  -0x30(%ebp)
  80139b:	57                   	push   %edi
  80139c:	e8 6e 03 00 00       	call   80170f <strnlen>
  8013a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a4:	29 c1                	sub    %eax,%ecx
  8013a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b8:	eb 0f                	jmp    8013c9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	53                   	push   %ebx
  8013be:	ff 75 e0             	pushl  -0x20(%ebp)
  8013c1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c3:	83 ef 01             	sub    $0x1,%edi
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 ff                	test   %edi,%edi
  8013cb:	7f ed                	jg     8013ba <vprintfmt+0x1ae>
  8013cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013d3:	85 c9                	test   %ecx,%ecx
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	0f 49 c1             	cmovns %ecx,%eax
  8013dd:	29 c1                	sub    %eax,%ecx
  8013df:	89 75 08             	mov    %esi,0x8(%ebp)
  8013e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e8:	89 cb                	mov    %ecx,%ebx
  8013ea:	eb 16                	jmp    801402 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f0:	75 31                	jne    801423 <vprintfmt+0x217>
					putch(ch, putdat);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	50                   	push   %eax
  8013f9:	ff 55 08             	call   *0x8(%ebp)
  8013fc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013ff:	83 eb 01             	sub    $0x1,%ebx
  801402:	83 c7 01             	add    $0x1,%edi
  801405:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801409:	0f be c2             	movsbl %dl,%eax
  80140c:	85 c0                	test   %eax,%eax
  80140e:	74 59                	je     801469 <vprintfmt+0x25d>
  801410:	85 f6                	test   %esi,%esi
  801412:	78 d8                	js     8013ec <vprintfmt+0x1e0>
  801414:	83 ee 01             	sub    $0x1,%esi
  801417:	79 d3                	jns    8013ec <vprintfmt+0x1e0>
  801419:	89 df                	mov    %ebx,%edi
  80141b:	8b 75 08             	mov    0x8(%ebp),%esi
  80141e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801421:	eb 37                	jmp    80145a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801423:	0f be d2             	movsbl %dl,%edx
  801426:	83 ea 20             	sub    $0x20,%edx
  801429:	83 fa 5e             	cmp    $0x5e,%edx
  80142c:	76 c4                	jbe    8013f2 <vprintfmt+0x1e6>
					putch('?', putdat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	6a 3f                	push   $0x3f
  801436:	ff 55 08             	call   *0x8(%ebp)
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	eb c1                	jmp    8013ff <vprintfmt+0x1f3>
  80143e:	89 75 08             	mov    %esi,0x8(%ebp)
  801441:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801444:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801447:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144a:	eb b6                	jmp    801402 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	53                   	push   %ebx
  801450:	6a 20                	push   $0x20
  801452:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801454:	83 ef 01             	sub    $0x1,%edi
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 ff                	test   %edi,%edi
  80145c:	7f ee                	jg     80144c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80145e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801461:	89 45 14             	mov    %eax,0x14(%ebp)
  801464:	e9 78 01 00 00       	jmp    8015e1 <vprintfmt+0x3d5>
  801469:	89 df                	mov    %ebx,%edi
  80146b:	8b 75 08             	mov    0x8(%ebp),%esi
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801471:	eb e7                	jmp    80145a <vprintfmt+0x24e>
	if (lflag >= 2)
  801473:	83 f9 01             	cmp    $0x1,%ecx
  801476:	7e 3f                	jle    8014b7 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801478:	8b 45 14             	mov    0x14(%ebp),%eax
  80147b:	8b 50 04             	mov    0x4(%eax),%edx
  80147e:	8b 00                	mov    (%eax),%eax
  801480:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801483:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801486:	8b 45 14             	mov    0x14(%ebp),%eax
  801489:	8d 40 08             	lea    0x8(%eax),%eax
  80148c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80148f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801493:	79 5c                	jns    8014f1 <vprintfmt+0x2e5>
				putch('-', putdat);
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	53                   	push   %ebx
  801499:	6a 2d                	push   $0x2d
  80149b:	ff d6                	call   *%esi
				num = -(long long) num;
  80149d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014a3:	f7 da                	neg    %edx
  8014a5:	83 d1 00             	adc    $0x0,%ecx
  8014a8:	f7 d9                	neg    %ecx
  8014aa:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b2:	e9 10 01 00 00       	jmp    8015c7 <vprintfmt+0x3bb>
	else if (lflag)
  8014b7:	85 c9                	test   %ecx,%ecx
  8014b9:	75 1b                	jne    8014d6 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c3:	89 c1                	mov    %eax,%ecx
  8014c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8d 40 04             	lea    0x4(%eax),%eax
  8014d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d4:	eb b9                	jmp    80148f <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 c1                	mov    %eax,%ecx
  8014e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e9:	8d 40 04             	lea    0x4(%eax),%eax
  8014ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ef:	eb 9e                	jmp    80148f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fc:	e9 c6 00 00 00       	jmp    8015c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801501:	83 f9 01             	cmp    $0x1,%ecx
  801504:	7e 18                	jle    80151e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801506:	8b 45 14             	mov    0x14(%ebp),%eax
  801509:	8b 10                	mov    (%eax),%edx
  80150b:	8b 48 04             	mov    0x4(%eax),%ecx
  80150e:	8d 40 08             	lea    0x8(%eax),%eax
  801511:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801514:	b8 0a 00 00 00       	mov    $0xa,%eax
  801519:	e9 a9 00 00 00       	jmp    8015c7 <vprintfmt+0x3bb>
	else if (lflag)
  80151e:	85 c9                	test   %ecx,%ecx
  801520:	75 1a                	jne    80153c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8b 10                	mov    (%eax),%edx
  801527:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152c:	8d 40 04             	lea    0x4(%eax),%eax
  80152f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801532:	b8 0a 00 00 00       	mov    $0xa,%eax
  801537:	e9 8b 00 00 00       	jmp    8015c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80153c:	8b 45 14             	mov    0x14(%ebp),%eax
  80153f:	8b 10                	mov    (%eax),%edx
  801541:	b9 00 00 00 00       	mov    $0x0,%ecx
  801546:	8d 40 04             	lea    0x4(%eax),%eax
  801549:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80154c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801551:	eb 74                	jmp    8015c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801553:	83 f9 01             	cmp    $0x1,%ecx
  801556:	7e 15                	jle    80156d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8b 10                	mov    (%eax),%edx
  80155d:	8b 48 04             	mov    0x4(%eax),%ecx
  801560:	8d 40 08             	lea    0x8(%eax),%eax
  801563:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801566:	b8 08 00 00 00       	mov    $0x8,%eax
  80156b:	eb 5a                	jmp    8015c7 <vprintfmt+0x3bb>
	else if (lflag)
  80156d:	85 c9                	test   %ecx,%ecx
  80156f:	75 17                	jne    801588 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801571:	8b 45 14             	mov    0x14(%ebp),%eax
  801574:	8b 10                	mov    (%eax),%edx
  801576:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157b:	8d 40 04             	lea    0x4(%eax),%eax
  80157e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801581:	b8 08 00 00 00       	mov    $0x8,%eax
  801586:	eb 3f                	jmp    8015c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8b 10                	mov    (%eax),%edx
  80158d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801592:	8d 40 04             	lea    0x4(%eax),%eax
  801595:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801598:	b8 08 00 00 00       	mov    $0x8,%eax
  80159d:	eb 28                	jmp    8015c7 <vprintfmt+0x3bb>
			putch('0', putdat);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	6a 30                	push   $0x30
  8015a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	6a 78                	push   $0x78
  8015ad:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8b 10                	mov    (%eax),%edx
  8015b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015bc:	8d 40 04             	lea    0x4(%eax),%eax
  8015bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ce:	57                   	push   %edi
  8015cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	51                   	push   %ecx
  8015d4:	52                   	push   %edx
  8015d5:	89 da                	mov    %ebx,%edx
  8015d7:	89 f0                	mov    %esi,%eax
  8015d9:	e8 45 fb ff ff       	call   801123 <printnum>
			break;
  8015de:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015e4:	83 c7 01             	add    $0x1,%edi
  8015e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015eb:	83 f8 25             	cmp    $0x25,%eax
  8015ee:	0f 84 2f fc ff ff    	je     801223 <vprintfmt+0x17>
			if (ch == '\0')
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	0f 84 8b 00 00 00    	je     801687 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	50                   	push   %eax
  801601:	ff d6                	call   *%esi
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb dc                	jmp    8015e4 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801608:	83 f9 01             	cmp    $0x1,%ecx
  80160b:	7e 15                	jle    801622 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80160d:	8b 45 14             	mov    0x14(%ebp),%eax
  801610:	8b 10                	mov    (%eax),%edx
  801612:	8b 48 04             	mov    0x4(%eax),%ecx
  801615:	8d 40 08             	lea    0x8(%eax),%eax
  801618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161b:	b8 10 00 00 00       	mov    $0x10,%eax
  801620:	eb a5                	jmp    8015c7 <vprintfmt+0x3bb>
	else if (lflag)
  801622:	85 c9                	test   %ecx,%ecx
  801624:	75 17                	jne    80163d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801626:	8b 45 14             	mov    0x14(%ebp),%eax
  801629:	8b 10                	mov    (%eax),%edx
  80162b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801630:	8d 40 04             	lea    0x4(%eax),%eax
  801633:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801636:	b8 10 00 00 00       	mov    $0x10,%eax
  80163b:	eb 8a                	jmp    8015c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80163d:	8b 45 14             	mov    0x14(%ebp),%eax
  801640:	8b 10                	mov    (%eax),%edx
  801642:	b9 00 00 00 00       	mov    $0x0,%ecx
  801647:	8d 40 04             	lea    0x4(%eax),%eax
  80164a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80164d:	b8 10 00 00 00       	mov    $0x10,%eax
  801652:	e9 70 ff ff ff       	jmp    8015c7 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	6a 25                	push   $0x25
  80165d:	ff d6                	call   *%esi
			break;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	e9 7a ff ff ff       	jmp    8015e1 <vprintfmt+0x3d5>
			putch('%', putdat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	6a 25                	push   $0x25
  80166d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	89 f8                	mov    %edi,%eax
  801674:	eb 03                	jmp    801679 <vprintfmt+0x46d>
  801676:	83 e8 01             	sub    $0x1,%eax
  801679:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80167d:	75 f7                	jne    801676 <vprintfmt+0x46a>
  80167f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801682:	e9 5a ff ff ff       	jmp    8015e1 <vprintfmt+0x3d5>
}
  801687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5f                   	pop    %edi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 18             	sub    $0x18,%esp
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
  801698:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80169b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80169e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	74 26                	je     8016d6 <vsnprintf+0x47>
  8016b0:	85 d2                	test   %edx,%edx
  8016b2:	7e 22                	jle    8016d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016b4:	ff 75 14             	pushl  0x14(%ebp)
  8016b7:	ff 75 10             	pushl  0x10(%ebp)
  8016ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	68 d2 11 80 00       	push   $0x8011d2
  8016c3:	e8 44 fb ff ff       	call   80120c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	83 c4 10             	add    $0x10,%esp
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    
		return -E_INVAL;
  8016d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016db:	eb f7                	jmp    8016d4 <vsnprintf+0x45>

008016dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016e6:	50                   	push   %eax
  8016e7:	ff 75 10             	pushl  0x10(%ebp)
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	ff 75 08             	pushl  0x8(%ebp)
  8016f0:	e8 9a ff ff ff       	call   80168f <vsnprintf>
	va_end(ap);

	return rc;
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801702:	eb 03                	jmp    801707 <strlen+0x10>
		n++;
  801704:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801707:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80170b:	75 f7                	jne    801704 <strlen+0xd>
	return n;
}
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801718:	b8 00 00 00 00       	mov    $0x0,%eax
  80171d:	eb 03                	jmp    801722 <strnlen+0x13>
		n++;
  80171f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801722:	39 d0                	cmp    %edx,%eax
  801724:	74 06                	je     80172c <strnlen+0x1d>
  801726:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80172a:	75 f3                	jne    80171f <strnlen+0x10>
	return n;
}
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801738:	89 c2                	mov    %eax,%edx
  80173a:	83 c1 01             	add    $0x1,%ecx
  80173d:	83 c2 01             	add    $0x1,%edx
  801740:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801744:	88 5a ff             	mov    %bl,-0x1(%edx)
  801747:	84 db                	test   %bl,%bl
  801749:	75 ef                	jne    80173a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80174b:	5b                   	pop    %ebx
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	53                   	push   %ebx
  801752:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801755:	53                   	push   %ebx
  801756:	e8 9c ff ff ff       	call   8016f7 <strlen>
  80175b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80175e:	ff 75 0c             	pushl  0xc(%ebp)
  801761:	01 d8                	add    %ebx,%eax
  801763:	50                   	push   %eax
  801764:	e8 c5 ff ff ff       	call   80172e <strcpy>
	return dst;
}
  801769:	89 d8                	mov    %ebx,%eax
  80176b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	8b 75 08             	mov    0x8(%ebp),%esi
  801778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177b:	89 f3                	mov    %esi,%ebx
  80177d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801780:	89 f2                	mov    %esi,%edx
  801782:	eb 0f                	jmp    801793 <strncpy+0x23>
		*dst++ = *src;
  801784:	83 c2 01             	add    $0x1,%edx
  801787:	0f b6 01             	movzbl (%ecx),%eax
  80178a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80178d:	80 39 01             	cmpb   $0x1,(%ecx)
  801790:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801793:	39 da                	cmp    %ebx,%edx
  801795:	75 ed                	jne    801784 <strncpy+0x14>
	}
	return ret;
}
  801797:	89 f0                	mov    %esi,%eax
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ab:	89 f0                	mov    %esi,%eax
  8017ad:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017b1:	85 c9                	test   %ecx,%ecx
  8017b3:	75 0b                	jne    8017c0 <strlcpy+0x23>
  8017b5:	eb 17                	jmp    8017ce <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b7:	83 c2 01             	add    $0x1,%edx
  8017ba:	83 c0 01             	add    $0x1,%eax
  8017bd:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017c0:	39 d8                	cmp    %ebx,%eax
  8017c2:	74 07                	je     8017cb <strlcpy+0x2e>
  8017c4:	0f b6 0a             	movzbl (%edx),%ecx
  8017c7:	84 c9                	test   %cl,%cl
  8017c9:	75 ec                	jne    8017b7 <strlcpy+0x1a>
		*dst = '\0';
  8017cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ce:	29 f0                	sub    %esi,%eax
}
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017dd:	eb 06                	jmp    8017e5 <strcmp+0x11>
		p++, q++;
  8017df:	83 c1 01             	add    $0x1,%ecx
  8017e2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017e5:	0f b6 01             	movzbl (%ecx),%eax
  8017e8:	84 c0                	test   %al,%al
  8017ea:	74 04                	je     8017f0 <strcmp+0x1c>
  8017ec:	3a 02                	cmp    (%edx),%al
  8017ee:	74 ef                	je     8017df <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f0:	0f b6 c0             	movzbl %al,%eax
  8017f3:	0f b6 12             	movzbl (%edx),%edx
  8017f6:	29 d0                	sub    %edx,%eax
}
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 55 0c             	mov    0xc(%ebp),%edx
  801804:	89 c3                	mov    %eax,%ebx
  801806:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801809:	eb 06                	jmp    801811 <strncmp+0x17>
		n--, p++, q++;
  80180b:	83 c0 01             	add    $0x1,%eax
  80180e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801811:	39 d8                	cmp    %ebx,%eax
  801813:	74 16                	je     80182b <strncmp+0x31>
  801815:	0f b6 08             	movzbl (%eax),%ecx
  801818:	84 c9                	test   %cl,%cl
  80181a:	74 04                	je     801820 <strncmp+0x26>
  80181c:	3a 0a                	cmp    (%edx),%cl
  80181e:	74 eb                	je     80180b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801820:	0f b6 00             	movzbl (%eax),%eax
  801823:	0f b6 12             	movzbl (%edx),%edx
  801826:	29 d0                	sub    %edx,%eax
}
  801828:	5b                   	pop    %ebx
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    
		return 0;
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
  801830:	eb f6                	jmp    801828 <strncmp+0x2e>

00801832 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183c:	0f b6 10             	movzbl (%eax),%edx
  80183f:	84 d2                	test   %dl,%dl
  801841:	74 09                	je     80184c <strchr+0x1a>
		if (*s == c)
  801843:	38 ca                	cmp    %cl,%dl
  801845:	74 0a                	je     801851 <strchr+0x1f>
	for (; *s; s++)
  801847:	83 c0 01             	add    $0x1,%eax
  80184a:	eb f0                	jmp    80183c <strchr+0xa>
			return (char *) s;
	return 0;
  80184c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80185d:	eb 03                	jmp    801862 <strfind+0xf>
  80185f:	83 c0 01             	add    $0x1,%eax
  801862:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801865:	38 ca                	cmp    %cl,%dl
  801867:	74 04                	je     80186d <strfind+0x1a>
  801869:	84 d2                	test   %dl,%dl
  80186b:	75 f2                	jne    80185f <strfind+0xc>
			break;
	return (char *) s;
}
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	57                   	push   %edi
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	8b 7d 08             	mov    0x8(%ebp),%edi
  801878:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80187b:	85 c9                	test   %ecx,%ecx
  80187d:	74 13                	je     801892 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80187f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801885:	75 05                	jne    80188c <memset+0x1d>
  801887:	f6 c1 03             	test   $0x3,%cl
  80188a:	74 0d                	je     801899 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80188c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188f:	fc                   	cld    
  801890:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801892:	89 f8                	mov    %edi,%eax
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5f                   	pop    %edi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    
		c &= 0xFF;
  801899:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80189d:	89 d3                	mov    %edx,%ebx
  80189f:	c1 e3 08             	shl    $0x8,%ebx
  8018a2:	89 d0                	mov    %edx,%eax
  8018a4:	c1 e0 18             	shl    $0x18,%eax
  8018a7:	89 d6                	mov    %edx,%esi
  8018a9:	c1 e6 10             	shl    $0x10,%esi
  8018ac:	09 f0                	or     %esi,%eax
  8018ae:	09 c2                	or     %eax,%edx
  8018b0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018b2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018b5:	89 d0                	mov    %edx,%eax
  8018b7:	fc                   	cld    
  8018b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8018ba:	eb d6                	jmp    801892 <memset+0x23>

008018bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ca:	39 c6                	cmp    %eax,%esi
  8018cc:	73 35                	jae    801903 <memmove+0x47>
  8018ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018d1:	39 c2                	cmp    %eax,%edx
  8018d3:	76 2e                	jbe    801903 <memmove+0x47>
		s += n;
		d += n;
  8018d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d8:	89 d6                	mov    %edx,%esi
  8018da:	09 fe                	or     %edi,%esi
  8018dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018e2:	74 0c                	je     8018f0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018e4:	83 ef 01             	sub    $0x1,%edi
  8018e7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018ea:	fd                   	std    
  8018eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ed:	fc                   	cld    
  8018ee:	eb 21                	jmp    801911 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f0:	f6 c1 03             	test   $0x3,%cl
  8018f3:	75 ef                	jne    8018e4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018f5:	83 ef 04             	sub    $0x4,%edi
  8018f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018fe:	fd                   	std    
  8018ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801901:	eb ea                	jmp    8018ed <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801903:	89 f2                	mov    %esi,%edx
  801905:	09 c2                	or     %eax,%edx
  801907:	f6 c2 03             	test   $0x3,%dl
  80190a:	74 09                	je     801915 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190c:	89 c7                	mov    %eax,%edi
  80190e:	fc                   	cld    
  80190f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801911:	5e                   	pop    %esi
  801912:	5f                   	pop    %edi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801915:	f6 c1 03             	test   $0x3,%cl
  801918:	75 f2                	jne    80190c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80191a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80191d:	89 c7                	mov    %eax,%edi
  80191f:	fc                   	cld    
  801920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801922:	eb ed                	jmp    801911 <memmove+0x55>

00801924 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801927:	ff 75 10             	pushl  0x10(%ebp)
  80192a:	ff 75 0c             	pushl  0xc(%ebp)
  80192d:	ff 75 08             	pushl  0x8(%ebp)
  801930:	e8 87 ff ff ff       	call   8018bc <memmove>
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	56                   	push   %esi
  80193b:	53                   	push   %ebx
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801942:	89 c6                	mov    %eax,%esi
  801944:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801947:	39 f0                	cmp    %esi,%eax
  801949:	74 1c                	je     801967 <memcmp+0x30>
		if (*s1 != *s2)
  80194b:	0f b6 08             	movzbl (%eax),%ecx
  80194e:	0f b6 1a             	movzbl (%edx),%ebx
  801951:	38 d9                	cmp    %bl,%cl
  801953:	75 08                	jne    80195d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801955:	83 c0 01             	add    $0x1,%eax
  801958:	83 c2 01             	add    $0x1,%edx
  80195b:	eb ea                	jmp    801947 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80195d:	0f b6 c1             	movzbl %cl,%eax
  801960:	0f b6 db             	movzbl %bl,%ebx
  801963:	29 d8                	sub    %ebx,%eax
  801965:	eb 05                	jmp    80196c <memcmp+0x35>
	}

	return 0;
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196c:	5b                   	pop    %ebx
  80196d:	5e                   	pop    %esi
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801979:	89 c2                	mov    %eax,%edx
  80197b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80197e:	39 d0                	cmp    %edx,%eax
  801980:	73 09                	jae    80198b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801982:	38 08                	cmp    %cl,(%eax)
  801984:	74 05                	je     80198b <memfind+0x1b>
	for (; s < ends; s++)
  801986:	83 c0 01             	add    $0x1,%eax
  801989:	eb f3                	jmp    80197e <memfind+0xe>
			break;
	return (void *) s;
}
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801996:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801999:	eb 03                	jmp    80199e <strtol+0x11>
		s++;
  80199b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80199e:	0f b6 01             	movzbl (%ecx),%eax
  8019a1:	3c 20                	cmp    $0x20,%al
  8019a3:	74 f6                	je     80199b <strtol+0xe>
  8019a5:	3c 09                	cmp    $0x9,%al
  8019a7:	74 f2                	je     80199b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019a9:	3c 2b                	cmp    $0x2b,%al
  8019ab:	74 2e                	je     8019db <strtol+0x4e>
	int neg = 0;
  8019ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019b2:	3c 2d                	cmp    $0x2d,%al
  8019b4:	74 2f                	je     8019e5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019bc:	75 05                	jne    8019c3 <strtol+0x36>
  8019be:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c1:	74 2c                	je     8019ef <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c3:	85 db                	test   %ebx,%ebx
  8019c5:	75 0a                	jne    8019d1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cf:	74 28                	je     8019f9 <strtol+0x6c>
		base = 10;
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019d9:	eb 50                	jmp    801a2b <strtol+0x9e>
		s++;
  8019db:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019de:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e3:	eb d1                	jmp    8019b6 <strtol+0x29>
		s++, neg = 1;
  8019e5:	83 c1 01             	add    $0x1,%ecx
  8019e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ed:	eb c7                	jmp    8019b6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019f3:	74 0e                	je     801a03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f5:	85 db                	test   %ebx,%ebx
  8019f7:	75 d8                	jne    8019d1 <strtol+0x44>
		s++, base = 8;
  8019f9:	83 c1 01             	add    $0x1,%ecx
  8019fc:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a01:	eb ce                	jmp    8019d1 <strtol+0x44>
		s += 2, base = 16;
  801a03:	83 c1 02             	add    $0x2,%ecx
  801a06:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0b:	eb c4                	jmp    8019d1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a10:	89 f3                	mov    %esi,%ebx
  801a12:	80 fb 19             	cmp    $0x19,%bl
  801a15:	77 29                	ja     801a40 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a17:	0f be d2             	movsbl %dl,%edx
  801a1a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a20:	7d 30                	jge    801a52 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a22:	83 c1 01             	add    $0x1,%ecx
  801a25:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a29:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a2b:	0f b6 11             	movzbl (%ecx),%edx
  801a2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	80 fb 09             	cmp    $0x9,%bl
  801a36:	77 d5                	ja     801a0d <strtol+0x80>
			dig = *s - '0';
  801a38:	0f be d2             	movsbl %dl,%edx
  801a3b:	83 ea 30             	sub    $0x30,%edx
  801a3e:	eb dd                	jmp    801a1d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a40:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a43:	89 f3                	mov    %esi,%ebx
  801a45:	80 fb 19             	cmp    $0x19,%bl
  801a48:	77 08                	ja     801a52 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a4a:	0f be d2             	movsbl %dl,%edx
  801a4d:	83 ea 37             	sub    $0x37,%edx
  801a50:	eb cb                	jmp    801a1d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a56:	74 05                	je     801a5d <strtol+0xd0>
		*endptr = (char *) s;
  801a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	f7 da                	neg    %edx
  801a61:	85 ff                	test   %edi,%edi
  801a63:	0f 45 c2             	cmovne %edx,%eax
}
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 75 08             	mov    0x8(%ebp),%esi
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a80:	0f 44 c2             	cmove  %edx,%eax
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	50                   	push   %eax
  801a87:	e8 7e e8 ff ff       	call   80030a <sys_ipc_recv>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 2b                	js     801abe <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a93:	85 f6                	test   %esi,%esi
  801a95:	74 0a                	je     801aa1 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801a97:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9c:	8b 40 74             	mov    0x74(%eax),%eax
  801a9f:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	74 0a                	je     801aaf <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaa:	8b 40 78             	mov    0x78(%eax),%eax
  801aad:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    
        *from_env_store = 0;
  801abe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ac4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801aca:	eb eb                	jmp    801ab7 <ipc_recv+0x4c>

00801acc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801adb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ade:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801ae0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae5:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801ae8:	ff 75 14             	pushl  0x14(%ebp)
  801aeb:	53                   	push   %ebx
  801aec:	56                   	push   %esi
  801aed:	57                   	push   %edi
  801aee:	e8 f4 e7 ff ff       	call   8002e7 <sys_ipc_try_send>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	74 17                	je     801b11 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801afa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afd:	74 e9                	je     801ae8 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801aff:	50                   	push   %eax
  801b00:	68 60 22 80 00       	push   $0x802260
  801b05:	6a 3e                	push   $0x3e
  801b07:	68 72 22 80 00       	push   $0x802272
  801b0c:	e8 23 f5 ff ff       	call   801034 <_panic>
        }
    }
}
  801b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5f                   	pop    %edi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2d:	8b 52 50             	mov    0x50(%edx),%edx
  801b30:	39 ca                	cmp    %ecx,%edx
  801b32:	74 11                	je     801b45 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b34:	83 c0 01             	add    $0x1,%eax
  801b37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3c:	75 e6                	jne    801b24 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b43:	eb 0b                	jmp    801b50 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b45:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b48:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b4d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b58:	89 d0                	mov    %edx,%eax
  801b5a:	c1 e8 16             	shr    $0x16,%eax
  801b5d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b69:	f6 c1 01             	test   $0x1,%cl
  801b6c:	74 1d                	je     801b8b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b6e:	c1 ea 0c             	shr    $0xc,%edx
  801b71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b78:	f6 c2 01             	test   $0x1,%dl
  801b7b:	74 0e                	je     801b8b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7d:	c1 ea 0c             	shr    $0xc,%edx
  801b80:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b87:	ef 
  801b88:	0f b7 c0             	movzwl %ax,%eax
}
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
  801b8d:	66 90                	xchg   %ax,%ax
  801b8f:	90                   	nop

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ba7:	85 d2                	test   %edx,%edx
  801ba9:	75 35                	jne    801be0 <__udivdi3+0x50>
  801bab:	39 f3                	cmp    %esi,%ebx
  801bad:	0f 87 bd 00 00 00    	ja     801c70 <__udivdi3+0xe0>
  801bb3:	85 db                	test   %ebx,%ebx
  801bb5:	89 d9                	mov    %ebx,%ecx
  801bb7:	75 0b                	jne    801bc4 <__udivdi3+0x34>
  801bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f3                	div    %ebx
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	31 d2                	xor    %edx,%edx
  801bc6:	89 f0                	mov    %esi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
  801bcc:	89 e8                	mov    %ebp,%eax
  801bce:	89 f7                	mov    %esi,%edi
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	83 c4 1c             	add    $0x1c,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 7c                	ja     801c60 <__udivdi3+0xd0>
  801be4:	0f bd fa             	bsr    %edx,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0xf8>
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf7:	29 f8                	sub    %edi,%eax
  801bf9:	d3 e2                	shl    %cl,%edx
  801bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 d1                	or     %edx,%ecx
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 c1                	mov    %eax,%ecx
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	d3 e6                	shl    %cl,%esi
  801c21:	89 eb                	mov    %ebp,%ebx
  801c23:	89 c1                	mov    %eax,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 de                	or     %ebx,%esi
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	f7 74 24 08          	divl   0x8(%esp)
  801c2f:	89 d6                	mov    %edx,%esi
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	f7 64 24 0c          	mull   0xc(%esp)
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	72 0c                	jb     801c47 <__udivdi3+0xb7>
  801c3b:	89 f9                	mov    %edi,%ecx
  801c3d:	d3 e5                	shl    %cl,%ebp
  801c3f:	39 c5                	cmp    %eax,%ebp
  801c41:	73 5d                	jae    801ca0 <__udivdi3+0x110>
  801c43:	39 d6                	cmp    %edx,%esi
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x110>
  801c47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4a:	31 ff                	xor    %edi,%edi
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	8d 76 00             	lea    0x0(%esi),%esi
  801c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	31 c0                	xor    %eax,%eax
  801c64:	89 fa                	mov    %edi,%edx
  801c66:	83 c4 1c             	add    $0x1c,%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	89 e8                	mov    %ebp,%eax
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	f7 f3                	div    %ebx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x102>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 d2                	ja     801c64 <__udivdi3+0xd4>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb cb                	jmp    801c64 <__udivdi3+0xd4>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	31 ff                	xor    %edi,%edi
  801ca4:	eb be                	jmp    801c64 <__udivdi3+0xd4>
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 ed                	test   %ebp,%ebp
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	0f 86 b1 00 00 00    	jbe    801d88 <__umoddi3+0xd8>
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	39 dd                	cmp    %ebx,%ebp
  801cea:	77 f1                	ja     801cdd <__umoddi3+0x2d>
  801cec:	0f bd cd             	bsr    %ebp,%ecx
  801cef:	83 f1 1f             	xor    $0x1f,%ecx
  801cf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cf6:	0f 84 b4 00 00 00    	je     801db0 <__umoddi3+0x100>
  801cfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	29 c2                	sub    %eax,%edx
  801d09:	89 c1                	mov    %eax,%ecx
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	09 c5                	or     %eax,%ebp
  801d19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1d:	89 c1                	mov    %eax,%ecx
  801d1f:	d3 e7                	shl    %cl,%edi
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d27:	89 df                	mov    %ebx,%edi
  801d29:	d3 ef                	shr    %cl,%edi
  801d2b:	89 c1                	mov    %eax,%ecx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	d3 e3                	shl    %cl,%ebx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 fa                	mov    %edi,%edx
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d3c:	09 d8                	or     %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	f7 64 24 08          	mull   0x8(%esp)
  801d48:	39 d1                	cmp    %edx,%ecx
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	72 06                	jb     801d56 <__umoddi3+0xa6>
  801d50:	75 0e                	jne    801d60 <__umoddi3+0xb0>
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 0a                	jae    801d60 <__umoddi3+0xb0>
  801d56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d5a:	19 ea                	sbb    %ebp,%edx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	89 ca                	mov    %ecx,%edx
  801d62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d67:	29 de                	sub    %ebx,%esi
  801d69:	19 fa                	sbb    %edi,%edx
  801d6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	d3 e0                	shl    %cl,%eax
  801d73:	89 d9                	mov    %ebx,%ecx
  801d75:	d3 ee                	shr    %cl,%esi
  801d77:	d3 ea                	shr    %cl,%edx
  801d79:	09 f0                	or     %esi,%eax
  801d7b:	83 c4 1c             	add    $0x1c,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 f9                	mov    %edi,%ecx
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0xe9>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	f7 f1                	div    %ecx
  801da3:	e9 31 ff ff ff       	jmp    801cd9 <__umoddi3+0x29>
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 dd                	cmp    %ebx,%ebp
  801db2:	72 08                	jb     801dbc <__umoddi3+0x10c>
  801db4:	39 f7                	cmp    %esi,%edi
  801db6:	0f 87 21 ff ff ff    	ja     801cdd <__umoddi3+0x2d>
  801dbc:	89 da                	mov    %ebx,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	29 f8                	sub    %edi,%eax
  801dc2:	19 ea                	sbb    %ebp,%edx
  801dc4:	e9 14 ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
