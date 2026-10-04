    .extern start_kernel
    .section .text.entry
    .globl _start
_start:
    lla sp, boot_stack_top  # 栈指针sp = 栈区最高地址（.bss.stack 顶端）
    j   start_kernel    # 无条件跳转到start_kernel，相当于jal x0, start_kernel，不保存 ra 一去不返回
    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- 4KiB = 4096bytes

    .globl boot_stack_top
boot_stack_top: