
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 92 04 00 00       	call   80051c <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7f 08                	jg     800100 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800100:	83 ec 0c             	sub    $0xc,%esp
  800103:	50                   	push   %eax
  800104:	6a 03                	push   $0x3
  800106:	68 ea 1d 80 00       	push   $0x801dea
  80010b:	6a 23                	push   $0x23
  80010d:	68 07 1e 80 00       	push   $0x801e07
  800112:	e8 18 0f 00 00       	call   80102f <_panic>

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7f 08                	jg     800181 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	6a 04                	push   $0x4
  800187:	68 ea 1d 80 00       	push   $0x801dea
  80018c:	6a 23                	push   $0x23
  80018e:	68 07 1e 80 00       	push   $0x801e07
  800193:	e8 97 0e 00 00       	call   80102f <_panic>

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7f 08                	jg     8001c3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	50                   	push   %eax
  8001c7:	6a 05                	push   $0x5
  8001c9:	68 ea 1d 80 00       	push   $0x801dea
  8001ce:	6a 23                	push   $0x23
  8001d0:	68 07 1e 80 00       	push   $0x801e07
  8001d5:	e8 55 0e 00 00       	call   80102f <_panic>

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7f 08                	jg     800205 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5f                   	pop    %edi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	50                   	push   %eax
  800209:	6a 06                	push   $0x6
  80020b:	68 ea 1d 80 00       	push   $0x801dea
  800210:	6a 23                	push   $0x23
  800212:	68 07 1e 80 00       	push   $0x801e07
  800217:	e8 13 0e 00 00       	call   80102f <_panic>

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7f 08                	jg     800247 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	50                   	push   %eax
  80024b:	6a 08                	push   $0x8
  80024d:	68 ea 1d 80 00       	push   $0x801dea
  800252:	6a 23                	push   $0x23
  800254:	68 07 1e 80 00       	push   $0x801e07
  800259:	e8 d1 0d 00 00       	call   80102f <_panic>

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7f 08                	jg     800289 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	50                   	push   %eax
  80028d:	6a 09                	push   $0x9
  80028f:	68 ea 1d 80 00       	push   $0x801dea
  800294:	6a 23                	push   $0x23
  800296:	68 07 1e 80 00       	push   $0x801e07
  80029b:	e8 8f 0d 00 00       	call   80102f <_panic>

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7f 08                	jg     8002cb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cb:	83 ec 0c             	sub    $0xc,%esp
  8002ce:	50                   	push   %eax
  8002cf:	6a 0a                	push   $0xa
  8002d1:	68 ea 1d 80 00       	push   $0x801dea
  8002d6:	6a 23                	push   $0x23
  8002d8:	68 07 1e 80 00       	push   $0x801e07
  8002dd:	e8 4d 0d 00 00       	call   80102f <_panic>

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	be 00 00 00 00       	mov    $0x0,%esi
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7f 08                	jg     80032f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 0d                	push   $0xd
  800335:	68 ea 1d 80 00       	push   $0x801dea
  80033a:	6a 23                	push   $0x23
  80033c:	68 07 1e 80 00       	push   $0x801e07
  800341:	e8 e9 0c 00 00       	call   80102f <_panic>

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 2a                	je     8003b3 <fd_alloc+0x46>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 19                	je     8003b3 <fd_alloc+0x46>
  80039a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80039f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a4:	75 d2                	jne    800378 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ac:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b1:	eb 07                	jmp    8003ba <fd_alloc+0x4d>
			*fd_store = fd;
  8003b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb f7                	jmp    8003fb <fd_lookup+0x3f>
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb f0                	jmp    8003fb <fd_lookup+0x3f>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb e9                	jmp    8003fb <fd_lookup+0x3f>

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	74 33                	je     80045c <dev_lookup+0x4a>
  800429:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	75 f3                	jne    800425 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800432:	a1 04 40 80 00       	mov    0x804004,%eax
  800437:	8b 40 48             	mov    0x48(%eax),%eax
  80043a:	83 ec 04             	sub    $0x4,%esp
  80043d:	51                   	push   %ecx
  80043e:	50                   	push   %eax
  80043f:	68 18 1e 80 00       	push   $0x801e18
  800444:	e8 c1 0c 00 00       	call   80110a <cprintf>
	*dev = 0;
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045a:	c9                   	leave  
  80045b:	c3                   	ret    
			*dev = devtab[i];
  80045c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb f2                	jmp    80045a <dev_lookup+0x48>

00800468 <fd_close>:
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	57                   	push   %edi
  80046c:	56                   	push   %esi
  80046d:	53                   	push   %ebx
  80046e:	83 ec 1c             	sub    $0x1c,%esp
  800471:	8b 75 08             	mov    0x8(%ebp),%esi
  800474:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800481:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	50                   	push   %eax
  800485:	e8 32 ff ff ff       	call   8003bc <fd_lookup>
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	83 c4 08             	add    $0x8,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	78 05                	js     800498 <fd_close+0x30>
	    || fd != fd2)
  800493:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800496:	74 16                	je     8004ae <fd_close+0x46>
		return (must_exist ? r : 0);
  800498:	89 f8                	mov    %edi,%eax
  80049a:	84 c0                	test   %al,%al
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a4:	89 d8                	mov    %ebx,%eax
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b4:	50                   	push   %eax
  8004b5:	ff 36                	pushl  (%esi)
  8004b7:	e8 56 ff ff ff       	call   800412 <dev_lookup>
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	78 15                	js     8004da <fd_close+0x72>
		if (dev->dev_close)
  8004c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c8:	8b 40 10             	mov    0x10(%eax),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 1b                	je     8004ea <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004cf:	83 ec 0c             	sub    $0xc,%esp
  8004d2:	56                   	push   %esi
  8004d3:	ff d0                	call   *%eax
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	6a 00                	push   $0x0
  8004e0:	e8 f5 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb ba                	jmp    8004a4 <fd_close+0x3c>
			r = 0;
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ef:	eb e9                	jmp    8004da <fd_close+0x72>

008004f1 <close>:

int
close(int fdnum)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 b9 fe ff ff       	call   8003bc <fd_lookup>
  800503:	83 c4 08             	add    $0x8,%esp
  800506:	85 c0                	test   %eax,%eax
  800508:	78 10                	js     80051a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	6a 01                	push   $0x1
  80050f:	ff 75 f4             	pushl  -0xc(%ebp)
  800512:	e8 51 ff ff ff       	call   800468 <fd_close>
  800517:	83 c4 10             	add    $0x10,%esp
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <close_all>:

void
close_all(void)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	53                   	push   %ebx
  800520:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	53                   	push   %ebx
  80052c:	e8 c0 ff ff ff       	call   8004f1 <close>
	for (i = 0; i < MAXFD; i++)
  800531:	83 c3 01             	add    $0x1,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	83 fb 20             	cmp    $0x20,%ebx
  80053a:	75 ec                	jne    800528 <close_all+0xc>
}
  80053c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 08             	pushl  0x8(%ebp)
  800551:	e8 66 fe ff ff       	call   8003bc <fd_lookup>
  800556:	89 c3                	mov    %eax,%ebx
  800558:	83 c4 08             	add    $0x8,%esp
  80055b:	85 c0                	test   %eax,%eax
  80055d:	0f 88 81 00 00 00    	js     8005e4 <dup+0xa3>
		return r;
	close(newfdnum);
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	e8 83 ff ff ff       	call   8004f1 <close>

	newfd = INDEX2FD(newfdnum);
  80056e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800571:	c1 e6 0c             	shl    $0xc,%esi
  800574:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057a:	83 c4 04             	add    $0x4,%esp
  80057d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800580:	e8 d1 fd ff ff       	call   800356 <fd2data>
  800585:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 c7 fd ff ff       	call   800356 <fd2data>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800594:	89 d8                	mov    %ebx,%eax
  800596:	c1 e8 16             	shr    $0x16,%eax
  800599:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a0:	a8 01                	test   $0x1,%al
  8005a2:	74 11                	je     8005b5 <dup+0x74>
  8005a4:	89 d8                	mov    %ebx,%eax
  8005a6:	c1 e8 0c             	shr    $0xc,%eax
  8005a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b0:	f6 c2 01             	test   $0x1,%dl
  8005b3:	75 39                	jne    8005ee <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 d0                	mov    %edx,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cc:	50                   	push   %eax
  8005cd:	56                   	push   %esi
  8005ce:	6a 00                	push   $0x0
  8005d0:	52                   	push   %edx
  8005d1:	6a 00                	push   $0x0
  8005d3:	e8 c0 fb ff ff       	call   800198 <sys_page_map>
  8005d8:	89 c3                	mov    %eax,%ebx
  8005da:	83 c4 20             	add    $0x20,%esp
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 31                	js     800612 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e4:	89 d8                	mov    %ebx,%eax
  8005e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e9:	5b                   	pop    %ebx
  8005ea:	5e                   	pop    %esi
  8005eb:	5f                   	pop    %edi
  8005ec:	5d                   	pop    %ebp
  8005ed:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fd:	50                   	push   %eax
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 8f fb ff ff       	call   800198 <sys_page_map>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	79 a3                	jns    8005b5 <dup+0x74>
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 00                	push   $0x0
  800618:	e8 bd fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 00                	push   $0x0
  800623:	e8 b2 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb b7                	jmp    8005e4 <dup+0xa3>

