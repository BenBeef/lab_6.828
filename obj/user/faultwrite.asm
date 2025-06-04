
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 92 04 00 00       	call   800525 <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7f 08                	jg     800109 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 ea 1d 80 00       	push   $0x801dea
  800114:	6a 23                	push   $0x23
  800116:	68 07 1e 80 00       	push   $0x801e07
  80011b:	e8 18 0f 00 00       	call   801038 <_panic>

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7f 08                	jg     80018a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 ea 1d 80 00       	push   $0x801dea
  800195:	6a 23                	push   $0x23
  800197:	68 07 1e 80 00       	push   $0x801e07
  80019c:	e8 97 0e 00 00       	call   801038 <_panic>

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 ea 1d 80 00       	push   $0x801dea
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 07 1e 80 00       	push   $0x801e07
  8001de:	e8 55 0e 00 00       	call   801038 <_panic>

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7f 08                	jg     80020e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 ea 1d 80 00       	push   $0x801dea
  800219:	6a 23                	push   $0x23
  80021b:	68 07 1e 80 00       	push   $0x801e07
  800220:	e8 13 0e 00 00       	call   801038 <_panic>

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 ea 1d 80 00       	push   $0x801dea
  80025b:	6a 23                	push   $0x23
  80025d:	68 07 1e 80 00       	push   $0x801e07
  800262:	e8 d1 0d 00 00       	call   801038 <_panic>

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 ea 1d 80 00       	push   $0x801dea
  80029d:	6a 23                	push   $0x23
  80029f:	68 07 1e 80 00       	push   $0x801e07
  8002a4:	e8 8f 0d 00 00       	call   801038 <_panic>

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7f 08                	jg     8002d4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 ea 1d 80 00       	push   $0x801dea
  8002df:	6a 23                	push   $0x23
  8002e1:	68 07 1e 80 00       	push   $0x801e07
  8002e6:	e8 4d 0d 00 00       	call   801038 <_panic>

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fc:	be 00 00 00 00       	mov    $0x0,%esi
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7f 08                	jg     800338 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 ea 1d 80 00       	push   $0x801dea
  800343:	6a 23                	push   $0x23
  800345:	68 07 1e 80 00       	push   $0x801e07
  80034a:	e8 e9 0c 00 00       	call   801038 <_panic>

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 2a                	je     8003bc <fd_alloc+0x46>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	74 19                	je     8003bc <fd_alloc+0x46>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 d2                	jne    800381 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003ba:	eb 07                	jmp    8003c3 <fd_alloc+0x4d>
			*fd_store = fd;
  8003bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb f7                	jmp    800404 <fd_lookup+0x3f>
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb f0                	jmp    800404 <fd_lookup+0x3f>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800419:	eb e9                	jmp    800404 <fd_lookup+0x3f>

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	74 33                	je     800465 <dev_lookup+0x4a>
  800432:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 f3                	jne    80042e <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 18 1e 80 00       	push   $0x801e18
  80044d:	e8 c1 0c 00 00       	call   801113 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    
			*dev = devtab[i];
  800465:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800468:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	eb f2                	jmp    800463 <dev_lookup+0x48>

00800471 <fd_close>:
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 1c             	sub    $0x1c,%esp
  80047a:	8b 75 08             	mov    0x8(%ebp),%esi
  80047d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800480:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800483:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800484:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048d:	50                   	push   %eax
  80048e:	e8 32 ff ff ff       	call   8003c5 <fd_lookup>
  800493:	89 c3                	mov    %eax,%ebx
  800495:	83 c4 08             	add    $0x8,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 05                	js     8004a1 <fd_close+0x30>
	    || fd != fd2)
  80049c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049f:	74 16                	je     8004b7 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a1:	89 f8                	mov    %edi,%eax
  8004a3:	84 c0                	test   %al,%al
  8004a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004aa:	0f 44 d8             	cmove  %eax,%ebx
}
  8004ad:	89 d8                	mov    %ebx,%eax
  8004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004bd:	50                   	push   %eax
  8004be:	ff 36                	pushl  (%esi)
  8004c0:	e8 56 ff ff ff       	call   80041b <dev_lookup>
  8004c5:	89 c3                	mov    %eax,%ebx
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 15                	js     8004e3 <fd_close+0x72>
		if (dev->dev_close)
  8004ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d1:	8b 40 10             	mov    0x10(%eax),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	74 1b                	je     8004f3 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d8:	83 ec 0c             	sub    $0xc,%esp
  8004db:	56                   	push   %esi
  8004dc:	ff d0                	call   *%eax
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	6a 00                	push   $0x0
  8004e9:	e8 f5 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb ba                	jmp    8004ad <fd_close+0x3c>
			r = 0;
  8004f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f8:	eb e9                	jmp    8004e3 <fd_close+0x72>

008004fa <close>:

int
close(int fdnum)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 b9 fe ff ff       	call   8003c5 <fd_lookup>
  80050c:	83 c4 08             	add    $0x8,%esp
  80050f:	85 c0                	test   %eax,%eax
  800511:	78 10                	js     800523 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	6a 01                	push   $0x1
  800518:	ff 75 f4             	pushl  -0xc(%ebp)
  80051b:	e8 51 ff ff ff       	call   800471 <fd_close>
  800520:	83 c4 10             	add    $0x10,%esp
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <close_all>:

void
close_all(void)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	53                   	push   %ebx
  800529:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800531:	83 ec 0c             	sub    $0xc,%esp
  800534:	53                   	push   %ebx
  800535:	e8 c0 ff ff ff       	call   8004fa <close>
	for (i = 0; i < MAXFD; i++)
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	83 fb 20             	cmp    $0x20,%ebx
  800543:	75 ec                	jne    800531 <close_all+0xc>
}
  800545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	57                   	push   %edi
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 66 fe ff ff       	call   8003c5 <fd_lookup>
  80055f:	89 c3                	mov    %eax,%ebx
  800561:	83 c4 08             	add    $0x8,%esp
  800564:	85 c0                	test   %eax,%eax
  800566:	0f 88 81 00 00 00    	js     8005ed <dup+0xa3>
		return r;
	close(newfdnum);
  80056c:	83 ec 0c             	sub    $0xc,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	e8 83 ff ff ff       	call   8004fa <close>

	newfd = INDEX2FD(newfdnum);
  800577:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057a:	c1 e6 0c             	shl    $0xc,%esi
  80057d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800583:	83 c4 04             	add    $0x4,%esp
  800586:	ff 75 e4             	pushl  -0x1c(%ebp)
  800589:	e8 d1 fd ff ff       	call   80035f <fd2data>
  80058e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800590:	89 34 24             	mov    %esi,(%esp)
  800593:	e8 c7 fd ff ff       	call   80035f <fd2data>
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 d8                	mov    %ebx,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 11                	je     8005be <dup+0x74>
  8005ad:	89 d8                	mov    %ebx,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	75 39                	jne    8005f7 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c1:	89 d0                	mov    %edx,%eax
  8005c3:	c1 e8 0c             	shr    $0xc,%eax
  8005c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d5:	50                   	push   %eax
  8005d6:	56                   	push   %esi
  8005d7:	6a 00                	push   $0x0
  8005d9:	52                   	push   %edx
  8005da:	6a 00                	push   $0x0
  8005dc:	e8 c0 fb ff ff       	call   8001a1 <sys_page_map>
  8005e1:	89 c3                	mov    %eax,%ebx
  8005e3:	83 c4 20             	add    $0x20,%esp
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	78 31                	js     80061b <dup+0xd1>
		goto err;

	return newfdnum;
  8005ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ed:	89 d8                	mov    %ebx,%eax
  8005ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	57                   	push   %edi
  800608:	6a 00                	push   $0x0
  80060a:	53                   	push   %ebx
  80060b:	6a 00                	push   $0x0
  80060d:	e8 8f fb ff ff       	call   8001a1 <sys_page_map>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	83 c4 20             	add    $0x20,%esp
  800617:	85 c0                	test   %eax,%eax
  800619:	79 a3                	jns    8005be <dup+0x74>
	sys_page_unmap(0, newfd);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	56                   	push   %esi
  80061f:	6a 00                	push   $0x0
  800621:	e8 bd fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	57                   	push   %edi
  80062a:	6a 00                	push   $0x0
  80062c:	e8 b2 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb b7                	jmp    8005ed <dup+0xa3>

00800636 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	53                   	push   %ebx
  80063a:	83 ec 14             	sub    $0x14,%esp
  80063d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	e8 7b fd ff ff       	call   8003c5 <fd_lookup>
  80064a:	83 c4 08             	add    $0x8,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 3f                	js     800690 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	ff 30                	pushl  (%eax)
  80065d:	e8 b9 fd ff ff       	call   80041b <dev_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 27                	js     800690 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	8b 42 08             	mov    0x8(%edx),%eax
  80066f:	83 e0 03             	and    $0x3,%eax
  800672:	83 f8 01             	cmp    $0x1,%eax
  800675:	74 1e                	je     800695 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067a:	8b 40 08             	mov    0x8(%eax),%eax
  80067d:	85 c0                	test   %eax,%eax
  80067f:	74 35                	je     8006b6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	ff 75 10             	pushl  0x10(%ebp)
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	52                   	push   %edx
  80068b:	ff d0                	call   *%eax
  80068d:	83 c4 10             	add    $0x10,%esp
}
  800690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800693:	c9                   	leave  
  800694:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 59 1e 80 00       	push   $0x801e59
  8006a7:	e8 67 0a 00 00       	call   801113 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb da                	jmp    800690 <read+0x5a>
		return -E_NOT_SUPP;
  8006b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bb:	eb d3                	jmp    800690 <read+0x5a>

008006bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d1:	39 f3                	cmp    %esi,%ebx
  8006d3:	73 25                	jae    8006fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	29 d8                	sub    %ebx,%eax
  8006dc:	50                   	push   %eax
  8006dd:	89 d8                	mov    %ebx,%eax
  8006df:	03 45 0c             	add    0xc(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	57                   	push   %edi
  8006e4:	e8 4d ff ff ff       	call   800636 <read>
		if (m < 0)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	78 08                	js     8006f8 <readn+0x3b>
			return m;
		if (m == 0)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 06                	je     8006fa <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f4:	01 c3                	add    %eax,%ebx
  8006f6:	eb d9                	jmp    8006d1 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	83 ec 14             	sub    $0x14,%esp
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	53                   	push   %ebx
  800713:	e8 ad fc ff ff       	call   8003c5 <fd_lookup>
  800718:	83 c4 08             	add    $0x8,%esp
  80071b:	85 c0                	test   %eax,%eax
  80071d:	78 3a                	js     800759 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800729:	ff 30                	pushl  (%eax)
  80072b:	e8 eb fc ff ff       	call   80041b <dev_lookup>
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	85 c0                	test   %eax,%eax
  800735:	78 22                	js     800759 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073e:	74 1e                	je     80075e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800743:	8b 52 0c             	mov    0xc(%edx),%edx
  800746:	85 d2                	test   %edx,%edx
  800748:	74 35                	je     80077f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074a:	83 ec 04             	sub    $0x4,%esp
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	50                   	push   %eax
  800754:	ff d2                	call   *%edx
  800756:	83 c4 10             	add    $0x10,%esp
}
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 04 40 80 00       	mov    0x804004,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 75 1e 80 00       	push   $0x801e75
  800770:	e8 9e 09 00 00       	call   801113 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077d:	eb da                	jmp    800759 <write+0x55>
		return -E_NOT_SUPP;
  80077f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800784:	eb d3                	jmp    800759 <write+0x55>

00800786 <seek>:

int
seek(int fdnum, off_t offset)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 2d fc ff ff       	call   8003c5 <fd_lookup>
  800798:	83 c4 08             	add    $0x8,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 0e                	js     8007ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	83 ec 14             	sub    $0x14,%esp
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	53                   	push   %ebx
  8007be:	e8 02 fc ff ff       	call   8003c5 <fd_lookup>
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 37                	js     800801 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	ff 30                	pushl  (%eax)
  8007d6:	e8 40 fc ff ff       	call   80041b <dev_lookup>
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 1f                	js     800801 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e9:	74 1b                	je     800806 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ee:	8b 52 18             	mov    0x18(%edx),%edx
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 32                	je     800827 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	50                   	push   %eax
  8007fc:	ff d2                	call   *%edx
  8007fe:	83 c4 10             	add    $0x10,%esp
}
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    
			thisenv->env_id, fdnum);
  800806:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080b:	8b 40 48             	mov    0x48(%eax),%eax
  80080e:	83 ec 04             	sub    $0x4,%esp
  800811:	53                   	push   %ebx
  800812:	50                   	push   %eax
  800813:	68 38 1e 80 00       	push   $0x801e38
  800818:	e8 f6 08 00 00       	call   801113 <cprintf>
		return -E_INVAL;
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800825:	eb da                	jmp    800801 <ftruncate+0x52>
		return -E_NOT_SUPP;
  800827:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80082c:	eb d3                	jmp    800801 <ftruncate+0x52>

0080082e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	83 ec 14             	sub    $0x14,%esp
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083b:	50                   	push   %eax
  80083c:	ff 75 08             	pushl  0x8(%ebp)
  80083f:	e8 81 fb ff ff       	call   8003c5 <fd_lookup>
  800844:	83 c4 08             	add    $0x8,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 4b                	js     800896 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800855:	ff 30                	pushl  (%eax)
  800857:	e8 bf fb ff ff       	call   80041b <dev_lookup>
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 33                	js     800896 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800866:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086a:	74 2f                	je     80089b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80086c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800876:	00 00 00 
	stat->st_isdir = 0;
  800879:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800880:	00 00 00 
	stat->st_dev = dev;
  800883:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	ff 75 f0             	pushl  -0x10(%ebp)
  800890:	ff 50 14             	call   *0x14(%eax)
  800893:	83 c4 10             	add    $0x10,%esp
}
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    
		return -E_NOT_SUPP;
  80089b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a0:	eb f4                	jmp    800896 <fstat+0x68>

008008a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	6a 00                	push   $0x0
  8008ac:	ff 75 08             	pushl  0x8(%ebp)
  8008af:	e8 e7 01 00 00       	call   800a9b <open>
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	78 1b                	js     8008d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	50                   	push   %eax
  8008c4:	e8 65 ff ff ff       	call   80082e <fstat>
  8008c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8008cb:	89 1c 24             	mov    %ebx,(%esp)
  8008ce:	e8 27 fc ff ff       	call   8004fa <close>
	return r;
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	89 f3                	mov    %esi,%ebx
}
  8008d8:	89 d8                	mov    %ebx,%eax
  8008da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	89 c6                	mov    %eax,%esi
  8008e8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f1:	74 27                	je     80091a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f3:	6a 07                	push   $0x7
  8008f5:	68 00 50 80 00       	push   $0x805000
  8008fa:	56                   	push   %esi
  8008fb:	ff 35 00 40 80 00    	pushl  0x804000
  800901:	e8 ca 11 00 00       	call   801ad0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800906:	83 c4 0c             	add    $0xc,%esp
  800909:	6a 00                	push   $0x0
  80090b:	53                   	push   %ebx
  80090c:	6a 00                	push   $0x0
  80090e:	e8 5c 11 00 00       	call   801a6f <ipc_recv>
}
  800913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	6a 01                	push   $0x1
  80091f:	e8 f9 11 00 00       	call   801b1d <ipc_find_env>
  800924:	a3 00 40 80 00       	mov    %eax,0x804000
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	eb c5                	jmp    8008f3 <fsipc+0x12>

0080092e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 40 0c             	mov    0xc(%eax),%eax
  80093a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800947:	ba 00 00 00 00       	mov    $0x0,%edx
  80094c:	b8 02 00 00 00       	mov    $0x2,%eax
  800951:	e8 8b ff ff ff       	call   8008e1 <fsipc>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <devfile_flush>:
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 40 0c             	mov    0xc(%eax),%eax
  800964:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
  80096e:	b8 06 00 00 00       	mov    $0x6,%eax
  800973:	e8 69 ff ff ff       	call   8008e1 <fsipc>
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <devfile_stat>:
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 04             	sub    $0x4,%esp
  800981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 40 0c             	mov    0xc(%eax),%eax
  80098a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098f:	ba 00 00 00 00       	mov    $0x0,%edx
  800994:	b8 05 00 00 00       	mov    $0x5,%eax
  800999:	e8 43 ff ff ff       	call   8008e1 <fsipc>
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	78 2c                	js     8009ce <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	68 00 50 80 00       	push   $0x805000
  8009aa:	53                   	push   %ebx
  8009ab:	e8 82 0d 00 00       	call   801732 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009bb:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <devfile_write>:
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009dc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e6:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ef:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009f5:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8009fa:	50                   	push   %eax
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	68 08 50 80 00       	push   $0x805008
  800a03:	e8 b8 0e 00 00       	call   8018c0 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a08:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a12:	e8 ca fe ff ff       	call   8008e1 <fsipc>
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_read>:
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 40 0c             	mov    0xc(%eax),%eax
  800a27:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3c:	e8 a0 fe ff ff       	call   8008e1 <fsipc>
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	85 c0                	test   %eax,%eax
  800a45:	78 1f                	js     800a66 <devfile_read+0x4d>
	assert(r <= n);
  800a47:	39 f0                	cmp    %esi,%eax
  800a49:	77 24                	ja     800a6f <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a4b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a50:	7f 33                	jg     800a85 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a52:	83 ec 04             	sub    $0x4,%esp
  800a55:	50                   	push   %eax
  800a56:	68 00 50 80 00       	push   $0x805000
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	e8 5d 0e 00 00       	call   8018c0 <memmove>
	return r;
  800a63:	83 c4 10             	add    $0x10,%esp
}
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    
	assert(r <= n);
  800a6f:	68 a4 1e 80 00       	push   $0x801ea4
  800a74:	68 ab 1e 80 00       	push   $0x801eab
  800a79:	6a 7d                	push   $0x7d
  800a7b:	68 c0 1e 80 00       	push   $0x801ec0
  800a80:	e8 b3 05 00 00       	call   801038 <_panic>
	assert(r <= PGSIZE);
  800a85:	68 cb 1e 80 00       	push   $0x801ecb
  800a8a:	68 ab 1e 80 00       	push   $0x801eab
  800a8f:	6a 7e                	push   $0x7e
  800a91:	68 c0 1e 80 00       	push   $0x801ec0
  800a96:	e8 9d 05 00 00       	call   801038 <_panic>

