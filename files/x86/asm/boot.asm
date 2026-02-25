[org 0x7C00]
[bits 16]
section .bss
readpos: resb 2
mem_pos: resb 2
readsectors: resb 1

section .text
start:
mov word [mem_pos], 0x1000
mov word [readpos], 0001
mov byte [readsectors], 01
call read_loop_ATA_PIO
xor ax, ax
mov es, ax
mov di, 0x1000
jmp 0x0000:0x1000
mov ax, 0xEEEE
cli
hlt

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

push ax
xor ax, ax
mov es, ax
pop ax

mov cx, 256
mov di, [mem_pos]
mov dx, 0x1F0
xor ax, ax
mov es, ax
rep insw

add di, 512
mov word [mem_pos], di
inc word [readpos]
dec byte [readsectors]
jnz read_loop_ATA_PIO

ret
times 510-($-$$) db 0
dw 0xAA55
