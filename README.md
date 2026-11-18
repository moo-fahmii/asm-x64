# x86-64 Assembly Portfolio

Linux x86-64 assembly programs written from scratch, no libc — direct syscalls only.
Part of my journey toward malware analysis and reverse engineering.

## Why assembly?

Reverse engineering at the binary level requires knowing what the CPU is
actually doing: registers, stack pointer, argument flow. Writing small
assembly programs makes this concrete.

## Environment

- Linux x86-64, GNU `as` + `ld`, Intel syntax (`.intel_syntax noprefix`)
- Debugging with `gdb` (`set disassembly-flavor intel`) and `strace`

## Projects

| File | Demonstrates |
|------|--------------|
| `helloworld.s` | `_start`, `sys_write`, `sys_exit` |
| `writesys.s` | write syscall convention (`rax`, `rdi`, `rsi`, `rdx`) |
| `readsys.s` | `sys_read` from stdin, echo |
| `pushpop.s` | `push`/`pop`, `rsp` movement |
| `call.s` | `call`/`ret`, return address on stack |
| `funcarg.s` | SysV register ABI, prologue/epilogue |
| `extended_func.s` | Multi-function, callee-saved discipline |
| `stackpassing.s` | Stack args at `[rbp+16]`, `[rbp+24]` |
| `stackpassing2.s` | Return values → syscall number |
| `printf_in_asm.s` | Variadic printf, `%d`, `div`-based itoa |

## Build

```bash
as file.s -o file.o
ld -e _start file.o -o file
./file

## License

MIT
