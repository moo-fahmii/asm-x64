.intel_syntax noprefix

.section .rodata
fmt:
    .string "sum = %d\n"

.section .data
array:
    .quad 10, 20, 30, 40        # row 0  100
    .quad  1,  2,  3,  4        # row 1  10
    .quad  5,  5,  5,  5        # row 2  20

.equ num_rows, 3
.equ num_cols, 4

.text
.global _start
_start:
    lea r15, [rip + array]      # row pointer
    mov rbx, num_rows           # row counter

.row_loop:
    # Push 4 values in REVERSE order (col4 first, col1 last)
    mov rax, [r15 + 24]         # col 4 = 40
    push rax
    mov rax, [r15 + 16]         # col 3 = 30
    push rax
    mov rax, [r15 + 8]          # col 2 = 20
    push rax
    mov rax, [r15 + 0]          # col 1 = 10
    push rax

    mov rdi, num_cols           # count = 4
    call _sum_stack             # rax = sum
    add rsp, 32                 # clean up 4 stack args

    # Now print "sum = <rax>\n"
    push rax                    # the sum, as _printf's stack arg
    lea rdi, [rip + fmt]        # format string
    mov rsi, 1                  # one %d
    call _printf
    add rsp, 8                  # clean up printf's arg

    add r15, 32                 # next row (4 quads = 32 bytes)
    dec rbx
    jnz .row_loop

    mov rax, 60
    xor rdi, rdi
    syscall

# 
# _sum_stack(rdi = count)  rax = sum
# Stack args at [rbp+16], [rbp+24], ...
# 
.global _sum_stack
.type   _sum_stack, @function
_sum_stack:
    push rbp
    mov rbp, rsp

    xor rax, rax                # sum = 0
    mov rcx, rdi                # counter = count
    lea r8, [rbp + 16]          # pointer to first stack arg

.loop:
    test rcx, rcx
    jz   .done
    add rax, [r8]               # sum += *r8
    add r8, 8                   # advance pointer
    dec rcx
    jmp .loop

.done:
    mov rsp, rbp
    pop rbp
    ret
.size _sum_stack, .-_sum_stack

# ─────────────────────────────────────────────────────────
# _printf(rdi = fmt, rsi = count) — walks format string, prints
# Stack args at [rbp+16], [rbp+24]
# ─────────────────────────────────────────────────────────
.global _printf
.type   _printf, @function
_printf:
    push rbp
    mov rbp, rsp
    push r12                    # MUST save callee-saved regs we use
    push r13
    push r14

    mov r12, rdi                # fmt pointer (walk)
    mov r13, rsi                # remaining arg count
    lea r14, [rbp + 16]         # pointer to next stack arg

.fmt_loop:
    movzx eax, byte ptr [r12]   # load current byte
    test al, al
    jz .fmt_done                # null terminator  done

    cmp al, '%'
    jne .print_char             # not '%'  print literally

    # We saw '%', check for 'd'
    cmp byte ptr [r12 + 1], 'd'
    jne .print_char             # not %d  print '%' literally

    test r13, r13
    jz .print_char              # no args left  print '%' literally

    # Consume one arg
    mov rdi, [r14]              # value to print
    add r14, 8                  # advance arg pointer
    dec r13                     # decrement remaining
    call _print_uint            # print the number

    add r12, 2                  # skip past "%d"
    jmp .fmt_loop

.print_char:
    mov rax, 1                  # sys_write
    mov rdi, 1                  # stdout
    mov rsi, r12                # current byte
    mov rdx, 1
    syscall
    inc r12                     # advance by 1
    jmp .fmt_loop

.fmt_done:
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret
.size _printf, .-_printf

#
# _print_uint(rdi = value)  prints non-negative integer
# 
.global _print_uint
.type   _print_uint, @function
_print_uint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 32                 # 32-byte digit buffer

    mov rax, rdi                # rax = value
    mov rbx, 10                 # divisor
    lea r12, [rsp + 31]         # point at last byte of buffer

.conv:
    xor rdx, rdx                # MUST clear before div
    div rbx                     # rdx:rax / 10  rax=quot, rdx=rem
    add dl, '0'                 # remainder  ASCII digit
    mov [r12], dl               # store digit
    dec r12                     # move pointer back
    test rax, rax
    jnz .conv                   # loop while quotient != 0

    # Now r12+1 points at first digit
    lea rsi, [r12 + 1]          # buffer start
    lea rdx, [rsp + 32]         # buffer end
    sub rdx, rsi                # length = end - start

    mov rax, 1                  # sys_write
    mov rdi, 1                  # stdout
    syscall

    add rsp, 32
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
.size _print_uint, .-_print_uint

.section .note.GNU-stack,"",@progbits
