
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 92 04 00 00       	call   80051d <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7f 08                	jg     800101 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ea 1d 80 00       	push   $0x801dea
  80010c:	6a 23                	push   $0x23
  80010e:	68 07 1e 80 00       	push   $0x801e07
  800113:	e8 18 0f 00 00       	call   801030 <_panic>

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7f 08                	jg     800182 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ea 1d 80 00       	push   $0x801dea
  80018d:	6a 23                	push   $0x23
  80018f:	68 07 1e 80 00       	push   $0x801e07
  800194:	e8 97 0e 00 00       	call   801030 <_panic>

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7f 08                	jg     8001c4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ea 1d 80 00       	push   $0x801dea
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 07 1e 80 00       	push   $0x801e07
  8001d6:	e8 55 0e 00 00       	call   801030 <_panic>

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7f 08                	jg     800206 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ea 1d 80 00       	push   $0x801dea
  800211:	6a 23                	push   $0x23
  800213:	68 07 1e 80 00       	push   $0x801e07
  800218:	e8 13 0e 00 00       	call   801030 <_panic>

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7f 08                	jg     800248 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ea 1d 80 00       	push   $0x801dea
  800253:	6a 23                	push   $0x23
  800255:	68 07 1e 80 00       	push   $0x801e07
  80025a:	e8 d1 0d 00 00       	call   801030 <_panic>

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 09 00 00 00       	mov    $0x9,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ea 1d 80 00       	push   $0x801dea
  800295:	6a 23                	push   $0x23
  800297:	68 07 1e 80 00       	push   $0x801e07
  80029c:	e8 8f 0d 00 00       	call   801030 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7f 08                	jg     8002cc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 ea 1d 80 00       	push   $0x801dea
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 07 1e 80 00       	push   $0x801e07
  8002de:	e8 4d 0d 00 00       	call   801030 <_panic>

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7f 08                	jg     800330 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 ea 1d 80 00       	push   $0x801dea
  80033b:	6a 23                	push   $0x23
  80033d:	68 07 1e 80 00       	push   $0x801e07
  800342:	e8 e9 0c 00 00       	call   801030 <_panic>

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 2a                	je     8003b4 <fd_alloc+0x46>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	74 19                	je     8003b4 <fd_alloc+0x46>
  80039b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a5:	75 d2                	jne    800379 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b2:	eb 07                	jmp    8003bb <fd_alloc+0x4d>
			*fd_store = fd;
  8003b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb f7                	jmp    8003fc <fd_lookup+0x3f>
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb f0                	jmp    8003fc <fd_lookup+0x3f>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800411:	eb e9                	jmp    8003fc <fd_lookup+0x3f>

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	74 33                	je     80045d <dev_lookup+0x4a>
  80042a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042d:	8b 02                	mov    (%edx),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	75 f3                	jne    800426 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800433:	a1 04 40 80 00       	mov    0x804004,%eax
  800438:	8b 40 48             	mov    0x48(%eax),%eax
  80043b:	83 ec 04             	sub    $0x4,%esp
  80043e:	51                   	push   %ecx
  80043f:	50                   	push   %eax
  800440:	68 18 1e 80 00       	push   $0x801e18
  800445:	e8 c1 0c 00 00       	call   80110b <cprintf>
	*dev = 0;
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045b:	c9                   	leave  
  80045c:	c3                   	ret    
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb f2                	jmp    80045b <dev_lookup+0x48>

00800469 <fd_close>:
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	57                   	push   %edi
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 1c             	sub    $0x1c,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	50                   	push   %eax
  800486:	e8 32 ff ff ff       	call   8003bd <fd_lookup>
  80048b:	89 c3                	mov    %eax,%ebx
  80048d:	83 c4 08             	add    $0x8,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	78 05                	js     800499 <fd_close+0x30>
	    || fd != fd2)
  800494:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800497:	74 16                	je     8004af <fd_close+0x46>
		return (must_exist ? r : 0);
  800499:	89 f8                	mov    %edi,%eax
  80049b:	84 c0                	test   %al,%al
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a5:	89 d8                	mov    %ebx,%eax
  8004a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 56 ff ff ff       	call   800413 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 15                	js     8004db <fd_close+0x72>
		if (dev->dev_close)
  8004c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	74 1b                	je     8004eb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d0:	83 ec 0c             	sub    $0xc,%esp
  8004d3:	56                   	push   %esi
  8004d4:	ff d0                	call   *%eax
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	56                   	push   %esi
  8004df:	6a 00                	push   $0x0
  8004e1:	e8 f5 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb ba                	jmp    8004a5 <fd_close+0x3c>
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f0:	eb e9                	jmp    8004db <fd_close+0x72>

008004f2 <close>:

int
close(int fdnum)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 08             	pushl  0x8(%ebp)
  8004ff:	e8 b9 fe ff ff       	call   8003bd <fd_lookup>
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	85 c0                	test   %eax,%eax
  800509:	78 10                	js     80051b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	6a 01                	push   $0x1
  800510:	ff 75 f4             	pushl  -0xc(%ebp)
  800513:	e8 51 ff ff ff       	call   800469 <fd_close>
  800518:	83 c4 10             	add    $0x10,%esp
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <close_all>:

void
close_all(void)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	53                   	push   %ebx
  800521:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	53                   	push   %ebx
  80052d:	e8 c0 ff ff ff       	call   8004f2 <close>
	for (i = 0; i < MAXFD; i++)
  800532:	83 c3 01             	add    $0x1,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	83 fb 20             	cmp    $0x20,%ebx
  80053b:	75 ec                	jne    800529 <close_all+0xc>
}
  80053d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 66 fe ff ff       	call   8003bd <fd_lookup>
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	0f 88 81 00 00 00    	js     8005e5 <dup+0xa3>
		return r;
	close(newfdnum);
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	e8 83 ff ff ff       	call   8004f2 <close>

	newfd = INDEX2FD(newfdnum);
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800572:	c1 e6 0c             	shl    $0xc,%esi
  800575:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 d1 fd ff ff       	call   800357 <fd2data>
  800586:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800588:	89 34 24             	mov    %esi,(%esp)
  80058b:	e8 c7 fd ff ff       	call   800357 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800595:	89 d8                	mov    %ebx,%eax
  800597:	c1 e8 16             	shr    $0x16,%eax
  80059a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a1:	a8 01                	test   $0x1,%al
  8005a3:	74 11                	je     8005b6 <dup+0x74>
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b1:	f6 c2 01             	test   $0x1,%dl
  8005b4:	75 39                	jne    8005ef <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b9:	89 d0                	mov    %edx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	52                   	push   %edx
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 c0 fb ff ff       	call   800199 <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	78 31                	js     800613 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e5:	89 d8                	mov    %ebx,%eax
  8005e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fe:	50                   	push   %eax
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	53                   	push   %ebx
  800603:	6a 00                	push   $0x0
  800605:	e8 8f fb ff ff       	call   800199 <sys_page_map>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 a3                	jns    8005b6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	56                   	push   %esi
  800617:	6a 00                	push   $0x0
  800619:	e8 bd fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	57                   	push   %edi
  800622:	6a 00                	push   $0x0
  800624:	e8 b2 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb b7                	jmp    8005e5 <dup+0xa3>

0080062e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	53                   	push   %ebx
  800632:	83 ec 14             	sub    $0x14,%esp
  800635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063b:	50                   	push   %eax
  80063c:	53                   	push   %ebx
  80063d:	e8 7b fd ff ff       	call   8003bd <fd_lookup>
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	85 c0                	test   %eax,%eax
  800647:	78 3f                	js     800688 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800653:	ff 30                	pushl  (%eax)
  800655:	e8 b9 fd ff ff       	call   800413 <dev_lookup>
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	85 c0                	test   %eax,%eax
  80065f:	78 27                	js     800688 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800661:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800664:	8b 42 08             	mov    0x8(%edx),%eax
  800667:	83 e0 03             	and    $0x3,%eax
  80066a:	83 f8 01             	cmp    $0x1,%eax
  80066d:	74 1e                	je     80068d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800672:	8b 40 08             	mov    0x8(%eax),%eax
  800675:	85 c0                	test   %eax,%eax
  800677:	74 35                	je     8006ae <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800679:	83 ec 04             	sub    $0x4,%esp
  80067c:	ff 75 10             	pushl  0x10(%ebp)
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	52                   	push   %edx
  800683:	ff d0                	call   *%eax
  800685:	83 c4 10             	add    $0x10,%esp
}
  800688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 04 40 80 00       	mov    0x804004,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 59 1e 80 00       	push   $0x801e59
  80069f:	e8 67 0a 00 00       	call   80110b <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb da                	jmp    800688 <read+0x5a>
		return -E_NOT_SUPP;
  8006ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b3:	eb d3                	jmp    800688 <read+0x5a>

