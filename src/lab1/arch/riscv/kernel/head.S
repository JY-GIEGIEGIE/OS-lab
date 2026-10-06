    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    lla sp, boot_stack_top  # 栈指针sp = 栈区最高地址（.bss.stack 顶端）

    # set sie[STIE] = 1
    li t0, 0x20
    csrs sie, t0
    # set sstatus[SIE] = 1
    li t0, 0x2
    csrs sstatus, t0

    # set stvec = _traps        先注释，等 entry.S 写好再补
    # set first time interrupt  先跳过

    j   start_kernel    # 无条件跳转到start_kernel，相当于jal x0, start_kernel，不保存 ra 一去不返回
    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- 4KiB = 4096bytes

    .globl boot_stack_top
boot_stack_top: