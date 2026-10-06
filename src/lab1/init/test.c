#include "sbi.h"

#include "printk.h"

// 原版 test() 开机后立即 shutdown，观察不到内核持续运行的状态，按文档改为死循环。
// 注意：test() 是 C 函数，位于 .text.test 段（工程开着 -ffunction-sections），
// 由链接脚本的 *(.text .text.*) 收集；.text.init 是 _start 专属段，与之无关。
void test() {
    int i = 0;
    while (1) {
        if ((++i) % 100000000 == 0) { 
            printk("kernel is running!\n");
            i = 0;
        }
    }
}