0080062d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	53                   	push   %ebx
  800631:	83 ec 14             	sub    $0x14,%esp
  800634:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800637:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063a:	50                   	push   %eax
  80063b:	53                   	push   %ebx
  80063c:	e8 7b fd ff ff       	call   8003bc <fd_lookup>
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	78 3f                	js     800687 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 b9 fd ff ff       	call   800412 <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 27                	js     800687 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	74 1e                	je     80068c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	8b 40 08             	mov    0x8(%eax),%eax
  800674:	85 c0                	test   %eax,%eax
  800676:	74 35                	je     8006ad <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	52                   	push   %edx
  800682:	ff d0                	call   *%eax
  800684:	83 c4 10             	add    $0x10,%esp
}
  800687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068c:	a1 04 40 80 00       	mov    0x804004,%eax
  800691:	8b 40 48             	mov    0x48(%eax),%eax
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	53                   	push   %ebx
  800698:	50                   	push   %eax
  800699:	68 59 1e 80 00       	push   $0x801e59
  80069e:	e8 67 0a 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ab:	eb da                	jmp    800687 <read+0x5a>
		return -E_NOT_SUPP;
  8006ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b2:	eb d3                	jmp    800687 <read+0x5a>

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	39 f3                	cmp    %esi,%ebx
  8006ca:	73 25                	jae    8006f1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	29 d8                	sub    %ebx,%eax
  8006d3:	50                   	push   %eax
  8006d4:	89 d8                	mov    %ebx,%eax
  8006d6:	03 45 0c             	add    0xc(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	57                   	push   %edi
  8006db:	e8 4d ff ff ff       	call   80062d <read>
		if (m < 0)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 08                	js     8006ef <readn+0x3b>
			return m;
		if (m == 0)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 06                	je     8006f1 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006eb:	01 c3                	add    %eax,%ebx
  8006ed:	eb d9                	jmp    8006c8 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ef:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	83 ec 14             	sub    $0x14,%esp
  800702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	53                   	push   %ebx
  80070a:	e8 ad fc ff ff       	call   8003bc <fd_lookup>
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	85 c0                	test   %eax,%eax
  800714:	78 3a                	js     800750 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800720:	ff 30                	pushl  (%eax)
  800722:	e8 eb fc ff ff       	call   800412 <dev_lookup>
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 22                	js     800750 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800735:	74 1e                	je     800755 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073a:	8b 52 0c             	mov    0xc(%edx),%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 35                	je     800776 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	50                   	push   %eax
  80074b:	ff d2                	call   *%edx
  80074d:	83 c4 10             	add    $0x10,%esp
}
  800750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800753:	c9                   	leave  
  800754:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800755:	a1 04 40 80 00       	mov    0x804004,%eax
  80075a:	8b 40 48             	mov    0x48(%eax),%eax
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	53                   	push   %ebx
  800761:	50                   	push   %eax
  800762:	68 75 1e 80 00       	push   $0x801e75
  800767:	e8 9e 09 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb da                	jmp    800750 <write+0x55>
		return -E_NOT_SUPP;
  800776:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077b:	eb d3                	jmp    800750 <write+0x55>

0080077d <seek>:

int
seek(int fdnum, off_t offset)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800783:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	ff 75 08             	pushl  0x8(%ebp)
  80078a:	e8 2d fc ff ff       	call   8003bc <fd_lookup>
  80078f:	83 c4 08             	add    $0x8,%esp
  800792:	85 c0                	test   %eax,%eax
  800794:	78 0e                	js     8007a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	83 ec 14             	sub    $0x14,%esp
  8007ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	53                   	push   %ebx
  8007b5:	e8 02 fc ff ff       	call   8003bc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 37                	js     8007f8 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cb:	ff 30                	pushl  (%eax)
  8007cd:	e8 40 fc ff ff       	call   800412 <dev_lookup>
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 1f                	js     8007f8 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e0:	74 1b                	je     8007fd <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e5:	8b 52 18             	mov    0x18(%edx),%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	74 32                	je     80081e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	50                   	push   %eax
  8007f3:	ff d2                	call   *%edx
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 38 1e 80 00       	push   $0x801e38
  80080f:	e8 f6 08 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081c:	eb da                	jmp    8007f8 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800823:	eb d3                	jmp    8007f8 <ftruncate+0x52>

00800825 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 14             	sub    $0x14,%esp
  80082c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 81 fb ff ff       	call   8003bc <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 4b                	js     80088d <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	ff 30                	pushl  (%eax)
  80084e:	e8 bf fb ff ff       	call   800412 <dev_lookup>
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 33                	js     80088d <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800861:	74 2f                	je     800892 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800863:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800866:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086d:	00 00 00 
	stat->st_isdir = 0;
  800870:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800877:	00 00 00 
	stat->st_dev = dev;
  80087a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	ff 75 f0             	pushl  -0x10(%ebp)
  800887:	ff 50 14             	call   *0x14(%eax)
  80088a:	83 c4 10             	add    $0x10,%esp
}
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    
		return -E_NOT_SUPP;
  800892:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800897:	eb f4                	jmp    80088d <fstat+0x68>

00800899 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	6a 00                	push   $0x0
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 e7 01 00 00       	call   800a92 <open>
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 1b                	js     8008cf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ba:	50                   	push   %eax
  8008bb:	e8 65 ff ff ff       	call   800825 <fstat>
  8008c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	e8 27 fc ff ff       	call   8004f1 <close>
	return r;
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	89 f3                	mov    %esi,%ebx
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	89 c6                	mov    %eax,%esi
  8008df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e8:	74 27                	je     800911 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ea:	6a 07                	push   $0x7
  8008ec:	68 00 50 80 00       	push   $0x805000
  8008f1:	56                   	push   %esi
  8008f2:	ff 35 00 40 80 00    	pushl  0x804000
  8008f8:	e8 ca 11 00 00       	call   801ac7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fd:	83 c4 0c             	add    $0xc,%esp
  800900:	6a 00                	push   $0x0
  800902:	53                   	push   %ebx
  800903:	6a 00                	push   $0x0
  800905:	e8 5c 11 00 00       	call   801a66 <ipc_recv>
}
  80090a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800911:	83 ec 0c             	sub    $0xc,%esp
  800914:	6a 01                	push   $0x1
  800916:	e8 f9 11 00 00       	call   801b14 <ipc_find_env>
  80091b:	a3 00 40 80 00       	mov    %eax,0x804000
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb c5                	jmp    8008ea <fsipc+0x12>

00800925 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 40 0c             	mov    0xc(%eax),%eax
  800931:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	b8 02 00 00 00       	mov    $0x2,%eax
  800948:	e8 8b ff ff ff       	call   8008d8 <fsipc>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <devfile_flush>:
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	b8 06 00 00 00       	mov    $0x6,%eax
  80096a:	e8 69 ff ff ff       	call   8008d8 <fsipc>
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <devfile_stat>:
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	83 ec 04             	sub    $0x4,%esp
  800978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 40 0c             	mov    0xc(%eax),%eax
  800981:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 05 00 00 00       	mov    $0x5,%eax
  800990:	e8 43 ff ff ff       	call   8008d8 <fsipc>
  800995:	85 c0                	test   %eax,%eax
  800997:	78 2c                	js     8009c5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	68 00 50 80 00       	push   $0x805000
  8009a1:	53                   	push   %ebx
  8009a2:	e8 82 0d 00 00       	call   801729 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <devfile_write>:
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009d3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009dd:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e6:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009ec:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8009f1:	50                   	push   %eax
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	68 08 50 80 00       	push   $0x805008
  8009fa:	e8 b8 0e 00 00       	call   8018b7 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 04 00 00 00       	mov    $0x4,%eax
  800a09:	e8 ca fe ff ff       	call   8008d8 <fsipc>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <devfile_read>:
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 a0 fe ff ff       	call   8008d8 <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 1f                	js     800a5d <devfile_read+0x4d>
	assert(r <= n);
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	77 24                	ja     800a66 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a47:	7f 33                	jg     800a7c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a49:	83 ec 04             	sub    $0x4,%esp
  800a4c:	50                   	push   %eax
  800a4d:	68 00 50 80 00       	push   $0x805000
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	e8 5d 0e 00 00       	call   8018b7 <memmove>
	return r;
  800a5a:	83 c4 10             	add    $0x10,%esp
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	assert(r <= n);
  800a66:	68 a4 1e 80 00       	push   $0x801ea4
  800a6b:	68 ab 1e 80 00       	push   $0x801eab
  800a70:	6a 7d                	push   $0x7d
  800a72:	68 c0 1e 80 00       	push   $0x801ec0
  800a77:	e8 b3 05 00 00       	call   80102f <_panic>
	assert(r <= PGSIZE);
  800a7c:	68 cb 1e 80 00       	push   $0x801ecb
  800a81:	68 ab 1e 80 00       	push   $0x801eab
  800a86:	6a 7e                	push   $0x7e
  800a88:	68 c0 1e 80 00       	push   $0x801ec0
  800a8d:	e8 9d 05 00 00       	call   80102f <_panic>

