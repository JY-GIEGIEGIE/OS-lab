#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("sstatus = %p\n", csr_read(sstatus));          // csr_read宏读sstatus寄存器的值, 可删除
    csr_write(sscratch, 0xcafebabedeadbeef);              // csr_write宏写sscratch寄存器的值为0xcafebabedeadbeef, 作为csr_write功能的测试，在开始写trap部分前要删除以免冲突
    printk("sscratch = %p\n", csr_read(sscratch));
    printk("2024");
    printk(" ZJU Operating System\n");

    test();
    return 0;
}