00800a9b <open>:
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 1c             	sub    $0x1c,%esp
  800aa3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa6:	56                   	push   %esi
  800aa7:	e8 4f 0c 00 00       	call   8016fb <strlen>
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab4:	0f 8f 96 00 00 00    	jg     800b50 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800aba:	83 ec 0c             	sub    $0xc,%esp
  800abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac0:	50                   	push   %eax
  800ac1:	e8 b0 f8 ff ff       	call   800376 <fd_alloc>
  800ac6:	89 c3                	mov    %eax,%ebx
  800ac8:	83 c4 10             	add    $0x10,%esp
  800acb:	85 c0                	test   %eax,%eax
  800acd:	78 66                	js     800b35 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800acf:	83 ec 08             	sub    $0x8,%esp
  800ad2:	56                   	push   %esi
  800ad3:	68 00 50 80 00       	push   $0x805000
  800ad8:	e8 55 0c 00 00       	call   801732 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae8:	b8 01 00 00 00       	mov    $0x1,%eax
  800aed:	e8 ef fd ff ff       	call   8008e1 <fsipc>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	85 c0                	test   %eax,%eax
  800af9:	78 43                	js     800b3e <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	ff 75 f4             	pushl  -0xc(%ebp)
  800b01:	e8 49 f8 ff ff       	call   80034f <fd2num>
  800b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b09:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b0f:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b12:	83 c4 08             	add    $0x8,%esp
  800b15:	50                   	push   %eax
  800b16:	52                   	push   %edx
  800b17:	ff 32                	pushl  (%edx)
  800b19:	56                   	push   %esi
  800b1a:	51                   	push   %ecx
  800b1b:	68 d8 1e 80 00       	push   $0x801ed8
  800b20:	e8 ee 05 00 00       	call   801113 <cprintf>
	return fd2num(fd);
  800b25:	83 c4 14             	add    $0x14,%esp
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 1f f8 ff ff       	call   80034f <fd2num>
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	83 c4 10             	add    $0x10,%esp
}
  800b35:	89 d8                	mov    %ebx,%eax
  800b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
		fd_close(fd, 0);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	6a 00                	push   $0x0
  800b43:	ff 75 f4             	pushl  -0xc(%ebp)
  800b46:	e8 26 f9 ff ff       	call   800471 <fd_close>
		return r;
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	eb e5                	jmp    800b35 <open+0x9a>
		return -E_BAD_PATH;
  800b50:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b55:	eb de                	jmp    800b35 <open+0x9a>

00800b57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 08 00 00 00       	mov    $0x8,%eax
  800b67:	e8 75 fd ff ff       	call   8008e1 <fsipc>
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	ff 75 08             	pushl  0x8(%ebp)
  800b7c:	e8 de f7 ff ff       	call   80035f <fd2data>
  800b81:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b83:	83 c4 08             	add    $0x8,%esp
  800b86:	68 17 1f 80 00       	push   $0x801f17
  800b8b:	53                   	push   %ebx
  800b8c:	e8 a1 0b 00 00       	call   801732 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b91:	8b 46 04             	mov    0x4(%esi),%eax
  800b94:	2b 06                	sub    (%esi),%eax
  800b96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba3:	00 00 00 
	stat->st_dev = &devpipe;
  800ba6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bad:	30 80 00 
	return 0;
}
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc6:	53                   	push   %ebx
  800bc7:	6a 00                	push   $0x0
  800bc9:	e8 15 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bce:	89 1c 24             	mov    %ebx,(%esp)
  800bd1:	e8 89 f7 ff ff       	call   80035f <fd2data>
  800bd6:	83 c4 08             	add    $0x8,%esp
  800bd9:	50                   	push   %eax
  800bda:	6a 00                	push   $0x0
  800bdc:	e8 02 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800be1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <_pipeisclosed>:
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 1c             	sub    $0x1c,%esp
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bf3:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	57                   	push   %edi
  800bff:	e8 52 0f 00 00       	call   801b56 <pageref>
  800c04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c07:	89 34 24             	mov    %esi,(%esp)
  800c0a:	e8 47 0f 00 00       	call   801b56 <pageref>
		nn = thisenv->env_runs;
  800c0f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	39 cb                	cmp    %ecx,%ebx
  800c1d:	74 1b                	je     800c3a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c1f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c22:	75 cf                	jne    800bf3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c24:	8b 42 58             	mov    0x58(%edx),%eax
  800c27:	6a 01                	push   $0x1
  800c29:	50                   	push   %eax
  800c2a:	53                   	push   %ebx
  800c2b:	68 1e 1f 80 00       	push   $0x801f1e
  800c30:	e8 de 04 00 00       	call   801113 <cprintf>
  800c35:	83 c4 10             	add    $0x10,%esp
  800c38:	eb b9                	jmp    800bf3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c3a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c3d:	0f 94 c0             	sete   %al
  800c40:	0f b6 c0             	movzbl %al,%eax
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <devpipe_write>:
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 28             	sub    $0x28,%esp
  800c54:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c57:	56                   	push   %esi
  800c58:	e8 02 f7 ff ff       	call   80035f <fd2data>
  800c5d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	bf 00 00 00 00       	mov    $0x0,%edi
  800c67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c6a:	74 4f                	je     800cbb <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6f:	8b 0b                	mov    (%ebx),%ecx
  800c71:	8d 51 20             	lea    0x20(%ecx),%edx
  800c74:	39 d0                	cmp    %edx,%eax
  800c76:	72 14                	jb     800c8c <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c78:	89 da                	mov    %ebx,%edx
  800c7a:	89 f0                	mov    %esi,%eax
  800c7c:	e8 65 ff ff ff       	call   800be6 <_pipeisclosed>
  800c81:	85 c0                	test   %eax,%eax
  800c83:	75 3a                	jne    800cbf <devpipe_write+0x74>
			sys_yield();
  800c85:	e8 b5 f4 ff ff       	call   80013f <sys_yield>
  800c8a:	eb e0                	jmp    800c6c <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c96:	89 c2                	mov    %eax,%edx
  800c98:	c1 fa 1f             	sar    $0x1f,%edx
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca3:	83 e2 1f             	and    $0x1f,%edx
  800ca6:	29 ca                	sub    %ecx,%edx
  800ca8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cb6:	83 c7 01             	add    $0x1,%edi
  800cb9:	eb ac                	jmp    800c67 <devpipe_write+0x1c>
	return i;
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	eb 05                	jmp    800cc4 <devpipe_write+0x79>
				return 0;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <devpipe_read>:
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 18             	sub    $0x18,%esp
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd8:	57                   	push   %edi
  800cd9:	e8 81 f6 ff ff       	call   80035f <fd2data>
  800cde:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	be 00 00 00 00       	mov    $0x0,%esi
  800ce8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ceb:	74 47                	je     800d34 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 03                	mov    (%ebx),%eax
  800cef:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cf2:	75 22                	jne    800d16 <devpipe_read+0x4a>
			if (i > 0)
  800cf4:	85 f6                	test   %esi,%esi
  800cf6:	75 14                	jne    800d0c <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cf8:	89 da                	mov    %ebx,%edx
  800cfa:	89 f8                	mov    %edi,%eax
  800cfc:	e8 e5 fe ff ff       	call   800be6 <_pipeisclosed>
  800d01:	85 c0                	test   %eax,%eax
  800d03:	75 33                	jne    800d38 <devpipe_read+0x6c>
			sys_yield();
  800d05:	e8 35 f4 ff ff       	call   80013f <sys_yield>
  800d0a:	eb e1                	jmp    800ced <devpipe_read+0x21>
				return i;
  800d0c:	89 f0                	mov    %esi,%eax
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d16:	99                   	cltd   
  800d17:	c1 ea 1b             	shr    $0x1b,%edx
  800d1a:	01 d0                	add    %edx,%eax
  800d1c:	83 e0 1f             	and    $0x1f,%eax
  800d1f:	29 d0                	sub    %edx,%eax
  800d21:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d2c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d2f:	83 c6 01             	add    $0x1,%esi
  800d32:	eb b4                	jmp    800ce8 <devpipe_read+0x1c>
	return i;
  800d34:	89 f0                	mov    %esi,%eax
  800d36:	eb d6                	jmp    800d0e <devpipe_read+0x42>
				return 0;
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3d:	eb cf                	jmp    800d0e <devpipe_read+0x42>

