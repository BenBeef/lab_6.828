/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
extern struct Gatedesc idt[];
extern struct Pseudodesc idt_pd;

void trap_init(void);
void trap_init_percpu(void);
void print_regs(struct PushRegs *regs);
void print_trapframe(struct Trapframe *tf);

void divide_error_handler(struct Trapframe *);
void debug_exception_handler(struct Trapframe *);
void non_maskable_interrupt_handler(struct Trapframe *);
void breakpoint_handler(struct Trapframe *);
void overflow_handler(struct Trapframe *);
void bounds_check_handler(struct Trapframe *);
void illegal_opcode_handler(struct Trapframe *);
void device_not_available_handler(struct Trapframe *);
void double_fault_handler(struct Trapframe *);
// reserved
void invalid_task_switch_segment_handler(struct Trapframe *);
void segment_not_present_handler(struct Trapframe *);
void stack_exception_handler(struct Trapframe *);
void general_protection_fault_handler(struct Trapframe *);
void page_fault_handler(struct Trapframe *);
// reserved
void floating_point_error_handler(struct Trapframe *);
void aligment_check_handler(struct Trapframe *);
void machine_check_handler(struct Trapframe *);
void SIMD_floating_point_error_handler(struct Trapframe *);

void backtrace(struct Trapframe *);

extern void divide_error();
extern void debug_exception();
extern void non_maskable_interrupt();
extern void breakpoint_int();
extern void overflow();
extern void bounds_check();
extern void illegal_opcode();
extern void device_not_available();
extern void double_fault();
extern void reserved();
extern void invalid_task_switch_segment();
extern void segment_not_present();
extern void stack_exception();
extern void general_protection_fault();
extern void page_fault();
// reserved
extern void floating_point_error();
extern void aligment_check();
extern void machine_check();
extern void SIMD_floating_point_error();

extern void system_call();

#endif /* JOS_KERN_TRAP_H */