008006b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	57                   	push   %edi
  8006b9:	56                   	push   %esi
  8006ba:	53                   	push   %ebx
  8006bb:	83 ec 0c             	sub    $0xc,%esp
  8006be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c9:	39 f3                	cmp    %esi,%ebx
  8006cb:	73 25                	jae    8006f2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	29 d8                	sub    %ebx,%eax
  8006d4:	50                   	push   %eax
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	03 45 0c             	add    0xc(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	57                   	push   %edi
  8006dc:	e8 4d ff ff ff       	call   80062e <read>
		if (m < 0)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	78 08                	js     8006f0 <readn+0x3b>
			return m;
		if (m == 0)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 06                	je     8006f2 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006ec:	01 c3                	add    %eax,%ebx
  8006ee:	eb d9                	jmp    8006c9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f2:	89 d8                	mov    %ebx,%eax
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ad fc ff ff       	call   8003bd <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	78 3a                	js     800751 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800721:	ff 30                	pushl  (%eax)
  800723:	e8 eb fc ff ff       	call   800413 <dev_lookup>
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 22                	js     800751 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800736:	74 1e                	je     800756 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073b:	8b 52 0c             	mov    0xc(%edx),%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 35                	je     800777 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	50                   	push   %eax
  80074c:	ff d2                	call   *%edx
  80074e:	83 c4 10             	add    $0x10,%esp
}
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800756:	a1 04 40 80 00       	mov    0x804004,%eax
  80075b:	8b 40 48             	mov    0x48(%eax),%eax
  80075e:	83 ec 04             	sub    $0x4,%esp
  800761:	53                   	push   %ebx
  800762:	50                   	push   %eax
  800763:	68 75 1e 80 00       	push   $0x801e75
  800768:	e8 9e 09 00 00       	call   80110b <cprintf>
		return -E_INVAL;
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb da                	jmp    800751 <write+0x55>
		return -E_NOT_SUPP;
  800777:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077c:	eb d3                	jmp    800751 <write+0x55>

0080077e <seek>:

int
seek(int fdnum, off_t offset)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800784:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 2d fc ff ff       	call   8003bd <fd_lookup>
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	85 c0                	test   %eax,%eax
  800795:	78 0e                	js     8007a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 14             	sub    $0x14,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	53                   	push   %ebx
  8007b6:	e8 02 fc ff ff       	call   8003bd <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 37                	js     8007f9 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cc:	ff 30                	pushl  (%eax)
  8007ce:	e8 40 fc ff ff       	call   800413 <dev_lookup>
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 1f                	js     8007f9 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e1:	74 1b                	je     8007fe <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e6:	8b 52 18             	mov    0x18(%edx),%edx
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 32                	je     80081f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	50                   	push   %eax
  8007f4:	ff d2                	call   *%edx
  8007f6:	83 c4 10             	add    $0x10,%esp
}
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fe:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800803:	8b 40 48             	mov    0x48(%eax),%eax
  800806:	83 ec 04             	sub    $0x4,%esp
  800809:	53                   	push   %ebx
  80080a:	50                   	push   %eax
  80080b:	68 38 1e 80 00       	push   $0x801e38
  800810:	e8 f6 08 00 00       	call   80110b <cprintf>
		return -E_INVAL;
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081d:	eb da                	jmp    8007f9 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800824:	eb d3                	jmp    8007f9 <ftruncate+0x52>

00800826 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	83 ec 14             	sub    $0x14,%esp
  80082d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800830:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	e8 81 fb ff ff       	call   8003bd <fd_lookup>
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	78 4b                	js     80088e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	ff 30                	pushl  (%eax)
  80084f:	e8 bf fb ff ff       	call   800413 <dev_lookup>
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	85 c0                	test   %eax,%eax
  800859:	78 33                	js     80088e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800862:	74 2f                	je     800893 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800864:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800867:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086e:	00 00 00 
	stat->st_isdir = 0;
  800871:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800878:	00 00 00 
	stat->st_dev = dev;
  80087b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	53                   	push   %ebx
  800885:	ff 75 f0             	pushl  -0x10(%ebp)
  800888:	ff 50 14             	call   *0x14(%eax)
  80088b:	83 c4 10             	add    $0x10,%esp
}
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    
		return -E_NOT_SUPP;
  800893:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800898:	eb f4                	jmp    80088e <fstat+0x68>

0080089a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	6a 00                	push   $0x0
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 e7 01 00 00       	call   800a93 <open>
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 1b                	js     8008d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	ff 75 0c             	pushl  0xc(%ebp)
  8008bb:	50                   	push   %eax
  8008bc:	e8 65 ff ff ff       	call   800826 <fstat>
  8008c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c3:	89 1c 24             	mov    %ebx,(%esp)
  8008c6:	e8 27 fc ff ff       	call   8004f2 <close>
	return r;
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	89 f3                	mov    %esi,%ebx
}
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e9:	74 27                	je     800912 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008eb:	6a 07                	push   $0x7
  8008ed:	68 00 50 80 00       	push   $0x805000
  8008f2:	56                   	push   %esi
  8008f3:	ff 35 00 40 80 00    	pushl  0x804000
  8008f9:	e8 ca 11 00 00       	call   801ac8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fe:	83 c4 0c             	add    $0xc,%esp
  800901:	6a 00                	push   $0x0
  800903:	53                   	push   %ebx
  800904:	6a 00                	push   $0x0
  800906:	e8 5c 11 00 00       	call   801a67 <ipc_recv>
}
  80090b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	6a 01                	push   $0x1
  800917:	e8 f9 11 00 00       	call   801b15 <ipc_find_env>
  80091c:	a3 00 40 80 00       	mov    %eax,0x804000
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb c5                	jmp    8008eb <fsipc+0x12>

00800926 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 40 0c             	mov    0xc(%eax),%eax
  800932:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093f:	ba 00 00 00 00       	mov    $0x0,%edx
  800944:	b8 02 00 00 00       	mov    $0x2,%eax
  800949:	e8 8b ff ff ff       	call   8008d9 <fsipc>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <devfile_flush>:
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 40 0c             	mov    0xc(%eax),%eax
  80095c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800961:	ba 00 00 00 00       	mov    $0x0,%edx
  800966:	b8 06 00 00 00       	mov    $0x6,%eax
  80096b:	e8 69 ff ff ff       	call   8008d9 <fsipc>
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <devfile_stat>:
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	83 ec 04             	sub    $0x4,%esp
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 40 0c             	mov    0xc(%eax),%eax
  800982:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
  80098c:	b8 05 00 00 00       	mov    $0x5,%eax
  800991:	e8 43 ff ff ff       	call   8008d9 <fsipc>
  800996:	85 c0                	test   %eax,%eax
  800998:	78 2c                	js     8009c6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	68 00 50 80 00       	push   $0x805000
  8009a2:	53                   	push   %ebx
  8009a3:	e8 82 0d 00 00       	call   80172a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_write>:
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009de:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e7:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009ed:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8009f2:	50                   	push   %eax
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	68 08 50 80 00       	push   $0x805008
  8009fb:	e8 b8 0e 00 00       	call   8018b8 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0a:	e8 ca fe ff ff       	call   8008d9 <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_read>:
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a24:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a34:	e8 a0 fe ff ff       	call   8008d9 <fsipc>
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 1f                	js     800a5e <devfile_read+0x4d>
	assert(r <= n);
  800a3f:	39 f0                	cmp    %esi,%eax
  800a41:	77 24                	ja     800a67 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a43:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a48:	7f 33                	jg     800a7d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4a:	83 ec 04             	sub    $0x4,%esp
  800a4d:	50                   	push   %eax
  800a4e:	68 00 50 80 00       	push   $0x805000
  800a53:	ff 75 0c             	pushl  0xc(%ebp)
  800a56:	e8 5d 0e 00 00       	call   8018b8 <memmove>
	return r;
  800a5b:	83 c4 10             	add    $0x10,%esp
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    
	assert(r <= n);
  800a67:	68 a4 1e 80 00       	push   $0x801ea4
  800a6c:	68 ab 1e 80 00       	push   $0x801eab
  800a71:	6a 7d                	push   $0x7d
  800a73:	68 c0 1e 80 00       	push   $0x801ec0
  800a78:	e8 b3 05 00 00       	call   801030 <_panic>
	assert(r <= PGSIZE);
  800a7d:	68 cb 1e 80 00       	push   $0x801ecb
  800a82:	68 ab 1e 80 00       	push   $0x801eab
  800a87:	6a 7e                	push   $0x7e
  800a89:	68 c0 1e 80 00       	push   $0x801ec0
  800a8e:	e8 9d 05 00 00       	call   801030 <_panic>