00800d3f <pipe>:
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4a:	50                   	push   %eax
  800d4b:	e8 26 f6 ff ff       	call   800376 <fd_alloc>
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 5b                	js     800db4 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	68 07 04 00 00       	push   $0x407
  800d61:	ff 75 f4             	pushl  -0xc(%ebp)
  800d64:	6a 00                	push   $0x0
  800d66:	e8 f3 f3 ff ff       	call   80015e <sys_page_alloc>
  800d6b:	89 c3                	mov    %eax,%ebx
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 40                	js     800db4 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7a:	50                   	push   %eax
  800d7b:	e8 f6 f5 ff ff       	call   800376 <fd_alloc>
  800d80:	89 c3                	mov    %eax,%ebx
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 1b                	js     800da4 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	68 07 04 00 00       	push   $0x407
  800d91:	ff 75 f0             	pushl  -0x10(%ebp)
  800d94:	6a 00                	push   $0x0
  800d96:	e8 c3 f3 ff ff       	call   80015e <sys_page_alloc>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	79 19                	jns    800dbd <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800da4:	83 ec 08             	sub    $0x8,%esp
  800da7:	ff 75 f4             	pushl  -0xc(%ebp)
  800daa:	6a 00                	push   $0x0
  800dac:	e8 32 f4 ff ff       	call   8001e3 <sys_page_unmap>
  800db1:	83 c4 10             	add    $0x10,%esp
}
  800db4:	89 d8                	mov    %ebx,%eax
  800db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
	va = fd2data(fd0);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc3:	e8 97 f5 ff ff       	call   80035f <fd2data>
  800dc8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 c4 0c             	add    $0xc,%esp
  800dcd:	68 07 04 00 00       	push   $0x407
  800dd2:	50                   	push   %eax
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 84 f3 ff ff       	call   80015e <sys_page_alloc>
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	0f 88 8c 00 00 00    	js     800e73 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	ff 75 f0             	pushl  -0x10(%ebp)
  800ded:	e8 6d f5 ff ff       	call   80035f <fd2data>
  800df2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df9:	50                   	push   %eax
  800dfa:	6a 00                	push   $0x0
  800dfc:	56                   	push   %esi
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 9d f3 ff ff       	call   8001a1 <sys_page_map>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 20             	add    $0x20,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	78 58                	js     800e65 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3d:	e8 0d f5 ff ff       	call   80034f <fd2num>
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e47:	83 c4 04             	add    $0x4,%esp
  800e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4d:	e8 fd f4 ff ff       	call   80034f <fd2num>
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e60:	e9 4f ff ff ff       	jmp    800db4 <pipe+0x75>
	sys_page_unmap(0, va);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	56                   	push   %esi
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 73 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 63 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	e9 1c ff ff ff       	jmp    800da4 <pipe+0x65>

00800e88 <pipeisclosed>:
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 2b f5 ff ff       	call   8003c5 <fd_lookup>
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 18                	js     800eb9 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea7:	e8 b3 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb1:	e8 30 fd ff ff       	call   800be6 <_pipeisclosed>
  800eb6:	83 c4 10             	add    $0x10,%esp
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecb:	68 36 1f 80 00       	push   $0x801f36
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	e8 5a 08 00 00       	call   801732 <strcpy>
	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_write>:
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ef6:	eb 2f                	jmp    800f27 <devcons_write+0x48>
		m = n - tot;
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	29 f3                	sub    %esi,%ebx
  800efd:	83 fb 7f             	cmp    $0x7f,%ebx
  800f00:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f05:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	89 f0                	mov    %esi,%eax
  800f0e:	03 45 0c             	add    0xc(%ebp),%eax
  800f11:	50                   	push   %eax
  800f12:	57                   	push   %edi
  800f13:	e8 a8 09 00 00       	call   8018c0 <memmove>
		sys_cputs(buf, m);
  800f18:	83 c4 08             	add    $0x8,%esp
  800f1b:	53                   	push   %ebx
  800f1c:	57                   	push   %edi
  800f1d:	e8 80 f1 ff ff       	call   8000a2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f22:	01 de                	add    %ebx,%esi
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2a:	72 cc                	jb     800ef8 <devcons_write+0x19>
}
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <devcons_read>:
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f45:	75 07                	jne    800f4e <devcons_read+0x18>
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    
		sys_yield();
  800f49:	e8 f1 f1 ff ff       	call   80013f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f4e:	e8 6d f1 ff ff       	call   8000c0 <sys_cgetc>
  800f53:	85 c0                	test   %eax,%eax
  800f55:	74 f2                	je     800f49 <devcons_read+0x13>
	if (c < 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 ec                	js     800f47 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f5b:	83 f8 04             	cmp    $0x4,%eax
  800f5e:	74 0c                	je     800f6c <devcons_read+0x36>
	*(char*)vbuf = c;
  800f60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f63:	88 02                	mov    %al,(%edx)
	return 1;
  800f65:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6a:	eb db                	jmp    800f47 <devcons_read+0x11>
		return 0;
  800f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f71:	eb d4                	jmp    800f47 <devcons_read+0x11>

00800f73 <cputchar>:
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f7f:	6a 01                	push   $0x1
  800f81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f84:	50                   	push   %eax
  800f85:	e8 18 f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <getchar>:
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f95:	6a 01                	push   $0x1
  800f97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 94 f6 ff ff       	call   800636 <read>
	if (r < 0)
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 08                	js     800fb1 <getchar+0x22>
	if (r < 1)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 06                	jle    800fb3 <getchar+0x24>
	return c;
  800fad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    
		return -E_EOF;
  800fb3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb8:	eb f7                	jmp    800fb1 <getchar+0x22>

00800fba <iscons>:
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 08             	pushl  0x8(%ebp)
  800fc7:	e8 f9 f3 ff ff       	call   8003c5 <fd_lookup>
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 11                	js     800fe4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdc:	39 10                	cmp    %edx,(%eax)
  800fde:	0f 94 c0             	sete   %al
  800fe1:	0f b6 c0             	movzbl %al,%eax
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <opencons>:
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	e8 81 f3 ff ff       	call   800376 <fd_alloc>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 3a                	js     801036 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 07 04 00 00       	push   $0x407
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	6a 00                	push   $0x0
  801009:	e8 50 f1 ff ff       	call   80015e <sys_page_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 21                	js     801036 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	50                   	push   %eax
  80102e:	e8 1c f3 ff ff       	call   80034f <fd2num>
  801033:	83 c4 10             	add    $0x10,%esp
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801040:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801046:	e8 d5 f0 ff ff       	call   800120 <sys_getenvid>
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	ff 75 0c             	pushl  0xc(%ebp)
  801051:	ff 75 08             	pushl  0x8(%ebp)
  801054:	56                   	push   %esi
  801055:	50                   	push   %eax
  801056:	68 44 1f 80 00       	push   $0x801f44
  80105b:	e8 b3 00 00 00       	call   801113 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801060:	83 c4 18             	add    $0x18,%esp
  801063:	53                   	push   %ebx
  801064:	ff 75 10             	pushl  0x10(%ebp)
  801067:	e8 56 00 00 00       	call   8010c2 <vcprintf>
	cprintf("\n");
  80106c:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  801073:	e8 9b 00 00 00       	call   801113 <cprintf>
  801078:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107b:	cc                   	int3   
  80107c:	eb fd                	jmp    80107b <_panic+0x43>

0080107e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	53                   	push   %ebx
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801088:	8b 13                	mov    (%ebx),%edx
  80108a:	8d 42 01             	lea    0x1(%edx),%eax
  80108d:	89 03                	mov    %eax,(%ebx)
  80108f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801092:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801096:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109b:	74 09                	je     8010a6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80109d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	68 ff 00 00 00       	push   $0xff
  8010ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b1:	50                   	push   %eax
  8010b2:	e8 eb ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	eb db                	jmp    80109d <putch+0x1f>

008010c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d2:	00 00 00 
	b.cnt = 0;
  8010d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010df:	ff 75 0c             	pushl  0xc(%ebp)
  8010e2:	ff 75 08             	pushl  0x8(%ebp)
  8010e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	68 7e 10 80 00       	push   $0x80107e
  8010f1:	e8 1a 01 00 00       	call   801210 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f6:	83 c4 08             	add    $0x8,%esp
  8010f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	e8 97 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80110b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801119:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111c:	50                   	push   %eax
  80111d:	ff 75 08             	pushl  0x8(%ebp)
  801120:	e8 9d ff ff ff       	call   8010c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 1c             	sub    $0x1c,%esp
  801130:	89 c7                	mov    %eax,%edi
  801132:	89 d6                	mov    %edx,%esi
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801140:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801143:	bb 00 00 00 00       	mov    $0x0,%ebx
  801148:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114e:	39 d3                	cmp    %edx,%ebx
  801150:	72 05                	jb     801157 <printnum+0x30>
  801152:	39 45 10             	cmp    %eax,0x10(%ebp)
  801155:	77 7a                	ja     8011d1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	ff 75 18             	pushl  0x18(%ebp)
  80115d:	8b 45 14             	mov    0x14(%ebp),%eax
  801160:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801163:	53                   	push   %ebx
  801164:	ff 75 10             	pushl  0x10(%ebp)
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116d:	ff 75 e0             	pushl  -0x20(%ebp)
  801170:	ff 75 dc             	pushl  -0x24(%ebp)
  801173:	ff 75 d8             	pushl  -0x28(%ebp)
  801176:	e8 25 0a 00 00       	call   801ba0 <__udivdi3>
  80117b:	83 c4 18             	add    $0x18,%esp
  80117e:	52                   	push   %edx
  80117f:	50                   	push   %eax
  801180:	89 f2                	mov    %esi,%edx
  801182:	89 f8                	mov    %edi,%eax
  801184:	e8 9e ff ff ff       	call   801127 <printnum>
  801189:	83 c4 20             	add    $0x20,%esp
  80118c:	eb 13                	jmp    8011a1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	56                   	push   %esi
  801192:	ff 75 18             	pushl  0x18(%ebp)
  801195:	ff d7                	call   *%edi
  801197:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80119a:	83 eb 01             	sub    $0x1,%ebx
  80119d:	85 db                	test   %ebx,%ebx
  80119f:	7f ed                	jg     80118e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	56                   	push   %esi
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b4:	e8 07 0b 00 00       	call   801cc0 <__umoddi3>
  8011b9:	83 c4 14             	add    $0x14,%esp
  8011bc:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff d7                	call   *%edi
}
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
  8011d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011d4:	eb c4                	jmp    80119a <printnum+0x73>

