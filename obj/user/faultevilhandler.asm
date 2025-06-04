
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 92 04 00 00       	call   800548 <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7f 08                	jg     80012c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	50                   	push   %eax
  800130:	6a 03                	push   $0x3
  800132:	68 0a 1e 80 00       	push   $0x801e0a
  800137:	6a 23                	push   $0x23
  800139:	68 27 1e 80 00       	push   $0x801e27
  80013e:	e8 18 0f 00 00       	call   80105b <_panic>

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7f 08                	jg     8001ad <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	50                   	push   %eax
  8001b1:	6a 04                	push   $0x4
  8001b3:	68 0a 1e 80 00       	push   $0x801e0a
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 27 1e 80 00       	push   $0x801e27
  8001bf:	e8 97 0e 00 00       	call   80105b <_panic>

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7f 08                	jg     8001ef <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	50                   	push   %eax
  8001f3:	6a 05                	push   $0x5
  8001f5:	68 0a 1e 80 00       	push   $0x801e0a
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 27 1e 80 00       	push   $0x801e27
  800201:	e8 55 0e 00 00       	call   80105b <_panic>

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7f 08                	jg     800231 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 0a 1e 80 00       	push   $0x801e0a
  80023c:	6a 23                	push   $0x23
  80023e:	68 27 1e 80 00       	push   $0x801e27
  800243:	e8 13 0e 00 00       	call   80105b <_panic>

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 0a 1e 80 00       	push   $0x801e0a
  80027e:	6a 23                	push   $0x23
  800280:	68 27 1e 80 00       	push   $0x801e27
  800285:	e8 d1 0d 00 00       	call   80105b <_panic>

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7f 08                	jg     8002b5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 0a 1e 80 00       	push   $0x801e0a
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 27 1e 80 00       	push   $0x801e27
  8002c7:	e8 8f 0d 00 00       	call   80105b <_panic>

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7f 08                	jg     8002f7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	50                   	push   %eax
  8002fb:	6a 0a                	push   $0xa
  8002fd:	68 0a 1e 80 00       	push   $0x801e0a
  800302:	6a 23                	push   $0x23
  800304:	68 27 1e 80 00       	push   $0x801e27
  800309:	e8 4d 0d 00 00       	call   80105b <_panic>

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	asm volatile("int %1\n"
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	b8 0d 00 00 00       	mov    $0xd,%eax
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7f 08                	jg     80035b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	50                   	push   %eax
  80035f:	6a 0d                	push   $0xd
  800361:	68 0a 1e 80 00       	push   $0x801e0a
  800366:	6a 23                	push   $0x23
  800368:	68 27 1e 80 00       	push   $0x801e27
  80036d:	e8 e9 0c 00 00       	call   80105b <_panic>

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 2a                	je     8003df <fd_alloc+0x46>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	74 19                	je     8003df <fd_alloc+0x46>
  8003c6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d0:	75 d2                	jne    8003a4 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003dd:	eb 07                	jmp    8003e6 <fd_alloc+0x4d>
			*fd_store = fd;
  8003df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb f7                	jmp    800427 <fd_lookup+0x3f>
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb f0                	jmp    800427 <fd_lookup+0x3f>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043c:	eb e9                	jmp    800427 <fd_lookup+0x3f>

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	74 33                	je     800488 <dev_lookup+0x4a>
  800455:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800458:	8b 02                	mov    (%edx),%eax
  80045a:	85 c0                	test   %eax,%eax
  80045c:	75 f3                	jne    800451 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045e:	a1 04 40 80 00       	mov    0x804004,%eax
  800463:	8b 40 48             	mov    0x48(%eax),%eax
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	51                   	push   %ecx
  80046a:	50                   	push   %eax
  80046b:	68 38 1e 80 00       	push   $0x801e38
  800470:	e8 c1 0c 00 00       	call   801136 <cprintf>
	*dev = 0;
  800475:	8b 45 0c             	mov    0xc(%ebp),%eax
  800478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    
			*dev = devtab[i];
  800488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	eb f2                	jmp    800486 <dev_lookup+0x48>

00800494 <fd_close>:
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 1c             	sub    $0x1c,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004a6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b0:	50                   	push   %eax
  8004b1:	e8 32 ff ff ff       	call   8003e8 <fd_lookup>
  8004b6:	89 c3                	mov    %eax,%ebx
  8004b8:	83 c4 08             	add    $0x8,%esp
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	78 05                	js     8004c4 <fd_close+0x30>
	    || fd != fd2)
  8004bf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004c2:	74 16                	je     8004da <fd_close+0x46>
		return (must_exist ? r : 0);
  8004c4:	89 f8                	mov    %edi,%eax
  8004c6:	84 c0                	test   %al,%al
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	0f 44 d8             	cmove  %eax,%ebx
}
  8004d0:	89 d8                	mov    %ebx,%eax
  8004d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d5:	5b                   	pop    %ebx
  8004d6:	5e                   	pop    %esi
  8004d7:	5f                   	pop    %edi
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff 36                	pushl  (%esi)
  8004e3:	e8 56 ff ff ff       	call   80043e <dev_lookup>
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	78 15                	js     800506 <fd_close+0x72>
		if (dev->dev_close)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	8b 40 10             	mov    0x10(%eax),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	74 1b                	je     800516 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	56                   	push   %esi
  8004ff:	ff d0                	call   *%eax
  800501:	89 c3                	mov    %eax,%ebx
  800503:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	56                   	push   %esi
  80050a:	6a 00                	push   $0x0
  80050c:	e8 f5 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb ba                	jmp    8004d0 <fd_close+0x3c>
			r = 0;
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80051b:	eb e9                	jmp    800506 <fd_close+0x72>

0080051d <close>:

int
close(int fdnum)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800526:	50                   	push   %eax
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 b9 fe ff ff       	call   8003e8 <fd_lookup>
  80052f:	83 c4 08             	add    $0x8,%esp
  800532:	85 c0                	test   %eax,%eax
  800534:	78 10                	js     800546 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	6a 01                	push   $0x1
  80053b:	ff 75 f4             	pushl  -0xc(%ebp)
  80053e:	e8 51 ff ff ff       	call   800494 <fd_close>
  800543:	83 c4 10             	add    $0x10,%esp
}
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <close_all>:

void
close_all(void)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	53                   	push   %ebx
  80054c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800554:	83 ec 0c             	sub    $0xc,%esp
  800557:	53                   	push   %ebx
  800558:	e8 c0 ff ff ff       	call   80051d <close>
	for (i = 0; i < MAXFD; i++)
  80055d:	83 c3 01             	add    $0x1,%ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	83 fb 20             	cmp    $0x20,%ebx
  800566:	75 ec                	jne    800554 <close_all+0xc>
}
  800568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 66 fe ff ff       	call   8003e8 <fd_lookup>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	83 c4 08             	add    $0x8,%esp
  800587:	85 c0                	test   %eax,%eax
  800589:	0f 88 81 00 00 00    	js     800610 <dup+0xa3>
		return r;
	close(newfdnum);
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	e8 83 ff ff ff       	call   80051d <close>

	newfd = INDEX2FD(newfdnum);
  80059a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059d:	c1 e6 0c             	shl    $0xc,%esi
  8005a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005a6:	83 c4 04             	add    $0x4,%esp
  8005a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ac:	e8 d1 fd ff ff       	call   800382 <fd2data>
  8005b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	e8 c7 fd ff ff       	call   800382 <fd2data>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c0:	89 d8                	mov    %ebx,%eax
  8005c2:	c1 e8 16             	shr    $0x16,%eax
  8005c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005cc:	a8 01                	test   $0x1,%al
  8005ce:	74 11                	je     8005e1 <dup+0x74>
  8005d0:	89 d8                	mov    %ebx,%eax
  8005d2:	c1 e8 0c             	shr    $0xc,%eax
  8005d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005dc:	f6 c2 01             	test   $0x1,%dl
  8005df:	75 39                	jne    80061a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 d0                	mov    %edx,%eax
  8005e6:	c1 e8 0c             	shr    $0xc,%eax
  8005e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f8:	50                   	push   %eax
  8005f9:	56                   	push   %esi
  8005fa:	6a 00                	push   $0x0
  8005fc:	52                   	push   %edx
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 c0 fb ff ff       	call   8001c4 <sys_page_map>
  800604:	89 c3                	mov    %eax,%ebx
  800606:	83 c4 20             	add    $0x20,%esp
  800609:	85 c0                	test   %eax,%eax
  80060b:	78 31                	js     80063e <dup+0xd1>
		goto err;

	return newfdnum;
  80060d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800610:	89 d8                	mov    %ebx,%eax
  800612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800615:	5b                   	pop    %ebx
  800616:	5e                   	pop    %esi
  800617:	5f                   	pop    %edi
  800618:	5d                   	pop    %ebp
  800619:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	25 07 0e 00 00       	and    $0xe07,%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	6a 00                	push   $0x0
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 8f fb ff ff       	call   8001c4 <sys_page_map>
  800635:	89 c3                	mov    %eax,%ebx
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	79 a3                	jns    8005e1 <dup+0x74>
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	56                   	push   %esi
  800642:	6a 00                	push   $0x0
  800644:	e8 bd fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 00                	push   $0x0
  80064f:	e8 b2 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb b7                	jmp    800610 <dup+0xa3>

00800659 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	53                   	push   %ebx
  80065d:	83 ec 14             	sub    $0x14,%esp
  800660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800663:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	53                   	push   %ebx
  800668:	e8 7b fd ff ff       	call   8003e8 <fd_lookup>
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	85 c0                	test   %eax,%eax
  800672:	78 3f                	js     8006b3 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067e:	ff 30                	pushl  (%eax)
  800680:	e8 b9 fd ff ff       	call   80043e <dev_lookup>
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	85 c0                	test   %eax,%eax
  80068a:	78 27                	js     8006b3 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068f:	8b 42 08             	mov    0x8(%edx),%eax
  800692:	83 e0 03             	and    $0x3,%eax
  800695:	83 f8 01             	cmp    $0x1,%eax
  800698:	74 1e                	je     8006b8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	8b 40 08             	mov    0x8(%eax),%eax
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	74 35                	je     8006d9 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	52                   	push   %edx
  8006ae:	ff d0                	call   *%eax
  8006b0:	83 c4 10             	add    $0x10,%esp
}
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006bd:	8b 40 48             	mov    0x48(%eax),%eax
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	50                   	push   %eax
  8006c5:	68 79 1e 80 00       	push   $0x801e79
  8006ca:	e8 67 0a 00 00       	call   801136 <cprintf>
		return -E_INVAL;
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb da                	jmp    8006b3 <read+0x5a>
		return -E_NOT_SUPP;
  8006d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006de:	eb d3                	jmp    8006b3 <read+0x5a>

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	39 f3                	cmp    %esi,%ebx
  8006f6:	73 25                	jae    80071d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	83 ec 04             	sub    $0x4,%esp
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	29 d8                	sub    %ebx,%eax
  8006ff:	50                   	push   %eax
  800700:	89 d8                	mov    %ebx,%eax
  800702:	03 45 0c             	add    0xc(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	57                   	push   %edi
  800707:	e8 4d ff ff ff       	call   800659 <read>
		if (m < 0)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	78 08                	js     80071b <readn+0x3b>
			return m;
		if (m == 0)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 06                	je     80071d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800717:	01 c3                	add    %eax,%ebx
  800719:	eb d9                	jmp    8006f4 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80071d:	89 d8                	mov    %ebx,%eax
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	83 ec 14             	sub    $0x14,%esp
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800731:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	53                   	push   %ebx
  800736:	e8 ad fc ff ff       	call   8003e8 <fd_lookup>
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 3a                	js     80077c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074c:	ff 30                	pushl  (%eax)
  80074e:	e8 eb fc ff ff       	call   80043e <dev_lookup>
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 22                	js     80077c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800761:	74 1e                	je     800781 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800763:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800766:	8b 52 0c             	mov    0xc(%edx),%edx
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 35                	je     8007a2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076d:	83 ec 04             	sub    $0x4,%esp
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	50                   	push   %eax
  800777:	ff d2                	call   *%edx
  800779:	83 c4 10             	add    $0x10,%esp
}
  80077c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800781:	a1 04 40 80 00       	mov    0x804004,%eax
  800786:	8b 40 48             	mov    0x48(%eax),%eax
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	53                   	push   %ebx
  80078d:	50                   	push   %eax
  80078e:	68 95 1e 80 00       	push   $0x801e95
  800793:	e8 9e 09 00 00       	call   801136 <cprintf>
		return -E_INVAL;
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a0:	eb da                	jmp    80077c <write+0x55>
		return -E_NOT_SUPP;
  8007a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a7:	eb d3                	jmp    80077c <write+0x55>

008007a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 2d fc ff ff       	call   8003e8 <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 0e                	js     8007d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 14             	sub    $0x14,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	53                   	push   %ebx
  8007e1:	e8 02 fc ff ff       	call   8003e8 <fd_lookup>
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 37                	js     800824 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 40 fc ff ff       	call   80043e <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 1f                	js     800824 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	74 1b                	je     800829 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800811:	8b 52 18             	mov    0x18(%edx),%edx
  800814:	85 d2                	test   %edx,%edx
  800816:	74 32                	je     80084a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	50                   	push   %eax
  80081f:	ff d2                	call   *%edx
  800821:	83 c4 10             	add    $0x10,%esp
}
  800824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800827:	c9                   	leave  
  800828:	c3                   	ret    
			thisenv->env_id, fdnum);
  800829:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80082e:	8b 40 48             	mov    0x48(%eax),%eax
  800831:	83 ec 04             	sub    $0x4,%esp
  800834:	53                   	push   %ebx
  800835:	50                   	push   %eax
  800836:	68 58 1e 80 00       	push   $0x801e58
  80083b:	e8 f6 08 00 00       	call   801136 <cprintf>
		return -E_INVAL;
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800848:	eb da                	jmp    800824 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80084a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80084f:	eb d3                	jmp    800824 <ftruncate+0x52>

00800851 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 14             	sub    $0x14,%esp
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 81 fb ff ff       	call   8003e8 <fd_lookup>
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 4b                	js     8008b9 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 bf fb ff ff       	call   80043e <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 33                	js     8008b9 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 2f                	je     8008be <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	83 c4 10             	add    $0x10,%esp
}
  8008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    
		return -E_NOT_SUPP;
  8008be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008c3:	eb f4                	jmp    8008b9 <fstat+0x68>

008008c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	6a 00                	push   $0x0
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 e7 01 00 00       	call   800abe <open>
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 1b                	js     8008fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	50                   	push   %eax
  8008e7:	e8 65 ff ff ff       	call   800851 <fstat>
  8008ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ee:	89 1c 24             	mov    %ebx,(%esp)
  8008f1:	e8 27 fc ff ff       	call   80051d <close>
	return r;
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	89 f3                	mov    %esi,%ebx
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	89 c6                	mov    %eax,%esi
  80090b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800914:	74 27                	je     80093d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800916:	6a 07                	push   $0x7
  800918:	68 00 50 80 00       	push   $0x805000
  80091d:	56                   	push   %esi
  80091e:	ff 35 00 40 80 00    	pushl  0x804000
  800924:	e8 ca 11 00 00       	call   801af3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800929:	83 c4 0c             	add    $0xc,%esp
  80092c:	6a 00                	push   $0x0
  80092e:	53                   	push   %ebx
  80092f:	6a 00                	push   $0x0
  800931:	e8 5c 11 00 00       	call   801a92 <ipc_recv>
}
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093d:	83 ec 0c             	sub    $0xc,%esp
  800940:	6a 01                	push   $0x1
  800942:	e8 f9 11 00 00       	call   801b40 <ipc_find_env>
  800947:	a3 00 40 80 00       	mov    %eax,0x804000
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	eb c5                	jmp    800916 <fsipc+0x12>

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8b ff ff ff       	call   800904 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 69 ff ff ff       	call   800904 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 43 ff ff ff       	call   800904 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 82 0d 00 00       	call   801755 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009ff:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a04:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a09:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a12:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a18:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 b8 0e 00 00       	call   8018e3 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 ca fe ff ff       	call   800904 <fsipc>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_read>:
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	e8 a0 fe ff ff       	call   800904 <fsipc>
  800a64:	89 c3                	mov    %eax,%ebx
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 1f                	js     800a89 <devfile_read+0x4d>
	assert(r <= n);
  800a6a:	39 f0                	cmp    %esi,%eax
  800a6c:	77 24                	ja     800a92 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a73:	7f 33                	jg     800aa8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	50                   	push   %eax
  800a79:	68 00 50 80 00       	push   $0x805000
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	e8 5d 0e 00 00       	call   8018e3 <memmove>
	return r;
  800a86:	83 c4 10             	add    $0x10,%esp
}
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    
	assert(r <= n);
  800a92:	68 c4 1e 80 00       	push   $0x801ec4
  800a97:	68 cb 1e 80 00       	push   $0x801ecb
  800a9c:	6a 7d                	push   $0x7d
  800a9e:	68 e0 1e 80 00       	push   $0x801ee0
  800aa3:	e8 b3 05 00 00       	call   80105b <_panic>
	assert(r <= PGSIZE);
  800aa8:	68 eb 1e 80 00       	push   $0x801eeb
  800aad:	68 cb 1e 80 00       	push   $0x801ecb
  800ab2:	6a 7e                	push   $0x7e
  800ab4:	68 e0 1e 80 00       	push   $0x801ee0
  800ab9:	e8 9d 05 00 00       	call   80105b <_panic>

00800abe <open>:
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 1c             	sub    $0x1c,%esp
  800ac6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ac9:	56                   	push   %esi
  800aca:	e8 4f 0c 00 00       	call   80171e <strlen>
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad7:	0f 8f 96 00 00 00    	jg     800b73 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae3:	50                   	push   %eax
  800ae4:	e8 b0 f8 ff ff       	call   800399 <fd_alloc>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 66                	js     800b58 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800af2:	83 ec 08             	sub    $0x8,%esp
  800af5:	56                   	push   %esi
  800af6:	68 00 50 80 00       	push   $0x805000
  800afb:	e8 55 0c 00 00       	call   801755 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b10:	e8 ef fd ff ff       	call   800904 <fsipc>
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	78 43                	js     800b61 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	ff 75 f4             	pushl  -0xc(%ebp)
  800b24:	e8 49 f8 ff ff       	call   800372 <fd2num>
  800b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2c:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b32:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	50                   	push   %eax
  800b39:	52                   	push   %edx
  800b3a:	ff 32                	pushl  (%edx)
  800b3c:	56                   	push   %esi
  800b3d:	51                   	push   %ecx
  800b3e:	68 f8 1e 80 00       	push   $0x801ef8
  800b43:	e8 ee 05 00 00       	call   801136 <cprintf>
	return fd2num(fd);
  800b48:	83 c4 14             	add    $0x14,%esp
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 1f f8 ff ff       	call   800372 <fd2num>
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	83 c4 10             	add    $0x10,%esp
}
  800b58:	89 d8                	mov    %ebx,%eax
  800b5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    
		fd_close(fd, 0);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	6a 00                	push   $0x0
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 26 f9 ff ff       	call   800494 <fd_close>
		return r;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	eb e5                	jmp    800b58 <open+0x9a>
		return -E_BAD_PATH;
  800b73:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b78:	eb de                	jmp    800b58 <open+0x9a>

