# 常见问题及解答
<!-- - [常见问题及解答](#常见问题及解答)
  - [1 为什么我把 Linux 源码放在共享文件夹或 wsl2 的 `/mnt` 下编译不出来？](#1-为什么我把-linux-源码放在共享文件夹或-wsl2-的-mnt-下编译不出来)
  - [2 为什么 QEMU & GDB 使用 `si` 单指令调试遇到模式切换时无法正常执行？](#2-为什么-qemu--gdb-使用-si-单指令调试遇到模式切换时无法正常执行)
  - [3 为什么我不能在 GDB 中使用 `next` 或者 `finish` ?](#3-为什么我不能在-gdb-中使用-next-或者-finish-)
  - [4 为什么我在内核中添加了 debug 信息，但是还是没法使用 `next` 或者 `finish` ?](#4-为什么我在内核中添加了-debug-信息但是还是没法使用-next-或者-finish-)
  - [5  为什么我在 `start_kernel` 处不能正常使用断点？](#5--为什么我在-start_kernel-处不能正常使用断点)
  - [6 为什么 Lab1 中提示 `riscv64-elf-unknown-gcc: No such file or directory` ?](#6-为什么-lab1-中提示-riscv64-elf-unknown-gcc-no-such-file-or-directory-)
  - [7 为什么 Lab1 中我的 C 语言函数的参数无法正确传入？](#7-为什么-lab1-中我的-c-语言函数的参数无法正确传入)
  - [8 为什么我把 `puti` 的参数类型替换成 `uint64` 还是只能打印出 32bits 的值？](#8-为什么我把-puti-的参数类型替换成-uint64-还是只能打印出-32bits-的值)
  - [9 为什么我的 QEMU 会 “卡住”？](#9-为什么我的-QEMU-会-“卡住”？)
  - [10 为什么我在设置 `satp` 后导致了 `gdb-multiarch` 的 `segmentation fault` ?](#10-为什么我在设置-satp-后导致了-gdb-multiarch-的-segmentation-fault)
  - [11 -->

!!! warning "首先需要明确的是，本次实验中的所有操作都不应该经由 Windows 中的文件系统，请直接在**虚拟机或 Linux 物理机**中直接完成。"

!!! warning "禁止直接 fork 本课程的 github 仓库"
    本课程要求同学们严格遵循诚信守则，禁止同学之间互相抄袭实验代码。如需建立私人 github 仓库，请将本课程仓库 clone 到本地之后，上传到自己的 private repo。禁止直接 fork 本课程的 github 仓库或直接将本课程实验相关内容上传到任何 public repo。

## 为什么我把 Linux 源码放在共享文件夹或 wsl2 的 `/mnt` 下编译不出来？

这种情况下，Linux 在使用 Windows 上的文件系统。请使用 `wget` 等工具将 Linux 源码下载至容器内目录**而非共享目录或 `/mnt` 目录下的任何位置**，然后执行编译。

## 为什么 QEMU & GDB 使用 `si` 单指令调试遇到模式切换时无法正常执行？

在遇到诸如 `mret`, `sret` 等指令造成的模式切换时，`si` 指令会失效，可能表现为程序开始不停跑，影响对程序运行行为的判断。

一个解决方法是在程序**预期跳转**的位置打上断点，断点不会受到模式切换的影响，比如：

```bash
(gdb) i r sepc    
sepc        0x8000babe
(gdb) b * 0x8000babe
Breakpoint 1 at 0x8000babe
(gdb) si    # 或者使用 c
Breakpoint 1, 0x000000008000babe in _never_gonna_give_you_up ()
...
```

这样就可以看到断点被触发，可以继续调试了。

## 为什么我不能在 GDB 中使用 `next` 或者 `finish` ?

这两条命令都依赖在内核中添加的调试信息，可以通过 `menuconfig` 进行配置添加。我们在实验中没有对这部分内容作要求，可以自行 Google 探索。

## 为什么我在内核中添加了 debug 信息，但是还是没法使用 `next` 或者 `finish` ?

可能你在配置内核时已经添加了调试信息，但是并没有在**QEMU运行的其他部分**添加。例如 SRAM 中对 `march` 进行配置的过程，以及 opensbi 中的所有部分，都缺少调试信息。所以才无法按照函数的层级进行调试。我们在实验中没有对这部分内容作要求，可以自行 Google 探索。

## 为什么 Lab1 中我的 C 语言函数的参数无法正确传入？

确认自己是否在 `head.S` 里的 `_start` 函数中正确设置了 `sp`，正常情况下它的值应该是 `0x8020XXXX`。未设置或设置错 `sp` 会使栈上的值不正确且无法写入。

!!! tip 
    注意检查是否将 `head.S` 里的 `.section` 改为 `.text.init`，如果不改的话 `_traps` 和 `_start` 都在 `.text.entry` 段，此时 `_traps` 会被放置到 `0x80200000` 处，导致其先于 `_start` 执行；而此时还未设置 `sp`，故传参时会出现混乱（具体表现为 `trap_handler` 的所有参数均显示 `2^64-1`）。

## 不会找 Lab1 的 syscall table 怎么办？

主要有两种方法，一种是安装该架构的交叉编译工具链并编译得到预处理产物，另一种则是在某些文件中直接就有现成的 syscall table. 无论选用哪种方法都要善用搜索，查找系统调用具体放在哪个文件中。可以参考[这篇文章](https://unix.stackexchange.com/questions/421750/where-do-you-find-the-syscall-table-for-linux)。

!!! tip 
    或许可以直接去 `arch` 对应架构文件夹下搜索关键词？

## lab1-思考题6：如何获取ARM64/RV32/RV64/x86_64架构的系统调用表

!!! tip

    相信有很多同学在完成这个思考题时，找到了类似`*.tbl`的文件，但是恰恰RISCV目录下是没有这个文件的（其实这个RISCV使用的是linux大目录下`scripts`中的`.tbl`文件。）

    需要注意的是，`*.tbl`文件 **并不是** 思考题中要求的“宏展开后”的文件，它只是一个存放数据的文件，并没有体现出它在代码中的嵌入关系。

    而在思考题5中，我们使用交叉编译生成的`*.i`文件，才是该思考题希望同学们获取的答案。


> 由于该部分较为复杂，因此同学们在报告中该思考题的ARM和x86的部分只需要提供.tbl文件的截图即可（RISCV仍然需要体现使用交叉编译生成文件的过程），具体的交叉编译方法供有兴趣的同学参考。

首先，我们要梳理获取系统调用表的具体方法：

### 1. 找到调用了系统调用表并进行配置的`*.c`文件

在不同的架构中，这些文件可能位于不同的位置（同学们可以思考 ~~不使用GPT~~ 如何找到它们，这里直接将答案列出）：

- ARM64：位于`arch/arm64/kernel/sys.c`
- RISCV32/64：位于`arch/riscv/kernel/syscall_table.c`
- x86_64：位于`arch/x86/entry/syscall_64.c`

!!! tip

    为什么RISCV32/64使用的是同一个.c文件呢？
    
    因为这个文件会通过编译时所使用的编译器来考虑使用RISCV32/64的系统调用表，换言之，对于RV32/64的编译，生成目标（即.i文件的路径）是不变的，你只需要修改所使用的编译器即可。


### 2. 对这个`*.c`文件进行交叉编译，目标是生成`*.i`文件（实验指导一：其他架构的交叉编译中提及）

生成`*.i`文件的本质目的是： **将c文件中的宏定义进行展开，获取展开后的系统调用表** 

- 这是因为：`*.c`文件往往是通过引用多个`*.h`文件来进行构造的，而实际的系统调用表内容一般存放在`*.h`文件中。因此，只观察`*.c`文件是无法看到具体的系统调用表内容的。

对于不同的架构，你需要选择（必要时需要安装）不同的编译工具链，并指定好对应需要生成的`*.i`文件的路径：

对于编译工具链：

- ARM64：使用`gcc-aarch64-linux-gnu`，需要自行安装（指导中已给出方法）
- RISCV32：使用`riscv64-linux-gnu-`， **但是需要使用不同的config使其能够使用RV32编译方法**
- RISCV64：使用`riscv64-linux-gnu-`，在lab0中我们使用的就是这个编译器
- x86_64：使用`x86_64-linux-gnu-`，使用WSL的同学应当在Linux初始化环境时就拥有这个编译器，如果是其他方式进行实验的同学可能需要自行安装

在安装好工具链后， **需要先进行config配置** （具体方法在lab0中使用过）

- 对于ARM64、x86_64、RISCV64，使用`defconfig`配置即可
- 对于RISCV32，需要使用`rv32_defconfig`配置

之后，就可以依照lab1给出的模板生成`.i`文件了：

`make ARCH=<arch name> CROSS_COMPILE=<compiler name> <path>`

其中`<>`的内容是需要根据需求进行替换的部分，需要注意的是：
- `<path>`替换为当前目录下的相对路径，如`arch/arm64/kernel/sys.i`

!!! tip

    如果在编译过程中报错：缺失`<gelf.h>`文件：

    需要通过`sudo apt install libelf-dev`安装libelf-dev工具来补充该头文件

之后，如果你所生成的`.i`文件的末尾（约70000行）存在类似这样的对照表（不同架构生成的内容表现形式可能不同，但应当是系统调用号到系统调用名之间的一一对应关系）：

```
# 1 "./arch/riscv/include/generated/asm/syscall_table_64.h" 1
[0] = __riscv_sys_io_setup,
[1] = __riscv_sys_io_destroy,
[2] = __riscv_sys_io_submit,
[3] = __riscv_sys_io_cancel,
[4] = __riscv_sys_io_getevents,
[5] = __riscv_sys_setxattr,
[6] = __riscv_sys_lsetxattr,
[7] = __riscv_sys_fsetxattr,
[8] = __riscv_sys_getxattr,
[9] = __riscv_sys_lgetxattr,
[10] = __riscv_sys_fgetxattr,
# ...
```

这说明你成功地获取了宏展开后的系统调用表！

### 3. What About ARM32?

ARM32的情况相比于其余几种架构更为特殊，它的导入路径如下：

`arch/arm/tools/syscall.tbl -----> arch/arm/include/generated/asm/unistd-nr.h -----> arch/arm/kernel/entry-common.S`

这意味着，经过Makefile的层层处理后，最终是由一个`.S`文件来参与最终的编译和链接。遗憾的是，Makefile中并没有给出`*.S`到`*.i`的转化规则，仅有`*.S`到`*.o`的转化规则 ~~（拼尽全力无法战胜）~~ ，因此在不修改执行命令或者Makefile的前提下无法显式地查看宏展开后的系统调用表。

> 如果有同学发现了可以查看该系统调用表的方法或有补充意见及建议，欢迎与助教联系！

## 如何升级到 Ubuntu 24.04

请按照 [How to upgrade - Ubuntu](https://ubuntu.com/server/docs/how-to-upgrade-your-release) 或 [DebianUpgrade - Debian Wiki](https://wiki.debian.org/DebianUpgrade) 的说明进行升级，所需命令概括如下（使用两种方式之一即可）：

- 使用 Ubuntu 特有的 `do-release-upgrade` 命令：

    ```shell
    sudo apt update
    sudo apt upgrade
    sudo apt full-upgrade
    sudo do-release-upgrade
    ```

- 使用 Debian 标准的升级流程：

    ```shell
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get full-upgrade
    # 修改 APT 源
    sudo apt-get clean
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get full-upgrade
    sudo apt-get autoremove
    ```

升级完成后，务必尽快重启，不论是物理机还是虚拟机（WSL、Docker）。

## 不知道如何计算 Lab3 建立映射时所需的虚拟地址 `va` 和大小 `sz`？

在 `vmlinux.lds` 中有 `_stext`, `_srodata` 等符号，可以在代码里这样来声明它：`extern char _stext[]`，这样就可以通过 `_stext` 获得其所在虚拟地址 `va`，并且可以通过两个段的开头符号做减法获得段的大小 `sz`。

<!--
## 为什么我的 QEMU 会 “卡住”？

`qemu-system` 本身作为一个模拟器，是不会直接卡死的，如果你在 `si` 或者 `c` 后，QEMU 看起来失去了响应，那么极有可能是程序运行到了意想不到的地方。例如在写入 `satp` 后，如果部分 bit 没有成功设置，那么可能会直接跳进 `trap`。而且在前面的实验中我们也发现了，在发生特权级切换或者发生陷入时，`si` 是有可能无法触发的，这种情况下就需要你在程序可能到达的地方都打上断点来暂停 QEMU 的执行了。

## 为什么我在设置 `satp` 后导致了 `gdb-multiarch` 的 `segmentation fault` ?

因为 `satp` 或者各级页表项设置有问题。比如检查一下我们之前一直忽略的页表项里 U-bit 设置好了没有。

## 为什么在 `vmlinux.lds.S` 中会 `#include "types.h"`?

因为我们实验代码存在一些历史限制没来得及修改，在 `vmlinux.lds.S` 中有 `#include "defs.h"`，然后之前又没有提醒同学不要在 `defs.h` 里面添加东西，导致在 `defs.h`中添加的内容阻碍了 `vmlinux.lds` 的正确生成。一个可行的做法是将 `defs.h` 中除了宏定义以外的部分全部去除（包括宏include），然后将这些去掉的部分添加到其他的头文件里以供使用。

## `uapp` 明明已经在内存里了，为什么还要被拷贝一次才能运行？

因为我们在实验中不准备引入磁盘驱动，所以将内存的一部分作为 `ramdisk`, 也就是说有一段内存被我们当成了硬盘。这段内存就是从 `uapp_start`  到 `uapp_end` 的空间，所以我们需要像操作磁盘一样操作这段内存。在运行磁盘上的程序前，我们需要将其拷贝到我们为程序分配的内存空间中，并依照 Elf Header 的要求映射到用户能访问的地址空间。这时候用户就能访问我们从磁盘拷贝到内存中的数据和代码了。

## 为什么我 `sret` 到用户程序的第一条指令时会 Instruction Page Fault?

大概率是因为没有设置好页表项里的 U-bit, 详细可以读一下 Privileged Spec. 也有可能你没有将内存映射到正确的位置上。

## `uapp` 要怎么拷贝到内存里？是要我们直接实现 VMA 和 `mmap` 吗？

只要一个一个字节地将内容复制到我们使用 `alloc_pages` 或者 `kalloc` 开辟的内存中即可，VMA 和 `mmap` 将在 Lab6 或之后才会引入，暂时不用同学们实现。 -->