008011d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e0:	8b 10                	mov    (%eax),%edx
  8011e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e5:	73 0a                	jae    8011f1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ea:	89 08                	mov    %ecx,(%eax)
  8011ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ef:	88 02                	mov    %al,(%edx)
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <printfmt>:
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011fc:	50                   	push   %eax
  8011fd:	ff 75 10             	pushl  0x10(%ebp)
  801200:	ff 75 0c             	pushl  0xc(%ebp)
  801203:	ff 75 08             	pushl  0x8(%ebp)
  801206:	e8 05 00 00 00       	call   801210 <vprintfmt>
}
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <vprintfmt>:
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 2c             	sub    $0x2c,%esp
  801219:	8b 75 08             	mov    0x8(%ebp),%esi
  80121c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801222:	e9 c1 03 00 00       	jmp    8015e8 <vprintfmt+0x3d8>
		padc = ' ';
  801227:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80122b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801232:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801239:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801240:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801245:	8d 47 01             	lea    0x1(%edi),%eax
  801248:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124b:	0f b6 17             	movzbl (%edi),%edx
  80124e:	8d 42 dd             	lea    -0x23(%edx),%eax
  801251:	3c 55                	cmp    $0x55,%al
  801253:	0f 87 12 04 00 00    	ja     80166b <vprintfmt+0x45b>
  801259:	0f b6 c0             	movzbl %al,%eax
  80125c:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801263:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801266:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80126a:	eb d9                	jmp    801245 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80126f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801273:	eb d0                	jmp    801245 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801275:	0f b6 d2             	movzbl %dl,%edx
  801278:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801283:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801286:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80128a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80128d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801290:	83 f9 09             	cmp    $0x9,%ecx
  801293:	77 55                	ja     8012ea <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801295:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801298:	eb e9                	jmp    801283 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80129a:	8b 45 14             	mov    0x14(%ebp),%eax
  80129d:	8b 00                	mov    (%eax),%eax
  80129f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a5:	8d 40 04             	lea    0x4(%eax),%eax
  8012a8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012b2:	79 91                	jns    801245 <vprintfmt+0x35>
				width = precision, precision = -1;
  8012b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012c1:	eb 82                	jmp    801245 <vprintfmt+0x35>
  8012c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cd:	0f 49 d0             	cmovns %eax,%edx
  8012d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d6:	e9 6a ff ff ff       	jmp    801245 <vprintfmt+0x35>
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e5:	e9 5b ff ff ff       	jmp    801245 <vprintfmt+0x35>
  8012ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012f0:	eb bc                	jmp    8012ae <vprintfmt+0x9e>
			lflag++;
  8012f2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012f8:	e9 48 ff ff ff       	jmp    801245 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801300:	8d 78 04             	lea    0x4(%eax),%edi
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	53                   	push   %ebx
  801307:	ff 30                	pushl  (%eax)
  801309:	ff d6                	call   *%esi
			break;
  80130b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80130e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801311:	e9 cf 02 00 00       	jmp    8015e5 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801316:	8b 45 14             	mov    0x14(%ebp),%eax
  801319:	8d 78 04             	lea    0x4(%eax),%edi
  80131c:	8b 00                	mov    (%eax),%eax
  80131e:	99                   	cltd   
  80131f:	31 d0                	xor    %edx,%eax
  801321:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801323:	83 f8 0f             	cmp    $0xf,%eax
  801326:	7f 23                	jg     80134b <vprintfmt+0x13b>
  801328:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80132f:	85 d2                	test   %edx,%edx
  801331:	74 18                	je     80134b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801333:	52                   	push   %edx
  801334:	68 bd 1e 80 00       	push   $0x801ebd
  801339:	53                   	push   %ebx
  80133a:	56                   	push   %esi
  80133b:	e8 b3 fe ff ff       	call   8011f3 <printfmt>
  801340:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801343:	89 7d 14             	mov    %edi,0x14(%ebp)
  801346:	e9 9a 02 00 00       	jmp    8015e5 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80134b:	50                   	push   %eax
  80134c:	68 7f 1f 80 00       	push   $0x801f7f
  801351:	53                   	push   %ebx
  801352:	56                   	push   %esi
  801353:	e8 9b fe ff ff       	call   8011f3 <printfmt>
  801358:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80135b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80135e:	e9 82 02 00 00       	jmp    8015e5 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	83 c0 04             	add    $0x4,%eax
  801369:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80136c:	8b 45 14             	mov    0x14(%ebp),%eax
  80136f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801371:	85 ff                	test   %edi,%edi
  801373:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801378:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80137b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137f:	0f 8e bd 00 00 00    	jle    801442 <vprintfmt+0x232>
  801385:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801389:	75 0e                	jne    801399 <vprintfmt+0x189>
  80138b:	89 75 08             	mov    %esi,0x8(%ebp)
  80138e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801391:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801394:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801397:	eb 6d                	jmp    801406 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	ff 75 d0             	pushl  -0x30(%ebp)
  80139f:	57                   	push   %edi
  8013a0:	e8 6e 03 00 00       	call   801713 <strnlen>
  8013a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a8:	29 c1                	sub    %eax,%ecx
  8013aa:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013b0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013ba:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bc:	eb 0f                	jmp    8013cd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8013c5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c7:	83 ef 01             	sub    $0x1,%edi
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 ff                	test   %edi,%edi
  8013cf:	7f ed                	jg     8013be <vprintfmt+0x1ae>
  8013d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013d4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013d7:	85 c9                	test   %ecx,%ecx
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013de:	0f 49 c1             	cmovns %ecx,%eax
  8013e1:	29 c1                	sub    %eax,%ecx
  8013e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8013e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013ec:	89 cb                	mov    %ecx,%ebx
  8013ee:	eb 16                	jmp    801406 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f4:	75 31                	jne    801427 <vprintfmt+0x217>
					putch(ch, putdat);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	ff 75 0c             	pushl  0xc(%ebp)
  8013fc:	50                   	push   %eax
  8013fd:	ff 55 08             	call   *0x8(%ebp)
  801400:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801403:	83 eb 01             	sub    $0x1,%ebx
  801406:	83 c7 01             	add    $0x1,%edi
  801409:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80140d:	0f be c2             	movsbl %dl,%eax
  801410:	85 c0                	test   %eax,%eax
  801412:	74 59                	je     80146d <vprintfmt+0x25d>
  801414:	85 f6                	test   %esi,%esi
  801416:	78 d8                	js     8013f0 <vprintfmt+0x1e0>
  801418:	83 ee 01             	sub    $0x1,%esi
  80141b:	79 d3                	jns    8013f0 <vprintfmt+0x1e0>
  80141d:	89 df                	mov    %ebx,%edi
  80141f:	8b 75 08             	mov    0x8(%ebp),%esi
  801422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801425:	eb 37                	jmp    80145e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801427:	0f be d2             	movsbl %dl,%edx
  80142a:	83 ea 20             	sub    $0x20,%edx
  80142d:	83 fa 5e             	cmp    $0x5e,%edx
  801430:	76 c4                	jbe    8013f6 <vprintfmt+0x1e6>
					putch('?', putdat);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	ff 75 0c             	pushl  0xc(%ebp)
  801438:	6a 3f                	push   $0x3f
  80143a:	ff 55 08             	call   *0x8(%ebp)
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	eb c1                	jmp    801403 <vprintfmt+0x1f3>
  801442:	89 75 08             	mov    %esi,0x8(%ebp)
  801445:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801448:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144e:	eb b6                	jmp    801406 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	53                   	push   %ebx
  801454:	6a 20                	push   $0x20
  801456:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801458:	83 ef 01             	sub    $0x1,%edi
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 ff                	test   %edi,%edi
  801460:	7f ee                	jg     801450 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801462:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801465:	89 45 14             	mov    %eax,0x14(%ebp)
  801468:	e9 78 01 00 00       	jmp    8015e5 <vprintfmt+0x3d5>
  80146d:	89 df                	mov    %ebx,%edi
  80146f:	8b 75 08             	mov    0x8(%ebp),%esi
  801472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801475:	eb e7                	jmp    80145e <vprintfmt+0x24e>
	if (lflag >= 2)
  801477:	83 f9 01             	cmp    $0x1,%ecx
  80147a:	7e 3f                	jle    8014bb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80147c:	8b 45 14             	mov    0x14(%ebp),%eax
  80147f:	8b 50 04             	mov    0x4(%eax),%edx
  801482:	8b 00                	mov    (%eax),%eax
  801484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801487:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148a:	8b 45 14             	mov    0x14(%ebp),%eax
  80148d:	8d 40 08             	lea    0x8(%eax),%eax
  801490:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801493:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801497:	79 5c                	jns    8014f5 <vprintfmt+0x2e5>
				putch('-', putdat);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	53                   	push   %ebx
  80149d:	6a 2d                	push   $0x2d
  80149f:	ff d6                	call   *%esi
				num = -(long long) num;
  8014a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014a7:	f7 da                	neg    %edx
  8014a9:	83 d1 00             	adc    $0x0,%ecx
  8014ac:	f7 d9                	neg    %ecx
  8014ae:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b6:	e9 10 01 00 00       	jmp    8015cb <vprintfmt+0x3bb>
	else if (lflag)
  8014bb:	85 c9                	test   %ecx,%ecx
  8014bd:	75 1b                	jne    8014da <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c2:	8b 00                	mov    (%eax),%eax
  8014c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c7:	89 c1                	mov    %eax,%ecx
  8014c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8d 40 04             	lea    0x4(%eax),%eax
  8014d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d8:	eb b9                	jmp    801493 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014da:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dd:	8b 00                	mov    (%eax),%eax
  8014df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e2:	89 c1                	mov    %eax,%ecx
  8014e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8d 40 04             	lea    0x4(%eax),%eax
  8014f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f3:	eb 9e                	jmp    801493 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  801500:	e9 c6 00 00 00       	jmp    8015cb <vprintfmt+0x3bb>
	if (lflag >= 2)
  801505:	83 f9 01             	cmp    $0x1,%ecx
  801508:	7e 18                	jle    801522 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8b 10                	mov    (%eax),%edx
  80150f:	8b 48 04             	mov    0x4(%eax),%ecx
  801512:	8d 40 08             	lea    0x8(%eax),%eax
  801515:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801518:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151d:	e9 a9 00 00 00       	jmp    8015cb <vprintfmt+0x3bb>
	else if (lflag)
  801522:	85 c9                	test   %ecx,%ecx
  801524:	75 1a                	jne    801540 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801526:	8b 45 14             	mov    0x14(%ebp),%eax
  801529:	8b 10                	mov    (%eax),%edx
  80152b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801530:	8d 40 04             	lea    0x4(%eax),%eax
  801533:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153b:	e9 8b 00 00 00       	jmp    8015cb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801540:	8b 45 14             	mov    0x14(%ebp),%eax
  801543:	8b 10                	mov    (%eax),%edx
  801545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80154a:	8d 40 04             	lea    0x4(%eax),%eax
  80154d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801550:	b8 0a 00 00 00       	mov    $0xa,%eax
  801555:	eb 74                	jmp    8015cb <vprintfmt+0x3bb>
	if (lflag >= 2)
  801557:	83 f9 01             	cmp    $0x1,%ecx
  80155a:	7e 15                	jle    801571 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80155c:	8b 45 14             	mov    0x14(%ebp),%eax
  80155f:	8b 10                	mov    (%eax),%edx
  801561:	8b 48 04             	mov    0x4(%eax),%ecx
  801564:	8d 40 08             	lea    0x8(%eax),%eax
  801567:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80156a:	b8 08 00 00 00       	mov    $0x8,%eax
  80156f:	eb 5a                	jmp    8015cb <vprintfmt+0x3bb>
	else if (lflag)
  801571:	85 c9                	test   %ecx,%ecx
  801573:	75 17                	jne    80158c <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801575:	8b 45 14             	mov    0x14(%ebp),%eax
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157f:	8d 40 04             	lea    0x4(%eax),%eax
  801582:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801585:	b8 08 00 00 00       	mov    $0x8,%eax
  80158a:	eb 3f                	jmp    8015cb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80158c:	8b 45 14             	mov    0x14(%ebp),%eax
  80158f:	8b 10                	mov    (%eax),%edx
  801591:	b9 00 00 00 00       	mov    $0x0,%ecx
  801596:	8d 40 04             	lea    0x4(%eax),%eax
  801599:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80159c:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a1:	eb 28                	jmp    8015cb <vprintfmt+0x3bb>
			putch('0', putdat);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 30                	push   $0x30
  8015a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	6a 78                	push   $0x78
  8015b1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b6:	8b 10                	mov    (%eax),%edx
  8015b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015bd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015c0:	8d 40 04             	lea    0x4(%eax),%eax
  8015c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d2:	57                   	push   %edi
  8015d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d6:	50                   	push   %eax
  8015d7:	51                   	push   %ecx
  8015d8:	52                   	push   %edx
  8015d9:	89 da                	mov    %ebx,%edx
  8015db:	89 f0                	mov    %esi,%eax
  8015dd:	e8 45 fb ff ff       	call   801127 <printnum>
			break;
  8015e2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015e8:	83 c7 01             	add    $0x1,%edi
  8015eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ef:	83 f8 25             	cmp    $0x25,%eax
  8015f2:	0f 84 2f fc ff ff    	je     801227 <vprintfmt+0x17>
			if (ch == '\0')
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	0f 84 8b 00 00 00    	je     80168b <vprintfmt+0x47b>
			putch(ch, putdat);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	50                   	push   %eax
  801605:	ff d6                	call   *%esi
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb dc                	jmp    8015e8 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80160c:	83 f9 01             	cmp    $0x1,%ecx
  80160f:	7e 15                	jle    801626 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8b 10                	mov    (%eax),%edx
  801616:	8b 48 04             	mov    0x4(%eax),%ecx
  801619:	8d 40 08             	lea    0x8(%eax),%eax
  80161c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161f:	b8 10 00 00 00       	mov    $0x10,%eax
  801624:	eb a5                	jmp    8015cb <vprintfmt+0x3bb>
	else if (lflag)
  801626:	85 c9                	test   %ecx,%ecx
  801628:	75 17                	jne    801641 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80162a:	8b 45 14             	mov    0x14(%ebp),%eax
  80162d:	8b 10                	mov    (%eax),%edx
  80162f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801634:	8d 40 04             	lea    0x4(%eax),%eax
  801637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80163a:	b8 10 00 00 00       	mov    $0x10,%eax
  80163f:	eb 8a                	jmp    8015cb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801641:	8b 45 14             	mov    0x14(%ebp),%eax
  801644:	8b 10                	mov    (%eax),%edx
  801646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80164b:	8d 40 04             	lea    0x4(%eax),%eax
  80164e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801651:	b8 10 00 00 00       	mov    $0x10,%eax
  801656:	e9 70 ff ff ff       	jmp    8015cb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	6a 25                	push   $0x25
  801661:	ff d6                	call   *%esi
			break;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	e9 7a ff ff ff       	jmp    8015e5 <vprintfmt+0x3d5>
			putch('%', putdat);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	53                   	push   %ebx
  80166f:	6a 25                	push   $0x25
  801671:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	89 f8                	mov    %edi,%eax
  801678:	eb 03                	jmp    80167d <vprintfmt+0x46d>
  80167a:	83 e8 01             	sub    $0x1,%eax
  80167d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801681:	75 f7                	jne    80167a <vprintfmt+0x46a>
  801683:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801686:	e9 5a ff ff ff       	jmp    8015e5 <vprintfmt+0x3d5>
}
  80168b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 18             	sub    $0x18,%esp
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80169f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	74 26                	je     8016da <vsnprintf+0x47>
  8016b4:	85 d2                	test   %edx,%edx
  8016b6:	7e 22                	jle    8016da <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016b8:	ff 75 14             	pushl  0x14(%ebp)
  8016bb:	ff 75 10             	pushl  0x10(%ebp)
  8016be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	68 d6 11 80 00       	push   $0x8011d6
  8016c7:	e8 44 fb ff ff       	call   801210 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	83 c4 10             	add    $0x10,%esp
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    
		return -E_INVAL;
  8016da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016df:	eb f7                	jmp    8016d8 <vsnprintf+0x45>

