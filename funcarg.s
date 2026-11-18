# functions in assembly & passing the arg via the registers
.intel_syntax noprefix
.section .rodata

label1:
.string "Hello World!\n"
.equ length, . - label1 - 1

.text
.global _start
_start:
       lea rdi, label1[rip]
       mov rsi, length
       call _print
       mov rax, 0x3c
       xor rdi, rdi
       syscall


.global _print
_print:
      push rbp
      mov rbp, rsp
      mov rdx, rsi
      mov rsi, rdi
      mov rax, 0x01
      mov rdi, 1
      syscall
      mov rsp, rbp
      pop rbp
      ret 
.size _print, .-_print


