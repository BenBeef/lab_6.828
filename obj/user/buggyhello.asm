
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 92 04 00 00       	call   80052a <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7f 08                	jg     80010e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 ea 1d 80 00       	push   $0x801dea
  800119:	6a 23                	push   $0x23
  80011b:	68 07 1e 80 00       	push   $0x801e07
  800120:	e8 18 0f 00 00       	call   80103d <_panic>

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7f 08                	jg     80018f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	6a 04                	push   $0x4
  800195:	68 ea 1d 80 00       	push   $0x801dea
  80019a:	6a 23                	push   $0x23
  80019c:	68 07 1e 80 00       	push   $0x801e07
  8001a1:	e8 97 0e 00 00       	call   80103d <_panic>

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7f 08                	jg     8001d1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	50                   	push   %eax
  8001d5:	6a 05                	push   $0x5
  8001d7:	68 ea 1d 80 00       	push   $0x801dea
  8001dc:	6a 23                	push   $0x23
  8001de:	68 07 1e 80 00       	push   $0x801e07
  8001e3:	e8 55 0e 00 00       	call   80103d <_panic>

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7f 08                	jg     800213 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	50                   	push   %eax
  800217:	6a 06                	push   $0x6
  800219:	68 ea 1d 80 00       	push   $0x801dea
  80021e:	6a 23                	push   $0x23
  800220:	68 07 1e 80 00       	push   $0x801e07
  800225:	e8 13 0e 00 00       	call   80103d <_panic>

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 08 00 00 00       	mov    $0x8,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 08                	push   $0x8
  80025b:	68 ea 1d 80 00       	push   $0x801dea
  800260:	6a 23                	push   $0x23
  800262:	68 07 1e 80 00       	push   $0x801e07
  800267:	e8 d1 0d 00 00       	call   80103d <_panic>

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	b8 09 00 00 00       	mov    $0x9,%eax
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7f 08                	jg     800297 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	50                   	push   %eax
  80029b:	6a 09                	push   $0x9
  80029d:	68 ea 1d 80 00       	push   $0x801dea
  8002a2:	6a 23                	push   $0x23
  8002a4:	68 07 1e 80 00       	push   $0x801e07
  8002a9:	e8 8f 0d 00 00       	call   80103d <_panic>

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7f 08                	jg     8002d9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	50                   	push   %eax
  8002dd:	6a 0a                	push   $0xa
  8002df:	68 ea 1d 80 00       	push   $0x801dea
  8002e4:	6a 23                	push   $0x23
  8002e6:	68 07 1e 80 00       	push   $0x801e07
  8002eb:	e8 4d 0d 00 00       	call   80103d <_panic>

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800301:	be 00 00 00 00       	mov    $0x0,%esi
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7f 08                	jg     80033d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	50                   	push   %eax
  800341:	6a 0d                	push   $0xd
  800343:	68 ea 1d 80 00       	push   $0x801dea
  800348:	6a 23                	push   $0x23
  80034a:	68 07 1e 80 00       	push   $0x801e07
  80034f:	e8 e9 0c 00 00       	call   80103d <_panic>

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 2a                	je     8003c1 <fd_alloc+0x46>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 19                	je     8003c1 <fd_alloc+0x46>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 d2                	jne    800386 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003bf:	eb 07                	jmp    8003c8 <fd_alloc+0x4d>
			*fd_store = fd;
  8003c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb f7                	jmp    800409 <fd_lookup+0x3f>
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f0                	jmp    800409 <fd_lookup+0x3f>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb e9                	jmp    800409 <fd_lookup+0x3f>

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	74 33                	je     80046a <dev_lookup+0x4a>
  800437:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 f3                	jne    800433 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 18 1e 80 00       	push   $0x801e18
  800452:	e8 c1 0c 00 00       	call   801118 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb f2                	jmp    800468 <dev_lookup+0x48>

00800476 <fd_close>:
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 1c             	sub    $0x1c,%esp
  80047f:	8b 75 08             	mov    0x8(%ebp),%esi
  800482:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800488:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800489:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	50                   	push   %eax
  800493:	e8 32 ff ff ff       	call   8003ca <fd_lookup>
  800498:	89 c3                	mov    %eax,%ebx
  80049a:	83 c4 08             	add    $0x8,%esp
  80049d:	85 c0                	test   %eax,%eax
  80049f:	78 05                	js     8004a6 <fd_close+0x30>
	    || fd != fd2)
  8004a1:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a4:	74 16                	je     8004bc <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a6:	89 f8                	mov    %edi,%eax
  8004a8:	84 c0                	test   %al,%al
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b2:	89 d8                	mov    %ebx,%eax
  8004b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b7:	5b                   	pop    %ebx
  8004b8:	5e                   	pop    %esi
  8004b9:	5f                   	pop    %edi
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	ff 36                	pushl  (%esi)
  8004c5:	e8 56 ff ff ff       	call   800420 <dev_lookup>
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	78 15                	js     8004e8 <fd_close+0x72>
		if (dev->dev_close)
  8004d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d6:	8b 40 10             	mov    0x10(%eax),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	74 1b                	je     8004f8 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004dd:	83 ec 0c             	sub    $0xc,%esp
  8004e0:	56                   	push   %esi
  8004e1:	ff d0                	call   *%eax
  8004e3:	89 c3                	mov    %eax,%ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	6a 00                	push   $0x0
  8004ee:	e8 f5 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb ba                	jmp    8004b2 <fd_close+0x3c>
			r = 0;
  8004f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fd:	eb e9                	jmp    8004e8 <fd_close+0x72>

008004ff <close>:

int
close(int fdnum)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800508:	50                   	push   %eax
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 b9 fe ff ff       	call   8003ca <fd_lookup>
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	78 10                	js     800528 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	6a 01                	push   $0x1
  80051d:	ff 75 f4             	pushl  -0xc(%ebp)
  800520:	e8 51 ff ff ff       	call   800476 <fd_close>
  800525:	83 c4 10             	add    $0x10,%esp
}
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <close_all>:

void
close_all(void)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	53                   	push   %ebx
  80053a:	e8 c0 ff ff ff       	call   8004ff <close>
	for (i = 0; i < MAXFD; i++)
  80053f:	83 c3 01             	add    $0x1,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	83 fb 20             	cmp    $0x20,%ebx
  800548:	75 ec                	jne    800536 <close_all+0xc>
}
  80054a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054d:	c9                   	leave  
  80054e:	c3                   	ret    

0080054f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	53                   	push   %ebx
  800555:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800558:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	ff 75 08             	pushl  0x8(%ebp)
  80055f:	e8 66 fe ff ff       	call   8003ca <fd_lookup>
  800564:	89 c3                	mov    %eax,%ebx
  800566:	83 c4 08             	add    $0x8,%esp
  800569:	85 c0                	test   %eax,%eax
  80056b:	0f 88 81 00 00 00    	js     8005f2 <dup+0xa3>
		return r;
	close(newfdnum);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	e8 83 ff ff ff       	call   8004ff <close>

	newfd = INDEX2FD(newfdnum);
  80057c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057f:	c1 e6 0c             	shl    $0xc,%esi
  800582:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800588:	83 c4 04             	add    $0x4,%esp
  80058b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058e:	e8 d1 fd ff ff       	call   800364 <fd2data>
  800593:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800595:	89 34 24             	mov    %esi,(%esp)
  800598:	e8 c7 fd ff ff       	call   800364 <fd2data>
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a2:	89 d8                	mov    %ebx,%eax
  8005a4:	c1 e8 16             	shr    $0x16,%eax
  8005a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ae:	a8 01                	test   $0x1,%al
  8005b0:	74 11                	je     8005c3 <dup+0x74>
  8005b2:	89 d8                	mov    %ebx,%eax
  8005b4:	c1 e8 0c             	shr    $0xc,%eax
  8005b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005be:	f6 c2 01             	test   $0x1,%dl
  8005c1:	75 39                	jne    8005fc <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c6:	89 d0                	mov    %edx,%eax
  8005c8:	c1 e8 0c             	shr    $0xc,%eax
  8005cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005da:	50                   	push   %eax
  8005db:	56                   	push   %esi
  8005dc:	6a 00                	push   $0x0
  8005de:	52                   	push   %edx
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 c0 fb ff ff       	call   8001a6 <sys_page_map>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 31                	js     800620 <dup+0xd1>
		goto err;

	return newfdnum;
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f2:	89 d8                	mov    %ebx,%eax
  8005f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f7:	5b                   	pop    %ebx
  8005f8:	5e                   	pop    %esi
  8005f9:	5f                   	pop    %edi
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	57                   	push   %edi
  80060d:	6a 00                	push   $0x0
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	e8 8f fb ff ff       	call   8001a6 <sys_page_map>
  800617:	89 c3                	mov    %eax,%ebx
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	85 c0                	test   %eax,%eax
  80061e:	79 a3                	jns    8005c3 <dup+0x74>
	sys_page_unmap(0, newfd);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	56                   	push   %esi
  800624:	6a 00                	push   $0x0
  800626:	e8 bd fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 00                	push   $0x0
  800631:	e8 b2 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb b7                	jmp    8005f2 <dup+0xa3>

