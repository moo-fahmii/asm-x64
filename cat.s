.intel_syntax noprefix

.section .rodata
err_prefix:
    .string "cat:can't open: "
    .equ err_prefix_length, . - err_prefix -1

err_newline:
    .byte 10

.section .bss
buff:
    .space 4096


.section .text
.global _start

_start:
     mov r12, [rsp]    # argc
     lea r13, [rsp+8]  # argv
     add r13, 8        # to skip the name
     dec r12
     test r12, r12
     jnz .have_file

     mov rdi, 0
     call cat_fd
     jmp .ext_ok

.have_file:

.file_loop:
       test r12, r12
       jz .ext_ok
       mov r14, [r13]   # the path
       mov rax, 2       # syscall open
       mov rdi, r14     
       xor rsi, rsi     # O_RDONLY = 0
       xor rdx, rdx     # mode = 0 (irrelevant without O_CREAT)
       syscall
       test rax, rax
       js .open_fail
       mov r15, rax     # saving fd in r15
       mov rdi, r15
       call cat_fd
       mov rax, 3       # syscall close
       mov rdi, r15
       syscall
       add r13, 8
       dec r12
       jmp .file_loop

.open_fail: # "cat: cannot open: " to stderr
      
       mov rax, 1   # syscall write
       mov rdi, 2
       lea rsi, [rip + err_prefix] 
       mov rdx, err_prefix_length
       syscall

# write the path (its length  loop until null)
       mov rdi, r14
       xor rcx, rcx

.path_len:
       cmp byte ptr [rdi + rcx], 0
       je .path_len_done
       inc rcx
       jmp .path_len

.path_len_done:
       mov rax, 1  # syscall write
       mov rdi, 2
       mov rsi, r14
       mov rdx, rcx
       syscall
       mov rax, 1  # write syscall (newline)
       mov rdi, 2
       lea rsi, [rip + err_newline] 
       mov rdx, 1
       syscall
       mov rax, 60  # syscall exit
       mov rdi, 1
       syscall

.ext_ok:
       mov rax, 60  # syscall exit
       xor rdi, rdi
       syscall

# 
# cat_fd(rdi = fd) read from fd, write to stdout until EOF
# Preserves r15 (callee-saved; we use it internally).
# 
cat_fd:
       push rbp
       mov rbp,rsp
       push r15
       mov r15, rdi   # fd

.read_loop:
       mov rax, 0  # syscall read
       mov rdi, r15
       lea rsi, [rip + buff]
       mov rdx, 4096
       syscall
       test rax, rax
       jle .done  # 0 = EOF, negative = error
       mov rdx, rax # the bytes 
       mov rax, 1   # syscall wriiite
       mov rdi, 1   # stdout
       lea rsi, [rip + buff]
       syscall
       jmp .read_loop
.done:
       pop r15
       mov rsp, rbp
       pop rbp
       ret