008016e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 10             	pushl  0x10(%ebp)
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	e8 9a ff ff ff       	call   801693 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
  801706:	eb 03                	jmp    80170b <strlen+0x10>
		n++;
  801708:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80170b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80170f:	75 f7                	jne    801708 <strlen+0xd>
	return n;
}
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171c:	b8 00 00 00 00       	mov    $0x0,%eax
  801721:	eb 03                	jmp    801726 <strnlen+0x13>
		n++;
  801723:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801726:	39 d0                	cmp    %edx,%eax
  801728:	74 06                	je     801730 <strnlen+0x1d>
  80172a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80172e:	75 f3                	jne    801723 <strnlen+0x10>
	return n;
}
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	53                   	push   %ebx
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	83 c1 01             	add    $0x1,%ecx
  801741:	83 c2 01             	add    $0x1,%edx
  801744:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801748:	88 5a ff             	mov    %bl,-0x1(%edx)
  80174b:	84 db                	test   %bl,%bl
  80174d:	75 ef                	jne    80173e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80174f:	5b                   	pop    %ebx
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	53                   	push   %ebx
  801756:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801759:	53                   	push   %ebx
  80175a:	e8 9c ff ff ff       	call   8016fb <strlen>
  80175f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	01 d8                	add    %ebx,%eax
  801767:	50                   	push   %eax
  801768:	e8 c5 ff ff ff       	call   801732 <strcpy>
	return dst;
}
  80176d:	89 d8                	mov    %ebx,%eax
  80176f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	56                   	push   %esi
  801778:	53                   	push   %ebx
  801779:	8b 75 08             	mov    0x8(%ebp),%esi
  80177c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177f:	89 f3                	mov    %esi,%ebx
  801781:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801784:	89 f2                	mov    %esi,%edx
  801786:	eb 0f                	jmp    801797 <strncpy+0x23>
		*dst++ = *src;
  801788:	83 c2 01             	add    $0x1,%edx
  80178b:	0f b6 01             	movzbl (%ecx),%eax
  80178e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801791:	80 39 01             	cmpb   $0x1,(%ecx)
  801794:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801797:	39 da                	cmp    %ebx,%edx
  801799:	75 ed                	jne    801788 <strncpy+0x14>
	}
	return ret;
}
  80179b:	89 f0                	mov    %esi,%eax
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017af:	89 f0                	mov    %esi,%eax
  8017b1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017b5:	85 c9                	test   %ecx,%ecx
  8017b7:	75 0b                	jne    8017c4 <strlcpy+0x23>
  8017b9:	eb 17                	jmp    8017d2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017bb:	83 c2 01             	add    $0x1,%edx
  8017be:	83 c0 01             	add    $0x1,%eax
  8017c1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017c4:	39 d8                	cmp    %ebx,%eax
  8017c6:	74 07                	je     8017cf <strlcpy+0x2e>
  8017c8:	0f b6 0a             	movzbl (%edx),%ecx
  8017cb:	84 c9                	test   %cl,%cl
  8017cd:	75 ec                	jne    8017bb <strlcpy+0x1a>
		*dst = '\0';
  8017cf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017d2:	29 f0                	sub    %esi,%eax
}
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017e1:	eb 06                	jmp    8017e9 <strcmp+0x11>
		p++, q++;
  8017e3:	83 c1 01             	add    $0x1,%ecx
  8017e6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017e9:	0f b6 01             	movzbl (%ecx),%eax
  8017ec:	84 c0                	test   %al,%al
  8017ee:	74 04                	je     8017f4 <strcmp+0x1c>
  8017f0:	3a 02                	cmp    (%edx),%al
  8017f2:	74 ef                	je     8017e3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f4:	0f b6 c0             	movzbl %al,%eax
  8017f7:	0f b6 12             	movzbl (%edx),%edx
  8017fa:	29 d0                	sub    %edx,%eax
}
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	53                   	push   %ebx
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 55 0c             	mov    0xc(%ebp),%edx
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80180d:	eb 06                	jmp    801815 <strncmp+0x17>
		n--, p++, q++;
  80180f:	83 c0 01             	add    $0x1,%eax
  801812:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801815:	39 d8                	cmp    %ebx,%eax
  801817:	74 16                	je     80182f <strncmp+0x31>
  801819:	0f b6 08             	movzbl (%eax),%ecx
  80181c:	84 c9                	test   %cl,%cl
  80181e:	74 04                	je     801824 <strncmp+0x26>
  801820:	3a 0a                	cmp    (%edx),%cl
  801822:	74 eb                	je     80180f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801824:	0f b6 00             	movzbl (%eax),%eax
  801827:	0f b6 12             	movzbl (%edx),%edx
  80182a:	29 d0                	sub    %edx,%eax
}
  80182c:	5b                   	pop    %ebx
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    
		return 0;
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
  801834:	eb f6                	jmp    80182c <strncmp+0x2e>

