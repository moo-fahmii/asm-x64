.intel_syntax noprefix
.text
.global _start

_start:
      push 0x3c # first arg for _func, will be used later for exit syscall
      call _func
      add rsp, 8 # Remove the add rsp, 8 line and re-run Why does it still work here?
# _start doesn't clean up because it exits the stack is destroyed by the process                  
# the cleanup only matters for stack discipline across multiple calls
     xor rdi, rdi
     syscall # the syscall number came from the stack, through the function


_func:
     push rbp
     mov rbp, rsp
     mov rax, [rbp+16]
     mov rsp, rbp
     pop rbp
     ret