00800a92 <open>:
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 1c             	sub    $0x1c,%esp
  800a9a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9d:	56                   	push   %esi
  800a9e:	e8 4f 0c 00 00       	call   8016f2 <strlen>
  800aa3:	83 c4 10             	add    $0x10,%esp
  800aa6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aab:	0f 8f 96 00 00 00    	jg     800b47 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800ab1:	83 ec 0c             	sub    $0xc,%esp
  800ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab7:	50                   	push   %eax
  800ab8:	e8 b0 f8 ff ff       	call   80036d <fd_alloc>
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 66                	js     800b2c <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800ac6:	83 ec 08             	sub    $0x8,%esp
  800ac9:	56                   	push   %esi
  800aca:	68 00 50 80 00       	push   $0x805000
  800acf:	e8 55 0c 00 00       	call   801729 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae4:	e8 ef fd ff ff       	call   8008d8 <fsipc>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 43                	js     800b35 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	ff 75 f4             	pushl  -0xc(%ebp)
  800af8:	e8 49 f8 ff ff       	call   800346 <fd2num>
  800afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b00:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b06:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b09:	83 c4 08             	add    $0x8,%esp
  800b0c:	50                   	push   %eax
  800b0d:	52                   	push   %edx
  800b0e:	ff 32                	pushl  (%edx)
  800b10:	56                   	push   %esi
  800b11:	51                   	push   %ecx
  800b12:	68 d8 1e 80 00       	push   $0x801ed8
  800b17:	e8 ee 05 00 00       	call   80110a <cprintf>
	return fd2num(fd);
  800b1c:	83 c4 14             	add    $0x14,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 1f f8 ff ff       	call   800346 <fd2num>
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	83 c4 10             	add    $0x10,%esp
}
  800b2c:	89 d8                	mov    %ebx,%eax
  800b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    
		fd_close(fd, 0);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	6a 00                	push   $0x0
  800b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3d:	e8 26 f9 ff ff       	call   800468 <fd_close>
		return r;
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	eb e5                	jmp    800b2c <open+0x9a>
		return -E_BAD_PATH;
  800b47:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4c:	eb de                	jmp    800b2c <open+0x9a>

00800b4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5e:	e8 75 fd ff ff       	call   8008d8 <fsipc>
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 08             	pushl  0x8(%ebp)
  800b73:	e8 de f7 ff ff       	call   800356 <fd2data>
  800b78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7a:	83 c4 08             	add    $0x8,%esp
  800b7d:	68 17 1f 80 00       	push   $0x801f17
  800b82:	53                   	push   %ebx
  800b83:	e8 a1 0b 00 00       	call   801729 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b88:	8b 46 04             	mov    0x4(%esi),%eax
  800b8b:	2b 06                	sub    (%esi),%eax
  800b8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9a:	00 00 00 
	stat->st_dev = &devpipe;
  800b9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba4:	30 80 00 
	return 0;
}
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbd:	53                   	push   %ebx
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 15 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc5:	89 1c 24             	mov    %ebx,(%esp)
  800bc8:	e8 89 f7 ff ff       	call   800356 <fd2data>
  800bcd:	83 c4 08             	add    $0x8,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 00                	push   $0x0
  800bd3:	e8 02 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <_pipeisclosed>:
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 1c             	sub    $0x1c,%esp
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bea:	a1 04 40 80 00       	mov    0x804004,%eax
  800bef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	57                   	push   %edi
  800bf6:	e8 52 0f 00 00       	call   801b4d <pageref>
  800bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bfe:	89 34 24             	mov    %esi,(%esp)
  800c01:	e8 47 0f 00 00       	call   801b4d <pageref>
		nn = thisenv->env_runs;
  800c06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	39 cb                	cmp    %ecx,%ebx
  800c14:	74 1b                	je     800c31 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c16:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c19:	75 cf                	jne    800bea <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1b:	8b 42 58             	mov    0x58(%edx),%eax
  800c1e:	6a 01                	push   $0x1
  800c20:	50                   	push   %eax
  800c21:	53                   	push   %ebx
  800c22:	68 1e 1f 80 00       	push   $0x801f1e
  800c27:	e8 de 04 00 00       	call   80110a <cprintf>
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	eb b9                	jmp    800bea <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c31:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c34:	0f 94 c0             	sete   %al
  800c37:	0f b6 c0             	movzbl %al,%eax
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <devpipe_write>:
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 28             	sub    $0x28,%esp
  800c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c4e:	56                   	push   %esi
  800c4f:	e8 02 f7 ff ff       	call   800356 <fd2data>
  800c54:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c61:	74 4f                	je     800cb2 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c63:	8b 43 04             	mov    0x4(%ebx),%eax
  800c66:	8b 0b                	mov    (%ebx),%ecx
  800c68:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	72 14                	jb     800c83 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c6f:	89 da                	mov    %ebx,%edx
  800c71:	89 f0                	mov    %esi,%eax
  800c73:	e8 65 ff ff ff       	call   800bdd <_pipeisclosed>
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	75 3a                	jne    800cb6 <devpipe_write+0x74>
			sys_yield();
  800c7c:	e8 b5 f4 ff ff       	call   800136 <sys_yield>
  800c81:	eb e0                	jmp    800c63 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8d:	89 c2                	mov    %eax,%edx
  800c8f:	c1 fa 1f             	sar    $0x1f,%edx
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	c1 e9 1b             	shr    $0x1b,%ecx
  800c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9a:	83 e2 1f             	and    $0x1f,%edx
  800c9d:	29 ca                	sub    %ecx,%edx
  800c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cad:	83 c7 01             	add    $0x1,%edi
  800cb0:	eb ac                	jmp    800c5e <devpipe_write+0x1c>
	return i;
  800cb2:	89 f8                	mov    %edi,%eax
  800cb4:	eb 05                	jmp    800cbb <devpipe_write+0x79>
				return 0;
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <devpipe_read>:
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 18             	sub    $0x18,%esp
  800ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ccf:	57                   	push   %edi
  800cd0:	e8 81 f6 ff ff       	call   800356 <fd2data>
  800cd5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	be 00 00 00 00       	mov    $0x0,%esi
  800cdf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce2:	74 47                	je     800d2b <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ce4:	8b 03                	mov    (%ebx),%eax
  800ce6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ce9:	75 22                	jne    800d0d <devpipe_read+0x4a>
			if (i > 0)
  800ceb:	85 f6                	test   %esi,%esi
  800ced:	75 14                	jne    800d03 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cef:	89 da                	mov    %ebx,%edx
  800cf1:	89 f8                	mov    %edi,%eax
  800cf3:	e8 e5 fe ff ff       	call   800bdd <_pipeisclosed>
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	75 33                	jne    800d2f <devpipe_read+0x6c>
			sys_yield();
  800cfc:	e8 35 f4 ff ff       	call   800136 <sys_yield>
  800d01:	eb e1                	jmp    800ce4 <devpipe_read+0x21>
				return i;
  800d03:	89 f0                	mov    %esi,%eax
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0d:	99                   	cltd   
  800d0e:	c1 ea 1b             	shr    $0x1b,%edx
  800d11:	01 d0                	add    %edx,%eax
  800d13:	83 e0 1f             	and    $0x1f,%eax
  800d16:	29 d0                	sub    %edx,%eax
  800d18:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d23:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d26:	83 c6 01             	add    $0x1,%esi
  800d29:	eb b4                	jmp    800cdf <devpipe_read+0x1c>
	return i;
  800d2b:	89 f0                	mov    %esi,%eax
  800d2d:	eb d6                	jmp    800d05 <devpipe_read+0x42>
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d34:	eb cf                	jmp    800d05 <devpipe_read+0x42>