00800a93 <open>:
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 1c             	sub    $0x1c,%esp
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9e:	56                   	push   %esi
  800a9f:	e8 4f 0c 00 00       	call   8016f3 <strlen>
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aac:	0f 8f 96 00 00 00    	jg     800b48 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ab2:	83 ec 0c             	sub    $0xc,%esp
  800ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab8:	50                   	push   %eax
  800ab9:	e8 b0 f8 ff ff       	call   80036e <fd_alloc>
  800abe:	89 c3                	mov    %eax,%ebx
  800ac0:	83 c4 10             	add    $0x10,%esp
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	78 66                	js     800b2d <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800ac7:	83 ec 08             	sub    $0x8,%esp
  800aca:	56                   	push   %esi
  800acb:	68 00 50 80 00       	push   $0x805000
  800ad0:	e8 55 0c 00 00       	call   80172a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800add:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae5:	e8 ef fd ff ff       	call   8008d9 <fsipc>
  800aea:	89 c3                	mov    %eax,%ebx
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 43                	js     800b36 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	ff 75 f4             	pushl  -0xc(%ebp)
  800af9:	e8 49 f8 ff ff       	call   800347 <fd2num>
  800afe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b01:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b07:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b0a:	83 c4 08             	add    $0x8,%esp
  800b0d:	50                   	push   %eax
  800b0e:	52                   	push   %edx
  800b0f:	ff 32                	pushl  (%edx)
  800b11:	56                   	push   %esi
  800b12:	51                   	push   %ecx
  800b13:	68 d8 1e 80 00       	push   $0x801ed8
  800b18:	e8 ee 05 00 00       	call   80110b <cprintf>
	return fd2num(fd);
  800b1d:	83 c4 14             	add    $0x14,%esp
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 1f f8 ff ff       	call   800347 <fd2num>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	83 c4 10             	add    $0x10,%esp
}
  800b2d:	89 d8                	mov    %ebx,%eax
  800b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
		fd_close(fd, 0);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	6a 00                	push   $0x0
  800b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3e:	e8 26 f9 ff ff       	call   800469 <fd_close>
		return r;
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	eb e5                	jmp    800b2d <open+0x9a>
		return -E_BAD_PATH;
  800b48:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4d:	eb de                	jmp    800b2d <open+0x9a>

00800b4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5f:	e8 75 fd ff ff       	call   8008d9 <fsipc>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 08             	pushl  0x8(%ebp)
  800b74:	e8 de f7 ff ff       	call   800357 <fd2data>
  800b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7b:	83 c4 08             	add    $0x8,%esp
  800b7e:	68 17 1f 80 00       	push   $0x801f17
  800b83:	53                   	push   %ebx
  800b84:	e8 a1 0b 00 00       	call   80172a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b89:	8b 46 04             	mov    0x4(%esi),%eax
  800b8c:	2b 06                	sub    (%esi),%eax
  800b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9b:	00 00 00 
	stat->st_dev = &devpipe;
  800b9e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba5:	30 80 00 
	return 0;
}
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbe:	53                   	push   %ebx
  800bbf:	6a 00                	push   $0x0
  800bc1:	e8 15 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc6:	89 1c 24             	mov    %ebx,(%esp)
  800bc9:	e8 89 f7 ff ff       	call   800357 <fd2data>
  800bce:	83 c4 08             	add    $0x8,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 02 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <_pipeisclosed>:
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	89 c7                	mov    %eax,%edi
  800be9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800beb:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	57                   	push   %edi
  800bf7:	e8 52 0f 00 00       	call   801b4e <pageref>
  800bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bff:	89 34 24             	mov    %esi,(%esp)
  800c02:	e8 47 0f 00 00       	call   801b4e <pageref>
		nn = thisenv->env_runs;
  800c07:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	39 cb                	cmp    %ecx,%ebx
  800c15:	74 1b                	je     800c32 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c17:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1a:	75 cf                	jne    800beb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1c:	8b 42 58             	mov    0x58(%edx),%eax
  800c1f:	6a 01                	push   $0x1
  800c21:	50                   	push   %eax
  800c22:	53                   	push   %ebx
  800c23:	68 1e 1f 80 00       	push   $0x801f1e
  800c28:	e8 de 04 00 00       	call   80110b <cprintf>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	eb b9                	jmp    800beb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c32:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c35:	0f 94 c0             	sete   %al
  800c38:	0f b6 c0             	movzbl %al,%eax
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <devpipe_write>:
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 28             	sub    $0x28,%esp
  800c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c4f:	56                   	push   %esi
  800c50:	e8 02 f7 ff ff       	call   800357 <fd2data>
  800c55:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c62:	74 4f                	je     800cb3 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c64:	8b 43 04             	mov    0x4(%ebx),%eax
  800c67:	8b 0b                	mov    (%ebx),%ecx
  800c69:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6c:	39 d0                	cmp    %edx,%eax
  800c6e:	72 14                	jb     800c84 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c70:	89 da                	mov    %ebx,%edx
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	e8 65 ff ff ff       	call   800bde <_pipeisclosed>
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	75 3a                	jne    800cb7 <devpipe_write+0x74>
			sys_yield();
  800c7d:	e8 b5 f4 ff ff       	call   800137 <sys_yield>
  800c82:	eb e0                	jmp    800c64 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8e:	89 c2                	mov    %eax,%edx
  800c90:	c1 fa 1f             	sar    $0x1f,%edx
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	c1 e9 1b             	shr    $0x1b,%ecx
  800c98:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9b:	83 e2 1f             	and    $0x1f,%edx
  800c9e:	29 ca                	sub    %ecx,%edx
  800ca0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca8:	83 c0 01             	add    $0x1,%eax
  800cab:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cae:	83 c7 01             	add    $0x1,%edi
  800cb1:	eb ac                	jmp    800c5f <devpipe_write+0x1c>
	return i;
  800cb3:	89 f8                	mov    %edi,%eax
  800cb5:	eb 05                	jmp    800cbc <devpipe_write+0x79>
				return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <devpipe_read>:
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 18             	sub    $0x18,%esp
  800ccd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd0:	57                   	push   %edi
  800cd1:	e8 81 f6 ff ff       	call   800357 <fd2data>
  800cd6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce3:	74 47                	je     800d2c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ce5:	8b 03                	mov    (%ebx),%eax
  800ce7:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cea:	75 22                	jne    800d0e <devpipe_read+0x4a>
			if (i > 0)
  800cec:	85 f6                	test   %esi,%esi
  800cee:	75 14                	jne    800d04 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cf0:	89 da                	mov    %ebx,%edx
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	e8 e5 fe ff ff       	call   800bde <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	75 33                	jne    800d30 <devpipe_read+0x6c>
			sys_yield();
  800cfd:	e8 35 f4 ff ff       	call   800137 <sys_yield>
  800d02:	eb e1                	jmp    800ce5 <devpipe_read+0x21>
				return i;
  800d04:	89 f0                	mov    %esi,%eax
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0e:	99                   	cltd   
  800d0f:	c1 ea 1b             	shr    $0x1b,%edx
  800d12:	01 d0                	add    %edx,%eax
  800d14:	83 e0 1f             	and    $0x1f,%eax
  800d17:	29 d0                	sub    %edx,%eax
  800d19:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d24:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d27:	83 c6 01             	add    $0x1,%esi
  800d2a:	eb b4                	jmp    800ce0 <devpipe_read+0x1c>
	return i;
  800d2c:	89 f0                	mov    %esi,%eax
  800d2e:	eb d6                	jmp    800d06 <devpipe_read+0x42>
				return 0;
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  800d35:	eb cf                	jmp    800d06 <devpipe_read+0x42>

