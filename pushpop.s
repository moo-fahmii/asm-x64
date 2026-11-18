# demonstration of how push and pop work with debugging (gdb)
.intel_syntax noprefix
.text
.global _start
_start:
    mov r12, rsp        # r12 = initial rsp
    push 0x11
    push 0x22
    push 0x33
    # rsp should now be r12 - 24
    pop rax             # rax = 0x33
    pop rbx             # rbx = 0x22
    pop rcx             # rcx = 0x11
    # rsp should be back to r12

    mov rax, 0x3c
    xor rdi, rdi
    syscall
    
