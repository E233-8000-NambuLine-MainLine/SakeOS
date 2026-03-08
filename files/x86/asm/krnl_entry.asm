[org 0x8000]
[bits 16]
section .text
start:
jmp forpm
gdt:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_ptr:
    dw gdt_end - gdt - 1
    dd gdt

forpm:
cli
xor ax, ax
mov ds, ax

lgdt [gdt_ptr]

mov eax, cr0
or eax, 1
mov cr0, eax

jmp dword dword 0x08:pm_entry

[bits 32]
pm_entry:
mov ax, 0x10
mov es, ax
mov gs, ax
mov ds, ax
mov ss, ax
mov fs, ax
mov esp, 0x25000
mov ebp, esp

section .bss
mem_addr: resb 4