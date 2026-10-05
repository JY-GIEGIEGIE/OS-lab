#ifndef __DEFS_H__
#define __DEFS_H__

#include "stdint.h"

// define a variable to hold the value of a CSR register, and read the value of the CSR register into that variable
#define csr_read(csr)                   \
  ({                                    \
    uint64_t __v;                       \
    /* pseudo command : csrr rd csr, %0 for read CSR register csr into rd, and store the value in __v, 是GCC 替 __v 挑的那个寄存器的占位符 */ \
    asm volatile("csrr %0, " #csr : "=r"(__v)); \
    __v;                               \
    /* return the value of the CSR register read into the variable __v */ \
  })

#define csr_write(csr, val)                                    \
  ({                                                           \
    uint64_t __v = (uint64_t)(val);                            \
    asm volatile("csrw " #csr ", %0" : : "r"(__v) : "memory"); \
  })

#endif