00800b7a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8a:	e8 75 fd ff ff       	call   800904 <fsipc>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	ff 75 08             	pushl  0x8(%ebp)
  800b9f:	e8 de f7 ff ff       	call   800382 <fd2data>
  800ba4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba6:	83 c4 08             	add    $0x8,%esp
  800ba9:	68 37 1f 80 00       	push   $0x801f37
  800bae:	53                   	push   %ebx
  800baf:	e8 a1 0b 00 00       	call   801755 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb4:	8b 46 04             	mov    0x4(%esi),%eax
  800bb7:	2b 06                	sub    (%esi),%eax
  800bb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc6:	00 00 00 
	stat->st_dev = &devpipe;
  800bc9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd0:	30 80 00 
	return 0;
}
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be9:	53                   	push   %ebx
  800bea:	6a 00                	push   $0x0
  800bec:	e8 15 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf1:	89 1c 24             	mov    %ebx,(%esp)
  800bf4:	e8 89 f7 ff ff       	call   800382 <fd2data>
  800bf9:	83 c4 08             	add    $0x8,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 00                	push   $0x0
  800bff:	e8 02 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <_pipeisclosed>:
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 1c             	sub    $0x1c,%esp
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c16:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	57                   	push   %edi
  800c22:	e8 52 0f 00 00       	call   801b79 <pageref>
  800c27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c2a:	89 34 24             	mov    %esi,(%esp)
  800c2d:	e8 47 0f 00 00       	call   801b79 <pageref>
		nn = thisenv->env_runs;
  800c32:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c38:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	39 cb                	cmp    %ecx,%ebx
  800c40:	74 1b                	je     800c5d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c42:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c45:	75 cf                	jne    800c16 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c47:	8b 42 58             	mov    0x58(%edx),%eax
  800c4a:	6a 01                	push   $0x1
  800c4c:	50                   	push   %eax
  800c4d:	53                   	push   %ebx
  800c4e:	68 3e 1f 80 00       	push   $0x801f3e
  800c53:	e8 de 04 00 00       	call   801136 <cprintf>
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	eb b9                	jmp    800c16 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c5d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c60:	0f 94 c0             	sete   %al
  800c63:	0f b6 c0             	movzbl %al,%eax
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <devpipe_write>:
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 28             	sub    $0x28,%esp
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c7a:	56                   	push   %esi
  800c7b:	e8 02 f7 ff ff       	call   800382 <fd2data>
  800c80:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c8d:	74 4f                	je     800cde <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c92:	8b 0b                	mov    (%ebx),%ecx
  800c94:	8d 51 20             	lea    0x20(%ecx),%edx
  800c97:	39 d0                	cmp    %edx,%eax
  800c99:	72 14                	jb     800caf <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c9b:	89 da                	mov    %ebx,%edx
  800c9d:	89 f0                	mov    %esi,%eax
  800c9f:	e8 65 ff ff ff       	call   800c09 <_pipeisclosed>
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	75 3a                	jne    800ce2 <devpipe_write+0x74>
			sys_yield();
  800ca8:	e8 b5 f4 ff ff       	call   800162 <sys_yield>
  800cad:	eb e0                	jmp    800c8f <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb9:	89 c2                	mov    %eax,%edx
  800cbb:	c1 fa 1f             	sar    $0x1f,%edx
  800cbe:	89 d1                	mov    %edx,%ecx
  800cc0:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc6:	83 e2 1f             	and    $0x1f,%edx
  800cc9:	29 ca                	sub    %ecx,%edx
  800ccb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ccf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cd9:	83 c7 01             	add    $0x1,%edi
  800cdc:	eb ac                	jmp    800c8a <devpipe_write+0x1c>
	return i;
  800cde:	89 f8                	mov    %edi,%eax
  800ce0:	eb 05                	jmp    800ce7 <devpipe_write+0x79>
				return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <devpipe_read>:
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 18             	sub    $0x18,%esp
  800cf8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cfb:	57                   	push   %edi
  800cfc:	e8 81 f6 ff ff       	call   800382 <fd2data>
  800d01:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
  800d0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d0e:	74 47                	je     800d57 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800d10:	8b 03                	mov    (%ebx),%eax
  800d12:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d15:	75 22                	jne    800d39 <devpipe_read+0x4a>
			if (i > 0)
  800d17:	85 f6                	test   %esi,%esi
  800d19:	75 14                	jne    800d2f <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800d1b:	89 da                	mov    %ebx,%edx
  800d1d:	89 f8                	mov    %edi,%eax
  800d1f:	e8 e5 fe ff ff       	call   800c09 <_pipeisclosed>
  800d24:	85 c0                	test   %eax,%eax
  800d26:	75 33                	jne    800d5b <devpipe_read+0x6c>
			sys_yield();
  800d28:	e8 35 f4 ff ff       	call   800162 <sys_yield>
  800d2d:	eb e1                	jmp    800d10 <devpipe_read+0x21>
				return i;
  800d2f:	89 f0                	mov    %esi,%eax
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d39:	99                   	cltd   
  800d3a:	c1 ea 1b             	shr    $0x1b,%edx
  800d3d:	01 d0                	add    %edx,%eax
  800d3f:	83 e0 1f             	and    $0x1f,%eax
  800d42:	29 d0                	sub    %edx,%eax
  800d44:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d4f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d52:	83 c6 01             	add    $0x1,%esi
  800d55:	eb b4                	jmp    800d0b <devpipe_read+0x1c>
	return i;
  800d57:	89 f0                	mov    %esi,%eax
  800d59:	eb d6                	jmp    800d31 <devpipe_read+0x42>
				return 0;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d60:	eb cf                	jmp    800d31 <devpipe_read+0x42>

00800d62 <pipe>:
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6d:	50                   	push   %eax
  800d6e:	e8 26 f6 ff ff       	call   800399 <fd_alloc>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 5b                	js     800dd7 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7c:	83 ec 04             	sub    $0x4,%esp
  800d7f:	68 07 04 00 00       	push   $0x407
  800d84:	ff 75 f4             	pushl  -0xc(%ebp)
  800d87:	6a 00                	push   $0x0
  800d89:	e8 f3 f3 ff ff       	call   800181 <sys_page_alloc>
  800d8e:	89 c3                	mov    %eax,%ebx
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	85 c0                	test   %eax,%eax
  800d95:	78 40                	js     800dd7 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9d:	50                   	push   %eax
  800d9e:	e8 f6 f5 ff ff       	call   800399 <fd_alloc>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	78 1b                	js     800dc7 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	68 07 04 00 00       	push   $0x407
  800db4:	ff 75 f0             	pushl  -0x10(%ebp)
  800db7:	6a 00                	push   $0x0
  800db9:	e8 c3 f3 ff ff       	call   800181 <sys_page_alloc>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 19                	jns    800de0 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800dc7:	83 ec 08             	sub    $0x8,%esp
  800dca:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 32 f4 ff ff       	call   800206 <sys_page_unmap>
  800dd4:	83 c4 10             	add    $0x10,%esp
}
  800dd7:	89 d8                	mov    %ebx,%eax
  800dd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
	va = fd2data(fd0);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	ff 75 f4             	pushl  -0xc(%ebp)
  800de6:	e8 97 f5 ff ff       	call   800382 <fd2data>
  800deb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ded:	83 c4 0c             	add    $0xc,%esp
  800df0:	68 07 04 00 00       	push   $0x407
  800df5:	50                   	push   %eax
  800df6:	6a 00                	push   $0x0
  800df8:	e8 84 f3 ff ff       	call   800181 <sys_page_alloc>
  800dfd:	89 c3                	mov    %eax,%ebx
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	0f 88 8c 00 00 00    	js     800e96 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e10:	e8 6d f5 ff ff       	call   800382 <fd2data>
  800e15:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e1c:	50                   	push   %eax
  800e1d:	6a 00                	push   $0x0
  800e1f:	56                   	push   %esi
  800e20:	6a 00                	push   $0x0
  800e22:	e8 9d f3 ff ff       	call   8001c4 <sys_page_map>
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	83 c4 20             	add    $0x20,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 58                	js     800e88 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e53:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e5a:	83 ec 0c             	sub    $0xc,%esp
  800e5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e60:	e8 0d f5 ff ff       	call   800372 <fd2num>
  800e65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e68:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6a:	83 c4 04             	add    $0x4,%esp
  800e6d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e70:	e8 fd f4 ff ff       	call   800372 <fd2num>
  800e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e78:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e83:	e9 4f ff ff ff       	jmp    800dd7 <pipe+0x75>
	sys_page_unmap(0, va);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	56                   	push   %esi
  800e8c:	6a 00                	push   $0x0
  800e8e:	e8 73 f3 ff ff       	call   800206 <sys_page_unmap>
  800e93:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 63 f3 ff ff       	call   800206 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	e9 1c ff ff ff       	jmp    800dc7 <pipe+0x65>