00800d36 <pipe>:
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d41:	50                   	push   %eax
  800d42:	e8 26 f6 ff ff       	call   80036d <fd_alloc>
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	83 c4 10             	add    $0x10,%esp
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	78 5b                	js     800dab <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 07 04 00 00       	push   $0x407
  800d58:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5b:	6a 00                	push   $0x0
  800d5d:	e8 f3 f3 ff ff       	call   800155 <sys_page_alloc>
  800d62:	89 c3                	mov    %eax,%ebx
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 40                	js     800dab <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 f6 f5 ff ff       	call   80036d <fd_alloc>
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 1b                	js     800d9b <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d80:	83 ec 04             	sub    $0x4,%esp
  800d83:	68 07 04 00 00       	push   $0x407
  800d88:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 c3 f3 ff ff       	call   800155 <sys_page_alloc>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 19                	jns    800db4 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d9b:	83 ec 08             	sub    $0x8,%esp
  800d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800da1:	6a 00                	push   $0x0
  800da3:	e8 32 f4 ff ff       	call   8001da <sys_page_unmap>
  800da8:	83 c4 10             	add    $0x10,%esp
}
  800dab:	89 d8                	mov    %ebx,%eax
  800dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
	va = fd2data(fd0);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dba:	e8 97 f5 ff ff       	call   800356 <fd2data>
  800dbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc1:	83 c4 0c             	add    $0xc,%esp
  800dc4:	68 07 04 00 00       	push   $0x407
  800dc9:	50                   	push   %eax
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 84 f3 ff ff       	call   800155 <sys_page_alloc>
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	0f 88 8c 00 00 00    	js     800e6a <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	ff 75 f0             	pushl  -0x10(%ebp)
  800de4:	e8 6d f5 ff ff       	call   800356 <fd2data>
  800de9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df0:	50                   	push   %eax
  800df1:	6a 00                	push   $0x0
  800df3:	56                   	push   %esi
  800df4:	6a 00                	push   $0x0
  800df6:	e8 9d f3 ff ff       	call   800198 <sys_page_map>
  800dfb:	89 c3                	mov    %eax,%ebx
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 58                	js     800e5c <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e22:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	ff 75 f4             	pushl  -0xc(%ebp)
  800e34:	e8 0d f5 ff ff       	call   800346 <fd2num>
  800e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3e:	83 c4 04             	add    $0x4,%esp
  800e41:	ff 75 f0             	pushl  -0x10(%ebp)
  800e44:	e8 fd f4 ff ff       	call   800346 <fd2num>
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e57:	e9 4f ff ff ff       	jmp    800dab <pipe+0x75>
	sys_page_unmap(0, va);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	56                   	push   %esi
  800e60:	6a 00                	push   $0x0
  800e62:	e8 73 f3 ff ff       	call   8001da <sys_page_unmap>
  800e67:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e70:	6a 00                	push   $0x0
  800e72:	e8 63 f3 ff ff       	call   8001da <sys_page_unmap>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	e9 1c ff ff ff       	jmp    800d9b <pipe+0x65>

00800e7f <pipeisclosed>:
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	ff 75 08             	pushl  0x8(%ebp)
  800e8c:	e8 2b f5 ff ff       	call   8003bc <fd_lookup>
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 18                	js     800eb0 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9e:	e8 b3 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ea3:	89 c2                	mov    %eax,%edx
  800ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea8:	e8 30 fd ff ff       	call   800bdd <_pipeisclosed>
  800ead:	83 c4 10             	add    $0x10,%esp
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec2:	68 36 1f 80 00       	push   $0x801f36
  800ec7:	ff 75 0c             	pushl  0xc(%ebp)
  800eca:	e8 5a 08 00 00       	call   801729 <strcpy>
	return 0;
}
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <devcons_write>:
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eed:	eb 2f                	jmp    800f1e <devcons_write+0x48>
		m = n - tot;
  800eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef2:	29 f3                	sub    %esi,%ebx
  800ef4:	83 fb 7f             	cmp    $0x7f,%ebx
  800ef7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800efc:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	53                   	push   %ebx
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	03 45 0c             	add    0xc(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	57                   	push   %edi
  800f0a:	e8 a8 09 00 00       	call   8018b7 <memmove>
		sys_cputs(buf, m);
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	57                   	push   %edi
  800f14:	e8 80 f1 ff ff       	call   800099 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f19:	01 de                	add    %ebx,%esi
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f21:	72 cc                	jb     800eef <devcons_write+0x19>
}
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <devcons_read>:
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3c:	75 07                	jne    800f45 <devcons_read+0x18>
}
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    
		sys_yield();
  800f40:	e8 f1 f1 ff ff       	call   800136 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f45:	e8 6d f1 ff ff       	call   8000b7 <sys_cgetc>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	74 f2                	je     800f40 <devcons_read+0x13>
	if (c < 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 ec                	js     800f3e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f52:	83 f8 04             	cmp    $0x4,%eax
  800f55:	74 0c                	je     800f63 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	88 02                	mov    %al,(%edx)
	return 1;
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	eb db                	jmp    800f3e <devcons_read+0x11>
		return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	eb d4                	jmp    800f3e <devcons_read+0x11>

00800f6a <cputchar>:
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f76:	6a 01                	push   $0x1
  800f78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	e8 18 f1 ff ff       	call   800099 <sys_cputs>
}
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <getchar>:
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f8c:	6a 01                	push   $0x1
  800f8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	6a 00                	push   $0x0
  800f94:	e8 94 f6 ff ff       	call   80062d <read>
	if (r < 0)
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 08                	js     800fa8 <getchar+0x22>
	if (r < 1)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 06                	jle    800faa <getchar+0x24>
	return c;
  800fa4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    
		return -E_EOF;
  800faa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800faf:	eb f7                	jmp    800fa8 <getchar+0x22>

00800fb1 <iscons>:
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 f9 f3 ff ff       	call   8003bc <fd_lookup>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 11                	js     800fdb <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd3:	39 10                	cmp    %edx,(%eax)
  800fd5:	0f 94 c0             	sete   %al
  800fd8:	0f b6 c0             	movzbl %al,%eax
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <opencons>:
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	e8 81 f3 ff ff       	call   80036d <fd_alloc>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 3a                	js     80102d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	68 07 04 00 00       	push   $0x407
  800ffb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffe:	6a 00                	push   $0x0
  801000:	e8 50 f1 ff ff       	call   800155 <sys_page_alloc>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 21                	js     80102d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801015:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	50                   	push   %eax
  801025:	e8 1c f3 ff ff       	call   800346 <fd2num>
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801034:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801037:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103d:	e8 d5 f0 ff ff       	call   800117 <sys_getenvid>
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	ff 75 0c             	pushl  0xc(%ebp)
  801048:	ff 75 08             	pushl  0x8(%ebp)
  80104b:	56                   	push   %esi
  80104c:	50                   	push   %eax
  80104d:	68 44 1f 80 00       	push   $0x801f44
  801052:	e8 b3 00 00 00       	call   80110a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801057:	83 c4 18             	add    $0x18,%esp
  80105a:	53                   	push   %ebx
  80105b:	ff 75 10             	pushl  0x10(%ebp)
  80105e:	e8 56 00 00 00       	call   8010b9 <vcprintf>
	cprintf("\n");
  801063:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80106a:	e8 9b 00 00 00       	call   80110a <cprintf>
  80106f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801072:	cc                   	int3   
  801073:	eb fd                	jmp    801072 <_panic+0x43>

00801075 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	53                   	push   %ebx
  801079:	83 ec 04             	sub    $0x4,%esp
  80107c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80107f:	8b 13                	mov    (%ebx),%edx
  801081:	8d 42 01             	lea    0x1(%edx),%eax
  801084:	89 03                	mov    %eax,(%ebx)
  801086:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801089:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801092:	74 09                	je     80109d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801094:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 ff 00 00 00       	push   $0xff
  8010a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a8:	50                   	push   %eax
  8010a9:	e8 eb ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	eb db                	jmp    801094 <putch+0x1f>

