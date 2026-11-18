# using 3 syscal (read, write , exit)
.intel_syntax noprefix
.equ max_length, 100
.section .rodata
lab:
.string " put a massege :"
.equ size, .-lab -1
.section .data
lab2:
.zero max_length


.text
.global _start

_start:
    mov rax, 0x01
    mov rdi, 1
    lea rsi, lab[rip]
    mov rdx, size
    syscall             # write syscall 
    cmp rax, 0

    mov rax, 0x00
    mov rdi, 0
    lea rsi, lab2[rip]
    mov rdx, max_length
    syscall              # read syscall
    
    mov rdx, rax
    mov rax, 0x01
    mov rdi, 1
    lea rsi, lab2[rip]
    syscall             # write syscall 

    mov rax, 0x3c
    xor rdi, rdi
    syscall             # exit syscall
