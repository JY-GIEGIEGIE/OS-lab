#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("sstatus = %p\n", csr_read(sstatus));          // csr_read宏读sstatus寄存器的值, 可删除
    printk("2024");
    printk(" ZJU Operating System\n");

    test();
    return 0;
}
