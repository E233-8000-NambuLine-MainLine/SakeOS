[org 0x7E00]
[bits 16]
section .bss
readpos: resb 2
readsectors: resb 1
mem_pos: resb 2

section .text
start:
mov word [readpos], 0x0005
mov word [mem_pos], 0x8000
mov byte [readsectors], 0x01

call read_loop_ATA_PIO

jmp 0x0000:0x8000

cli
hlt
jmp $

read_loop_ATA_PIO:
mov dx, 0x1F2
mov al, 0x01
out dx, al

mov dx, 0x1F3
mov ax, [readpos]
out dx, al

mov dx, 0x1F4
mov al, ah
out dx, al

mov dx, 0x1F5
xor ax, ax
out dx, al

mov dx, 0x1F6
xor ax, ax
or al, 0xE0
out dx, al

mov dx, 0x1F7
mov al, 0x20
out dx, al

mov dx, 0x1F7

.wait:
in al, dx
test al, 0x80
jnz .wait
test al, 0x08
jz .wait

mov cx, 256
mov di, [mem_pos]

mov dx, 0x1F0

rep insw

inc word [readpos]
add word [mem_pos], 512
dec byte [readsectors]
jnz .wait

ret