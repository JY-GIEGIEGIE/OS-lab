C_SRC       = $(sort $(wildcard *.c))	#Makefile 被解析时，展开为当前目录（lib/）下所有 .c 文件名列表
OBJ = $(C_SRC:.c=.o)	#把列表里每个匹配 %.c 的词，替换成 %.o
all:$(OBJ)	#声明目标 all，依赖 printk.o
%.o:%.c	#声明目标 %.o，依赖 %.c
	${GCC} ${CFLAG} -c $< -o $@
clean:
	rm -f *.o
