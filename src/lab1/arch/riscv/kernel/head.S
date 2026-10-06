    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    lla sp, boot_stack_top  # 栈指针sp = 栈区最高地址（.bss.stack 顶端）

    # set stvec = _traps
    lla t0, _traps
    csrw stvec, t0 

    # set sie[STIE] = 1
    li t0, 0x20
    csrs sie, t0

    # set first time interrupt
    rdtime a0
    li t0, 10000000   # 10000000是qemu的一秒内时钟周期数
    add a0, a0, t0    # 加一秒
    call sbi_set_timer  # 把加一秒后的时间存进stimecmp，以供硬件比较器比较

    # set sstatus[SIE] = 1
    li t0, 0x2
    csrs sstatus, t0
       

    j   start_kernel    # 无条件跳转到start_kernel，相当于jal x0, start_kernel，不保存 ra 一去不返回
    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- 4KiB = 4096bytes

    .globl boot_stack_top
boot_stack_top: