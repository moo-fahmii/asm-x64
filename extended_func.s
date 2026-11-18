.intel_syntax noprefix
.section .rodata

prefix:
    .string "[LOG] "
    .equ prefix_len, . - prefix - 1

message:
    .string "Hello World!"
    .equ msg_len, . - message - 1

newline:
    .byte 10

.text
.global _start
_start:
    lea rdi, prefix[rip]
    mov rsi, prefix_len
    lea rdx, message[rip]
    mov rcx, msg_len
    call _print2
    mov rax, 60
    xor rdi, rdi
    syscall

.global _print2
_print2:
    push rbp
    mov rbp, rsp
    push rdx                   
    push rcx                    
    mov rdx, rsi                
    mov rsi, rdi                
    mov rdi, 1                 
    mov rax, 1                 
    syscall                     
    pop rdx                     
    pop rsi                     
    mov rdi, 1
    mov rax, 1
    syscall
    lea rsi, newline[rip]
    mov rdx, 1
    mov rdi, 1
    mov rax, 1
    syscall
    mov rsp, rbp
    pop rbp
    ret
.size _print2, .-_print2