008010b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c9:	00 00 00 
	b.cnt = 0;
  8010cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d6:	ff 75 0c             	pushl  0xc(%ebp)
  8010d9:	ff 75 08             	pushl  0x8(%ebp)
  8010dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	68 75 10 80 00       	push   $0x801075
  8010e8:	e8 1a 01 00 00       	call   801207 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ed:	83 c4 08             	add    $0x8,%esp
  8010f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	e8 97 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801102:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801110:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801113:	50                   	push   %eax
  801114:	ff 75 08             	pushl  0x8(%ebp)
  801117:	e8 9d ff ff ff       	call   8010b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	89 c7                	mov    %eax,%edi
  801129:	89 d6                	mov    %edx,%esi
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801134:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801137:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801142:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801145:	39 d3                	cmp    %edx,%ebx
  801147:	72 05                	jb     80114e <printnum+0x30>
  801149:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114c:	77 7a                	ja     8011c8 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	ff 75 18             	pushl  0x18(%ebp)
  801154:	8b 45 14             	mov    0x14(%ebp),%eax
  801157:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115a:	53                   	push   %ebx
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	ff 75 e0             	pushl  -0x20(%ebp)
  801167:	ff 75 dc             	pushl  -0x24(%ebp)
  80116a:	ff 75 d8             	pushl  -0x28(%ebp)
  80116d:	e8 1e 0a 00 00       	call   801b90 <__udivdi3>
  801172:	83 c4 18             	add    $0x18,%esp
  801175:	52                   	push   %edx
  801176:	50                   	push   %eax
  801177:	89 f2                	mov    %esi,%edx
  801179:	89 f8                	mov    %edi,%eax
  80117b:	e8 9e ff ff ff       	call   80111e <printnum>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	eb 13                	jmp    801198 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	ff 75 18             	pushl  0x18(%ebp)
  80118c:	ff d7                	call   *%edi
  80118e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801191:	83 eb 01             	sub    $0x1,%ebx
  801194:	85 db                	test   %ebx,%ebx
  801196:	7f ed                	jg     801185 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	56                   	push   %esi
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ab:	e8 00 0b 00 00       	call   801cb0 <__umoddi3>
  8011b0:	83 c4 14             	add    $0x14,%esp
  8011b3:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011ba:	50                   	push   %eax
  8011bb:	ff d7                	call   *%edi
}
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
  8011c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011cb:	eb c4                	jmp    801191 <printnum+0x73>

