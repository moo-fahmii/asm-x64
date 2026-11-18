.intel_syntax noprefix
.text
.global _start
_start:
       push 0x28 # arg2 = 40
       push 0x64 # arg1 = 100
       call func2
       add rsp, 16

       xor rdi, rdi
       # rax = 60 
       syscall

func2:
      push rbp
      mov rbp, rsp
      mov rax, [rbp+16]
      mov rdx, [rbp+24]
      sub rax, rdx
      mov rsp, rbp
      pop rbp
      ret

# (gdb) break *_start+offset_of_syscall
# (gdb) run
# (gdb) info registers rax rdi
# rax = 0x3c     60, from func2's return, not from any literal
# rdi = 0x0       exit code

# (gdb) break func2
# (gdb) run
# (gdb) x/2gx $rsp+8
# 0x...:  0x0000000000000064    100 (arg1)
# 0x...:  0x0000000000000028     40  (arg2)

# (gdb) stepi    through prologue, up to "sub rax, rdx"
# (gdb) info registers rax rdx
# rax = 0x64 (100)   rdx = 0x28 (40)

# (gdb) stepi    sub rax, rdx
# (gdb) info registers rax
# rax = 0x3c (60)   computed, on its way to becoming the syscall number
