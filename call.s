.intel_syntax noprefix
.text
.global _start
_start:
    mov r12, rsp
    call _retfunc
    # after call, rsp should be r12 again (_retfunc did ret)
    mov rax, 0x3c
    xor rdi, rdi
    syscall

_retfunc:
    # at entry here: [rsp] = return address into _start
    # rsp = r12 - 8 (because call pushed 8 bytes)
    ret             # pops return address, jumps back