00800d37 <pipe>:
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d42:	50                   	push   %eax
  800d43:	e8 26 f6 ff ff       	call   80036e <fd_alloc>
  800d48:	89 c3                	mov    %eax,%ebx
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 5b                	js     800dac <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 07 04 00 00       	push   $0x407
  800d59:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5c:	6a 00                	push   $0x0
  800d5e:	e8 f3 f3 ff ff       	call   800156 <sys_page_alloc>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 40                	js     800dac <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d72:	50                   	push   %eax
  800d73:	e8 f6 f5 ff ff       	call   80036e <fd_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	78 1b                	js     800d9c <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 07 04 00 00       	push   $0x407
  800d89:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8c:	6a 00                	push   $0x0
  800d8e:	e8 c3 f3 ff ff       	call   800156 <sys_page_alloc>
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	79 19                	jns    800db5 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d9c:	83 ec 08             	sub    $0x8,%esp
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	6a 00                	push   $0x0
  800da4:	e8 32 f4 ff ff       	call   8001db <sys_page_unmap>
  800da9:	83 c4 10             	add    $0x10,%esp
}
  800dac:	89 d8                	mov    %ebx,%eax
  800dae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
	va = fd2data(fd0);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbb:	e8 97 f5 ff ff       	call   800357 <fd2data>
  800dc0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc2:	83 c4 0c             	add    $0xc,%esp
  800dc5:	68 07 04 00 00       	push   $0x407
  800dca:	50                   	push   %eax
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 84 f3 ff ff       	call   800156 <sys_page_alloc>
  800dd2:	89 c3                	mov    %eax,%ebx
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	0f 88 8c 00 00 00    	js     800e6b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	ff 75 f0             	pushl  -0x10(%ebp)
  800de5:	e8 6d f5 ff ff       	call   800357 <fd2data>
  800dea:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df1:	50                   	push   %eax
  800df2:	6a 00                	push   $0x0
  800df4:	56                   	push   %esi
  800df5:	6a 00                	push   $0x0
  800df7:	e8 9d f3 ff ff       	call   800199 <sys_page_map>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	83 c4 20             	add    $0x20,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	78 58                	js     800e5d <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e23:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	ff 75 f4             	pushl  -0xc(%ebp)
  800e35:	e8 0d f5 ff ff       	call   800347 <fd2num>
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3f:	83 c4 04             	add    $0x4,%esp
  800e42:	ff 75 f0             	pushl  -0x10(%ebp)
  800e45:	e8 fd f4 ff ff       	call   800347 <fd2num>
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	e9 4f ff ff ff       	jmp    800dac <pipe+0x75>
	sys_page_unmap(0, va);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	56                   	push   %esi
  800e61:	6a 00                	push   $0x0
  800e63:	e8 73 f3 ff ff       	call   8001db <sys_page_unmap>
  800e68:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e71:	6a 00                	push   $0x0
  800e73:	e8 63 f3 ff ff       	call   8001db <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	e9 1c ff ff ff       	jmp    800d9c <pipe+0x65>

00800e80 <pipeisclosed>:
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e89:	50                   	push   %eax
  800e8a:	ff 75 08             	pushl  0x8(%ebp)
  800e8d:	e8 2b f5 ff ff       	call   8003bd <fd_lookup>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 18                	js     800eb1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9f:	e8 b3 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea9:	e8 30 fd ff ff       	call   800bde <_pipeisclosed>
  800eae:	83 c4 10             	add    $0x10,%esp
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec3:	68 36 1f 80 00       	push   $0x801f36
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	e8 5a 08 00 00       	call   80172a <strcpy>
	return 0;
}
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <devcons_write>:
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eee:	eb 2f                	jmp    800f1f <devcons_write+0x48>
		m = n - tot;
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	29 f3                	sub    %esi,%ebx
  800ef5:	83 fb 7f             	cmp    $0x7f,%ebx
  800ef8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800efd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	53                   	push   %ebx
  800f04:	89 f0                	mov    %esi,%eax
  800f06:	03 45 0c             	add    0xc(%ebp),%eax
  800f09:	50                   	push   %eax
  800f0a:	57                   	push   %edi
  800f0b:	e8 a8 09 00 00       	call   8018b8 <memmove>
		sys_cputs(buf, m);
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	53                   	push   %ebx
  800f14:	57                   	push   %edi
  800f15:	e8 80 f1 ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f1a:	01 de                	add    %ebx,%esi
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f22:	72 cc                	jb     800ef0 <devcons_write+0x19>
}
  800f24:	89 f0                	mov    %esi,%eax
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <devcons_read>:
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3d:	75 07                	jne    800f46 <devcons_read+0x18>
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    
		sys_yield();
  800f41:	e8 f1 f1 ff ff       	call   800137 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f46:	e8 6d f1 ff ff       	call   8000b8 <sys_cgetc>
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	74 f2                	je     800f41 <devcons_read+0x13>
	if (c < 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 ec                	js     800f3f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f53:	83 f8 04             	cmp    $0x4,%eax
  800f56:	74 0c                	je     800f64 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5b:	88 02                	mov    %al,(%edx)
	return 1;
  800f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f62:	eb db                	jmp    800f3f <devcons_read+0x11>
		return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	eb d4                	jmp    800f3f <devcons_read+0x11>

00800f6b <cputchar>:
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f77:	6a 01                	push   $0x1
  800f79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7c:	50                   	push   %eax
  800f7d:	e8 18 f1 ff ff       	call   80009a <sys_cputs>
}
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <getchar>:
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f8d:	6a 01                	push   $0x1
  800f8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f92:	50                   	push   %eax
  800f93:	6a 00                	push   $0x0
  800f95:	e8 94 f6 ff ff       	call   80062e <read>
	if (r < 0)
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 08                	js     800fa9 <getchar+0x22>
	if (r < 1)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 06                	jle    800fab <getchar+0x24>
	return c;
  800fa5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    
		return -E_EOF;
  800fab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb0:	eb f7                	jmp    800fa9 <getchar+0x22>

00800fb2 <iscons>:
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	ff 75 08             	pushl  0x8(%ebp)
  800fbf:	e8 f9 f3 ff ff       	call   8003bd <fd_lookup>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 11                	js     800fdc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd4:	39 10                	cmp    %edx,(%eax)
  800fd6:	0f 94 c0             	sete   %al
  800fd9:	0f b6 c0             	movzbl %al,%eax
}
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <opencons>:
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	e8 81 f3 ff ff       	call   80036e <fd_alloc>
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 3a                	js     80102e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	68 07 04 00 00       	push   $0x407
  800ffc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fff:	6a 00                	push   $0x0
  801001:	e8 50 f1 ff ff       	call   800156 <sys_page_alloc>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 21                	js     80102e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801016:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	50                   	push   %eax
  801026:	e8 1c f3 ff ff       	call   800347 <fd2num>
  80102b:	83 c4 10             	add    $0x10,%esp
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801035:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801038:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103e:	e8 d5 f0 ff ff       	call   800118 <sys_getenvid>
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 0c             	pushl  0xc(%ebp)
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	56                   	push   %esi
  80104d:	50                   	push   %eax
  80104e:	68 44 1f 80 00       	push   $0x801f44
  801053:	e8 b3 00 00 00       	call   80110b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801058:	83 c4 18             	add    $0x18,%esp
  80105b:	53                   	push   %ebx
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	e8 56 00 00 00       	call   8010ba <vcprintf>
	cprintf("\n");
  801064:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80106b:	e8 9b 00 00 00       	call   80110b <cprintf>
  801070:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801073:	cc                   	int3   
  801074:	eb fd                	jmp    801073 <_panic+0x43>

00801076 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801080:	8b 13                	mov    (%ebx),%edx
  801082:	8d 42 01             	lea    0x1(%edx),%eax
  801085:	89 03                	mov    %eax,(%ebx)
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801093:	74 09                	je     80109e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801095:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	68 ff 00 00 00       	push   $0xff
  8010a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a9:	50                   	push   %eax
  8010aa:	e8 eb ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	eb db                	jmp    801095 <putch+0x1f>