00800eab <pipeisclosed>:
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb4:	50                   	push   %eax
  800eb5:	ff 75 08             	pushl  0x8(%ebp)
  800eb8:	e8 2b f5 ff ff       	call   8003e8 <fd_lookup>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 18                	js     800edc <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eca:	e8 b3 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed4:	e8 30 fd ff ff       	call   800c09 <_pipeisclosed>
  800ed9:	83 c4 10             	add    $0x10,%esp
}
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eee:	68 56 1f 80 00       	push   $0x801f56
  800ef3:	ff 75 0c             	pushl  0xc(%ebp)
  800ef6:	e8 5a 08 00 00       	call   801755 <strcpy>
	return 0;
}
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <devcons_write>:
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f0e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f13:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f19:	eb 2f                	jmp    800f4a <devcons_write+0x48>
		m = n - tot;
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	29 f3                	sub    %esi,%ebx
  800f20:	83 fb 7f             	cmp    $0x7f,%ebx
  800f23:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f28:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	53                   	push   %ebx
  800f2f:	89 f0                	mov    %esi,%eax
  800f31:	03 45 0c             	add    0xc(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	57                   	push   %edi
  800f36:	e8 a8 09 00 00       	call   8018e3 <memmove>
		sys_cputs(buf, m);
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	53                   	push   %ebx
  800f3f:	57                   	push   %edi
  800f40:	e8 80 f1 ff ff       	call   8000c5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f45:	01 de                	add    %ebx,%esi
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f4d:	72 cc                	jb     800f1b <devcons_write+0x19>
}
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <devcons_read>:
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f68:	75 07                	jne    800f71 <devcons_read+0x18>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    
		sys_yield();
  800f6c:	e8 f1 f1 ff ff       	call   800162 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f71:	e8 6d f1 ff ff       	call   8000e3 <sys_cgetc>
  800f76:	85 c0                	test   %eax,%eax
  800f78:	74 f2                	je     800f6c <devcons_read+0x13>
	if (c < 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 ec                	js     800f6a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f7e:	83 f8 04             	cmp    $0x4,%eax
  800f81:	74 0c                	je     800f8f <devcons_read+0x36>
	*(char*)vbuf = c;
  800f83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f86:	88 02                	mov    %al,(%edx)
	return 1;
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	eb db                	jmp    800f6a <devcons_read+0x11>
		return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	eb d4                	jmp    800f6a <devcons_read+0x11>

00800f96 <cputchar>:
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fa2:	6a 01                	push   $0x1
  800fa4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	e8 18 f1 ff ff       	call   8000c5 <sys_cputs>
}
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <getchar>:
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fb8:	6a 01                	push   $0x1
  800fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	6a 00                	push   $0x0
  800fc0:	e8 94 f6 ff ff       	call   800659 <read>
	if (r < 0)
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 08                	js     800fd4 <getchar+0x22>
	if (r < 1)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	7e 06                	jle    800fd6 <getchar+0x24>
	return c;
  800fd0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    
		return -E_EOF;
  800fd6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fdb:	eb f7                	jmp    800fd4 <getchar+0x22>

00800fdd <iscons>:
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 75 08             	pushl  0x8(%ebp)
  800fea:	e8 f9 f3 ff ff       	call   8003e8 <fd_lookup>
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 11                	js     801007 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fff:	39 10                	cmp    %edx,(%eax)
  801001:	0f 94 c0             	sete   %al
  801004:	0f b6 c0             	movzbl %al,%eax
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <opencons>:
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80100f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801012:	50                   	push   %eax
  801013:	e8 81 f3 ff ff       	call   800399 <fd_alloc>
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 3a                	js     801059 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 07 04 00 00       	push   $0x407
  801027:	ff 75 f4             	pushl  -0xc(%ebp)
  80102a:	6a 00                	push   $0x0
  80102c:	e8 50 f1 ff ff       	call   800181 <sys_page_alloc>
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 21                	js     801059 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801041:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801046:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	e8 1c f3 ff ff       	call   800372 <fd2num>
  801056:	83 c4 10             	add    $0x10,%esp
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801060:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801063:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801069:	e8 d5 f0 ff ff       	call   800143 <sys_getenvid>
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	ff 75 0c             	pushl  0xc(%ebp)
  801074:	ff 75 08             	pushl  0x8(%ebp)
  801077:	56                   	push   %esi
  801078:	50                   	push   %eax
  801079:	68 64 1f 80 00       	push   $0x801f64
  80107e:	e8 b3 00 00 00       	call   801136 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801083:	83 c4 18             	add    $0x18,%esp
  801086:	53                   	push   %ebx
  801087:	ff 75 10             	pushl  0x10(%ebp)
  80108a:	e8 56 00 00 00       	call   8010e5 <vcprintf>
	cprintf("\n");
  80108f:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  801096:	e8 9b 00 00 00       	call   801136 <cprintf>
  80109b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109e:	cc                   	int3   
  80109f:	eb fd                	jmp    80109e <_panic+0x43>

008010a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ab:	8b 13                	mov    (%ebx),%edx
  8010ad:	8d 42 01             	lea    0x1(%edx),%eax
  8010b0:	89 03                	mov    %eax,(%ebx)
  8010b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010be:	74 09                	je     8010c9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	68 ff 00 00 00       	push   $0xff
  8010d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d4:	50                   	push   %eax
  8010d5:	e8 eb ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb db                	jmp    8010c0 <putch+0x1f>

008010e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f5:	00 00 00 
	b.cnt = 0;
  8010f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801102:	ff 75 0c             	pushl  0xc(%ebp)
  801105:	ff 75 08             	pushl  0x8(%ebp)
  801108:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	68 a1 10 80 00       	push   $0x8010a1
  801114:	e8 1a 01 00 00       	call   801233 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801119:	83 c4 08             	add    $0x8,%esp
  80111c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801122:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	e8 97 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80112e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113f:	50                   	push   %eax
  801140:	ff 75 08             	pushl  0x8(%ebp)
  801143:	e8 9d ff ff ff       	call   8010e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 c7                	mov    %eax,%edi
  801155:	89 d6                	mov    %edx,%esi
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
  80115a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801160:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801163:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801166:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801171:	39 d3                	cmp    %edx,%ebx
  801173:	72 05                	jb     80117a <printnum+0x30>
  801175:	39 45 10             	cmp    %eax,0x10(%ebp)
  801178:	77 7a                	ja     8011f4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 18             	pushl  0x18(%ebp)
  801180:	8b 45 14             	mov    0x14(%ebp),%eax
  801183:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801186:	53                   	push   %ebx
  801187:	ff 75 10             	pushl  0x10(%ebp)
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801190:	ff 75 e0             	pushl  -0x20(%ebp)
  801193:	ff 75 dc             	pushl  -0x24(%ebp)
  801196:	ff 75 d8             	pushl  -0x28(%ebp)
  801199:	e8 22 0a 00 00       	call   801bc0 <__udivdi3>
  80119e:	83 c4 18             	add    $0x18,%esp
  8011a1:	52                   	push   %edx
  8011a2:	50                   	push   %eax
  8011a3:	89 f2                	mov    %esi,%edx
  8011a5:	89 f8                	mov    %edi,%eax
  8011a7:	e8 9e ff ff ff       	call   80114a <printnum>
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	eb 13                	jmp    8011c4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	ff 75 18             	pushl  0x18(%ebp)
  8011b8:	ff d7                	call   *%edi
  8011ba:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011bd:	83 eb 01             	sub    $0x1,%ebx
  8011c0:	85 db                	test   %ebx,%ebx
  8011c2:	7f ed                	jg     8011b1 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	56                   	push   %esi
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d7:	e8 04 0b 00 00       	call   801ce0 <__umoddi3>
  8011dc:	83 c4 14             	add    $0x14,%esp
  8011df:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011e6:	50                   	push   %eax
  8011e7:	ff d7                	call   *%edi
}
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    
  8011f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011f7:	eb c4                	jmp    8011bd <printnum+0x73>

008011f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801203:	8b 10                	mov    (%eax),%edx
  801205:	3b 50 04             	cmp    0x4(%eax),%edx
  801208:	73 0a                	jae    801214 <sprintputch+0x1b>
		*b->buf++ = ch;
  80120a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80120d:	89 08                	mov    %ecx,(%eax)
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	88 02                	mov    %al,(%edx)
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <printfmt>:
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80121c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80121f:	50                   	push   %eax
  801220:	ff 75 10             	pushl  0x10(%ebp)
  801223:	ff 75 0c             	pushl  0xc(%ebp)
  801226:	ff 75 08             	pushl  0x8(%ebp)
  801229:	e8 05 00 00 00       	call   801233 <vprintfmt>
}
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <vprintfmt>:
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 2c             	sub    $0x2c,%esp
  80123c:	8b 75 08             	mov    0x8(%ebp),%esi
  80123f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801242:	8b 7d 10             	mov    0x10(%ebp),%edi
  801245:	e9 c1 03 00 00       	jmp    80160b <vprintfmt+0x3d8>
		padc = ' ';
  80124a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80124e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801255:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80125c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801263:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801268:	8d 47 01             	lea    0x1(%edi),%eax
  80126b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126e:	0f b6 17             	movzbl (%edi),%edx
  801271:	8d 42 dd             	lea    -0x23(%edx),%eax
  801274:	3c 55                	cmp    $0x55,%al
  801276:	0f 87 12 04 00 00    	ja     80168e <vprintfmt+0x45b>
  80127c:	0f b6 c0             	movzbl %al,%eax
  80127f:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801286:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801289:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80128d:	eb d9                	jmp    801268 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80128f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801292:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801296:	eb d0                	jmp    801268 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801298:	0f b6 d2             	movzbl %dl,%edx
  80129b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8012a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012ad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b3:	83 f9 09             	cmp    $0x9,%ecx
  8012b6:	77 55                	ja     80130d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8012b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8012bb:	eb e9                	jmp    8012a6 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8012bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c0:	8b 00                	mov    (%eax),%eax
  8012c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c8:	8d 40 04             	lea    0x4(%eax),%eax
  8012cb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012d5:	79 91                	jns    801268 <vprintfmt+0x35>
				width = precision, precision = -1;
  8012d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e4:	eb 82                	jmp    801268 <vprintfmt+0x35>
  8012e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	0f 49 d0             	cmovns %eax,%edx
  8012f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f9:	e9 6a ff ff ff       	jmp    801268 <vprintfmt+0x35>
  8012fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801301:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801308:	e9 5b ff ff ff       	jmp    801268 <vprintfmt+0x35>
  80130d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801310:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801313:	eb bc                	jmp    8012d1 <vprintfmt+0x9e>
			lflag++;
  801315:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80131b:	e9 48 ff ff ff       	jmp    801268 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801320:	8b 45 14             	mov    0x14(%ebp),%eax
  801323:	8d 78 04             	lea    0x4(%eax),%edi
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	53                   	push   %ebx
  80132a:	ff 30                	pushl  (%eax)
  80132c:	ff d6                	call   *%esi
			break;
  80132e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801331:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801334:	e9 cf 02 00 00       	jmp    801608 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801339:	8b 45 14             	mov    0x14(%ebp),%eax
  80133c:	8d 78 04             	lea    0x4(%eax),%edi
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	99                   	cltd   
  801342:	31 d0                	xor    %edx,%eax
  801344:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801346:	83 f8 0f             	cmp    $0xf,%eax
  801349:	7f 23                	jg     80136e <vprintfmt+0x13b>
  80134b:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  801352:	85 d2                	test   %edx,%edx
  801354:	74 18                	je     80136e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801356:	52                   	push   %edx
  801357:	68 dd 1e 80 00       	push   $0x801edd
  80135c:	53                   	push   %ebx
  80135d:	56                   	push   %esi
  80135e:	e8 b3 fe ff ff       	call   801216 <printfmt>
  801363:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801366:	89 7d 14             	mov    %edi,0x14(%ebp)
  801369:	e9 9a 02 00 00       	jmp    801608 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80136e:	50                   	push   %eax
  80136f:	68 9f 1f 80 00       	push   $0x801f9f
  801374:	53                   	push   %ebx
  801375:	56                   	push   %esi
  801376:	e8 9b fe ff ff       	call   801216 <printfmt>
  80137b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80137e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801381:	e9 82 02 00 00       	jmp    801608 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	83 c0 04             	add    $0x4,%eax
  80138c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801394:	85 ff                	test   %edi,%edi
  801396:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  80139b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80139e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a2:	0f 8e bd 00 00 00    	jle    801465 <vprintfmt+0x232>
  8013a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ac:	75 0e                	jne    8013bc <vprintfmt+0x189>
  8013ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8013b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8013ba:	eb 6d                	jmp    801429 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c2:	57                   	push   %edi
  8013c3:	e8 6e 03 00 00       	call   801736 <strnlen>
  8013c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013cb:	29 c1                	sub    %eax,%ecx
  8013cd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013dd:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013df:	eb 0f                	jmp    8013f0 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	53                   	push   %ebx
  8013e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ea:	83 ef 01             	sub    $0x1,%edi
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 ff                	test   %edi,%edi
  8013f2:	7f ed                	jg     8013e1 <vprintfmt+0x1ae>
  8013f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013fa:	85 c9                	test   %ecx,%ecx
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	0f 49 c1             	cmovns %ecx,%eax
  801404:	29 c1                	sub    %eax,%ecx
  801406:	89 75 08             	mov    %esi,0x8(%ebp)
  801409:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140f:	89 cb                	mov    %ecx,%ebx
  801411:	eb 16                	jmp    801429 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  801413:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801417:	75 31                	jne    80144a <vprintfmt+0x217>
					putch(ch, putdat);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	ff 75 0c             	pushl  0xc(%ebp)
  80141f:	50                   	push   %eax
  801420:	ff 55 08             	call   *0x8(%ebp)
  801423:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801426:	83 eb 01             	sub    $0x1,%ebx
  801429:	83 c7 01             	add    $0x1,%edi
  80142c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801430:	0f be c2             	movsbl %dl,%eax
  801433:	85 c0                	test   %eax,%eax
  801435:	74 59                	je     801490 <vprintfmt+0x25d>
  801437:	85 f6                	test   %esi,%esi
  801439:	78 d8                	js     801413 <vprintfmt+0x1e0>
  80143b:	83 ee 01             	sub    $0x1,%esi
  80143e:	79 d3                	jns    801413 <vprintfmt+0x1e0>
  801440:	89 df                	mov    %ebx,%edi
  801442:	8b 75 08             	mov    0x8(%ebp),%esi
  801445:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801448:	eb 37                	jmp    801481 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80144a:	0f be d2             	movsbl %dl,%edx
  80144d:	83 ea 20             	sub    $0x20,%edx
  801450:	83 fa 5e             	cmp    $0x5e,%edx
  801453:	76 c4                	jbe    801419 <vprintfmt+0x1e6>
					putch('?', putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	ff 75 0c             	pushl  0xc(%ebp)
  80145b:	6a 3f                	push   $0x3f
  80145d:	ff 55 08             	call   *0x8(%ebp)
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	eb c1                	jmp    801426 <vprintfmt+0x1f3>
  801465:	89 75 08             	mov    %esi,0x8(%ebp)
  801468:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801471:	eb b6                	jmp    801429 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	53                   	push   %ebx
  801477:	6a 20                	push   $0x20
  801479:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80147b:	83 ef 01             	sub    $0x1,%edi
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 ff                	test   %edi,%edi
  801483:	7f ee                	jg     801473 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801485:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801488:	89 45 14             	mov    %eax,0x14(%ebp)
  80148b:	e9 78 01 00 00       	jmp    801608 <vprintfmt+0x3d5>
  801490:	89 df                	mov    %ebx,%edi
  801492:	8b 75 08             	mov    0x8(%ebp),%esi
  801495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801498:	eb e7                	jmp    801481 <vprintfmt+0x24e>
	if (lflag >= 2)
  80149a:	83 f9 01             	cmp    $0x1,%ecx
  80149d:	7e 3f                	jle    8014de <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80149f:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a2:	8b 50 04             	mov    0x4(%eax),%edx
  8014a5:	8b 00                	mov    (%eax),%eax
  8014a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8d 40 08             	lea    0x8(%eax),%eax
  8014b3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8014b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014ba:	79 5c                	jns    801518 <vprintfmt+0x2e5>
				putch('-', putdat);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	6a 2d                	push   $0x2d
  8014c2:	ff d6                	call   *%esi
				num = -(long long) num;
  8014c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ca:	f7 da                	neg    %edx
  8014cc:	83 d1 00             	adc    $0x0,%ecx
  8014cf:	f7 d9                	neg    %ecx
  8014d1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d9:	e9 10 01 00 00       	jmp    8015ee <vprintfmt+0x3bb>
	else if (lflag)
  8014de:	85 c9                	test   %ecx,%ecx
  8014e0:	75 1b                	jne    8014fd <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8b 00                	mov    (%eax),%eax
  8014e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ea:	89 c1                	mov    %eax,%ecx
  8014ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 40 04             	lea    0x4(%eax),%eax
  8014f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014fb:	eb b9                	jmp    8014b6 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8b 00                	mov    (%eax),%eax
  801502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801505:	89 c1                	mov    %eax,%ecx
  801507:	c1 f9 1f             	sar    $0x1f,%ecx
  80150a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8d 40 04             	lea    0x4(%eax),%eax
  801513:	89 45 14             	mov    %eax,0x14(%ebp)
  801516:	eb 9e                	jmp    8014b6 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  801518:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80151b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80151e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801523:	e9 c6 00 00 00       	jmp    8015ee <vprintfmt+0x3bb>
	if (lflag >= 2)
  801528:	83 f9 01             	cmp    $0x1,%ecx
  80152b:	7e 18                	jle    801545 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8b 10                	mov    (%eax),%edx
  801532:	8b 48 04             	mov    0x4(%eax),%ecx
  801535:	8d 40 08             	lea    0x8(%eax),%eax
  801538:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80153b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801540:	e9 a9 00 00 00       	jmp    8015ee <vprintfmt+0x3bb>
	else if (lflag)
  801545:	85 c9                	test   %ecx,%ecx
  801547:	75 1a                	jne    801563 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8b 10                	mov    (%eax),%edx
  80154e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801553:	8d 40 04             	lea    0x4(%eax),%eax
  801556:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801559:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155e:	e9 8b 00 00 00       	jmp    8015ee <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8b 10                	mov    (%eax),%edx
  801568:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156d:	8d 40 04             	lea    0x4(%eax),%eax
  801570:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801573:	b8 0a 00 00 00       	mov    $0xa,%eax
  801578:	eb 74                	jmp    8015ee <vprintfmt+0x3bb>
	if (lflag >= 2)
  80157a:	83 f9 01             	cmp    $0x1,%ecx
  80157d:	7e 15                	jle    801594 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80157f:	8b 45 14             	mov    0x14(%ebp),%eax
  801582:	8b 10                	mov    (%eax),%edx
  801584:	8b 48 04             	mov    0x4(%eax),%ecx
  801587:	8d 40 08             	lea    0x8(%eax),%eax
  80158a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80158d:	b8 08 00 00 00       	mov    $0x8,%eax
  801592:	eb 5a                	jmp    8015ee <vprintfmt+0x3bb>
	else if (lflag)
  801594:	85 c9                	test   %ecx,%ecx
  801596:	75 17                	jne    8015af <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8b 10                	mov    (%eax),%edx
  80159d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a2:	8d 40 04             	lea    0x4(%eax),%eax
  8015a5:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8015a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ad:	eb 3f                	jmp    8015ee <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8b 10                	mov    (%eax),%edx
  8015b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b9:	8d 40 04             	lea    0x4(%eax),%eax
  8015bc:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8015bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c4:	eb 28                	jmp    8015ee <vprintfmt+0x3bb>
			putch('0', putdat);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	6a 30                	push   $0x30
  8015cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	53                   	push   %ebx
  8015d2:	6a 78                	push   $0x78
  8015d4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8b 10                	mov    (%eax),%edx
  8015db:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015e0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015e3:	8d 40 04             	lea    0x4(%eax),%eax
  8015e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f5:	57                   	push   %edi
  8015f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f9:	50                   	push   %eax
  8015fa:	51                   	push   %ecx
  8015fb:	52                   	push   %edx
  8015fc:	89 da                	mov    %ebx,%edx
  8015fe:	89 f0                	mov    %esi,%eax
  801600:	e8 45 fb ff ff       	call   80114a <printnum>
			break;
  801605:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80160b:	83 c7 01             	add    $0x1,%edi
  80160e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801612:	83 f8 25             	cmp    $0x25,%eax
  801615:	0f 84 2f fc ff ff    	je     80124a <vprintfmt+0x17>
			if (ch == '\0')
  80161b:	85 c0                	test   %eax,%eax
  80161d:	0f 84 8b 00 00 00    	je     8016ae <vprintfmt+0x47b>
			putch(ch, putdat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	50                   	push   %eax
  801628:	ff d6                	call   *%esi
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb dc                	jmp    80160b <vprintfmt+0x3d8>
	if (lflag >= 2)
  80162f:	83 f9 01             	cmp    $0x1,%ecx
  801632:	7e 15                	jle    801649 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801634:	8b 45 14             	mov    0x14(%ebp),%eax
  801637:	8b 10                	mov    (%eax),%edx
  801639:	8b 48 04             	mov    0x4(%eax),%ecx
  80163c:	8d 40 08             	lea    0x8(%eax),%eax
  80163f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801642:	b8 10 00 00 00       	mov    $0x10,%eax
  801647:	eb a5                	jmp    8015ee <vprintfmt+0x3bb>
	else if (lflag)
  801649:	85 c9                	test   %ecx,%ecx
  80164b:	75 17                	jne    801664 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8b 10                	mov    (%eax),%edx
  801652:	b9 00 00 00 00       	mov    $0x0,%ecx
  801657:	8d 40 04             	lea    0x4(%eax),%eax
  80165a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80165d:	b8 10 00 00 00       	mov    $0x10,%eax
  801662:	eb 8a                	jmp    8015ee <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801664:	8b 45 14             	mov    0x14(%ebp),%eax
  801667:	8b 10                	mov    (%eax),%edx
  801669:	b9 00 00 00 00       	mov    $0x0,%ecx
  80166e:	8d 40 04             	lea    0x4(%eax),%eax
  801671:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801674:	b8 10 00 00 00       	mov    $0x10,%eax
  801679:	e9 70 ff ff ff       	jmp    8015ee <vprintfmt+0x3bb>
			putch(ch, putdat);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	53                   	push   %ebx
  801682:	6a 25                	push   $0x25
  801684:	ff d6                	call   *%esi
			break;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	e9 7a ff ff ff       	jmp    801608 <vprintfmt+0x3d5>
			putch('%', putdat);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	53                   	push   %ebx
  801692:	6a 25                	push   $0x25
  801694:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	89 f8                	mov    %edi,%eax
  80169b:	eb 03                	jmp    8016a0 <vprintfmt+0x46d>
  80169d:	83 e8 01             	sub    $0x1,%eax
  8016a0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016a4:	75 f7                	jne    80169d <vprintfmt+0x46a>
  8016a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016a9:	e9 5a ff ff ff       	jmp    801608 <vprintfmt+0x3d5>
}
  8016ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5f                   	pop    %edi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 18             	sub    $0x18,%esp
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	74 26                	je     8016fd <vsnprintf+0x47>
  8016d7:	85 d2                	test   %edx,%edx
  8016d9:	7e 22                	jle    8016fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016db:	ff 75 14             	pushl  0x14(%ebp)
  8016de:	ff 75 10             	pushl  0x10(%ebp)
  8016e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	68 f9 11 80 00       	push   $0x8011f9
  8016ea:	e8 44 fb ff ff       	call   801233 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f8:	83 c4 10             	add    $0x10,%esp
}
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    
		return -E_INVAL;
  8016fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801702:	eb f7                	jmp    8016fb <vsnprintf+0x45>

