#include "printk.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("sie = %p\n", csr_read(sie));
    printk("sstatus = %p\n", csr_read(sstatus));

    printk("sscratch = %p\n", csr_read(sscratch));
    printk("2024");
    printk(" ZJU Operating System\n");

    test();
    return 0;
}