0080063b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 14             	sub    $0x14,%esp
  800642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	e8 7b fd ff ff       	call   8003ca <fd_lookup>
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 3f                	js     800695 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800660:	ff 30                	pushl  (%eax)
  800662:	e8 b9 fd ff ff       	call   800420 <dev_lookup>
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	85 c0                	test   %eax,%eax
  80066c:	78 27                	js     800695 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800671:	8b 42 08             	mov    0x8(%edx),%eax
  800674:	83 e0 03             	and    $0x3,%eax
  800677:	83 f8 01             	cmp    $0x1,%eax
  80067a:	74 1e                	je     80069a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067f:	8b 40 08             	mov    0x8(%eax),%eax
  800682:	85 c0                	test   %eax,%eax
  800684:	74 35                	je     8006bb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	52                   	push   %edx
  800690:	ff d0                	call   *%eax
  800692:	83 c4 10             	add    $0x10,%esp
}
  800695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800698:	c9                   	leave  
  800699:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069a:	a1 04 40 80 00       	mov    0x804004,%eax
  80069f:	8b 40 48             	mov    0x48(%eax),%eax
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	68 59 1e 80 00       	push   $0x801e59
  8006ac:	e8 67 0a 00 00       	call   801118 <cprintf>
		return -E_INVAL;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b9:	eb da                	jmp    800695 <read+0x5a>
		return -E_NOT_SUPP;
  8006bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c0:	eb d3                	jmp    800695 <read+0x5a>

008006c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d6:	39 f3                	cmp    %esi,%ebx
  8006d8:	73 25                	jae    8006ff <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 4d ff ff ff       	call   80063b <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 08                	js     8006fd <readn+0x3b>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 06                	je     8006ff <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	eb d9                	jmp    8006d6 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800704:	5b                   	pop    %ebx
  800705:	5e                   	pop    %esi
  800706:	5f                   	pop    %edi
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 14             	sub    $0x14,%esp
  800710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800713:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	53                   	push   %ebx
  800718:	e8 ad fc ff ff       	call   8003ca <fd_lookup>
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 3a                	js     80075e <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072e:	ff 30                	pushl  (%eax)
  800730:	e8 eb fc ff ff       	call   800420 <dev_lookup>
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 22                	js     80075e <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800743:	74 1e                	je     800763 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800748:	8b 52 0c             	mov    0xc(%edx),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 35                	je     800784 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	50                   	push   %eax
  800759:	ff d2                	call   *%edx
  80075b:	83 c4 10             	add    $0x10,%esp
}
  80075e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800761:	c9                   	leave  
  800762:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800763:	a1 04 40 80 00       	mov    0x804004,%eax
  800768:	8b 40 48             	mov    0x48(%eax),%eax
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	53                   	push   %ebx
  80076f:	50                   	push   %eax
  800770:	68 75 1e 80 00       	push   $0x801e75
  800775:	e8 9e 09 00 00       	call   801118 <cprintf>
		return -E_INVAL;
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb da                	jmp    80075e <write+0x55>
		return -E_NOT_SUPP;
  800784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800789:	eb d3                	jmp    80075e <write+0x55>

0080078b <seek>:

int
seek(int fdnum, off_t offset)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800791:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 2d fc ff ff       	call   8003ca <fd_lookup>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	78 0e                	js     8007b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 14             	sub    $0x14,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	53                   	push   %ebx
  8007c3:	e8 02 fc ff ff       	call   8003ca <fd_lookup>
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 37                	js     800806 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 40 fc ff ff       	call   800420 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 1f                	js     800806 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	74 1b                	je     80080b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f3:	8b 52 18             	mov    0x18(%edx),%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 32                	je     80082c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	50                   	push   %eax
  800801:	ff d2                	call   *%edx
  800803:	83 c4 10             	add    $0x10,%esp
}
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800810:	8b 40 48             	mov    0x48(%eax),%eax
  800813:	83 ec 04             	sub    $0x4,%esp
  800816:	53                   	push   %ebx
  800817:	50                   	push   %eax
  800818:	68 38 1e 80 00       	push   $0x801e38
  80081d:	e8 f6 08 00 00       	call   801118 <cprintf>
		return -E_INVAL;
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082a:	eb da                	jmp    800806 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800831:	eb d3                	jmp    800806 <ftruncate+0x52>

00800833 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 14             	sub    $0x14,%esp
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 81 fb ff ff       	call   8003ca <fd_lookup>
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 4b                	js     80089b <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800856:	50                   	push   %eax
  800857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085a:	ff 30                	pushl  (%eax)
  80085c:	e8 bf fb ff ff       	call   800420 <dev_lookup>
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	85 c0                	test   %eax,%eax
  800866:	78 33                	js     80089b <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086f:	74 2f                	je     8008a0 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800871:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800874:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087b:	00 00 00 
	stat->st_isdir = 0;
  80087e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800885:	00 00 00 
	stat->st_dev = dev;
  800888:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	53                   	push   %ebx
  800892:	ff 75 f0             	pushl  -0x10(%ebp)
  800895:	ff 50 14             	call   *0x14(%eax)
  800898:	83 c4 10             	add    $0x10,%esp
}
  80089b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a5:	eb f4                	jmp    80089b <fstat+0x68>

008008a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	6a 00                	push   $0x0
  8008b1:	ff 75 08             	pushl  0x8(%ebp)
  8008b4:	e8 e7 01 00 00       	call   800aa0 <open>
  8008b9:	89 c3                	mov    %eax,%ebx
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 1b                	js     8008dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	50                   	push   %eax
  8008c9:	e8 65 ff ff ff       	call   800833 <fstat>
  8008ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d0:	89 1c 24             	mov    %ebx,(%esp)
  8008d3:	e8 27 fc ff ff       	call   8004ff <close>
	return r;
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	89 f3                	mov    %esi,%ebx
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	89 c6                	mov    %eax,%esi
  8008ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f6:	74 27                	je     80091f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f8:	6a 07                	push   $0x7
  8008fa:	68 00 50 80 00       	push   $0x805000
  8008ff:	56                   	push   %esi
  800900:	ff 35 00 40 80 00    	pushl  0x804000
  800906:	e8 ca 11 00 00       	call   801ad5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090b:	83 c4 0c             	add    $0xc,%esp
  80090e:	6a 00                	push   $0x0
  800910:	53                   	push   %ebx
  800911:	6a 00                	push   $0x0
  800913:	e8 5c 11 00 00       	call   801a74 <ipc_recv>
}
  800918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	6a 01                	push   $0x1
  800924:	e8 f9 11 00 00       	call   801b22 <ipc_find_env>
  800929:	a3 00 40 80 00       	mov    %eax,0x804000
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	eb c5                	jmp    8008f8 <fsipc+0x12>