008010ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ca:	00 00 00 
	b.cnt = 0;
  8010cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d7:	ff 75 0c             	pushl  0xc(%ebp)
  8010da:	ff 75 08             	pushl  0x8(%ebp)
  8010dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	68 76 10 80 00       	push   $0x801076
  8010e9:	e8 1a 01 00 00       	call   801208 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 97 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801103:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801111:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801114:	50                   	push   %eax
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	e8 9d ff ff ff       	call   8010ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 1c             	sub    $0x1c,%esp
  801128:	89 c7                	mov    %eax,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801132:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801135:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801138:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801143:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801146:	39 d3                	cmp    %edx,%ebx
  801148:	72 05                	jb     80114f <printnum+0x30>
  80114a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114d:	77 7a                	ja     8011c9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	ff 75 18             	pushl  0x18(%ebp)
  801155:	8b 45 14             	mov    0x14(%ebp),%eax
  801158:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115b:	53                   	push   %ebx
  80115c:	ff 75 10             	pushl  0x10(%ebp)
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	ff 75 e4             	pushl  -0x1c(%ebp)
  801165:	ff 75 e0             	pushl  -0x20(%ebp)
  801168:	ff 75 dc             	pushl  -0x24(%ebp)
  80116b:	ff 75 d8             	pushl  -0x28(%ebp)
  80116e:	e8 1d 0a 00 00       	call   801b90 <__udivdi3>
  801173:	83 c4 18             	add    $0x18,%esp
  801176:	52                   	push   %edx
  801177:	50                   	push   %eax
  801178:	89 f2                	mov    %esi,%edx
  80117a:	89 f8                	mov    %edi,%eax
  80117c:	e8 9e ff ff ff       	call   80111f <printnum>
  801181:	83 c4 20             	add    $0x20,%esp
  801184:	eb 13                	jmp    801199 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	56                   	push   %esi
  80118a:	ff 75 18             	pushl  0x18(%ebp)
  80118d:	ff d7                	call   *%edi
  80118f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801192:	83 eb 01             	sub    $0x1,%ebx
  801195:	85 db                	test   %ebx,%ebx
  801197:	7f ed                	jg     801186 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	56                   	push   %esi
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ac:	e8 ff 0a 00 00       	call   801cb0 <__umoddi3>
  8011b1:	83 c4 14             	add    $0x14,%esp
  8011b4:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff d7                	call   *%edi
}
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
  8011c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011cc:	eb c4                	jmp    801192 <printnum+0x73>

