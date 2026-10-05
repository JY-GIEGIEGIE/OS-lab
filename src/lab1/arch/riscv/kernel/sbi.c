#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret ret;
    // Implement the SBI ECALL handling logic here
    asm volatile (
        "mv a7, %[eid]\n" // Move the extension ID to a7
        "mv a6, %[fid]\n" // Move the function ID to a6
        "mv a0, %[arg0]\n" // Move the first argument to a0
        "mv a1, %[arg1]\n" // Move the second argument to a1
        "mv a2, %[arg2]\n" // Move the third argument to a2
        "mv a3, %[arg3]\n" // Move the fourth argument to a3
        "mv a4, %[arg4]\n" // Move the fifth argument to a4
        "mv a5, %[arg5]\n" // Move the sixth argument to a5
        "ecall\n"       // Make the ecall
        "mv %[val], a1\n" // Store return value in ret.value
        "mv %[err], a0\n" // Store error code in ret.error
        : [val]"=r"(ret.value) , [err]"=r"(ret.error) // Output operand
        : [arg0]"r"(arg0), [arg1]"r"(arg1), [arg2]"r"(arg2), [arg3]"r"(arg3), [arg4]"r"(arg4), [arg5]"r"(arg5), [fid]"r"(fid), [eid]"r"(eid) // Input operands
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory" // 涉及到的所有寄存器声明，标准模板
    );
    return ret;
}

// Implement the SBI functions according to ecall specifications

struct sbiret sbi_set_timer(uint64_t stime_value){
    return sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0); // TIMESTAMP extension ID and function ID for set_timer
}

// 查阅 SBI v2.0 规范，得到read与write的原型

struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr) {
    return sbi_ecall(0x4442434e, 0, num_bytes, base_addr, 0, 0, 0, 0);
}

struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr) {
    return sbi_ecall(0x4442434e, 1, num_bytes, base_addr, 0, 0, 0, 0);
}


struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0); // DEBUG_CONSOLE extension ID and function ID for write_byte
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0); // SYSTEM_RESET extension ID and function ID for system_reset
}