00801704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80170a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80170d:	50                   	push   %eax
  80170e:	ff 75 10             	pushl  0x10(%ebp)
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 9a ff ff ff       	call   8016b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801724:	b8 00 00 00 00       	mov    $0x0,%eax
  801729:	eb 03                	jmp    80172e <strlen+0x10>
		n++;
  80172b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80172e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801732:	75 f7                	jne    80172b <strlen+0xd>
	return n;
}
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
  801744:	eb 03                	jmp    801749 <strnlen+0x13>
		n++;
  801746:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801749:	39 d0                	cmp    %edx,%eax
  80174b:	74 06                	je     801753 <strnlen+0x1d>
  80174d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801751:	75 f3                	jne    801746 <strnlen+0x10>
	return n;
}
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80175f:	89 c2                	mov    %eax,%edx
  801761:	83 c1 01             	add    $0x1,%ecx
  801764:	83 c2 01             	add    $0x1,%edx
  801767:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80176b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80176e:	84 db                	test   %bl,%bl
  801770:	75 ef                	jne    801761 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801772:	5b                   	pop    %ebx
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	53                   	push   %ebx
  801779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80177c:	53                   	push   %ebx
  80177d:	e8 9c ff ff ff       	call   80171e <strlen>
  801782:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	01 d8                	add    %ebx,%eax
  80178a:	50                   	push   %eax
  80178b:	e8 c5 ff ff ff       	call   801755 <strcpy>
	return dst;
}
  801790:	89 d8                	mov    %ebx,%eax
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	56                   	push   %esi
  80179b:	53                   	push   %ebx
  80179c:	8b 75 08             	mov    0x8(%ebp),%esi
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	89 f3                	mov    %esi,%ebx
  8017a4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017a7:	89 f2                	mov    %esi,%edx
  8017a9:	eb 0f                	jmp    8017ba <strncpy+0x23>
		*dst++ = *src;
  8017ab:	83 c2 01             	add    $0x1,%edx
  8017ae:	0f b6 01             	movzbl (%ecx),%eax
  8017b1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017b4:	80 39 01             	cmpb   $0x1,(%ecx)
  8017b7:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8017ba:	39 da                	cmp    %ebx,%edx
  8017bc:	75 ed                	jne    8017ab <strncpy+0x14>
	}
	return ret;
}
  8017be:	89 f0                	mov    %esi,%eax
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
  8017c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017d2:	89 f0                	mov    %esi,%eax
  8017d4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017d8:	85 c9                	test   %ecx,%ecx
  8017da:	75 0b                	jne    8017e7 <strlcpy+0x23>
  8017dc:	eb 17                	jmp    8017f5 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017de:	83 c2 01             	add    $0x1,%edx
  8017e1:	83 c0 01             	add    $0x1,%eax
  8017e4:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017e7:	39 d8                	cmp    %ebx,%eax
  8017e9:	74 07                	je     8017f2 <strlcpy+0x2e>
  8017eb:	0f b6 0a             	movzbl (%edx),%ecx
  8017ee:	84 c9                	test   %cl,%cl
  8017f0:	75 ec                	jne    8017de <strlcpy+0x1a>
		*dst = '\0';
  8017f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017f5:	29 f0                	sub    %esi,%eax
}
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801801:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801804:	eb 06                	jmp    80180c <strcmp+0x11>
		p++, q++;
  801806:	83 c1 01             	add    $0x1,%ecx
  801809:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80180c:	0f b6 01             	movzbl (%ecx),%eax
  80180f:	84 c0                	test   %al,%al
  801811:	74 04                	je     801817 <strcmp+0x1c>
  801813:	3a 02                	cmp    (%edx),%al
  801815:	74 ef                	je     801806 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801817:	0f b6 c0             	movzbl %al,%eax
  80181a:	0f b6 12             	movzbl (%edx),%edx
  80181d:	29 d0                	sub    %edx,%eax
}
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	53                   	push   %ebx
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182b:	89 c3                	mov    %eax,%ebx
  80182d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801830:	eb 06                	jmp    801838 <strncmp+0x17>
		n--, p++, q++;
  801832:	83 c0 01             	add    $0x1,%eax
  801835:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801838:	39 d8                	cmp    %ebx,%eax
  80183a:	74 16                	je     801852 <strncmp+0x31>
  80183c:	0f b6 08             	movzbl (%eax),%ecx
  80183f:	84 c9                	test   %cl,%cl
  801841:	74 04                	je     801847 <strncmp+0x26>
  801843:	3a 0a                	cmp    (%edx),%cl
  801845:	74 eb                	je     801832 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801847:	0f b6 00             	movzbl (%eax),%eax
  80184a:	0f b6 12             	movzbl (%edx),%edx
  80184d:	29 d0                	sub    %edx,%eax
}
  80184f:	5b                   	pop    %ebx
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    
		return 0;
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
  801857:	eb f6                	jmp    80184f <strncmp+0x2e>

00801859 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801863:	0f b6 10             	movzbl (%eax),%edx
  801866:	84 d2                	test   %dl,%dl
  801868:	74 09                	je     801873 <strchr+0x1a>
		if (*s == c)
  80186a:	38 ca                	cmp    %cl,%dl
  80186c:	74 0a                	je     801878 <strchr+0x1f>
	for (; *s; s++)
  80186e:	83 c0 01             	add    $0x1,%eax
  801871:	eb f0                	jmp    801863 <strchr+0xa>
			return (char *) s;
	return 0;
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801884:	eb 03                	jmp    801889 <strfind+0xf>
  801886:	83 c0 01             	add    $0x1,%eax
  801889:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80188c:	38 ca                	cmp    %cl,%dl
  80188e:	74 04                	je     801894 <strfind+0x1a>
  801890:	84 d2                	test   %dl,%dl
  801892:	75 f2                	jne    801886 <strfind+0xc>
			break;
	return (char *) s;
}
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	57                   	push   %edi
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018a2:	85 c9                	test   %ecx,%ecx
  8018a4:	74 13                	je     8018b9 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018ac:	75 05                	jne    8018b3 <memset+0x1d>
  8018ae:	f6 c1 03             	test   $0x3,%cl
  8018b1:	74 0d                	je     8018c0 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	fc                   	cld    
  8018b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018b9:	89 f8                	mov    %edi,%eax
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5f                   	pop    %edi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    
		c &= 0xFF;
  8018c0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018c4:	89 d3                	mov    %edx,%ebx
  8018c6:	c1 e3 08             	shl    $0x8,%ebx
  8018c9:	89 d0                	mov    %edx,%eax
  8018cb:	c1 e0 18             	shl    $0x18,%eax
  8018ce:	89 d6                	mov    %edx,%esi
  8018d0:	c1 e6 10             	shl    $0x10,%esi
  8018d3:	09 f0                	or     %esi,%eax
  8018d5:	09 c2                	or     %eax,%edx
  8018d7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018dc:	89 d0                	mov    %edx,%eax
  8018de:	fc                   	cld    
  8018df:	f3 ab                	rep stos %eax,%es:(%edi)
  8018e1:	eb d6                	jmp    8018b9 <memset+0x23>