008011ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d8:	8b 10                	mov    (%eax),%edx
  8011da:	3b 50 04             	cmp    0x4(%eax),%edx
  8011dd:	73 0a                	jae    8011e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e2:	89 08                	mov    %ecx,(%eax)
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	88 02                	mov    %al,(%edx)
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <printfmt>:
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f4:	50                   	push   %eax
  8011f5:	ff 75 10             	pushl  0x10(%ebp)
  8011f8:	ff 75 0c             	pushl  0xc(%ebp)
  8011fb:	ff 75 08             	pushl  0x8(%ebp)
  8011fe:	e8 05 00 00 00       	call   801208 <vprintfmt>
}
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <vprintfmt>:
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 2c             	sub    $0x2c,%esp
  801211:	8b 75 08             	mov    0x8(%ebp),%esi
  801214:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801217:	8b 7d 10             	mov    0x10(%ebp),%edi
  80121a:	e9 c1 03 00 00       	jmp    8015e0 <vprintfmt+0x3d8>
		padc = ' ';
  80121f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801223:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80122a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801231:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801238:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80123d:	8d 47 01             	lea    0x1(%edi),%eax
  801240:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801243:	0f b6 17             	movzbl (%edi),%edx
  801246:	8d 42 dd             	lea    -0x23(%edx),%eax
  801249:	3c 55                	cmp    $0x55,%al
  80124b:	0f 87 12 04 00 00    	ja     801663 <vprintfmt+0x45b>
  801251:	0f b6 c0             	movzbl %al,%eax
  801254:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80125b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80125e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801262:	eb d9                	jmp    80123d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801264:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801267:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80126b:	eb d0                	jmp    80123d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80126d:	0f b6 d2             	movzbl %dl,%edx
  801270:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80127b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80127e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801282:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801285:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801288:	83 f9 09             	cmp    $0x9,%ecx
  80128b:	77 55                	ja     8012e2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80128d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801290:	eb e9                	jmp    80127b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801292:	8b 45 14             	mov    0x14(%ebp),%eax
  801295:	8b 00                	mov    (%eax),%eax
  801297:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80129a:	8b 45 14             	mov    0x14(%ebp),%eax
  80129d:	8d 40 04             	lea    0x4(%eax),%eax
  8012a0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012aa:	79 91                	jns    80123d <vprintfmt+0x35>
				width = precision, precision = -1;
  8012ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b9:	eb 82                	jmp    80123d <vprintfmt+0x35>
  8012bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c5:	0f 49 d0             	cmovns %eax,%edx
  8012c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ce:	e9 6a ff ff ff       	jmp    80123d <vprintfmt+0x35>
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012dd:	e9 5b ff ff ff       	jmp    80123d <vprintfmt+0x35>
  8012e2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012e8:	eb bc                	jmp    8012a6 <vprintfmt+0x9e>
			lflag++;
  8012ea:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012f0:	e9 48 ff ff ff       	jmp    80123d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f8:	8d 78 04             	lea    0x4(%eax),%edi
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	53                   	push   %ebx
  8012ff:	ff 30                	pushl  (%eax)
  801301:	ff d6                	call   *%esi
			break;
  801303:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801306:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801309:	e9 cf 02 00 00       	jmp    8015dd <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80130e:	8b 45 14             	mov    0x14(%ebp),%eax
  801311:	8d 78 04             	lea    0x4(%eax),%edi
  801314:	8b 00                	mov    (%eax),%eax
  801316:	99                   	cltd   
  801317:	31 d0                	xor    %edx,%eax
  801319:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131b:	83 f8 0f             	cmp    $0xf,%eax
  80131e:	7f 23                	jg     801343 <vprintfmt+0x13b>
  801320:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 18                	je     801343 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80132b:	52                   	push   %edx
  80132c:	68 bd 1e 80 00       	push   $0x801ebd
  801331:	53                   	push   %ebx
  801332:	56                   	push   %esi
  801333:	e8 b3 fe ff ff       	call   8011eb <printfmt>
  801338:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80133b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80133e:	e9 9a 02 00 00       	jmp    8015dd <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801343:	50                   	push   %eax
  801344:	68 7f 1f 80 00       	push   $0x801f7f
  801349:	53                   	push   %ebx
  80134a:	56                   	push   %esi
  80134b:	e8 9b fe ff ff       	call   8011eb <printfmt>
  801350:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801353:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801356:	e9 82 02 00 00       	jmp    8015dd <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80135b:	8b 45 14             	mov    0x14(%ebp),%eax
  80135e:	83 c0 04             	add    $0x4,%eax
  801361:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801364:	8b 45 14             	mov    0x14(%ebp),%eax
  801367:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801369:	85 ff                	test   %edi,%edi
  80136b:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801370:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801377:	0f 8e bd 00 00 00    	jle    80143a <vprintfmt+0x232>
  80137d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801381:	75 0e                	jne    801391 <vprintfmt+0x189>
  801383:	89 75 08             	mov    %esi,0x8(%ebp)
  801386:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801389:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80138c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80138f:	eb 6d                	jmp    8013fe <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	ff 75 d0             	pushl  -0x30(%ebp)
  801397:	57                   	push   %edi
  801398:	e8 6e 03 00 00       	call   80170b <strnlen>
  80139d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a0:	29 c1                	sub    %eax,%ecx
  8013a2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013a8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b4:	eb 0f                	jmp    8013c5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8013bd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bf:	83 ef 01             	sub    $0x1,%edi
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 ff                	test   %edi,%edi
  8013c7:	7f ed                	jg     8013b6 <vprintfmt+0x1ae>
  8013c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013cf:	85 c9                	test   %ecx,%ecx
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d6:	0f 49 c1             	cmovns %ecx,%eax
  8013d9:	29 c1                	sub    %eax,%ecx
  8013db:	89 75 08             	mov    %esi,0x8(%ebp)
  8013de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e4:	89 cb                	mov    %ecx,%ebx
  8013e6:	eb 16                	jmp    8013fe <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ec:	75 31                	jne    80141f <vprintfmt+0x217>
					putch(ch, putdat);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 0c             	pushl  0xc(%ebp)
  8013f4:	50                   	push   %eax
  8013f5:	ff 55 08             	call   *0x8(%ebp)
  8013f8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013fb:	83 eb 01             	sub    $0x1,%ebx
  8013fe:	83 c7 01             	add    $0x1,%edi
  801401:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801405:	0f be c2             	movsbl %dl,%eax
  801408:	85 c0                	test   %eax,%eax
  80140a:	74 59                	je     801465 <vprintfmt+0x25d>
  80140c:	85 f6                	test   %esi,%esi
  80140e:	78 d8                	js     8013e8 <vprintfmt+0x1e0>
  801410:	83 ee 01             	sub    $0x1,%esi
  801413:	79 d3                	jns    8013e8 <vprintfmt+0x1e0>
  801415:	89 df                	mov    %ebx,%edi
  801417:	8b 75 08             	mov    0x8(%ebp),%esi
  80141a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80141d:	eb 37                	jmp    801456 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80141f:	0f be d2             	movsbl %dl,%edx
  801422:	83 ea 20             	sub    $0x20,%edx
  801425:	83 fa 5e             	cmp    $0x5e,%edx
  801428:	76 c4                	jbe    8013ee <vprintfmt+0x1e6>
					putch('?', putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	ff 75 0c             	pushl  0xc(%ebp)
  801430:	6a 3f                	push   $0x3f
  801432:	ff 55 08             	call   *0x8(%ebp)
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	eb c1                	jmp    8013fb <vprintfmt+0x1f3>
  80143a:	89 75 08             	mov    %esi,0x8(%ebp)
  80143d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801440:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801443:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801446:	eb b6                	jmp    8013fe <vprintfmt+0x1f6>
				putch(' ', putdat);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	53                   	push   %ebx
  80144c:	6a 20                	push   $0x20
  80144e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801450:	83 ef 01             	sub    $0x1,%edi
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 ff                	test   %edi,%edi
  801458:	7f ee                	jg     801448 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80145a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80145d:	89 45 14             	mov    %eax,0x14(%ebp)
  801460:	e9 78 01 00 00       	jmp    8015dd <vprintfmt+0x3d5>
  801465:	89 df                	mov    %ebx,%edi
  801467:	8b 75 08             	mov    0x8(%ebp),%esi
  80146a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146d:	eb e7                	jmp    801456 <vprintfmt+0x24e>
	if (lflag >= 2)
  80146f:	83 f9 01             	cmp    $0x1,%ecx
  801472:	7e 3f                	jle    8014b3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801474:	8b 45 14             	mov    0x14(%ebp),%eax
  801477:	8b 50 04             	mov    0x4(%eax),%edx
  80147a:	8b 00                	mov    (%eax),%eax
  80147c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80147f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801482:	8b 45 14             	mov    0x14(%ebp),%eax
  801485:	8d 40 08             	lea    0x8(%eax),%eax
  801488:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80148b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80148f:	79 5c                	jns    8014ed <vprintfmt+0x2e5>
				putch('-', putdat);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	53                   	push   %ebx
  801495:	6a 2d                	push   $0x2d
  801497:	ff d6                	call   *%esi
				num = -(long long) num;
  801499:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80149c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80149f:	f7 da                	neg    %edx
  8014a1:	83 d1 00             	adc    $0x0,%ecx
  8014a4:	f7 d9                	neg    %ecx
  8014a6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ae:	e9 10 01 00 00       	jmp    8015c3 <vprintfmt+0x3bb>
	else if (lflag)
  8014b3:	85 c9                	test   %ecx,%ecx
  8014b5:	75 1b                	jne    8014d2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8b 00                	mov    (%eax),%eax
  8014bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bf:	89 c1                	mov    %eax,%ecx
  8014c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ca:	8d 40 04             	lea    0x4(%eax),%eax
  8014cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d0:	eb b9                	jmp    80148b <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014da:	89 c1                	mov    %eax,%ecx
  8014dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8d 40 04             	lea    0x4(%eax),%eax
  8014e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014eb:	eb 9e                	jmp    80148b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f8:	e9 c6 00 00 00       	jmp    8015c3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014fd:	83 f9 01             	cmp    $0x1,%ecx
  801500:	7e 18                	jle    80151a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	8b 10                	mov    (%eax),%edx
  801507:	8b 48 04             	mov    0x4(%eax),%ecx
  80150a:	8d 40 08             	lea    0x8(%eax),%eax
  80150d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801510:	b8 0a 00 00 00       	mov    $0xa,%eax
  801515:	e9 a9 00 00 00       	jmp    8015c3 <vprintfmt+0x3bb>
	else if (lflag)
  80151a:	85 c9                	test   %ecx,%ecx
  80151c:	75 1a                	jne    801538 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 10                	mov    (%eax),%edx
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	8d 40 04             	lea    0x4(%eax),%eax
  80152b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80152e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801533:	e9 8b 00 00 00       	jmp    8015c3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801538:	8b 45 14             	mov    0x14(%ebp),%eax
  80153b:	8b 10                	mov    (%eax),%edx
  80153d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801542:	8d 40 04             	lea    0x4(%eax),%eax
  801545:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154d:	eb 74                	jmp    8015c3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80154f:	83 f9 01             	cmp    $0x1,%ecx
  801552:	7e 15                	jle    801569 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801554:	8b 45 14             	mov    0x14(%ebp),%eax
  801557:	8b 10                	mov    (%eax),%edx
  801559:	8b 48 04             	mov    0x4(%eax),%ecx
  80155c:	8d 40 08             	lea    0x8(%eax),%eax
  80155f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801562:	b8 08 00 00 00       	mov    $0x8,%eax
  801567:	eb 5a                	jmp    8015c3 <vprintfmt+0x3bb>
	else if (lflag)
  801569:	85 c9                	test   %ecx,%ecx
  80156b:	75 17                	jne    801584 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80156d:	8b 45 14             	mov    0x14(%ebp),%eax
  801570:	8b 10                	mov    (%eax),%edx
  801572:	b9 00 00 00 00       	mov    $0x0,%ecx
  801577:	8d 40 04             	lea    0x4(%eax),%eax
  80157a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80157d:	b8 08 00 00 00       	mov    $0x8,%eax
  801582:	eb 3f                	jmp    8015c3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801584:	8b 45 14             	mov    0x14(%ebp),%eax
  801587:	8b 10                	mov    (%eax),%edx
  801589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158e:	8d 40 04             	lea    0x4(%eax),%eax
  801591:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801594:	b8 08 00 00 00       	mov    $0x8,%eax
  801599:	eb 28                	jmp    8015c3 <vprintfmt+0x3bb>
			putch('0', putdat);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	53                   	push   %ebx
  80159f:	6a 30                	push   $0x30
  8015a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 78                	push   $0x78
  8015a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ae:	8b 10                	mov    (%eax),%edx
  8015b0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015b8:	8d 40 04             	lea    0x4(%eax),%eax
  8015bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015be:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ca:	57                   	push   %edi
  8015cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ce:	50                   	push   %eax
  8015cf:	51                   	push   %ecx
  8015d0:	52                   	push   %edx
  8015d1:	89 da                	mov    %ebx,%edx
  8015d3:	89 f0                	mov    %esi,%eax
  8015d5:	e8 45 fb ff ff       	call   80111f <printnum>
			break;
  8015da:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015e0:	83 c7 01             	add    $0x1,%edi
  8015e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015e7:	83 f8 25             	cmp    $0x25,%eax
  8015ea:	0f 84 2f fc ff ff    	je     80121f <vprintfmt+0x17>
			if (ch == '\0')
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	0f 84 8b 00 00 00    	je     801683 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	50                   	push   %eax
  8015fd:	ff d6                	call   *%esi
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb dc                	jmp    8015e0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801604:	83 f9 01             	cmp    $0x1,%ecx
  801607:	7e 15                	jle    80161e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801609:	8b 45 14             	mov    0x14(%ebp),%eax
  80160c:	8b 10                	mov    (%eax),%edx
  80160e:	8b 48 04             	mov    0x4(%eax),%ecx
  801611:	8d 40 08             	lea    0x8(%eax),%eax
  801614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801617:	b8 10 00 00 00       	mov    $0x10,%eax
  80161c:	eb a5                	jmp    8015c3 <vprintfmt+0x3bb>
	else if (lflag)
  80161e:	85 c9                	test   %ecx,%ecx
  801620:	75 17                	jne    801639 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801622:	8b 45 14             	mov    0x14(%ebp),%eax
  801625:	8b 10                	mov    (%eax),%edx
  801627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80162c:	8d 40 04             	lea    0x4(%eax),%eax
  80162f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801632:	b8 10 00 00 00       	mov    $0x10,%eax
  801637:	eb 8a                	jmp    8015c3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801639:	8b 45 14             	mov    0x14(%ebp),%eax
  80163c:	8b 10                	mov    (%eax),%edx
  80163e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801643:	8d 40 04             	lea    0x4(%eax),%eax
  801646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801649:	b8 10 00 00 00       	mov    $0x10,%eax
  80164e:	e9 70 ff ff ff       	jmp    8015c3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	53                   	push   %ebx
  801657:	6a 25                	push   $0x25
  801659:	ff d6                	call   *%esi
			break;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	e9 7a ff ff ff       	jmp    8015dd <vprintfmt+0x3d5>
			putch('%', putdat);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	6a 25                	push   $0x25
  801669:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	89 f8                	mov    %edi,%eax
  801670:	eb 03                	jmp    801675 <vprintfmt+0x46d>
  801672:	83 e8 01             	sub    $0x1,%eax
  801675:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801679:	75 f7                	jne    801672 <vprintfmt+0x46a>
  80167b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80167e:	e9 5a ff ff ff       	jmp    8015dd <vprintfmt+0x3d5>
}
  801683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 18             	sub    $0x18,%esp
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80169a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80169e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	74 26                	je     8016d2 <vsnprintf+0x47>
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	7e 22                	jle    8016d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016b0:	ff 75 14             	pushl  0x14(%ebp)
  8016b3:	ff 75 10             	pushl  0x10(%ebp)
  8016b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	68 ce 11 80 00       	push   $0x8011ce
  8016bf:	e8 44 fb ff ff       	call   801208 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cd:	83 c4 10             	add    $0x10,%esp
}
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    
		return -E_INVAL;
  8016d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d7:	eb f7                	jmp    8016d0 <vsnprintf+0x45>