00800933 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 40 0c             	mov    0xc(%eax),%eax
  80093f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 02 00 00 00       	mov    $0x2,%eax
  800956:	e8 8b ff ff ff       	call   8008e6 <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_flush>:
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 40 0c             	mov    0xc(%eax),%eax
  800969:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 06 00 00 00       	mov    $0x6,%eax
  800978:	e8 69 ff ff ff       	call   8008e6 <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	83 ec 04             	sub    $0x4,%esp
  800986:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 40 0c             	mov    0xc(%eax),%eax
  80098f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800994:	ba 00 00 00 00       	mov    $0x0,%edx
  800999:	b8 05 00 00 00       	mov    $0x5,%eax
  80099e:	e8 43 ff ff ff       	call   8008e6 <fsipc>
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 2c                	js     8009d3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	68 00 50 80 00       	push   $0x805000
  8009af:	53                   	push   %ebx
  8009b0:	e8 82 0d 00 00       	call   801737 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <devfile_write>:
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8009e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009eb:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f4:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8009fa:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8009ff:	50                   	push   %eax
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	68 08 50 80 00       	push   $0x805008
  800a08:	e8 b8 0e 00 00       	call   8018c5 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 04 00 00 00       	mov    $0x4,%eax
  800a17:	e8 ca fe ff ff       	call   8008e6 <fsipc>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_read>:
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a31:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a41:	e8 a0 fe ff ff       	call   8008e6 <fsipc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 1f                	js     800a6b <devfile_read+0x4d>
	assert(r <= n);
  800a4c:	39 f0                	cmp    %esi,%eax
  800a4e:	77 24                	ja     800a74 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a55:	7f 33                	jg     800a8a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a57:	83 ec 04             	sub    $0x4,%esp
  800a5a:	50                   	push   %eax
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	e8 5d 0e 00 00       	call   8018c5 <memmove>
	return r;
  800a68:	83 c4 10             	add    $0x10,%esp
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    
	assert(r <= n);
  800a74:	68 a4 1e 80 00       	push   $0x801ea4
  800a79:	68 ab 1e 80 00       	push   $0x801eab
  800a7e:	6a 7d                	push   $0x7d
  800a80:	68 c0 1e 80 00       	push   $0x801ec0
  800a85:	e8 b3 05 00 00       	call   80103d <_panic>
	assert(r <= PGSIZE);
  800a8a:	68 cb 1e 80 00       	push   $0x801ecb
  800a8f:	68 ab 1e 80 00       	push   $0x801eab
  800a94:	6a 7e                	push   $0x7e
  800a96:	68 c0 1e 80 00       	push   $0x801ec0
  800a9b:	e8 9d 05 00 00       	call   80103d <_panic>

00800aa0 <open>:
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 1c             	sub    $0x1c,%esp
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aab:	56                   	push   %esi
  800aac:	e8 4f 0c 00 00       	call   801700 <strlen>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab9:	0f 8f 96 00 00 00    	jg     800b55 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	e8 b0 f8 ff ff       	call   80037b <fd_alloc>
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	78 66                	js     800b3a <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	56                   	push   %esi
  800ad8:	68 00 50 80 00       	push   $0x805000
  800add:	e8 55 0c 00 00       	call   801737 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	e8 ef fd ff ff       	call   8008e6 <fsipc>
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 43                	js     800b43 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	ff 75 f4             	pushl  -0xc(%ebp)
  800b06:	e8 49 f8 ff ff       	call   800354 <fd2num>
  800b0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0e:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800b14:	8b 49 48             	mov    0x48(%ecx),%ecx
  800b17:	83 c4 08             	add    $0x8,%esp
  800b1a:	50                   	push   %eax
  800b1b:	52                   	push   %edx
  800b1c:	ff 32                	pushl  (%edx)
  800b1e:	56                   	push   %esi
  800b1f:	51                   	push   %ecx
  800b20:	68 d8 1e 80 00       	push   $0x801ed8
  800b25:	e8 ee 05 00 00       	call   801118 <cprintf>
	return fd2num(fd);
  800b2a:	83 c4 14             	add    $0x14,%esp
  800b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b30:	e8 1f f8 ff ff       	call   800354 <fd2num>
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	83 c4 10             	add    $0x10,%esp
}
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    
		fd_close(fd, 0);
  800b43:	83 ec 08             	sub    $0x8,%esp
  800b46:	6a 00                	push   $0x0
  800b48:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4b:	e8 26 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	eb e5                	jmp    800b3a <open+0x9a>
		return -E_BAD_PATH;
  800b55:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b5a:	eb de                	jmp    800b3a <open+0x9a>

00800b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6c:	e8 75 fd ff ff       	call   8008e6 <fsipc>
}
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 de f7 ff ff       	call   800364 <fd2data>
  800b86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b88:	83 c4 08             	add    $0x8,%esp
  800b8b:	68 17 1f 80 00       	push   $0x801f17
  800b90:	53                   	push   %ebx
  800b91:	e8 a1 0b 00 00       	call   801737 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b96:	8b 46 04             	mov    0x4(%esi),%eax
  800b99:	2b 06                	sub    (%esi),%eax
  800b9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba8:	00 00 00 
	stat->st_dev = &devpipe;
  800bab:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb2:	30 80 00 
	return 0;
}
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bcb:	53                   	push   %ebx
  800bcc:	6a 00                	push   $0x0
  800bce:	e8 15 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd3:	89 1c 24             	mov    %ebx,(%esp)
  800bd6:	e8 89 f7 ff ff       	call   800364 <fd2data>
  800bdb:	83 c4 08             	add    $0x8,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 00                	push   $0x0
  800be1:	e8 02 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800be6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <_pipeisclosed>:
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 1c             	sub    $0x1c,%esp
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bf8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	57                   	push   %edi
  800c04:	e8 52 0f 00 00       	call   801b5b <pageref>
  800c09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0c:	89 34 24             	mov    %esi,(%esp)
  800c0f:	e8 47 0f 00 00       	call   801b5b <pageref>
		nn = thisenv->env_runs;
  800c14:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	39 cb                	cmp    %ecx,%ebx
  800c22:	74 1b                	je     800c3f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c24:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c27:	75 cf                	jne    800bf8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c29:	8b 42 58             	mov    0x58(%edx),%eax
  800c2c:	6a 01                	push   $0x1
  800c2e:	50                   	push   %eax
  800c2f:	53                   	push   %ebx
  800c30:	68 1e 1f 80 00       	push   $0x801f1e
  800c35:	e8 de 04 00 00       	call   801118 <cprintf>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb b9                	jmp    800bf8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c3f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c42:	0f 94 c0             	sete   %al
  800c45:	0f b6 c0             	movzbl %al,%eax
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <devpipe_write>:
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 28             	sub    $0x28,%esp
  800c59:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c5c:	56                   	push   %esi
  800c5d:	e8 02 f7 ff ff       	call   800364 <fd2data>
  800c62:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c6f:	74 4f                	je     800cc0 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c71:	8b 43 04             	mov    0x4(%ebx),%eax
  800c74:	8b 0b                	mov    (%ebx),%ecx
  800c76:	8d 51 20             	lea    0x20(%ecx),%edx
  800c79:	39 d0                	cmp    %edx,%eax
  800c7b:	72 14                	jb     800c91 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c7d:	89 da                	mov    %ebx,%edx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	e8 65 ff ff ff       	call   800beb <_pipeisclosed>
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 3a                	jne    800cc4 <devpipe_write+0x74>
			sys_yield();
  800c8a:	e8 b5 f4 ff ff       	call   800144 <sys_yield>
  800c8f:	eb e0                	jmp    800c71 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c98:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9b:	89 c2                	mov    %eax,%edx
  800c9d:	c1 fa 1f             	sar    $0x1f,%edx
  800ca0:	89 d1                	mov    %edx,%ecx
  800ca2:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca8:	83 e2 1f             	and    $0x1f,%edx
  800cab:	29 ca                	sub    %ecx,%edx
  800cad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cbb:	83 c7 01             	add    $0x1,%edi
  800cbe:	eb ac                	jmp    800c6c <devpipe_write+0x1c>
	return i;
  800cc0:	89 f8                	mov    %edi,%eax
  800cc2:	eb 05                	jmp    800cc9 <devpipe_write+0x79>
				return 0;
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <devpipe_read>:
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 18             	sub    $0x18,%esp
  800cda:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cdd:	57                   	push   %edi
  800cde:	e8 81 f6 ff ff       	call   800364 <fd2data>
  800ce3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	be 00 00 00 00       	mov    $0x0,%esi
  800ced:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cf0:	74 47                	je     800d39 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cf2:	8b 03                	mov    (%ebx),%eax
  800cf4:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cf7:	75 22                	jne    800d1b <devpipe_read+0x4a>
			if (i > 0)
  800cf9:	85 f6                	test   %esi,%esi
  800cfb:	75 14                	jne    800d11 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cfd:	89 da                	mov    %ebx,%edx
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	e8 e5 fe ff ff       	call   800beb <_pipeisclosed>
  800d06:	85 c0                	test   %eax,%eax
  800d08:	75 33                	jne    800d3d <devpipe_read+0x6c>
			sys_yield();
  800d0a:	e8 35 f4 ff ff       	call   800144 <sys_yield>
  800d0f:	eb e1                	jmp    800cf2 <devpipe_read+0x21>
				return i;
  800d11:	89 f0                	mov    %esi,%eax
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1b:	99                   	cltd   
  800d1c:	c1 ea 1b             	shr    $0x1b,%edx
  800d1f:	01 d0                	add    %edx,%eax
  800d21:	83 e0 1f             	and    $0x1f,%eax
  800d24:	29 d0                	sub    %edx,%eax
  800d26:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d31:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d34:	83 c6 01             	add    $0x1,%esi
  800d37:	eb b4                	jmp    800ced <devpipe_read+0x1c>
	return i;
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	eb d6                	jmp    800d13 <devpipe_read+0x42>
				return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d42:	eb cf                	jmp    800d13 <devpipe_read+0x42>