008011cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d7:	8b 10                	mov    (%eax),%edx
  8011d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011dc:	73 0a                	jae    8011e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e1:	89 08                	mov    %ecx,(%eax)
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	88 02                	mov    %al,(%edx)
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <printfmt>:
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 10             	pushl  0x10(%ebp)
  8011f7:	ff 75 0c             	pushl  0xc(%ebp)
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 05 00 00 00       	call   801207 <vprintfmt>
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <vprintfmt>:
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 2c             	sub    $0x2c,%esp
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801216:	8b 7d 10             	mov    0x10(%ebp),%edi
  801219:	e9 c1 03 00 00       	jmp    8015df <vprintfmt+0x3d8>
		padc = ' ';
  80121e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801222:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801229:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801230:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801237:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80123c:	8d 47 01             	lea    0x1(%edi),%eax
  80123f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801242:	0f b6 17             	movzbl (%edi),%edx
  801245:	8d 42 dd             	lea    -0x23(%edx),%eax
  801248:	3c 55                	cmp    $0x55,%al
  80124a:	0f 87 12 04 00 00    	ja     801662 <vprintfmt+0x45b>
  801250:	0f b6 c0             	movzbl %al,%eax
  801253:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80125a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80125d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801261:	eb d9                	jmp    80123c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801263:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801266:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80126a:	eb d0                	jmp    80123c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80126c:	0f b6 d2             	movzbl %dl,%edx
  80126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
  801277:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80127a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80127d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801281:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801284:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801287:	83 f9 09             	cmp    $0x9,%ecx
  80128a:	77 55                	ja     8012e1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80128c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80128f:	eb e9                	jmp    80127a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801291:	8b 45 14             	mov    0x14(%ebp),%eax
  801294:	8b 00                	mov    (%eax),%eax
  801296:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801299:	8b 45 14             	mov    0x14(%ebp),%eax
  80129c:	8d 40 04             	lea    0x4(%eax),%eax
  80129f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012a9:	79 91                	jns    80123c <vprintfmt+0x35>
				width = precision, precision = -1;
  8012ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b8:	eb 82                	jmp    80123c <vprintfmt+0x35>
  8012ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c4:	0f 49 d0             	cmovns %eax,%edx
  8012c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cd:	e9 6a ff ff ff       	jmp    80123c <vprintfmt+0x35>
  8012d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012d5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012dc:	e9 5b ff ff ff       	jmp    80123c <vprintfmt+0x35>
  8012e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012e7:	eb bc                	jmp    8012a5 <vprintfmt+0x9e>
			lflag++;
  8012e9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ef:	e9 48 ff ff ff       	jmp    80123c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f7:	8d 78 04             	lea    0x4(%eax),%edi
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	53                   	push   %ebx
  8012fe:	ff 30                	pushl  (%eax)
  801300:	ff d6                	call   *%esi
			break;
  801302:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801305:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801308:	e9 cf 02 00 00       	jmp    8015dc <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80130d:	8b 45 14             	mov    0x14(%ebp),%eax
  801310:	8d 78 04             	lea    0x4(%eax),%edi
  801313:	8b 00                	mov    (%eax),%eax
  801315:	99                   	cltd   
  801316:	31 d0                	xor    %edx,%eax
  801318:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131a:	83 f8 0f             	cmp    $0xf,%eax
  80131d:	7f 23                	jg     801342 <vprintfmt+0x13b>
  80131f:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801326:	85 d2                	test   %edx,%edx
  801328:	74 18                	je     801342 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80132a:	52                   	push   %edx
  80132b:	68 bd 1e 80 00       	push   $0x801ebd
  801330:	53                   	push   %ebx
  801331:	56                   	push   %esi
  801332:	e8 b3 fe ff ff       	call   8011ea <printfmt>
  801337:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80133a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80133d:	e9 9a 02 00 00       	jmp    8015dc <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801342:	50                   	push   %eax
  801343:	68 7f 1f 80 00       	push   $0x801f7f
  801348:	53                   	push   %ebx
  801349:	56                   	push   %esi
  80134a:	e8 9b fe ff ff       	call   8011ea <printfmt>
  80134f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801352:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801355:	e9 82 02 00 00       	jmp    8015dc <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	83 c0 04             	add    $0x4,%eax
  801360:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801368:	85 ff                	test   %edi,%edi
  80136a:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  80136f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801372:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801376:	0f 8e bd 00 00 00    	jle    801439 <vprintfmt+0x232>
  80137c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801380:	75 0e                	jne    801390 <vprintfmt+0x189>
  801382:	89 75 08             	mov    %esi,0x8(%ebp)
  801385:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801388:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80138b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80138e:	eb 6d                	jmp    8013fd <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	ff 75 d0             	pushl  -0x30(%ebp)
  801396:	57                   	push   %edi
  801397:	e8 6e 03 00 00       	call   80170a <strnlen>
  80139c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80139f:	29 c1                	sub    %eax,%ecx
  8013a1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b1:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b3:	eb 0f                	jmp    8013c4 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8013bc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013be:	83 ef 01             	sub    $0x1,%edi
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 ff                	test   %edi,%edi
  8013c6:	7f ed                	jg     8013b5 <vprintfmt+0x1ae>
  8013c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013cb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013ce:	85 c9                	test   %ecx,%ecx
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	0f 49 c1             	cmovns %ecx,%eax
  8013d8:	29 c1                	sub    %eax,%ecx
  8013da:	89 75 08             	mov    %esi,0x8(%ebp)
  8013dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e3:	89 cb                	mov    %ecx,%ebx
  8013e5:	eb 16                	jmp    8013fd <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013eb:	75 31                	jne    80141e <vprintfmt+0x217>
					putch(ch, putdat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	ff 75 0c             	pushl  0xc(%ebp)
  8013f3:	50                   	push   %eax
  8013f4:	ff 55 08             	call   *0x8(%ebp)
  8013f7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013fa:	83 eb 01             	sub    $0x1,%ebx
  8013fd:	83 c7 01             	add    $0x1,%edi
  801400:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801404:	0f be c2             	movsbl %dl,%eax
  801407:	85 c0                	test   %eax,%eax
  801409:	74 59                	je     801464 <vprintfmt+0x25d>
  80140b:	85 f6                	test   %esi,%esi
  80140d:	78 d8                	js     8013e7 <vprintfmt+0x1e0>
  80140f:	83 ee 01             	sub    $0x1,%esi
  801412:	79 d3                	jns    8013e7 <vprintfmt+0x1e0>
  801414:	89 df                	mov    %ebx,%edi
  801416:	8b 75 08             	mov    0x8(%ebp),%esi
  801419:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80141c:	eb 37                	jmp    801455 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80141e:	0f be d2             	movsbl %dl,%edx
  801421:	83 ea 20             	sub    $0x20,%edx
  801424:	83 fa 5e             	cmp    $0x5e,%edx
  801427:	76 c4                	jbe    8013ed <vprintfmt+0x1e6>
					putch('?', putdat);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	ff 75 0c             	pushl  0xc(%ebp)
  80142f:	6a 3f                	push   $0x3f
  801431:	ff 55 08             	call   *0x8(%ebp)
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	eb c1                	jmp    8013fa <vprintfmt+0x1f3>
  801439:	89 75 08             	mov    %esi,0x8(%ebp)
  80143c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801442:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801445:	eb b6                	jmp    8013fd <vprintfmt+0x1f6>
				putch(' ', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	53                   	push   %ebx
  80144b:	6a 20                	push   $0x20
  80144d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80144f:	83 ef 01             	sub    $0x1,%edi
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 ff                	test   %edi,%edi
  801457:	7f ee                	jg     801447 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801459:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80145c:	89 45 14             	mov    %eax,0x14(%ebp)
  80145f:	e9 78 01 00 00       	jmp    8015dc <vprintfmt+0x3d5>
  801464:	89 df                	mov    %ebx,%edi
  801466:	8b 75 08             	mov    0x8(%ebp),%esi
  801469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146c:	eb e7                	jmp    801455 <vprintfmt+0x24e>
	if (lflag >= 2)
  80146e:	83 f9 01             	cmp    $0x1,%ecx
  801471:	7e 3f                	jle    8014b2 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801473:	8b 45 14             	mov    0x14(%ebp),%eax
  801476:	8b 50 04             	mov    0x4(%eax),%edx
  801479:	8b 00                	mov    (%eax),%eax
  80147b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80147e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801481:	8b 45 14             	mov    0x14(%ebp),%eax
  801484:	8d 40 08             	lea    0x8(%eax),%eax
  801487:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80148a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80148e:	79 5c                	jns    8014ec <vprintfmt+0x2e5>
				putch('-', putdat);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	53                   	push   %ebx
  801494:	6a 2d                	push   $0x2d
  801496:	ff d6                	call   *%esi
				num = -(long long) num;
  801498:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80149b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80149e:	f7 da                	neg    %edx
  8014a0:	83 d1 00             	adc    $0x0,%ecx
  8014a3:	f7 d9                	neg    %ecx
  8014a5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ad:	e9 10 01 00 00       	jmp    8015c2 <vprintfmt+0x3bb>
	else if (lflag)
  8014b2:	85 c9                	test   %ecx,%ecx
  8014b4:	75 1b                	jne    8014d1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8b 00                	mov    (%eax),%eax
  8014bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014be:	89 c1                	mov    %eax,%ecx
  8014c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c9:	8d 40 04             	lea    0x4(%eax),%eax
  8014cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cf:	eb b9                	jmp    80148a <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d4:	8b 00                	mov    (%eax),%eax
  8014d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d9:	89 c1                	mov    %eax,%ecx
  8014db:	c1 f9 1f             	sar    $0x1f,%ecx
  8014de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8d 40 04             	lea    0x4(%eax),%eax
  8014e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ea:	eb 9e                	jmp    80148a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f7:	e9 c6 00 00 00       	jmp    8015c2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014fc:	83 f9 01             	cmp    $0x1,%ecx
  8014ff:	7e 18                	jle    801519 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8b 10                	mov    (%eax),%edx
  801506:	8b 48 04             	mov    0x4(%eax),%ecx
  801509:	8d 40 08             	lea    0x8(%eax),%eax
  80150c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801514:	e9 a9 00 00 00       	jmp    8015c2 <vprintfmt+0x3bb>
	else if (lflag)
  801519:	85 c9                	test   %ecx,%ecx
  80151b:	75 1a                	jne    801537 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80151d:	8b 45 14             	mov    0x14(%ebp),%eax
  801520:	8b 10                	mov    (%eax),%edx
  801522:	b9 00 00 00 00       	mov    $0x0,%ecx
  801527:	8d 40 04             	lea    0x4(%eax),%eax
  80152a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80152d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801532:	e9 8b 00 00 00       	jmp    8015c2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 10                	mov    (%eax),%edx
  80153c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801541:	8d 40 04             	lea    0x4(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154c:	eb 74                	jmp    8015c2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80154e:	83 f9 01             	cmp    $0x1,%ecx
  801551:	7e 15                	jle    801568 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8b 10                	mov    (%eax),%edx
  801558:	8b 48 04             	mov    0x4(%eax),%ecx
  80155b:	8d 40 08             	lea    0x8(%eax),%eax
  80155e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801561:	b8 08 00 00 00       	mov    $0x8,%eax
  801566:	eb 5a                	jmp    8015c2 <vprintfmt+0x3bb>
	else if (lflag)
  801568:	85 c9                	test   %ecx,%ecx
  80156a:	75 17                	jne    801583 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80156c:	8b 45 14             	mov    0x14(%ebp),%eax
  80156f:	8b 10                	mov    (%eax),%edx
  801571:	b9 00 00 00 00       	mov    $0x0,%ecx
  801576:	8d 40 04             	lea    0x4(%eax),%eax
  801579:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80157c:	b8 08 00 00 00       	mov    $0x8,%eax
  801581:	eb 3f                	jmp    8015c2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801583:	8b 45 14             	mov    0x14(%ebp),%eax
  801586:	8b 10                	mov    (%eax),%edx
  801588:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158d:	8d 40 04             	lea    0x4(%eax),%eax
  801590:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  801593:	b8 08 00 00 00       	mov    $0x8,%eax
  801598:	eb 28                	jmp    8015c2 <vprintfmt+0x3bb>
			putch('0', putdat);
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	53                   	push   %ebx
  80159e:	6a 30                	push   $0x30
  8015a0:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	6a 78                	push   $0x78
  8015a8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ad:	8b 10                	mov    (%eax),%edx
  8015af:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015b7:	8d 40 04             	lea    0x4(%eax),%eax
  8015ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015bd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c9:	57                   	push   %edi
  8015ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cd:	50                   	push   %eax
  8015ce:	51                   	push   %ecx
  8015cf:	52                   	push   %edx
  8015d0:	89 da                	mov    %ebx,%edx
  8015d2:	89 f0                	mov    %esi,%eax
  8015d4:	e8 45 fb ff ff       	call   80111e <printnum>
			break;
  8015d9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015df:	83 c7 01             	add    $0x1,%edi
  8015e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015e6:	83 f8 25             	cmp    $0x25,%eax
  8015e9:	0f 84 2f fc ff ff    	je     80121e <vprintfmt+0x17>
			if (ch == '\0')
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	0f 84 8b 00 00 00    	je     801682 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	50                   	push   %eax
  8015fc:	ff d6                	call   *%esi
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb dc                	jmp    8015df <vprintfmt+0x3d8>
	if (lflag >= 2)
  801603:	83 f9 01             	cmp    $0x1,%ecx
  801606:	7e 15                	jle    80161d <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801608:	8b 45 14             	mov    0x14(%ebp),%eax
  80160b:	8b 10                	mov    (%eax),%edx
  80160d:	8b 48 04             	mov    0x4(%eax),%ecx
  801610:	8d 40 08             	lea    0x8(%eax),%eax
  801613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801616:	b8 10 00 00 00       	mov    $0x10,%eax
  80161b:	eb a5                	jmp    8015c2 <vprintfmt+0x3bb>
	else if (lflag)
  80161d:	85 c9                	test   %ecx,%ecx
  80161f:	75 17                	jne    801638 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801621:	8b 45 14             	mov    0x14(%ebp),%eax
  801624:	8b 10                	mov    (%eax),%edx
  801626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80162b:	8d 40 04             	lea    0x4(%eax),%eax
  80162e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801631:	b8 10 00 00 00       	mov    $0x10,%eax
  801636:	eb 8a                	jmp    8015c2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801638:	8b 45 14             	mov    0x14(%ebp),%eax
  80163b:	8b 10                	mov    (%eax),%edx
  80163d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801642:	8d 40 04             	lea    0x4(%eax),%eax
  801645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801648:	b8 10 00 00 00       	mov    $0x10,%eax
  80164d:	e9 70 ff ff ff       	jmp    8015c2 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	53                   	push   %ebx
  801656:	6a 25                	push   $0x25
  801658:	ff d6                	call   *%esi
			break;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	e9 7a ff ff ff       	jmp    8015dc <vprintfmt+0x3d5>
			putch('%', putdat);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	53                   	push   %ebx
  801666:	6a 25                	push   $0x25
  801668:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	89 f8                	mov    %edi,%eax
  80166f:	eb 03                	jmp    801674 <vprintfmt+0x46d>
  801671:	83 e8 01             	sub    $0x1,%eax
  801674:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801678:	75 f7                	jne    801671 <vprintfmt+0x46a>
  80167a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80167d:	e9 5a ff ff ff       	jmp    8015dc <vprintfmt+0x3d5>
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 18             	sub    $0x18,%esp
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801699:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80169d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	74 26                	je     8016d1 <vsnprintf+0x47>
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	7e 22                	jle    8016d1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016af:	ff 75 14             	pushl  0x14(%ebp)
  8016b2:	ff 75 10             	pushl  0x10(%ebp)
  8016b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	68 cd 11 80 00       	push   $0x8011cd
  8016be:	e8 44 fb ff ff       	call   801207 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cc:	83 c4 10             	add    $0x10,%esp
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    
		return -E_INVAL;
  8016d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d6:	eb f7                	jmp    8016cf <vsnprintf+0x45>

008016d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016e1:	50                   	push   %eax
  8016e2:	ff 75 10             	pushl  0x10(%ebp)
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	ff 75 08             	pushl  0x8(%ebp)
  8016eb:	e8 9a ff ff ff       	call   80168a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fd:	eb 03                	jmp    801702 <strlen+0x10>
		n++;
  8016ff:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801702:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801706:	75 f7                	jne    8016ff <strlen+0xd>
	return n;
}
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801710:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801713:	b8 00 00 00 00       	mov    $0x0,%eax
  801718:	eb 03                	jmp    80171d <strnlen+0x13>
		n++;
  80171a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171d:	39 d0                	cmp    %edx,%eax
  80171f:	74 06                	je     801727 <strnlen+0x1d>
  801721:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801725:	75 f3                	jne    80171a <strnlen+0x10>
	return n;
}
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801733:	89 c2                	mov    %eax,%edx
  801735:	83 c1 01             	add    $0x1,%ecx
  801738:	83 c2 01             	add    $0x1,%edx
  80173b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80173f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801742:	84 db                	test   %bl,%bl
  801744:	75 ef                	jne    801735 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801746:	5b                   	pop    %ebx
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801750:	53                   	push   %ebx
  801751:	e8 9c ff ff ff       	call   8016f2 <strlen>
  801756:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801759:	ff 75 0c             	pushl  0xc(%ebp)
  80175c:	01 d8                	add    %ebx,%eax
  80175e:	50                   	push   %eax
  80175f:	e8 c5 ff ff ff       	call   801729 <strcpy>
	return dst;
}
  801764:	89 d8                	mov    %ebx,%eax
  801766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	8b 75 08             	mov    0x8(%ebp),%esi
  801773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801776:	89 f3                	mov    %esi,%ebx
  801778:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177b:	89 f2                	mov    %esi,%edx
  80177d:	eb 0f                	jmp    80178e <strncpy+0x23>
		*dst++ = *src;
  80177f:	83 c2 01             	add    $0x1,%edx
  801782:	0f b6 01             	movzbl (%ecx),%eax
  801785:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801788:	80 39 01             	cmpb   $0x1,(%ecx)
  80178b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80178e:	39 da                	cmp    %ebx,%edx
  801790:	75 ed                	jne    80177f <strncpy+0x14>
	}
	return ret;
}
  801792:	89 f0                	mov    %esi,%eax
  801794:	5b                   	pop    %ebx
  801795:	5e                   	pop    %esi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a6:	89 f0                	mov    %esi,%eax
  8017a8:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017ac:	85 c9                	test   %ecx,%ecx
  8017ae:	75 0b                	jne    8017bb <strlcpy+0x23>
  8017b0:	eb 17                	jmp    8017c9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b2:	83 c2 01             	add    $0x1,%edx
  8017b5:	83 c0 01             	add    $0x1,%eax
  8017b8:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017bb:	39 d8                	cmp    %ebx,%eax
  8017bd:	74 07                	je     8017c6 <strlcpy+0x2e>
  8017bf:	0f b6 0a             	movzbl (%edx),%ecx
  8017c2:	84 c9                	test   %cl,%cl
  8017c4:	75 ec                	jne    8017b2 <strlcpy+0x1a>
		*dst = '\0';
  8017c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c9:	29 f0                	sub    %esi,%eax
}
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d8:	eb 06                	jmp    8017e0 <strcmp+0x11>
		p++, q++;
  8017da:	83 c1 01             	add    $0x1,%ecx
  8017dd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017e0:	0f b6 01             	movzbl (%ecx),%eax
  8017e3:	84 c0                	test   %al,%al
  8017e5:	74 04                	je     8017eb <strcmp+0x1c>
  8017e7:	3a 02                	cmp    (%edx),%al
  8017e9:	74 ef                	je     8017da <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017eb:	0f b6 c0             	movzbl %al,%eax
  8017ee:	0f b6 12             	movzbl (%edx),%edx
  8017f1:	29 d0                	sub    %edx,%eax
}
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ff:	89 c3                	mov    %eax,%ebx
  801801:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801804:	eb 06                	jmp    80180c <strncmp+0x17>
		n--, p++, q++;
  801806:	83 c0 01             	add    $0x1,%eax
  801809:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80180c:	39 d8                	cmp    %ebx,%eax
  80180e:	74 16                	je     801826 <strncmp+0x31>
  801810:	0f b6 08             	movzbl (%eax),%ecx
  801813:	84 c9                	test   %cl,%cl
  801815:	74 04                	je     80181b <strncmp+0x26>
  801817:	3a 0a                	cmp    (%edx),%cl
  801819:	74 eb                	je     801806 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80181b:	0f b6 00             	movzbl (%eax),%eax
  80181e:	0f b6 12             	movzbl (%edx),%edx
  801821:	29 d0                	sub    %edx,%eax
}
  801823:	5b                   	pop    %ebx
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    
		return 0;
  801826:	b8 00 00 00 00       	mov    $0x0,%eax
  80182b:	eb f6                	jmp    801823 <strncmp+0x2e>

