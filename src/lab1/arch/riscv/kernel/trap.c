#include "stdint.h"
#include "printk.h"
#include "clock.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    // 通过 `scause` 判断 trap 类型
    if ((scause & 0x8000000000000000) != 0) { // 最高位为1
        // 如果是 interrupt 判断是否是 timer interrupt
        uint64_t interrupt_type = scause & 0xff; // 低8位为中断类型
        if (interrupt_type == 5) {
            // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
            printk("[S] Supervisor Mode Timer Interrupt\n");
            clock_set_next_event();
        }else{
            printk("unexpected interrupt: scause=%p, sepc=%p\n", scause, sepc);
        }
    }else{
        // exception（低 8 位为异常码），打印出来供以后调试
        printk("unexpected exception: scause=%p, sepc=%p\n", scause, sepc);
    }
}