00800d44 <pipe>:
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4f:	50                   	push   %eax
  800d50:	e8 26 f6 ff ff       	call   80037b <fd_alloc>
  800d55:	89 c3                	mov    %eax,%ebx
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	78 5b                	js     800db9 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5e:	83 ec 04             	sub    $0x4,%esp
  800d61:	68 07 04 00 00       	push   $0x407
  800d66:	ff 75 f4             	pushl  -0xc(%ebp)
  800d69:	6a 00                	push   $0x0
  800d6b:	e8 f3 f3 ff ff       	call   800163 <sys_page_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	78 40                	js     800db9 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 f6 f5 ff ff       	call   80037b <fd_alloc>
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	78 1b                	js     800da9 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f0             	pushl  -0x10(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 c3 f3 ff ff       	call   800163 <sys_page_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	79 19                	jns    800dc2 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800da9:	83 ec 08             	sub    $0x8,%esp
  800dac:	ff 75 f4             	pushl  -0xc(%ebp)
  800daf:	6a 00                	push   $0x0
  800db1:	e8 32 f4 ff ff       	call   8001e8 <sys_page_unmap>
  800db6:	83 c4 10             	add    $0x10,%esp
}
  800db9:	89 d8                	mov    %ebx,%eax
  800dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
	va = fd2data(fd0);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc8:	e8 97 f5 ff ff       	call   800364 <fd2data>
  800dcd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 c4 0c             	add    $0xc,%esp
  800dd2:	68 07 04 00 00       	push   $0x407
  800dd7:	50                   	push   %eax
  800dd8:	6a 00                	push   $0x0
  800dda:	e8 84 f3 ff ff       	call   800163 <sys_page_alloc>
  800ddf:	89 c3                	mov    %eax,%ebx
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	0f 88 8c 00 00 00    	js     800e78 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	ff 75 f0             	pushl  -0x10(%ebp)
  800df2:	e8 6d f5 ff ff       	call   800364 <fd2data>
  800df7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfe:	50                   	push   %eax
  800dff:	6a 00                	push   $0x0
  800e01:	56                   	push   %esi
  800e02:	6a 00                	push   $0x0
  800e04:	e8 9d f3 ff ff       	call   8001a6 <sys_page_map>
  800e09:	89 c3                	mov    %eax,%ebx
  800e0b:	83 c4 20             	add    $0x20,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 58                	js     800e6a <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e30:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e35:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e42:	e8 0d f5 ff ff       	call   800354 <fd2num>
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4c:	83 c4 04             	add    $0x4,%esp
  800e4f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e52:	e8 fd f4 ff ff       	call   800354 <fd2num>
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e65:	e9 4f ff ff ff       	jmp    800db9 <pipe+0x75>
	sys_page_unmap(0, va);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	56                   	push   %esi
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 73 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 63 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	e9 1c ff ff ff       	jmp    800da9 <pipe+0x65>

00800e8d <pipeisclosed>:
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e96:	50                   	push   %eax
  800e97:	ff 75 08             	pushl  0x8(%ebp)
  800e9a:	e8 2b f5 ff ff       	call   8003ca <fd_lookup>
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	78 18                	js     800ebe <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eac:	e8 b3 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb6:	e8 30 fd ff ff       	call   800beb <_pipeisclosed>
  800ebb:	83 c4 10             	add    $0x10,%esp
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed0:	68 36 1f 80 00       	push   $0x801f36
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	e8 5a 08 00 00       	call   801737 <strcpy>
	return 0;
}
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devcons_write>:
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ef0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ef5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800efb:	eb 2f                	jmp    800f2c <devcons_write+0x48>
		m = n - tot;
  800efd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f00:	29 f3                	sub    %esi,%ebx
  800f02:	83 fb 7f             	cmp    $0x7f,%ebx
  800f05:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f0a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	53                   	push   %ebx
  800f11:	89 f0                	mov    %esi,%eax
  800f13:	03 45 0c             	add    0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	57                   	push   %edi
  800f18:	e8 a8 09 00 00       	call   8018c5 <memmove>
		sys_cputs(buf, m);
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	e8 80 f1 ff ff       	call   8000a7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f27:	01 de                	add    %ebx,%esi
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2f:	72 cc                	jb     800efd <devcons_write+0x19>
}
  800f31:	89 f0                	mov    %esi,%eax
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <devcons_read>:
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4a:	75 07                	jne    800f53 <devcons_read+0x18>
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    
		sys_yield();
  800f4e:	e8 f1 f1 ff ff       	call   800144 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f53:	e8 6d f1 ff ff       	call   8000c5 <sys_cgetc>
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 f2                	je     800f4e <devcons_read+0x13>
	if (c < 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 ec                	js     800f4c <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f60:	83 f8 04             	cmp    $0x4,%eax
  800f63:	74 0c                	je     800f71 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f68:	88 02                	mov    %al,(%edx)
	return 1;
  800f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6f:	eb db                	jmp    800f4c <devcons_read+0x11>
		return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb d4                	jmp    800f4c <devcons_read+0x11>

00800f78 <cputchar>:
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f84:	6a 01                	push   $0x1
  800f86:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	e8 18 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <getchar>:
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f9a:	6a 01                	push   $0x1
  800f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 94 f6 ff ff       	call   80063b <read>
	if (r < 0)
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 08                	js     800fb6 <getchar+0x22>
	if (r < 1)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 06                	jle    800fb8 <getchar+0x24>
	return c;
  800fb2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    
		return -E_EOF;
  800fb8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fbd:	eb f7                	jmp    800fb6 <getchar+0x22>

00800fbf <iscons>:
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 f9 f3 ff ff       	call   8003ca <fd_lookup>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 11                	js     800fe9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe1:	39 10                	cmp    %edx,(%eax)
  800fe3:	0f 94 c0             	sete   %al
  800fe6:	0f b6 c0             	movzbl %al,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <opencons>:
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	e8 81 f3 ff ff       	call   80037b <fd_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 3a                	js     80103b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 07 04 00 00       	push   $0x407
  801009:	ff 75 f4             	pushl  -0xc(%ebp)
  80100c:	6a 00                	push   $0x0
  80100e:	e8 50 f1 ff ff       	call   800163 <sys_page_alloc>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 21                	js     80103b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801023:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801028:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	e8 1c f3 ff ff       	call   800354 <fd2num>
  801038:	83 c4 10             	add    $0x10,%esp
}
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801042:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801045:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104b:	e8 d5 f0 ff ff       	call   800125 <sys_getenvid>
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	ff 75 0c             	pushl  0xc(%ebp)
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	56                   	push   %esi
  80105a:	50                   	push   %eax
  80105b:	68 44 1f 80 00       	push   $0x801f44
  801060:	e8 b3 00 00 00       	call   801118 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801065:	83 c4 18             	add    $0x18,%esp
  801068:	53                   	push   %ebx
  801069:	ff 75 10             	pushl  0x10(%ebp)
  80106c:	e8 56 00 00 00       	call   8010c7 <vcprintf>
	cprintf("\n");
  801071:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  801078:	e8 9b 00 00 00       	call   801118 <cprintf>
  80107d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801080:	cc                   	int3   
  801081:	eb fd                	jmp    801080 <_panic+0x43>

00801083 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	53                   	push   %ebx
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108d:	8b 13                	mov    (%ebx),%edx
  80108f:	8d 42 01             	lea    0x1(%edx),%eax
  801092:	89 03                	mov    %eax,(%ebx)
  801094:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801097:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a0:	74 09                	je     8010ab <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	68 ff 00 00 00       	push   $0xff
  8010b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b6:	50                   	push   %eax
  8010b7:	e8 eb ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	eb db                	jmp    8010a2 <putch+0x1f>