0080182d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801837:	0f b6 10             	movzbl (%eax),%edx
  80183a:	84 d2                	test   %dl,%dl
  80183c:	74 09                	je     801847 <strchr+0x1a>
		if (*s == c)
  80183e:	38 ca                	cmp    %cl,%dl
  801840:	74 0a                	je     80184c <strchr+0x1f>
	for (; *s; s++)
  801842:	83 c0 01             	add    $0x1,%eax
  801845:	eb f0                	jmp    801837 <strchr+0xa>
			return (char *) s;
	return 0;
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801858:	eb 03                	jmp    80185d <strfind+0xf>
  80185a:	83 c0 01             	add    $0x1,%eax
  80185d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801860:	38 ca                	cmp    %cl,%dl
  801862:	74 04                	je     801868 <strfind+0x1a>
  801864:	84 d2                	test   %dl,%dl
  801866:	75 f2                	jne    80185a <strfind+0xc>
			break;
	return (char *) s;
}
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	8b 7d 08             	mov    0x8(%ebp),%edi
  801873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801876:	85 c9                	test   %ecx,%ecx
  801878:	74 13                	je     80188d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80187a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801880:	75 05                	jne    801887 <memset+0x1d>
  801882:	f6 c1 03             	test   $0x3,%cl
  801885:	74 0d                	je     801894 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188a:	fc                   	cld    
  80188b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188d:	89 f8                	mov    %edi,%eax
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	5f                   	pop    %edi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    
		c &= 0xFF;
  801894:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801898:	89 d3                	mov    %edx,%ebx
  80189a:	c1 e3 08             	shl    $0x8,%ebx
  80189d:	89 d0                	mov    %edx,%eax
  80189f:	c1 e0 18             	shl    $0x18,%eax
  8018a2:	89 d6                	mov    %edx,%esi
  8018a4:	c1 e6 10             	shl    $0x10,%esi
  8018a7:	09 f0                	or     %esi,%eax
  8018a9:	09 c2                	or     %eax,%edx
  8018ab:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018ad:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018b0:	89 d0                	mov    %edx,%eax
  8018b2:	fc                   	cld    
  8018b3:	f3 ab                	rep stos %eax,%es:(%edi)
  8018b5:	eb d6                	jmp    80188d <memset+0x23>

008018b7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	57                   	push   %edi
  8018bb:	56                   	push   %esi
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c5:	39 c6                	cmp    %eax,%esi
  8018c7:	73 35                	jae    8018fe <memmove+0x47>
  8018c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018cc:	39 c2                	cmp    %eax,%edx
  8018ce:	76 2e                	jbe    8018fe <memmove+0x47>
		s += n;
		d += n;
  8018d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d3:	89 d6                	mov    %edx,%esi
  8018d5:	09 fe                	or     %edi,%esi
  8018d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018dd:	74 0c                	je     8018eb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018df:	83 ef 01             	sub    $0x1,%edi
  8018e2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018e5:	fd                   	std    
  8018e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e8:	fc                   	cld    
  8018e9:	eb 21                	jmp    80190c <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018eb:	f6 c1 03             	test   $0x3,%cl
  8018ee:	75 ef                	jne    8018df <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018f0:	83 ef 04             	sub    $0x4,%edi
  8018f3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018f6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018f9:	fd                   	std    
  8018fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fc:	eb ea                	jmp    8018e8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fe:	89 f2                	mov    %esi,%edx
  801900:	09 c2                	or     %eax,%edx
  801902:	f6 c2 03             	test   $0x3,%dl
  801905:	74 09                	je     801910 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801907:	89 c7                	mov    %eax,%edi
  801909:	fc                   	cld    
  80190a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801910:	f6 c1 03             	test   $0x3,%cl
  801913:	75 f2                	jne    801907 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801915:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801918:	89 c7                	mov    %eax,%edi
  80191a:	fc                   	cld    
  80191b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80191d:	eb ed                	jmp    80190c <memmove+0x55>

