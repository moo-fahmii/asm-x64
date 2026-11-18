# shell code to use (write) syscall 
.intel_syntax noprefix
.text
.global _start
_start:
     mov rbx, 0x004F4C4C4548
     push rbx
     mov rax, 0x01
     mov rdi, 1
     mov rsi, rsp
     mov rdx, 5
     syscall   
     pop rbx
 