008016d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 10             	pushl  0x10(%ebp)
  8016e6:	ff 75 0c             	pushl  0xc(%ebp)
  8016e9:	ff 75 08             	pushl  0x8(%ebp)
  8016ec:	e8 9a ff ff ff       	call   80168b <vsnprintf>
	va_end(ap);

	return rc;
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fe:	eb 03                	jmp    801703 <strlen+0x10>
		n++;
  801700:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801703:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801707:	75 f7                	jne    801700 <strlen+0xd>
	return n;
}
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801711:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801714:	b8 00 00 00 00       	mov    $0x0,%eax
  801719:	eb 03                	jmp    80171e <strnlen+0x13>
		n++;
  80171b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171e:	39 d0                	cmp    %edx,%eax
  801720:	74 06                	je     801728 <strnlen+0x1d>
  801722:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801726:	75 f3                	jne    80171b <strnlen+0x10>
	return n;
}
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801734:	89 c2                	mov    %eax,%edx
  801736:	83 c1 01             	add    $0x1,%ecx
  801739:	83 c2 01             	add    $0x1,%edx
  80173c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801740:	88 5a ff             	mov    %bl,-0x1(%edx)
  801743:	84 db                	test   %bl,%bl
  801745:	75 ef                	jne    801736 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801747:	5b                   	pop    %ebx
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801751:	53                   	push   %ebx
  801752:	e8 9c ff ff ff       	call   8016f3 <strlen>
  801757:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80175a:	ff 75 0c             	pushl  0xc(%ebp)
  80175d:	01 d8                	add    %ebx,%eax
  80175f:	50                   	push   %eax
  801760:	e8 c5 ff ff ff       	call   80172a <strcpy>
	return dst;
}
  801765:	89 d8                	mov    %ebx,%eax
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	8b 75 08             	mov    0x8(%ebp),%esi
  801774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801777:	89 f3                	mov    %esi,%ebx
  801779:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177c:	89 f2                	mov    %esi,%edx
  80177e:	eb 0f                	jmp    80178f <strncpy+0x23>
		*dst++ = *src;
  801780:	83 c2 01             	add    $0x1,%edx
  801783:	0f b6 01             	movzbl (%ecx),%eax
  801786:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801789:	80 39 01             	cmpb   $0x1,(%ecx)
  80178c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80178f:	39 da                	cmp    %ebx,%edx
  801791:	75 ed                	jne    801780 <strncpy+0x14>
	}
	return ret;
}
  801793:	89 f0                	mov    %esi,%eax
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a7:	89 f0                	mov    %esi,%eax
  8017a9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017ad:	85 c9                	test   %ecx,%ecx
  8017af:	75 0b                	jne    8017bc <strlcpy+0x23>
  8017b1:	eb 17                	jmp    8017ca <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b3:	83 c2 01             	add    $0x1,%edx
  8017b6:	83 c0 01             	add    $0x1,%eax
  8017b9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017bc:	39 d8                	cmp    %ebx,%eax
  8017be:	74 07                	je     8017c7 <strlcpy+0x2e>
  8017c0:	0f b6 0a             	movzbl (%edx),%ecx
  8017c3:	84 c9                	test   %cl,%cl
  8017c5:	75 ec                	jne    8017b3 <strlcpy+0x1a>
		*dst = '\0';
  8017c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ca:	29 f0                	sub    %esi,%eax
}
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d9:	eb 06                	jmp    8017e1 <strcmp+0x11>
		p++, q++;
  8017db:	83 c1 01             	add    $0x1,%ecx
  8017de:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017e1:	0f b6 01             	movzbl (%ecx),%eax
  8017e4:	84 c0                	test   %al,%al
  8017e6:	74 04                	je     8017ec <strcmp+0x1c>
  8017e8:	3a 02                	cmp    (%edx),%al
  8017ea:	74 ef                	je     8017db <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ec:	0f b6 c0             	movzbl %al,%eax
  8017ef:	0f b6 12             	movzbl (%edx),%edx
  8017f2:	29 d0                	sub    %edx,%eax
}
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801800:	89 c3                	mov    %eax,%ebx
  801802:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801805:	eb 06                	jmp    80180d <strncmp+0x17>
		n--, p++, q++;
  801807:	83 c0 01             	add    $0x1,%eax
  80180a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80180d:	39 d8                	cmp    %ebx,%eax
  80180f:	74 16                	je     801827 <strncmp+0x31>
  801811:	0f b6 08             	movzbl (%eax),%ecx
  801814:	84 c9                	test   %cl,%cl
  801816:	74 04                	je     80181c <strncmp+0x26>
  801818:	3a 0a                	cmp    (%edx),%cl
  80181a:	74 eb                	je     801807 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80181c:	0f b6 00             	movzbl (%eax),%eax
  80181f:	0f b6 12             	movzbl (%edx),%edx
  801822:	29 d0                	sub    %edx,%eax
}
  801824:	5b                   	pop    %ebx
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    
		return 0;
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	eb f6                	jmp    801824 <strncmp+0x2e>

0080182e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801838:	0f b6 10             	movzbl (%eax),%edx
  80183b:	84 d2                	test   %dl,%dl
  80183d:	74 09                	je     801848 <strchr+0x1a>
		if (*s == c)
  80183f:	38 ca                	cmp    %cl,%dl
  801841:	74 0a                	je     80184d <strchr+0x1f>
	for (; *s; s++)
  801843:	83 c0 01             	add    $0x1,%eax
  801846:	eb f0                	jmp    801838 <strchr+0xa>
			return (char *) s;
	return 0;
  801848:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801859:	eb 03                	jmp    80185e <strfind+0xf>
  80185b:	83 c0 01             	add    $0x1,%eax
  80185e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801861:	38 ca                	cmp    %cl,%dl
  801863:	74 04                	je     801869 <strfind+0x1a>
  801865:	84 d2                	test   %dl,%dl
  801867:	75 f2                	jne    80185b <strfind+0xc>
			break;
	return (char *) s;
}
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	57                   	push   %edi
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	8b 7d 08             	mov    0x8(%ebp),%edi
  801874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801877:	85 c9                	test   %ecx,%ecx
  801879:	74 13                	je     80188e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80187b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801881:	75 05                	jne    801888 <memset+0x1d>
  801883:	f6 c1 03             	test   $0x3,%cl
  801886:	74 0d                	je     801895 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	fc                   	cld    
  80188c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188e:	89 f8                	mov    %edi,%eax
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    
		c &= 0xFF;
  801895:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801899:	89 d3                	mov    %edx,%ebx
  80189b:	c1 e3 08             	shl    $0x8,%ebx
  80189e:	89 d0                	mov    %edx,%eax
  8018a0:	c1 e0 18             	shl    $0x18,%eax
  8018a3:	89 d6                	mov    %edx,%esi
  8018a5:	c1 e6 10             	shl    $0x10,%esi
  8018a8:	09 f0                	or     %esi,%eax
  8018aa:	09 c2                	or     %eax,%edx
  8018ac:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018ae:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018b1:	89 d0                	mov    %edx,%eax
  8018b3:	fc                   	cld    
  8018b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8018b6:	eb d6                	jmp    80188e <memset+0x23>