0080191f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801922:	ff 75 10             	pushl  0x10(%ebp)
  801925:	ff 75 0c             	pushl  0xc(%ebp)
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 87 ff ff ff       	call   8018b7 <memmove>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193d:	89 c6                	mov    %eax,%esi
  80193f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801942:	39 f0                	cmp    %esi,%eax
  801944:	74 1c                	je     801962 <memcmp+0x30>
		if (*s1 != *s2)
  801946:	0f b6 08             	movzbl (%eax),%ecx
  801949:	0f b6 1a             	movzbl (%edx),%ebx
  80194c:	38 d9                	cmp    %bl,%cl
  80194e:	75 08                	jne    801958 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801950:	83 c0 01             	add    $0x1,%eax
  801953:	83 c2 01             	add    $0x1,%edx
  801956:	eb ea                	jmp    801942 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801958:	0f b6 c1             	movzbl %cl,%eax
  80195b:	0f b6 db             	movzbl %bl,%ebx
  80195e:	29 d8                	sub    %ebx,%eax
  801960:	eb 05                	jmp    801967 <memcmp+0x35>
	}

	return 0;
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801967:	5b                   	pop    %ebx
  801968:	5e                   	pop    %esi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801974:	89 c2                	mov    %eax,%edx
  801976:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801979:	39 d0                	cmp    %edx,%eax
  80197b:	73 09                	jae    801986 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197d:	38 08                	cmp    %cl,(%eax)
  80197f:	74 05                	je     801986 <memfind+0x1b>
	for (; s < ends; s++)
  801981:	83 c0 01             	add    $0x1,%eax
  801984:	eb f3                	jmp    801979 <memfind+0xe>
			break;
	return (void *) s;
}
  801986:	5d                   	pop    %ebp
  801987:	c3                   	ret    

00801988 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	57                   	push   %edi
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
  80198e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801991:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801994:	eb 03                	jmp    801999 <strtol+0x11>
		s++;
  801996:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801999:	0f b6 01             	movzbl (%ecx),%eax
  80199c:	3c 20                	cmp    $0x20,%al
  80199e:	74 f6                	je     801996 <strtol+0xe>
  8019a0:	3c 09                	cmp    $0x9,%al
  8019a2:	74 f2                	je     801996 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019a4:	3c 2b                	cmp    $0x2b,%al
  8019a6:	74 2e                	je     8019d6 <strtol+0x4e>
	int neg = 0;
  8019a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019ad:	3c 2d                	cmp    $0x2d,%al
  8019af:	74 2f                	je     8019e0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b7:	75 05                	jne    8019be <strtol+0x36>
  8019b9:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bc:	74 2c                	je     8019ea <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019be:	85 db                	test   %ebx,%ebx
  8019c0:	75 0a                	jne    8019cc <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019c7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ca:	74 28                	je     8019f4 <strtol+0x6c>
		base = 10;
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019d4:	eb 50                	jmp    801a26 <strtol+0x9e>
		s++;
  8019d6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019de:	eb d1                	jmp    8019b1 <strtol+0x29>
		s++, neg = 1;
  8019e0:	83 c1 01             	add    $0x1,%ecx
  8019e3:	bf 01 00 00 00       	mov    $0x1,%edi
  8019e8:	eb c7                	jmp    8019b1 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ee:	74 0e                	je     8019fe <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f0:	85 db                	test   %ebx,%ebx
  8019f2:	75 d8                	jne    8019cc <strtol+0x44>
		s++, base = 8;
  8019f4:	83 c1 01             	add    $0x1,%ecx
  8019f7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019fc:	eb ce                	jmp    8019cc <strtol+0x44>
		s += 2, base = 16;
  8019fe:	83 c1 02             	add    $0x2,%ecx
  801a01:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a06:	eb c4                	jmp    8019cc <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a08:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0b:	89 f3                	mov    %esi,%ebx
  801a0d:	80 fb 19             	cmp    $0x19,%bl
  801a10:	77 29                	ja     801a3b <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a12:	0f be d2             	movsbl %dl,%edx
  801a15:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a18:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1b:	7d 30                	jge    801a4d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a1d:	83 c1 01             	add    $0x1,%ecx
  801a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a24:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a26:	0f b6 11             	movzbl (%ecx),%edx
  801a29:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a2c:	89 f3                	mov    %esi,%ebx
  801a2e:	80 fb 09             	cmp    $0x9,%bl
  801a31:	77 d5                	ja     801a08 <strtol+0x80>
			dig = *s - '0';
  801a33:	0f be d2             	movsbl %dl,%edx
  801a36:	83 ea 30             	sub    $0x30,%edx
  801a39:	eb dd                	jmp    801a18 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a3e:	89 f3                	mov    %esi,%ebx
  801a40:	80 fb 19             	cmp    $0x19,%bl
  801a43:	77 08                	ja     801a4d <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a45:	0f be d2             	movsbl %dl,%edx
  801a48:	83 ea 37             	sub    $0x37,%edx
  801a4b:	eb cb                	jmp    801a18 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a51:	74 05                	je     801a58 <strtol+0xd0>
		*endptr = (char *) s;
  801a53:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a56:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	f7 da                	neg    %edx
  801a5c:	85 ff                	test   %edi,%edi
  801a5e:	0f 45 c2             	cmovne %edx,%eax
}
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a74:	85 c0                	test   %eax,%eax
  801a76:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a7b:	0f 44 c2             	cmove  %edx,%eax
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	50                   	push   %eax
  801a82:	e8 7e e8 ff ff       	call   800305 <sys_ipc_recv>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 2b                	js     801ab9 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a8e:	85 f6                	test   %esi,%esi
  801a90:	74 0a                	je     801a9c <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801a92:	a1 04 40 80 00       	mov    0x804004,%eax
  801a97:	8b 40 74             	mov    0x74(%eax),%eax
  801a9a:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	74 0a                	je     801aaa <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 40 78             	mov    0x78(%eax),%eax
  801aa8:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801aaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaf:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    
        *from_env_store = 0;
  801ab9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801abf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ac5:	eb eb                	jmp    801ab2 <ipc_recv+0x4c>

00801ac7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	57                   	push   %edi
  801acb:	56                   	push   %esi
  801acc:	53                   	push   %ebx
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ad9:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801adb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae0:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801ae3:	ff 75 14             	pushl  0x14(%ebp)
  801ae6:	53                   	push   %ebx
  801ae7:	56                   	push   %esi
  801ae8:	57                   	push   %edi
  801ae9:	e8 f4 e7 ff ff       	call   8002e2 <sys_ipc_try_send>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	74 17                	je     801b0c <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801af5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af8:	74 e9                	je     801ae3 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801afa:	50                   	push   %eax
  801afb:	68 60 22 80 00       	push   $0x802260
  801b00:	6a 3e                	push   $0x3e
  801b02:	68 72 22 80 00       	push   $0x802272
  801b07:	e8 23 f5 ff ff       	call   80102f <_panic>
        }
    }
}
  801b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b22:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b28:	8b 52 50             	mov    0x50(%edx),%edx
  801b2b:	39 ca                	cmp    %ecx,%edx
  801b2d:	74 11                	je     801b40 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b2f:	83 c0 01             	add    $0x1,%eax
  801b32:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b37:	75 e6                	jne    801b1f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 0b                	jmp    801b4b <ipc_find_env+0x37>
			return envs[i].env_id;
  801b40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b48:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	c1 e8 16             	shr    $0x16,%eax
  801b58:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b64:	f6 c1 01             	test   $0x1,%cl
  801b67:	74 1d                	je     801b86 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b69:	c1 ea 0c             	shr    $0xc,%edx
  801b6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b73:	f6 c2 01             	test   $0x1,%dl
  801b76:	74 0e                	je     801b86 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b78:	c1 ea 0c             	shr    $0xc,%edx
  801b7b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b82:	ef 
  801b83:	0f b7 c0             	movzwl %ax,%eax
}
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	66 90                	xchg   %ax,%ax
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

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