008010c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d7:	00 00 00 
	b.cnt = 0;
  8010da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e4:	ff 75 0c             	pushl  0xc(%ebp)
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f0:	50                   	push   %eax
  8010f1:	68 83 10 80 00       	push   $0x801083
  8010f6:	e8 1a 01 00 00       	call   801215 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fb:	83 c4 08             	add    $0x8,%esp
  8010fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801104:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	e8 97 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801110:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801121:	50                   	push   %eax
  801122:	ff 75 08             	pushl  0x8(%ebp)
  801125:	e8 9d ff ff ff       	call   8010c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 1c             	sub    $0x1c,%esp
  801135:	89 c7                	mov    %eax,%edi
  801137:	89 d6                	mov    %edx,%esi
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801142:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801145:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801150:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801153:	39 d3                	cmp    %edx,%ebx
  801155:	72 05                	jb     80115c <printnum+0x30>
  801157:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115a:	77 7a                	ja     8011d6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 18             	pushl  0x18(%ebp)
  801162:	8b 45 14             	mov    0x14(%ebp),%eax
  801165:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801168:	53                   	push   %ebx
  801169:	ff 75 10             	pushl  0x10(%ebp)
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801172:	ff 75 e0             	pushl  -0x20(%ebp)
  801175:	ff 75 dc             	pushl  -0x24(%ebp)
  801178:	ff 75 d8             	pushl  -0x28(%ebp)
  80117b:	e8 20 0a 00 00       	call   801ba0 <__udivdi3>
  801180:	83 c4 18             	add    $0x18,%esp
  801183:	52                   	push   %edx
  801184:	50                   	push   %eax
  801185:	89 f2                	mov    %esi,%edx
  801187:	89 f8                	mov    %edi,%eax
  801189:	e8 9e ff ff ff       	call   80112c <printnum>
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	eb 13                	jmp    8011a6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	56                   	push   %esi
  801197:	ff 75 18             	pushl  0x18(%ebp)
  80119a:	ff d7                	call   *%edi
  80119c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80119f:	83 eb 01             	sub    $0x1,%ebx
  8011a2:	85 db                	test   %ebx,%ebx
  8011a4:	7f ed                	jg     801193 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	56                   	push   %esi
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b9:	e8 02 0b 00 00       	call   801cc0 <__umoddi3>
  8011be:	83 c4 14             	add    $0x14,%esp
  8011c1:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011c8:	50                   	push   %eax
  8011c9:	ff d7                	call   *%edi
}
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
  8011d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011d9:	eb c4                	jmp    80119f <printnum+0x73>

008011db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e5:	8b 10                	mov    (%eax),%edx
  8011e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ea:	73 0a                	jae    8011f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	88 02                	mov    %al,(%edx)
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <printfmt>:
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801201:	50                   	push   %eax
  801202:	ff 75 10             	pushl  0x10(%ebp)
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 05 00 00 00       	call   801215 <vprintfmt>
}
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <vprintfmt>:
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 2c             	sub    $0x2c,%esp
  80121e:	8b 75 08             	mov    0x8(%ebp),%esi
  801221:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801224:	8b 7d 10             	mov    0x10(%ebp),%edi
  801227:	e9 c1 03 00 00       	jmp    8015ed <vprintfmt+0x3d8>
		padc = ' ';
  80122c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801230:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801237:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80123e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801245:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80124a:	8d 47 01             	lea    0x1(%edi),%eax
  80124d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801250:	0f b6 17             	movzbl (%edi),%edx
  801253:	8d 42 dd             	lea    -0x23(%edx),%eax
  801256:	3c 55                	cmp    $0x55,%al
  801258:	0f 87 12 04 00 00    	ja     801670 <vprintfmt+0x45b>
  80125e:	0f b6 c0             	movzbl %al,%eax
  801261:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801268:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80126b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80126f:	eb d9                	jmp    80124a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801271:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801274:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801278:	eb d0                	jmp    80124a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80127a:	0f b6 d2             	movzbl %dl,%edx
  80127d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801288:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80128b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80128f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801292:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801295:	83 f9 09             	cmp    $0x9,%ecx
  801298:	77 55                	ja     8012ef <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80129a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80129d:	eb e9                	jmp    801288 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80129f:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a2:	8b 00                	mov    (%eax),%eax
  8012a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012aa:	8d 40 04             	lea    0x4(%eax),%eax
  8012ad:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012b7:	79 91                	jns    80124a <vprintfmt+0x35>
				width = precision, precision = -1;
  8012b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012c6:	eb 82                	jmp    80124a <vprintfmt+0x35>
  8012c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d2:	0f 49 d0             	cmovns %eax,%edx
  8012d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012db:	e9 6a ff ff ff       	jmp    80124a <vprintfmt+0x35>
  8012e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ea:	e9 5b ff ff ff       	jmp    80124a <vprintfmt+0x35>
  8012ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012f5:	eb bc                	jmp    8012b3 <vprintfmt+0x9e>
			lflag++;
  8012f7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012fd:	e9 48 ff ff ff       	jmp    80124a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801302:	8b 45 14             	mov    0x14(%ebp),%eax
  801305:	8d 78 04             	lea    0x4(%eax),%edi
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	53                   	push   %ebx
  80130c:	ff 30                	pushl  (%eax)
  80130e:	ff d6                	call   *%esi
			break;
  801310:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801313:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801316:	e9 cf 02 00 00       	jmp    8015ea <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80131b:	8b 45 14             	mov    0x14(%ebp),%eax
  80131e:	8d 78 04             	lea    0x4(%eax),%edi
  801321:	8b 00                	mov    (%eax),%eax
  801323:	99                   	cltd   
  801324:	31 d0                	xor    %edx,%eax
  801326:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801328:	83 f8 0f             	cmp    $0xf,%eax
  80132b:	7f 23                	jg     801350 <vprintfmt+0x13b>
  80132d:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801334:	85 d2                	test   %edx,%edx
  801336:	74 18                	je     801350 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801338:	52                   	push   %edx
  801339:	68 bd 1e 80 00       	push   $0x801ebd
  80133e:	53                   	push   %ebx
  80133f:	56                   	push   %esi
  801340:	e8 b3 fe ff ff       	call   8011f8 <printfmt>
  801345:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801348:	89 7d 14             	mov    %edi,0x14(%ebp)
  80134b:	e9 9a 02 00 00       	jmp    8015ea <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801350:	50                   	push   %eax
  801351:	68 7f 1f 80 00       	push   $0x801f7f
  801356:	53                   	push   %ebx
  801357:	56                   	push   %esi
  801358:	e8 9b fe ff ff       	call   8011f8 <printfmt>
  80135d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801360:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801363:	e9 82 02 00 00       	jmp    8015ea <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801368:	8b 45 14             	mov    0x14(%ebp),%eax
  80136b:	83 c0 04             	add    $0x4,%eax
  80136e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801371:	8b 45 14             	mov    0x14(%ebp),%eax
  801374:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801376:	85 ff                	test   %edi,%edi
  801378:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  80137d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801380:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801384:	0f 8e bd 00 00 00    	jle    801447 <vprintfmt+0x232>
  80138a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80138e:	75 0e                	jne    80139e <vprintfmt+0x189>
  801390:	89 75 08             	mov    %esi,0x8(%ebp)
  801393:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801396:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801399:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80139c:	eb 6d                	jmp    80140b <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013a4:	57                   	push   %edi
  8013a5:	e8 6e 03 00 00       	call   801718 <strnlen>
  8013aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ad:	29 c1                	sub    %eax,%ecx
  8013af:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013bf:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c1:	eb 0f                	jmp    8013d2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cc:	83 ef 01             	sub    $0x1,%edi
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	85 ff                	test   %edi,%edi
  8013d4:	7f ed                	jg     8013c3 <vprintfmt+0x1ae>
  8013d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013d9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013dc:	85 c9                	test   %ecx,%ecx
  8013de:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e3:	0f 49 c1             	cmovns %ecx,%eax
  8013e6:	29 c1                	sub    %eax,%ecx
  8013e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8013eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013f1:	89 cb                	mov    %ecx,%ebx
  8013f3:	eb 16                	jmp    80140b <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f9:	75 31                	jne    80142c <vprintfmt+0x217>
					putch(ch, putdat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	50                   	push   %eax
  801402:	ff 55 08             	call   *0x8(%ebp)
  801405:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801408:	83 eb 01             	sub    $0x1,%ebx
  80140b:	83 c7 01             	add    $0x1,%edi
  80140e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801412:	0f be c2             	movsbl %dl,%eax
  801415:	85 c0                	test   %eax,%eax
  801417:	74 59                	je     801472 <vprintfmt+0x25d>
  801419:	85 f6                	test   %esi,%esi
  80141b:	78 d8                	js     8013f5 <vprintfmt+0x1e0>
  80141d:	83 ee 01             	sub    $0x1,%esi
  801420:	79 d3                	jns    8013f5 <vprintfmt+0x1e0>
  801422:	89 df                	mov    %ebx,%edi
  801424:	8b 75 08             	mov    0x8(%ebp),%esi
  801427:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80142a:	eb 37                	jmp    801463 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80142c:	0f be d2             	movsbl %dl,%edx
  80142f:	83 ea 20             	sub    $0x20,%edx
  801432:	83 fa 5e             	cmp    $0x5e,%edx
  801435:	76 c4                	jbe    8013fb <vprintfmt+0x1e6>
					putch('?', putdat);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	6a 3f                	push   $0x3f
  80143f:	ff 55 08             	call   *0x8(%ebp)
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb c1                	jmp    801408 <vprintfmt+0x1f3>
  801447:	89 75 08             	mov    %esi,0x8(%ebp)
  80144a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801450:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801453:	eb b6                	jmp    80140b <vprintfmt+0x1f6>
				putch(' ', putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	53                   	push   %ebx
  801459:	6a 20                	push   $0x20
  80145b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80145d:	83 ef 01             	sub    $0x1,%edi
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 ff                	test   %edi,%edi
  801465:	7f ee                	jg     801455 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801467:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80146a:	89 45 14             	mov    %eax,0x14(%ebp)
  80146d:	e9 78 01 00 00       	jmp    8015ea <vprintfmt+0x3d5>
  801472:	89 df                	mov    %ebx,%edi
  801474:	8b 75 08             	mov    0x8(%ebp),%esi
  801477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147a:	eb e7                	jmp    801463 <vprintfmt+0x24e>
	if (lflag >= 2)
  80147c:	83 f9 01             	cmp    $0x1,%ecx
  80147f:	7e 3f                	jle    8014c0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801481:	8b 45 14             	mov    0x14(%ebp),%eax
  801484:	8b 50 04             	mov    0x4(%eax),%edx
  801487:	8b 00                	mov    (%eax),%eax
  801489:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148f:	8b 45 14             	mov    0x14(%ebp),%eax
  801492:	8d 40 08             	lea    0x8(%eax),%eax
  801495:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801498:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80149c:	79 5c                	jns    8014fa <vprintfmt+0x2e5>
				putch('-', putdat);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	6a 2d                	push   $0x2d
  8014a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8014a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ac:	f7 da                	neg    %edx
  8014ae:	83 d1 00             	adc    $0x0,%ecx
  8014b1:	f7 d9                	neg    %ecx
  8014b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014bb:	e9 10 01 00 00       	jmp    8015d0 <vprintfmt+0x3bb>
	else if (lflag)
  8014c0:	85 c9                	test   %ecx,%ecx
  8014c2:	75 1b                	jne    8014df <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8b 00                	mov    (%eax),%eax
  8014c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cc:	89 c1                	mov    %eax,%ecx
  8014ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8d 40 04             	lea    0x4(%eax),%eax
  8014da:	89 45 14             	mov    %eax,0x14(%ebp)
  8014dd:	eb b9                	jmp    801498 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8b 00                	mov    (%eax),%eax
  8014e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e7:	89 c1                	mov    %eax,%ecx
  8014e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f2:	8d 40 04             	lea    0x4(%eax),%eax
  8014f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f8:	eb 9e                	jmp    801498 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801500:	b8 0a 00 00 00       	mov    $0xa,%eax
  801505:	e9 c6 00 00 00       	jmp    8015d0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80150a:	83 f9 01             	cmp    $0x1,%ecx
  80150d:	7e 18                	jle    801527 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80150f:	8b 45 14             	mov    0x14(%ebp),%eax
  801512:	8b 10                	mov    (%eax),%edx
  801514:	8b 48 04             	mov    0x4(%eax),%ecx
  801517:	8d 40 08             	lea    0x8(%eax),%eax
  80151a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80151d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801522:	e9 a9 00 00 00       	jmp    8015d0 <vprintfmt+0x3bb>
	else if (lflag)
  801527:	85 c9                	test   %ecx,%ecx
  801529:	75 1a                	jne    801545 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80152b:	8b 45 14             	mov    0x14(%ebp),%eax
  80152e:	8b 10                	mov    (%eax),%edx
  801530:	b9 00 00 00 00       	mov    $0x0,%ecx
  801535:	8d 40 04             	lea    0x4(%eax),%eax
  801538:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80153b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801540:	e9 8b 00 00 00       	jmp    8015d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8b 10                	mov    (%eax),%edx
  80154a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80154f:	8d 40 04             	lea    0x4(%eax),%eax
  801552:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155a:	eb 74                	jmp    8015d0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80155c:	83 f9 01             	cmp    $0x1,%ecx
  80155f:	7e 15                	jle    801576 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801561:	8b 45 14             	mov    0x14(%ebp),%eax
  801564:	8b 10                	mov    (%eax),%edx
  801566:	8b 48 04             	mov    0x4(%eax),%ecx
  801569:	8d 40 08             	lea    0x8(%eax),%eax
  80156c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80156f:	b8 08 00 00 00       	mov    $0x8,%eax
  801574:	eb 5a                	jmp    8015d0 <vprintfmt+0x3bb>
	else if (lflag)
  801576:	85 c9                	test   %ecx,%ecx
  801578:	75 17                	jne    801591 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80157a:	8b 45 14             	mov    0x14(%ebp),%eax
  80157d:	8b 10                	mov    (%eax),%edx
  80157f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801584:	8d 40 04             	lea    0x4(%eax),%eax
  801587:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80158a:	b8 08 00 00 00       	mov    $0x8,%eax
  80158f:	eb 3f                	jmp    8015d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8b 10                	mov    (%eax),%edx
  801596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159b:	8d 40 04             	lea    0x4(%eax),%eax
  80159e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8015a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a6:	eb 28                	jmp    8015d0 <vprintfmt+0x3bb>
			putch('0', putdat);
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 30                	push   $0x30
  8015ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 78                	push   $0x78
  8015b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8b 10                	mov    (%eax),%edx
  8015bd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015c2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015c5:	8d 40 04             	lea    0x4(%eax),%eax
  8015c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015cb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d7:	57                   	push   %edi
  8015d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015db:	50                   	push   %eax
  8015dc:	51                   	push   %ecx
  8015dd:	52                   	push   %edx
  8015de:	89 da                	mov    %ebx,%edx
  8015e0:	89 f0                	mov    %esi,%eax
  8015e2:	e8 45 fb ff ff       	call   80112c <printnum>
			break;
  8015e7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015ed:	83 c7 01             	add    $0x1,%edi
  8015f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015f4:	83 f8 25             	cmp    $0x25,%eax
  8015f7:	0f 84 2f fc ff ff    	je     80122c <vprintfmt+0x17>
			if (ch == '\0')
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	0f 84 8b 00 00 00    	je     801690 <vprintfmt+0x47b>
			putch(ch, putdat);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	53                   	push   %ebx
  801609:	50                   	push   %eax
  80160a:	ff d6                	call   *%esi
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb dc                	jmp    8015ed <vprintfmt+0x3d8>
	if (lflag >= 2)
  801611:	83 f9 01             	cmp    $0x1,%ecx
  801614:	7e 15                	jle    80162b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801616:	8b 45 14             	mov    0x14(%ebp),%eax
  801619:	8b 10                	mov    (%eax),%edx
  80161b:	8b 48 04             	mov    0x4(%eax),%ecx
  80161e:	8d 40 08             	lea    0x8(%eax),%eax
  801621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801624:	b8 10 00 00 00       	mov    $0x10,%eax
  801629:	eb a5                	jmp    8015d0 <vprintfmt+0x3bb>
	else if (lflag)
  80162b:	85 c9                	test   %ecx,%ecx
  80162d:	75 17                	jne    801646 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80162f:	8b 45 14             	mov    0x14(%ebp),%eax
  801632:	8b 10                	mov    (%eax),%edx
  801634:	b9 00 00 00 00       	mov    $0x0,%ecx
  801639:	8d 40 04             	lea    0x4(%eax),%eax
  80163c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80163f:	b8 10 00 00 00       	mov    $0x10,%eax
  801644:	eb 8a                	jmp    8015d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801646:	8b 45 14             	mov    0x14(%ebp),%eax
  801649:	8b 10                	mov    (%eax),%edx
  80164b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801650:	8d 40 04             	lea    0x4(%eax),%eax
  801653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801656:	b8 10 00 00 00       	mov    $0x10,%eax
  80165b:	e9 70 ff ff ff       	jmp    8015d0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	6a 25                	push   $0x25
  801666:	ff d6                	call   *%esi
			break;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	e9 7a ff ff ff       	jmp    8015ea <vprintfmt+0x3d5>
			putch('%', putdat);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	53                   	push   %ebx
  801674:	6a 25                	push   $0x25
  801676:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	89 f8                	mov    %edi,%eax
  80167d:	eb 03                	jmp    801682 <vprintfmt+0x46d>
  80167f:	83 e8 01             	sub    $0x1,%eax
  801682:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801686:	75 f7                	jne    80167f <vprintfmt+0x46a>
  801688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80168b:	e9 5a ff ff ff       	jmp    8015ea <vprintfmt+0x3d5>
}
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 18             	sub    $0x18,%esp
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	74 26                	je     8016df <vsnprintf+0x47>
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	7e 22                	jle    8016df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016bd:	ff 75 14             	pushl  0x14(%ebp)
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	68 db 11 80 00       	push   $0x8011db
  8016cc:	e8 44 fb ff ff       	call   801215 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	83 c4 10             	add    $0x10,%esp
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    
		return -E_INVAL;
  8016df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e4:	eb f7                	jmp    8016dd <vsnprintf+0x45>

008016e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ef:	50                   	push   %eax
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	ff 75 08             	pushl  0x8(%ebp)
  8016f9:	e8 9a ff ff ff       	call   801698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801706:	b8 00 00 00 00       	mov    $0x0,%eax
  80170b:	eb 03                	jmp    801710 <strlen+0x10>
		n++;
  80170d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801714:	75 f7                	jne    80170d <strlen+0xd>
	return n;
}
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801721:	b8 00 00 00 00       	mov    $0x0,%eax
  801726:	eb 03                	jmp    80172b <strnlen+0x13>
		n++;
  801728:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80172b:	39 d0                	cmp    %edx,%eax
  80172d:	74 06                	je     801735 <strnlen+0x1d>
  80172f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801733:	75 f3                	jne    801728 <strnlen+0x10>
	return n;
}
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c1 01             	add    $0x1,%ecx
  801746:	83 c2 01             	add    $0x1,%edx
  801749:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80174d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801750:	84 db                	test   %bl,%bl
  801752:	75 ef                	jne    801743 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801754:	5b                   	pop    %ebx
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	53                   	push   %ebx
  80175b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80175e:	53                   	push   %ebx
  80175f:	e8 9c ff ff ff       	call   801700 <strlen>
  801764:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	01 d8                	add    %ebx,%eax
  80176c:	50                   	push   %eax
  80176d:	e8 c5 ff ff ff       	call   801737 <strcpy>
	return dst;
}
  801772:	89 d8                	mov    %ebx,%eax
  801774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	8b 75 08             	mov    0x8(%ebp),%esi
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	89 f3                	mov    %esi,%ebx
  801786:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801789:	89 f2                	mov    %esi,%edx
  80178b:	eb 0f                	jmp    80179c <strncpy+0x23>
		*dst++ = *src;
  80178d:	83 c2 01             	add    $0x1,%edx
  801790:	0f b6 01             	movzbl (%ecx),%eax
  801793:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801796:	80 39 01             	cmpb   $0x1,(%ecx)
  801799:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80179c:	39 da                	cmp    %ebx,%edx
  80179e:	75 ed                	jne    80178d <strncpy+0x14>
	}
	return ret;
}
  8017a0:	89 f0                	mov    %esi,%eax
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017b4:	89 f0                	mov    %esi,%eax
  8017b6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017ba:	85 c9                	test   %ecx,%ecx
  8017bc:	75 0b                	jne    8017c9 <strlcpy+0x23>
  8017be:	eb 17                	jmp    8017d7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017c0:	83 c2 01             	add    $0x1,%edx
  8017c3:	83 c0 01             	add    $0x1,%eax
  8017c6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017c9:	39 d8                	cmp    %ebx,%eax
  8017cb:	74 07                	je     8017d4 <strlcpy+0x2e>
  8017cd:	0f b6 0a             	movzbl (%edx),%ecx
  8017d0:	84 c9                	test   %cl,%cl
  8017d2:	75 ec                	jne    8017c0 <strlcpy+0x1a>
		*dst = '\0';
  8017d4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017d7:	29 f0                	sub    %esi,%eax
}
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017e6:	eb 06                	jmp    8017ee <strcmp+0x11>
		p++, q++;
  8017e8:	83 c1 01             	add    $0x1,%ecx
  8017eb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017ee:	0f b6 01             	movzbl (%ecx),%eax
  8017f1:	84 c0                	test   %al,%al
  8017f3:	74 04                	je     8017f9 <strcmp+0x1c>
  8017f5:	3a 02                	cmp    (%edx),%al
  8017f7:	74 ef                	je     8017e8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f9:	0f b6 c0             	movzbl %al,%eax
  8017fc:	0f b6 12             	movzbl (%edx),%edx
  8017ff:	29 d0                	sub    %edx,%eax
}
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801812:	eb 06                	jmp    80181a <strncmp+0x17>
		n--, p++, q++;
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80181a:	39 d8                	cmp    %ebx,%eax
  80181c:	74 16                	je     801834 <strncmp+0x31>
  80181e:	0f b6 08             	movzbl (%eax),%ecx
  801821:	84 c9                	test   %cl,%cl
  801823:	74 04                	je     801829 <strncmp+0x26>
  801825:	3a 0a                	cmp    (%edx),%cl
  801827:	74 eb                	je     801814 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801829:	0f b6 00             	movzbl (%eax),%eax
  80182c:	0f b6 12             	movzbl (%edx),%edx
  80182f:	29 d0                	sub    %edx,%eax
}
  801831:	5b                   	pop    %ebx
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    
		return 0;
  801834:	b8 00 00 00 00       	mov    $0x0,%eax
  801839:	eb f6                	jmp    801831 <strncmp+0x2e>