00801836 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801840:	0f b6 10             	movzbl (%eax),%edx
  801843:	84 d2                	test   %dl,%dl
  801845:	74 09                	je     801850 <strchr+0x1a>
		if (*s == c)
  801847:	38 ca                	cmp    %cl,%dl
  801849:	74 0a                	je     801855 <strchr+0x1f>
	for (; *s; s++)
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	eb f0                	jmp    801840 <strchr+0xa>
			return (char *) s;
	return 0;
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801861:	eb 03                	jmp    801866 <strfind+0xf>
  801863:	83 c0 01             	add    $0x1,%eax
  801866:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801869:	38 ca                	cmp    %cl,%dl
  80186b:	74 04                	je     801871 <strfind+0x1a>
  80186d:	84 d2                	test   %dl,%dl
  80186f:	75 f2                	jne    801863 <strfind+0xc>
			break;
	return (char *) s;
}
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	8b 7d 08             	mov    0x8(%ebp),%edi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80187f:	85 c9                	test   %ecx,%ecx
  801881:	74 13                	je     801896 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801883:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801889:	75 05                	jne    801890 <memset+0x1d>
  80188b:	f6 c1 03             	test   $0x3,%cl
  80188e:	74 0d                	je     80189d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	fc                   	cld    
  801894:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801896:	89 f8                	mov    %edi,%eax
  801898:	5b                   	pop    %ebx
  801899:	5e                   	pop    %esi
  80189a:	5f                   	pop    %edi
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    
		c &= 0xFF;
  80189d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018a1:	89 d3                	mov    %edx,%ebx
  8018a3:	c1 e3 08             	shl    $0x8,%ebx
  8018a6:	89 d0                	mov    %edx,%eax
  8018a8:	c1 e0 18             	shl    $0x18,%eax
  8018ab:	89 d6                	mov    %edx,%esi
  8018ad:	c1 e6 10             	shl    $0x10,%esi
  8018b0:	09 f0                	or     %esi,%eax
  8018b2:	09 c2                	or     %eax,%edx
  8018b4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018b6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018b9:	89 d0                	mov    %edx,%eax
  8018bb:	fc                   	cld    
  8018bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8018be:	eb d6                	jmp    801896 <memset+0x23>