008018e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	57                   	push   %edi
  8018e7:	56                   	push   %esi
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018f1:	39 c6                	cmp    %eax,%esi
  8018f3:	73 35                	jae    80192a <memmove+0x47>
  8018f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018f8:	39 c2                	cmp    %eax,%edx
  8018fa:	76 2e                	jbe    80192a <memmove+0x47>
		s += n;
		d += n;
  8018fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ff:	89 d6                	mov    %edx,%esi
  801901:	09 fe                	or     %edi,%esi
  801903:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801909:	74 0c                	je     801917 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80190b:	83 ef 01             	sub    $0x1,%edi
  80190e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801911:	fd                   	std    
  801912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801914:	fc                   	cld    
  801915:	eb 21                	jmp    801938 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801917:	f6 c1 03             	test   $0x3,%cl
  80191a:	75 ef                	jne    80190b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80191c:	83 ef 04             	sub    $0x4,%edi
  80191f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801922:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801925:	fd                   	std    
  801926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801928:	eb ea                	jmp    801914 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80192a:	89 f2                	mov    %esi,%edx
  80192c:	09 c2                	or     %eax,%edx
  80192e:	f6 c2 03             	test   $0x3,%dl
  801931:	74 09                	je     80193c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801933:	89 c7                	mov    %eax,%edi
  801935:	fc                   	cld    
  801936:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801938:	5e                   	pop    %esi
  801939:	5f                   	pop    %edi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80193c:	f6 c1 03             	test   $0x3,%cl
  80193f:	75 f2                	jne    801933 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801941:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801944:	89 c7                	mov    %eax,%edi
  801946:	fc                   	cld    
  801947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801949:	eb ed                	jmp    801938 <memmove+0x55>

0080194b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80194e:	ff 75 10             	pushl  0x10(%ebp)
  801951:	ff 75 0c             	pushl  0xc(%ebp)
  801954:	ff 75 08             	pushl  0x8(%ebp)
  801957:	e8 87 ff ff ff       	call   8018e3 <memmove>
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	8b 55 0c             	mov    0xc(%ebp),%edx
  801969:	89 c6                	mov    %eax,%esi
  80196b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80196e:	39 f0                	cmp    %esi,%eax
  801970:	74 1c                	je     80198e <memcmp+0x30>
		if (*s1 != *s2)
  801972:	0f b6 08             	movzbl (%eax),%ecx
  801975:	0f b6 1a             	movzbl (%edx),%ebx
  801978:	38 d9                	cmp    %bl,%cl
  80197a:	75 08                	jne    801984 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80197c:	83 c0 01             	add    $0x1,%eax
  80197f:	83 c2 01             	add    $0x1,%edx
  801982:	eb ea                	jmp    80196e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801984:	0f b6 c1             	movzbl %cl,%eax
  801987:	0f b6 db             	movzbl %bl,%ebx
  80198a:	29 d8                	sub    %ebx,%eax
  80198c:	eb 05                	jmp    801993 <memcmp+0x35>
	}

	return 0;
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801993:	5b                   	pop    %ebx
  801994:	5e                   	pop    %esi
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8019a5:	39 d0                	cmp    %edx,%eax
  8019a7:	73 09                	jae    8019b2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a9:	38 08                	cmp    %cl,(%eax)
  8019ab:	74 05                	je     8019b2 <memfind+0x1b>
	for (; s < ends; s++)
  8019ad:	83 c0 01             	add    $0x1,%eax
  8019b0:	eb f3                	jmp    8019a5 <memfind+0xe>
			break;
	return (void *) s;
}
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	57                   	push   %edi
  8019b8:	56                   	push   %esi
  8019b9:	53                   	push   %ebx
  8019ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c0:	eb 03                	jmp    8019c5 <strtol+0x11>
		s++;
  8019c2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019c5:	0f b6 01             	movzbl (%ecx),%eax
  8019c8:	3c 20                	cmp    $0x20,%al
  8019ca:	74 f6                	je     8019c2 <strtol+0xe>
  8019cc:	3c 09                	cmp    $0x9,%al
  8019ce:	74 f2                	je     8019c2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019d0:	3c 2b                	cmp    $0x2b,%al
  8019d2:	74 2e                	je     801a02 <strtol+0x4e>
	int neg = 0;
  8019d4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019d9:	3c 2d                	cmp    $0x2d,%al
  8019db:	74 2f                	je     801a0c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019e3:	75 05                	jne    8019ea <strtol+0x36>
  8019e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e8:	74 2c                	je     801a16 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ea:	85 db                	test   %ebx,%ebx
  8019ec:	75 0a                	jne    8019f8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8019f6:	74 28                	je     801a20 <strtol+0x6c>
		base = 10;
  8019f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a00:	eb 50                	jmp    801a52 <strtol+0x9e>
		s++;
  801a02:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a05:	bf 00 00 00 00       	mov    $0x0,%edi
  801a0a:	eb d1                	jmp    8019dd <strtol+0x29>
		s++, neg = 1;
  801a0c:	83 c1 01             	add    $0x1,%ecx
  801a0f:	bf 01 00 00 00       	mov    $0x1,%edi
  801a14:	eb c7                	jmp    8019dd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a16:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a1a:	74 0e                	je     801a2a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a1c:	85 db                	test   %ebx,%ebx
  801a1e:	75 d8                	jne    8019f8 <strtol+0x44>
		s++, base = 8;
  801a20:	83 c1 01             	add    $0x1,%ecx
  801a23:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a28:	eb ce                	jmp    8019f8 <strtol+0x44>
		s += 2, base = 16;
  801a2a:	83 c1 02             	add    $0x2,%ecx
  801a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a32:	eb c4                	jmp    8019f8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a34:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a37:	89 f3                	mov    %esi,%ebx
  801a39:	80 fb 19             	cmp    $0x19,%bl
  801a3c:	77 29                	ja     801a67 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a3e:	0f be d2             	movsbl %dl,%edx
  801a41:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a44:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a47:	7d 30                	jge    801a79 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a49:	83 c1 01             	add    $0x1,%ecx
  801a4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a50:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a52:	0f b6 11             	movzbl (%ecx),%edx
  801a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a58:	89 f3                	mov    %esi,%ebx
  801a5a:	80 fb 09             	cmp    $0x9,%bl
  801a5d:	77 d5                	ja     801a34 <strtol+0x80>
			dig = *s - '0';
  801a5f:	0f be d2             	movsbl %dl,%edx
  801a62:	83 ea 30             	sub    $0x30,%edx
  801a65:	eb dd                	jmp    801a44 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a67:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a6a:	89 f3                	mov    %esi,%ebx
  801a6c:	80 fb 19             	cmp    $0x19,%bl
  801a6f:	77 08                	ja     801a79 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a71:	0f be d2             	movsbl %dl,%edx
  801a74:	83 ea 37             	sub    $0x37,%edx
  801a77:	eb cb                	jmp    801a44 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a7d:	74 05                	je     801a84 <strtol+0xd0>
		*endptr = (char *) s;
  801a7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a82:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a84:	89 c2                	mov    %eax,%edx
  801a86:	f7 da                	neg    %edx
  801a88:	85 ff                	test   %edi,%edi
  801a8a:	0f 45 c2             	cmovne %edx,%eax
}
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aa7:	0f 44 c2             	cmove  %edx,%eax
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	50                   	push   %eax
  801aae:	e8 7e e8 ff ff       	call   800331 <sys_ipc_recv>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 2b                	js     801ae5 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801aba:	85 f6                	test   %esi,%esi
  801abc:	74 0a                	je     801ac8 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801abe:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac3:	8b 40 74             	mov    0x74(%eax),%eax
  801ac6:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801ac8:	85 db                	test   %ebx,%ebx
  801aca:	74 0a                	je     801ad6 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 78             	mov    0x78(%eax),%eax
  801ad4:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801ad6:	a1 04 40 80 00       	mov    0x804004,%eax
  801adb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    
        *from_env_store = 0;
  801ae5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801aeb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801af1:	eb eb                	jmp    801ade <ipc_recv+0x4c>

00801af3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	57                   	push   %edi
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801b05:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801b07:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b0c:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801b0f:	ff 75 14             	pushl  0x14(%ebp)
  801b12:	53                   	push   %ebx
  801b13:	56                   	push   %esi
  801b14:	57                   	push   %edi
  801b15:	e8 f4 e7 ff ff       	call   80030e <sys_ipc_try_send>
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	74 17                	je     801b38 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801b21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b24:	74 e9                	je     801b0f <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801b26:	50                   	push   %eax
  801b27:	68 80 22 80 00       	push   $0x802280
  801b2c:	6a 3e                	push   $0x3e
  801b2e:	68 92 22 80 00       	push   $0x802292
  801b33:	e8 23 f5 ff ff       	call   80105b <_panic>
        }
    }
}
  801b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    

00801b40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b54:	8b 52 50             	mov    0x50(%edx),%edx
  801b57:	39 ca                	cmp    %ecx,%edx
  801b59:	74 11                	je     801b6c <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b5b:	83 c0 01             	add    $0x1,%eax
  801b5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b63:	75 e6                	jne    801b4b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	eb 0b                	jmp    801b77 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b6c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b74:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7f:	89 d0                	mov    %edx,%eax
  801b81:	c1 e8 16             	shr    $0x16,%eax
  801b84:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b90:	f6 c1 01             	test   $0x1,%cl
  801b93:	74 1d                	je     801bb2 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b95:	c1 ea 0c             	shr    $0xc,%edx
  801b98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9f:	f6 c2 01             	test   $0x1,%dl
  801ba2:	74 0e                	je     801bb2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba4:	c1 ea 0c             	shr    $0xc,%edx
  801ba7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bae:	ef 
  801baf:	0f b7 c0             	movzwl %ax,%eax
}
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    
  801bb4:	66 90                	xchg   %ax,%ax
  801bb6:	66 90                	xchg   %ax,%ax
  801bb8:	66 90                	xchg   %ax,%ax
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bcb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bd3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bd7:	85 d2                	test   %edx,%edx
  801bd9:	75 35                	jne    801c10 <__udivdi3+0x50>
  801bdb:	39 f3                	cmp    %esi,%ebx
  801bdd:	0f 87 bd 00 00 00    	ja     801ca0 <__udivdi3+0xe0>
  801be3:	85 db                	test   %ebx,%ebx
  801be5:	89 d9                	mov    %ebx,%ecx
  801be7:	75 0b                	jne    801bf4 <__udivdi3+0x34>
  801be9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f3                	div    %ebx
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	31 d2                	xor    %edx,%edx
  801bf6:	89 f0                	mov    %esi,%eax
  801bf8:	f7 f1                	div    %ecx
  801bfa:	89 c6                	mov    %eax,%esi
  801bfc:	89 e8                	mov    %ebp,%eax
  801bfe:	89 f7                	mov    %esi,%edi
  801c00:	f7 f1                	div    %ecx
  801c02:	89 fa                	mov    %edi,%edx
  801c04:	83 c4 1c             	add    $0x1c,%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    
  801c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 f2                	cmp    %esi,%edx
  801c12:	77 7c                	ja     801c90 <__udivdi3+0xd0>
  801c14:	0f bd fa             	bsr    %edx,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0xf8>
  801c20:	89 f9                	mov    %edi,%ecx
  801c22:	b8 20 00 00 00       	mov    $0x20,%eax
  801c27:	29 f8                	sub    %edi,%eax
  801c29:	d3 e2                	shl    %cl,%edx
  801c2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c2f:	89 c1                	mov    %eax,%ecx
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	d3 ea                	shr    %cl,%edx
  801c35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c39:	09 d1                	or     %edx,%ecx
  801c3b:	89 f2                	mov    %esi,%edx
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e3                	shl    %cl,%ebx
  801c45:	89 c1                	mov    %eax,%ecx
  801c47:	d3 ea                	shr    %cl,%edx
  801c49:	89 f9                	mov    %edi,%ecx
  801c4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c4f:	d3 e6                	shl    %cl,%esi
  801c51:	89 eb                	mov    %ebp,%ebx
  801c53:	89 c1                	mov    %eax,%ecx
  801c55:	d3 eb                	shr    %cl,%ebx
  801c57:	09 de                	or     %ebx,%esi
  801c59:	89 f0                	mov    %esi,%eax
  801c5b:	f7 74 24 08          	divl   0x8(%esp)
  801c5f:	89 d6                	mov    %edx,%esi
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	f7 64 24 0c          	mull   0xc(%esp)
  801c67:	39 d6                	cmp    %edx,%esi
  801c69:	72 0c                	jb     801c77 <__udivdi3+0xb7>
  801c6b:	89 f9                	mov    %edi,%ecx
  801c6d:	d3 e5                	shl    %cl,%ebp
  801c6f:	39 c5                	cmp    %eax,%ebp
  801c71:	73 5d                	jae    801cd0 <__udivdi3+0x110>
  801c73:	39 d6                	cmp    %edx,%esi
  801c75:	75 59                	jne    801cd0 <__udivdi3+0x110>
  801c77:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c7a:	31 ff                	xor    %edi,%edi
  801c7c:	89 fa                	mov    %edi,%edx
  801c7e:	83 c4 1c             	add    $0x1c,%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    
  801c86:	8d 76 00             	lea    0x0(%esi),%esi
  801c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c90:	31 ff                	xor    %edi,%edi
  801c92:	31 c0                	xor    %eax,%eax
  801c94:	89 fa                	mov    %edi,%edx
  801c96:	83 c4 1c             	add    $0x1c,%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    
  801c9e:	66 90                	xchg   %ax,%ax
  801ca0:	31 ff                	xor    %edi,%edi
  801ca2:	89 e8                	mov    %ebp,%eax
  801ca4:	89 f2                	mov    %esi,%edx
  801ca6:	f7 f3                	div    %ebx
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	72 06                	jb     801cc2 <__udivdi3+0x102>
  801cbc:	31 c0                	xor    %eax,%eax
  801cbe:	39 eb                	cmp    %ebp,%ebx
  801cc0:	77 d2                	ja     801c94 <__udivdi3+0xd4>
  801cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc7:	eb cb                	jmp    801c94 <__udivdi3+0xd4>
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	31 ff                	xor    %edi,%edi
  801cd4:	eb be                	jmp    801c94 <__udivdi3+0xd4>
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ceb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 ed                	test   %ebp,%ebp
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	89 da                	mov    %ebx,%edx
  801cfd:	75 19                	jne    801d18 <__umoddi3+0x38>
  801cff:	39 df                	cmp    %ebx,%edi
  801d01:	0f 86 b1 00 00 00    	jbe    801db8 <__umoddi3+0xd8>
  801d07:	f7 f7                	div    %edi
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	83 c4 1c             	add    $0x1c,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    
  801d15:	8d 76 00             	lea    0x0(%esi),%esi
  801d18:	39 dd                	cmp    %ebx,%ebp
  801d1a:	77 f1                	ja     801d0d <__umoddi3+0x2d>
  801d1c:	0f bd cd             	bsr    %ebp,%ecx
  801d1f:	83 f1 1f             	xor    $0x1f,%ecx
  801d22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d26:	0f 84 b4 00 00 00    	je     801de0 <__umoddi3+0x100>
  801d2c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d37:	29 c2                	sub    %eax,%edx
  801d39:	89 c1                	mov    %eax,%ecx
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	d3 e5                	shl    %cl,%ebp
  801d3f:	89 d1                	mov    %edx,%ecx
  801d41:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d45:	d3 e8                	shr    %cl,%eax
  801d47:	09 c5                	or     %eax,%ebp
  801d49:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d4d:	89 c1                	mov    %eax,%ecx
  801d4f:	d3 e7                	shl    %cl,%edi
  801d51:	89 d1                	mov    %edx,%ecx
  801d53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d57:	89 df                	mov    %ebx,%edi
  801d59:	d3 ef                	shr    %cl,%edi
  801d5b:	89 c1                	mov    %eax,%ecx
  801d5d:	89 f0                	mov    %esi,%eax
  801d5f:	d3 e3                	shl    %cl,%ebx
  801d61:	89 d1                	mov    %edx,%ecx
  801d63:	89 fa                	mov    %edi,%edx
  801d65:	d3 e8                	shr    %cl,%eax
  801d67:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d6c:	09 d8                	or     %ebx,%eax
  801d6e:	f7 f5                	div    %ebp
  801d70:	d3 e6                	shl    %cl,%esi
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	f7 64 24 08          	mull   0x8(%esp)
  801d78:	39 d1                	cmp    %edx,%ecx
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	89 d7                	mov    %edx,%edi
  801d7e:	72 06                	jb     801d86 <__umoddi3+0xa6>
  801d80:	75 0e                	jne    801d90 <__umoddi3+0xb0>
  801d82:	39 c6                	cmp    %eax,%esi
  801d84:	73 0a                	jae    801d90 <__umoddi3+0xb0>
  801d86:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d8a:	19 ea                	sbb    %ebp,%edx
  801d8c:	89 d7                	mov    %edx,%edi
  801d8e:	89 c3                	mov    %eax,%ebx
  801d90:	89 ca                	mov    %ecx,%edx
  801d92:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d97:	29 de                	sub    %ebx,%esi
  801d99:	19 fa                	sbb    %edi,%edx
  801d9b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d9f:	89 d0                	mov    %edx,%eax
  801da1:	d3 e0                	shl    %cl,%eax
  801da3:	89 d9                	mov    %ebx,%ecx
  801da5:	d3 ee                	shr    %cl,%esi
  801da7:	d3 ea                	shr    %cl,%edx
  801da9:	09 f0                	or     %esi,%eax
  801dab:	83 c4 1c             	add    $0x1c,%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	85 ff                	test   %edi,%edi
  801dba:	89 f9                	mov    %edi,%ecx
  801dbc:	75 0b                	jne    801dc9 <__umoddi3+0xe9>
  801dbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f7                	div    %edi
  801dc7:	89 c1                	mov    %eax,%ecx
  801dc9:	89 d8                	mov    %ebx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f1                	div    %ecx
  801dcf:	89 f0                	mov    %esi,%eax
  801dd1:	f7 f1                	div    %ecx
  801dd3:	e9 31 ff ff ff       	jmp    801d09 <__umoddi3+0x29>
  801dd8:	90                   	nop
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	39 dd                	cmp    %ebx,%ebp
  801de2:	72 08                	jb     801dec <__umoddi3+0x10c>
  801de4:	39 f7                	cmp    %esi,%edi
  801de6:	0f 87 21 ff ff ff    	ja     801d0d <__umoddi3+0x2d>
  801dec:	89 da                	mov    %ebx,%edx
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	29 f8                	sub    %edi,%eax
  801df2:	19 ea                	sbb    %ebp,%edx
  801df4:	e9 14 ff ff ff       	jmp    801d0d <__umoddi3+0x2d>
