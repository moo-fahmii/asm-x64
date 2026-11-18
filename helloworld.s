# hello world in asssembly 

.intel_syntax noprefix
.section  .rodata

label1:
.string "HELLO WORLD!\n"
.equ size, .-label1 -1
.text
.global _start
_start:
     mov rax, 0x01
     mov rdi, 1
     lea rsi, label1[rip]
     mov rdx, size
     syscall
     cmp rax, 0
     jl error
     mov rax, 0x3c
     xor rdi, rdi 
     syscall
     error:
     mov rax, 0x3c 
     mov rdi, 1
     syscall