0080183b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801845:	0f b6 10             	movzbl (%eax),%edx
  801848:	84 d2                	test   %dl,%dl
  80184a:	74 09                	je     801855 <strchr+0x1a>
		if (*s == c)
  80184c:	38 ca                	cmp    %cl,%dl
  80184e:	74 0a                	je     80185a <strchr+0x1f>
	for (; *s; s++)
  801850:	83 c0 01             	add    $0x1,%eax
  801853:	eb f0                	jmp    801845 <strchr+0xa>
			return (char *) s;
	return 0;
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801866:	eb 03                	jmp    80186b <strfind+0xf>
  801868:	83 c0 01             	add    $0x1,%eax
  80186b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80186e:	38 ca                	cmp    %cl,%dl
  801870:	74 04                	je     801876 <strfind+0x1a>
  801872:	84 d2                	test   %dl,%dl
  801874:	75 f2                	jne    801868 <strfind+0xc>
			break;
	return (char *) s;
}
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801884:	85 c9                	test   %ecx,%ecx
  801886:	74 13                	je     80189b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801888:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80188e:	75 05                	jne    801895 <memset+0x1d>
  801890:	f6 c1 03             	test   $0x3,%cl
  801893:	74 0d                	je     8018a2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	fc                   	cld    
  801899:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80189b:	89 f8                	mov    %edi,%eax
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    
		c &= 0xFF;
  8018a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018a6:	89 d3                	mov    %edx,%ebx
  8018a8:	c1 e3 08             	shl    $0x8,%ebx
  8018ab:	89 d0                	mov    %edx,%eax
  8018ad:	c1 e0 18             	shl    $0x18,%eax
  8018b0:	89 d6                	mov    %edx,%esi
  8018b2:	c1 e6 10             	shl    $0x10,%esi
  8018b5:	09 f0                	or     %esi,%eax
  8018b7:	09 c2                	or     %eax,%edx
  8018b9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018bb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	fc                   	cld    
  8018c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8018c3:	eb d6                	jmp    80189b <memset+0x23>

008018c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	57                   	push   %edi
  8018c9:	56                   	push   %esi
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018d3:	39 c6                	cmp    %eax,%esi
  8018d5:	73 35                	jae    80190c <memmove+0x47>
  8018d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018da:	39 c2                	cmp    %eax,%edx
  8018dc:	76 2e                	jbe    80190c <memmove+0x47>
		s += n;
		d += n;
  8018de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e1:	89 d6                	mov    %edx,%esi
  8018e3:	09 fe                	or     %edi,%esi
  8018e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018eb:	74 0c                	je     8018f9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ed:	83 ef 01             	sub    $0x1,%edi
  8018f0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018f3:	fd                   	std    
  8018f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f6:	fc                   	cld    
  8018f7:	eb 21                	jmp    80191a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f9:	f6 c1 03             	test   $0x3,%cl
  8018fc:	75 ef                	jne    8018ed <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018fe:	83 ef 04             	sub    $0x4,%edi
  801901:	8d 72 fc             	lea    -0x4(%edx),%esi
  801904:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801907:	fd                   	std    
  801908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190a:	eb ea                	jmp    8018f6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80190c:	89 f2                	mov    %esi,%edx
  80190e:	09 c2                	or     %eax,%edx
  801910:	f6 c2 03             	test   $0x3,%dl
  801913:	74 09                	je     80191e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801915:	89 c7                	mov    %eax,%edi
  801917:	fc                   	cld    
  801918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80191e:	f6 c1 03             	test   $0x3,%cl
  801921:	75 f2                	jne    801915 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801926:	89 c7                	mov    %eax,%edi
  801928:	fc                   	cld    
  801929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80192b:	eb ed                	jmp    80191a <memmove+0x55>

0080192d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801930:	ff 75 10             	pushl  0x10(%ebp)
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	ff 75 08             	pushl  0x8(%ebp)
  801939:	e8 87 ff ff ff       	call   8018c5 <memmove>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194b:	89 c6                	mov    %eax,%esi
  80194d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801950:	39 f0                	cmp    %esi,%eax
  801952:	74 1c                	je     801970 <memcmp+0x30>
		if (*s1 != *s2)
  801954:	0f b6 08             	movzbl (%eax),%ecx
  801957:	0f b6 1a             	movzbl (%edx),%ebx
  80195a:	38 d9                	cmp    %bl,%cl
  80195c:	75 08                	jne    801966 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80195e:	83 c0 01             	add    $0x1,%eax
  801961:	83 c2 01             	add    $0x1,%edx
  801964:	eb ea                	jmp    801950 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801966:	0f b6 c1             	movzbl %cl,%eax
  801969:	0f b6 db             	movzbl %bl,%ebx
  80196c:	29 d8                	sub    %ebx,%eax
  80196e:	eb 05                	jmp    801975 <memcmp+0x35>
	}

	return 0;
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801982:	89 c2                	mov    %eax,%edx
  801984:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801987:	39 d0                	cmp    %edx,%eax
  801989:	73 09                	jae    801994 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80198b:	38 08                	cmp    %cl,(%eax)
  80198d:	74 05                	je     801994 <memfind+0x1b>
	for (; s < ends; s++)
  80198f:	83 c0 01             	add    $0x1,%eax
  801992:	eb f3                	jmp    801987 <memfind+0xe>
			break;
	return (void *) s;
}
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	57                   	push   %edi
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a2:	eb 03                	jmp    8019a7 <strtol+0x11>
		s++;
  8019a4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019a7:	0f b6 01             	movzbl (%ecx),%eax
  8019aa:	3c 20                	cmp    $0x20,%al
  8019ac:	74 f6                	je     8019a4 <strtol+0xe>
  8019ae:	3c 09                	cmp    $0x9,%al
  8019b0:	74 f2                	je     8019a4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019b2:	3c 2b                	cmp    $0x2b,%al
  8019b4:	74 2e                	je     8019e4 <strtol+0x4e>
	int neg = 0;
  8019b6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019bb:	3c 2d                	cmp    $0x2d,%al
  8019bd:	74 2f                	je     8019ee <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c5:	75 05                	jne    8019cc <strtol+0x36>
  8019c7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ca:	74 2c                	je     8019f8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019cc:	85 db                	test   %ebx,%ebx
  8019ce:	75 0a                	jne    8019da <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019d5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d8:	74 28                	je     801a02 <strtol+0x6c>
		base = 10;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019e2:	eb 50                	jmp    801a34 <strtol+0x9e>
		s++;
  8019e4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ec:	eb d1                	jmp    8019bf <strtol+0x29>
		s++, neg = 1;
  8019ee:	83 c1 01             	add    $0x1,%ecx
  8019f1:	bf 01 00 00 00       	mov    $0x1,%edi
  8019f6:	eb c7                	jmp    8019bf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019fc:	74 0e                	je     801a0c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019fe:	85 db                	test   %ebx,%ebx
  801a00:	75 d8                	jne    8019da <strtol+0x44>
		s++, base = 8;
  801a02:	83 c1 01             	add    $0x1,%ecx
  801a05:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a0a:	eb ce                	jmp    8019da <strtol+0x44>
		s += 2, base = 16;
  801a0c:	83 c1 02             	add    $0x2,%ecx
  801a0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a14:	eb c4                	jmp    8019da <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a16:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a19:	89 f3                	mov    %esi,%ebx
  801a1b:	80 fb 19             	cmp    $0x19,%bl
  801a1e:	77 29                	ja     801a49 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a20:	0f be d2             	movsbl %dl,%edx
  801a23:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a26:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a29:	7d 30                	jge    801a5b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a2b:	83 c1 01             	add    $0x1,%ecx
  801a2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a32:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a34:	0f b6 11             	movzbl (%ecx),%edx
  801a37:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a3a:	89 f3                	mov    %esi,%ebx
  801a3c:	80 fb 09             	cmp    $0x9,%bl
  801a3f:	77 d5                	ja     801a16 <strtol+0x80>
			dig = *s - '0';
  801a41:	0f be d2             	movsbl %dl,%edx
  801a44:	83 ea 30             	sub    $0x30,%edx
  801a47:	eb dd                	jmp    801a26 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a49:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a4c:	89 f3                	mov    %esi,%ebx
  801a4e:	80 fb 19             	cmp    $0x19,%bl
  801a51:	77 08                	ja     801a5b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a53:	0f be d2             	movsbl %dl,%edx
  801a56:	83 ea 37             	sub    $0x37,%edx
  801a59:	eb cb                	jmp    801a26 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a5f:	74 05                	je     801a66 <strtol+0xd0>
		*endptr = (char *) s;
  801a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	f7 da                	neg    %edx
  801a6a:	85 ff                	test   %edi,%edi
  801a6c:	0f 45 c2             	cmovne %edx,%eax
}
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	56                   	push   %esi
  801a78:	53                   	push   %ebx
  801a79:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801a82:	85 c0                	test   %eax,%eax
  801a84:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a89:	0f 44 c2             	cmove  %edx,%eax
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	50                   	push   %eax
  801a90:	e8 7e e8 ff ff       	call   800313 <sys_ipc_recv>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 2b                	js     801ac7 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801a9c:	85 f6                	test   %esi,%esi
  801a9e:	74 0a                	je     801aaa <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 40 74             	mov    0x74(%eax),%eax
  801aa8:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 0a                	je     801ab8 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801aae:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab3:	8b 40 78             	mov    0x78(%eax),%eax
  801ab6:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801ab8:	a1 04 40 80 00       	mov    0x804004,%eax
  801abd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    
        *from_env_store = 0;
  801ac7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801acd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ad3:	eb eb                	jmp    801ac0 <ipc_recv+0x4c>

00801ad5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	57                   	push   %edi
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ae7:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801ae9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aee:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801af1:	ff 75 14             	pushl  0x14(%ebp)
  801af4:	53                   	push   %ebx
  801af5:	56                   	push   %esi
  801af6:	57                   	push   %edi
  801af7:	e8 f4 e7 ff ff       	call   8002f0 <sys_ipc_try_send>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	74 17                	je     801b1a <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801b03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b06:	74 e9                	je     801af1 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801b08:	50                   	push   %eax
  801b09:	68 60 22 80 00       	push   $0x802260
  801b0e:	6a 3e                	push   $0x3e
  801b10:	68 72 22 80 00       	push   $0x802272
  801b15:	e8 23 f5 ff ff       	call   80103d <_panic>
        }
    }
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b2d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b30:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b36:	8b 52 50             	mov    0x50(%edx),%edx
  801b39:	39 ca                	cmp    %ecx,%edx
  801b3b:	74 11                	je     801b4e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b3d:	83 c0 01             	add    $0x1,%eax
  801b40:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b45:	75 e6                	jne    801b2d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	eb 0b                	jmp    801b59 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b4e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b51:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b56:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b61:	89 d0                	mov    %edx,%eax
  801b63:	c1 e8 16             	shr    $0x16,%eax
  801b66:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b72:	f6 c1 01             	test   $0x1,%cl
  801b75:	74 1d                	je     801b94 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b77:	c1 ea 0c             	shr    $0xc,%edx
  801b7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b81:	f6 c2 01             	test   $0x1,%dl
  801b84:	74 0e                	je     801b94 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b86:	c1 ea 0c             	shr    $0xc,%edx
  801b89:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b90:	ef 
  801b91:	0f b7 c0             	movzwl %ax,%eax
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

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