008018c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ce:	39 c6                	cmp    %eax,%esi
  8018d0:	73 35                	jae    801907 <memmove+0x47>
  8018d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018d5:	39 c2                	cmp    %eax,%edx
  8018d7:	76 2e                	jbe    801907 <memmove+0x47>
		s += n;
		d += n;
  8018d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018dc:	89 d6                	mov    %edx,%esi
  8018de:	09 fe                	or     %edi,%esi
  8018e0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018e6:	74 0c                	je     8018f4 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018e8:	83 ef 01             	sub    $0x1,%edi
  8018eb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018ee:	fd                   	std    
  8018ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f1:	fc                   	cld    
  8018f2:	eb 21                	jmp    801915 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f4:	f6 c1 03             	test   $0x3,%cl
  8018f7:	75 ef                	jne    8018e8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018f9:	83 ef 04             	sub    $0x4,%edi
  8018fc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ff:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801902:	fd                   	std    
  801903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801905:	eb ea                	jmp    8018f1 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801907:	89 f2                	mov    %esi,%edx
  801909:	09 c2                	or     %eax,%edx
  80190b:	f6 c2 03             	test   $0x3,%dl
  80190e:	74 09                	je     801919 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801910:	89 c7                	mov    %eax,%edi
  801912:	fc                   	cld    
  801913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801919:	f6 c1 03             	test   $0x3,%cl
  80191c:	75 f2                	jne    801910 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80191e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801921:	89 c7                	mov    %eax,%edi
  801923:	fc                   	cld    
  801924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801926:	eb ed                	jmp    801915 <memmove+0x55>

00801928 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80192b:	ff 75 10             	pushl  0x10(%ebp)
  80192e:	ff 75 0c             	pushl  0xc(%ebp)
  801931:	ff 75 08             	pushl  0x8(%ebp)
  801934:	e8 87 ff ff ff       	call   8018c0 <memmove>
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	8b 55 0c             	mov    0xc(%ebp),%edx
  801946:	89 c6                	mov    %eax,%esi
  801948:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194b:	39 f0                	cmp    %esi,%eax
  80194d:	74 1c                	je     80196b <memcmp+0x30>
		if (*s1 != *s2)
  80194f:	0f b6 08             	movzbl (%eax),%ecx
  801952:	0f b6 1a             	movzbl (%edx),%ebx
  801955:	38 d9                	cmp    %bl,%cl
  801957:	75 08                	jne    801961 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801959:	83 c0 01             	add    $0x1,%eax
  80195c:	83 c2 01             	add    $0x1,%edx
  80195f:	eb ea                	jmp    80194b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801961:	0f b6 c1             	movzbl %cl,%eax
  801964:	0f b6 db             	movzbl %bl,%ebx
  801967:	29 d8                	sub    %ebx,%eax
  801969:	eb 05                	jmp    801970 <memcmp+0x35>
	}

	return 0;
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801982:	39 d0                	cmp    %edx,%eax
  801984:	73 09                	jae    80198f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801986:	38 08                	cmp    %cl,(%eax)
  801988:	74 05                	je     80198f <memfind+0x1b>
	for (; s < ends; s++)
  80198a:	83 c0 01             	add    $0x1,%eax
  80198d:	eb f3                	jmp    801982 <memfind+0xe>
			break;
	return (void *) s;
}
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	57                   	push   %edi
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199d:	eb 03                	jmp    8019a2 <strtol+0x11>
		s++;
  80199f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019a2:	0f b6 01             	movzbl (%ecx),%eax
  8019a5:	3c 20                	cmp    $0x20,%al
  8019a7:	74 f6                	je     80199f <strtol+0xe>
  8019a9:	3c 09                	cmp    $0x9,%al
  8019ab:	74 f2                	je     80199f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019ad:	3c 2b                	cmp    $0x2b,%al
  8019af:	74 2e                	je     8019df <strtol+0x4e>
	int neg = 0;
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019b6:	3c 2d                	cmp    $0x2d,%al
  8019b8:	74 2f                	je     8019e9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c0:	75 05                	jne    8019c7 <strtol+0x36>
  8019c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c5:	74 2c                	je     8019f3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c7:	85 db                	test   %ebx,%ebx
  8019c9:	75 0a                	jne    8019d5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019cb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019d0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d3:	74 28                	je     8019fd <strtol+0x6c>
		base = 10;
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019dd:	eb 50                	jmp    801a2f <strtol+0x9e>
		s++;
  8019df:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e7:	eb d1                	jmp    8019ba <strtol+0x29>
		s++, neg = 1;
  8019e9:	83 c1 01             	add    $0x1,%ecx
  8019ec:	bf 01 00 00 00       	mov    $0x1,%edi
  8019f1:	eb c7                	jmp    8019ba <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019f7:	74 0e                	je     801a07 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f9:	85 db                	test   %ebx,%ebx
  8019fb:	75 d8                	jne    8019d5 <strtol+0x44>
		s++, base = 8;
  8019fd:	83 c1 01             	add    $0x1,%ecx
  801a00:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a05:	eb ce                	jmp    8019d5 <strtol+0x44>
		s += 2, base = 16;
  801a07:	83 c1 02             	add    $0x2,%ecx
  801a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0f:	eb c4                	jmp    8019d5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a11:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a14:	89 f3                	mov    %esi,%ebx
  801a16:	80 fb 19             	cmp    $0x19,%bl
  801a19:	77 29                	ja     801a44 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a1b:	0f be d2             	movsbl %dl,%edx
  801a1e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a21:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a24:	7d 30                	jge    801a56 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a26:	83 c1 01             	add    $0x1,%ecx
  801a29:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a2f:	0f b6 11             	movzbl (%ecx),%edx
  801a32:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a35:	89 f3                	mov    %esi,%ebx
  801a37:	80 fb 09             	cmp    $0x9,%bl
  801a3a:	77 d5                	ja     801a11 <strtol+0x80>
			dig = *s - '0';
  801a3c:	0f be d2             	movsbl %dl,%edx
  801a3f:	83 ea 30             	sub    $0x30,%edx
  801a42:	eb dd                	jmp    801a21 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a44:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a47:	89 f3                	mov    %esi,%ebx
  801a49:	80 fb 19             	cmp    $0x19,%bl
  801a4c:	77 08                	ja     801a56 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a4e:	0f be d2             	movsbl %dl,%edx
  801a51:	83 ea 37             	sub    $0x37,%edx
  801a54:	eb cb                	jmp    801a21 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a5a:	74 05                	je     801a61 <strtol+0xd0>
		*endptr = (char *) s;
  801a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a61:	89 c2                	mov    %eax,%edx
  801a63:	f7 da                	neg    %edx
  801a65:	85 ff                	test   %edi,%edi
  801a67:	0f 45 c2             	cmovne %edx,%eax
}
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
  801a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a84:	0f 44 c2             	cmove  %edx,%eax
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	50                   	push   %eax
  801a8b:	e8 7e e8 ff ff       	call   80030e <sys_ipc_recv>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 2b                	js     801ac2 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a97:	85 f6                	test   %esi,%esi
  801a99:	74 0a                	je     801aa5 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801a9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa0:	8b 40 74             	mov    0x74(%eax),%eax
  801aa3:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801aa5:	85 db                	test   %ebx,%ebx
  801aa7:	74 0a                	je     801ab3 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801aa9:	a1 04 40 80 00       	mov    0x804004,%eax
  801aae:	8b 40 78             	mov    0x78(%eax),%eax
  801ab1:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 40 70             	mov    0x70(%eax),%eax
}
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    
        *from_env_store = 0;
  801ac2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ac8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ace:	eb eb                	jmp    801abb <ipc_recv+0x4c>

00801ad0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ae2:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801ae4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae9:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801aec:	ff 75 14             	pushl  0x14(%ebp)
  801aef:	53                   	push   %ebx
  801af0:	56                   	push   %esi
  801af1:	57                   	push   %edi
  801af2:	e8 f4 e7 ff ff       	call   8002eb <sys_ipc_try_send>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	74 17                	je     801b15 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801afe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b01:	74 e9                	je     801aec <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801b03:	50                   	push   %eax
  801b04:	68 60 22 80 00       	push   $0x802260
  801b09:	6a 3e                	push   $0x3e
  801b0b:	68 72 22 80 00       	push   $0x802272
  801b10:	e8 23 f5 ff ff       	call   801038 <_panic>
        }
    }
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b28:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b31:	8b 52 50             	mov    0x50(%edx),%edx
  801b34:	39 ca                	cmp    %ecx,%edx
  801b36:	74 11                	je     801b49 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b38:	83 c0 01             	add    $0x1,%eax
  801b3b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b40:	75 e6                	jne    801b28 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	eb 0b                	jmp    801b54 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5c:	89 d0                	mov    %edx,%eax
  801b5e:	c1 e8 16             	shr    $0x16,%eax
  801b61:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b6d:	f6 c1 01             	test   $0x1,%cl
  801b70:	74 1d                	je     801b8f <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b72:	c1 ea 0c             	shr    $0xc,%edx
  801b75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7c:	f6 c2 01             	test   $0x1,%dl
  801b7f:	74 0e                	je     801b8f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b81:	c1 ea 0c             	shr    $0xc,%edx
  801b84:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8b:	ef 
  801b8c:	0f b7 c0             	movzwl %ax,%eax
}
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	66 90                	xchg   %ax,%ax
  801b93:	66 90                	xchg   %ax,%ax
  801b95:	66 90                	xchg   %ax,%ax
  801b97:	66 90                	xchg   %ax,%ax
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
