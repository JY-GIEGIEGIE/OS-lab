    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -32*8          # 分配 32 个 8 字节槽

    sd x1, 0*8(sp)              # ra
    # x2(sp) 稍后单独保存原始值
    sd x3, 2*8(sp)              # gp
    sd x4, 3*8(sp)              # tp
    sd x5, 4*8(sp)              # t0
    sd x6, 5*8(sp)              # t1
    sd x7, 6*8(sp)              # t2
    sd x8, 7*8(sp)              # s0/fp
    sd x9, 8*8(sp)              # s1
    sd x10, 9*8(sp)             # a0
    sd x11, 10*8(sp)            # a1
    sd x12, 11*8(sp)            # a2
    sd x13, 12*8(sp)            # a3
    sd x14, 13*8(sp)            # a4
    sd x15, 14*8(sp)            # a5
    sd x16, 15*8(sp)            # a6
    sd x17, 16*8(sp)            # a7
    sd x18, 17*8(sp)            # s2
    sd x19, 18*8(sp)            # s3
    sd x20, 19*8(sp)            # s4
    sd x21, 20*8(sp)            # s5
    sd x22, 21*8(sp)            # s6
    sd x23, 22*8(sp)            # s7
    sd x24, 23*8(sp)            # s8
    sd x25, 24*8(sp)            # s9
    sd x26, 25*8(sp)            # s10
    sd x27, 26*8(sp)            # s11
    sd x28, 27*8(sp)            # t3
    sd x29, 28*8(sp)            # t4
    sd x30, 29*8(sp)            # t5
    sd x31, 30*8(sp)            # t6

    # 保存原始 sp（x2）：进入 _traps 后 sp 已指向新栈帧，原始值 = 当前 sp + 32*8。
    # 借道 t0 中转——t0 的原始值已在槽 4 封存，之后可安全征用。
    addi t0, sp, 32*8
    sd t0, 1*8(sp)              # 存入 x2 对应的槽

    # 保存 sepc：CSR 不能直接写内存（不存在 sd sepc, ... 这类指令），
    # 必须借通用寄存器中转，继续用 t0。
    # 顺序约定：sepc 最后存、最先恢复，要求 t0 原始值先入栈，
    # 恢复它必须在 t0 被 ld 还原之前，所以恢复时放最前。
    csrr t0, sepc
    sd t0, 31*8(sp)

    # 2. call trap_handler(scause, sepc)
    # 参数按 C 调用约定走 a0/a1。覆盖 a0/a1 是安全的，因为被打断代码的 a0/a1 原始值已在槽 9、10 封存，返回后会恢复。
    csrr a0, scause             # 参数 1：trap 原因
    csrr a1, sepc               # 参数 2：触发 trap 的指令地址
    call trap_handler

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack

    ld t0, 31*8(sp)
    csrw sepc, t0               # 先恢复 sepc，须在下面 ld x5 把 t0 还原之前

    ld x1, 0*8(sp)
    ld x3, 2*8(sp)
    ld x4, 3*8(sp)
    ld x5, 4*8(sp)
    ld x6, 5*8(sp)
    ld x7, 6*8(sp)
    ld x8, 7*8(sp)
    ld x9, 8*8(sp)
    ld x10, 9*8(sp)
    ld x11, 10*8(sp)
    ld x12, 11*8(sp)
    ld x13, 12*8(sp)
    ld x14, 13*8(sp)
    ld x15, 14*8(sp)
    ld x16, 15*8(sp)
    ld x17, 16*8(sp)
    ld x18, 17*8(sp)
    ld x19, 18*8(sp)
    ld x20, 19*8(sp)
    ld x21, 20*8(sp)
    ld x22, 21*8(sp)
    ld x23, 22*8(sp)
    ld x24, 23*8(sp)
    ld x25, 24*8(sp)
    ld x26, 25*8(sp)
    ld x27, 26*8(sp)
    ld x28, 27*8(sp)
    ld x29, 28*8(sp)
    ld x30, 29*8(sp)
    ld x31, 30*8(sp)

    # 最后恢复 sp（x2），此后不能再访问栈
    ld sp, 1*8(sp)

    # 4. return from trap
    sret