008018b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	57                   	push   %edi
  8018bc:	56                   	push   %esi
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c6:	39 c6                	cmp    %eax,%esi
  8018c8:	73 35                	jae    8018ff <memmove+0x47>
  8018ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018cd:	39 c2                	cmp    %eax,%edx
  8018cf:	76 2e                	jbe    8018ff <memmove+0x47>
		s += n;
		d += n;
  8018d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d4:	89 d6                	mov    %edx,%esi
  8018d6:	09 fe                	or     %edi,%esi
  8018d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018de:	74 0c                	je     8018ec <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018e0:	83 ef 01             	sub    $0x1,%edi
  8018e3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018e6:	fd                   	std    
  8018e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e9:	fc                   	cld    
  8018ea:	eb 21                	jmp    80190d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ec:	f6 c1 03             	test   $0x3,%cl
  8018ef:	75 ef                	jne    8018e0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018f1:	83 ef 04             	sub    $0x4,%edi
  8018f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018f7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018fa:	fd                   	std    
  8018fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fd:	eb ea                	jmp    8018e9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ff:	89 f2                	mov    %esi,%edx
  801901:	09 c2                	or     %eax,%edx
  801903:	f6 c2 03             	test   $0x3,%dl
  801906:	74 09                	je     801911 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801911:	f6 c1 03             	test   $0x3,%cl
  801914:	75 f2                	jne    801908 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801916:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801919:	89 c7                	mov    %eax,%edi
  80191b:	fc                   	cld    
  80191c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80191e:	eb ed                	jmp    80190d <memmove+0x55>

00801920 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801923:	ff 75 10             	pushl  0x10(%ebp)
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	ff 75 08             	pushl  0x8(%ebp)
  80192c:	e8 87 ff ff ff       	call   8018b8 <memmove>
}
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193e:	89 c6                	mov    %eax,%esi
  801940:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801943:	39 f0                	cmp    %esi,%eax
  801945:	74 1c                	je     801963 <memcmp+0x30>
		if (*s1 != *s2)
  801947:	0f b6 08             	movzbl (%eax),%ecx
  80194a:	0f b6 1a             	movzbl (%edx),%ebx
  80194d:	38 d9                	cmp    %bl,%cl
  80194f:	75 08                	jne    801959 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801951:	83 c0 01             	add    $0x1,%eax
  801954:	83 c2 01             	add    $0x1,%edx
  801957:	eb ea                	jmp    801943 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801959:	0f b6 c1             	movzbl %cl,%eax
  80195c:	0f b6 db             	movzbl %bl,%ebx
  80195f:	29 d8                	sub    %ebx,%eax
  801961:	eb 05                	jmp    801968 <memcmp+0x35>
	}

	return 0;
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801975:	89 c2                	mov    %eax,%edx
  801977:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80197a:	39 d0                	cmp    %edx,%eax
  80197c:	73 09                	jae    801987 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197e:	38 08                	cmp    %cl,(%eax)
  801980:	74 05                	je     801987 <memfind+0x1b>
	for (; s < ends; s++)
  801982:	83 c0 01             	add    $0x1,%eax
  801985:	eb f3                	jmp    80197a <memfind+0xe>
			break;
	return (void *) s;
}
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	57                   	push   %edi
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801995:	eb 03                	jmp    80199a <strtol+0x11>
		s++;
  801997:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80199a:	0f b6 01             	movzbl (%ecx),%eax
  80199d:	3c 20                	cmp    $0x20,%al
  80199f:	74 f6                	je     801997 <strtol+0xe>
  8019a1:	3c 09                	cmp    $0x9,%al
  8019a3:	74 f2                	je     801997 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019a5:	3c 2b                	cmp    $0x2b,%al
  8019a7:	74 2e                	je     8019d7 <strtol+0x4e>
	int neg = 0;
  8019a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019ae:	3c 2d                	cmp    $0x2d,%al
  8019b0:	74 2f                	je     8019e1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b8:	75 05                	jne    8019bf <strtol+0x36>
  8019ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bd:	74 2c                	je     8019eb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019bf:	85 db                	test   %ebx,%ebx
  8019c1:	75 0a                	jne    8019cd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cb:	74 28                	je     8019f5 <strtol+0x6c>
		base = 10;
  8019cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019d5:	eb 50                	jmp    801a27 <strtol+0x9e>
		s++;
  8019d7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019da:	bf 00 00 00 00       	mov    $0x0,%edi
  8019df:	eb d1                	jmp    8019b2 <strtol+0x29>
		s++, neg = 1;
  8019e1:	83 c1 01             	add    $0x1,%ecx
  8019e4:	bf 01 00 00 00       	mov    $0x1,%edi
  8019e9:	eb c7                	jmp    8019b2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019eb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ef:	74 0e                	je     8019ff <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f1:	85 db                	test   %ebx,%ebx
  8019f3:	75 d8                	jne    8019cd <strtol+0x44>
		s++, base = 8;
  8019f5:	83 c1 01             	add    $0x1,%ecx
  8019f8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019fd:	eb ce                	jmp    8019cd <strtol+0x44>
		s += 2, base = 16;
  8019ff:	83 c1 02             	add    $0x2,%ecx
  801a02:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a07:	eb c4                	jmp    8019cd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a09:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 29                	ja     801a3c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a19:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1c:	7d 30                	jge    801a4e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a1e:	83 c1 01             	add    $0x1,%ecx
  801a21:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a25:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a27:	0f b6 11             	movzbl (%ecx),%edx
  801a2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a2d:	89 f3                	mov    %esi,%ebx
  801a2f:	80 fb 09             	cmp    $0x9,%bl
  801a32:	77 d5                	ja     801a09 <strtol+0x80>
			dig = *s - '0';
  801a34:	0f be d2             	movsbl %dl,%edx
  801a37:	83 ea 30             	sub    $0x30,%edx
  801a3a:	eb dd                	jmp    801a19 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a3f:	89 f3                	mov    %esi,%ebx
  801a41:	80 fb 19             	cmp    $0x19,%bl
  801a44:	77 08                	ja     801a4e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a46:	0f be d2             	movsbl %dl,%edx
  801a49:	83 ea 37             	sub    $0x37,%edx
  801a4c:	eb cb                	jmp    801a19 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a52:	74 05                	je     801a59 <strtol+0xd0>
		*endptr = (char *) s;
  801a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a57:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	f7 da                	neg    %edx
  801a5d:	85 ff                	test   %edi,%edi
  801a5f:	0f 45 c2             	cmovne %edx,%eax
}
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5f                   	pop    %edi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a75:	85 c0                	test   %eax,%eax
  801a77:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a7c:	0f 44 c2             	cmove  %edx,%eax
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 7e e8 ff ff       	call   800306 <sys_ipc_recv>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 2b                	js     801aba <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a8f:	85 f6                	test   %esi,%esi
  801a91:	74 0a                	je     801a9d <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801a93:	a1 04 40 80 00       	mov    0x804004,%eax
  801a98:	8b 40 74             	mov    0x74(%eax),%eax
  801a9b:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801a9d:	85 db                	test   %ebx,%ebx
  801a9f:	74 0a                	je     801aab <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801aa1:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa6:	8b 40 78             	mov    0x78(%eax),%eax
  801aa9:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801aab:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    
        *from_env_store = 0;
  801aba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ac0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ac6:	eb eb                	jmp    801ab3 <ipc_recv+0x4c>

00801ac8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ada:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801adc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae1:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801ae4:	ff 75 14             	pushl  0x14(%ebp)
  801ae7:	53                   	push   %ebx
  801ae8:	56                   	push   %esi
  801ae9:	57                   	push   %edi
  801aea:	e8 f4 e7 ff ff       	call   8002e3 <sys_ipc_try_send>
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	74 17                	je     801b0d <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801af6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af9:	74 e9                	je     801ae4 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801afb:	50                   	push   %eax
  801afc:	68 60 22 80 00       	push   $0x802260
  801b01:	6a 3e                	push   $0x3e
  801b03:	68 72 22 80 00       	push   $0x802272
  801b08:	e8 23 f5 ff ff       	call   801030 <_panic>
        }
    }
}
  801b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5f                   	pop    %edi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b20:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b23:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b29:	8b 52 50             	mov    0x50(%edx),%edx
  801b2c:	39 ca                	cmp    %ecx,%edx
  801b2e:	74 11                	je     801b41 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b30:	83 c0 01             	add    $0x1,%eax
  801b33:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b38:	75 e6                	jne    801b20 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3f:	eb 0b                	jmp    801b4c <ipc_find_env+0x37>
			return envs[i].env_id;
  801b41:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b49:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b54:	89 d0                	mov    %edx,%eax
  801b56:	c1 e8 16             	shr    $0x16,%eax
  801b59:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b65:	f6 c1 01             	test   $0x1,%cl
  801b68:	74 1d                	je     801b87 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b6a:	c1 ea 0c             	shr    $0xc,%edx
  801b6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b74:	f6 c2 01             	test   $0x1,%dl
  801b77:	74 0e                	je     801b87 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b79:	c1 ea 0c             	shr    $0xc,%edx
  801b7c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b83:	ef 
  801b84:	0f b7 c0             	movzwl %ax,%eax
}
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    
  801b89:	66 90                	xchg   %ax,%ax
  801b8b:	66 90                	xchg   %ax,%ax
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
