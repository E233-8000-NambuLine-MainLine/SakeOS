[org 0x1000]
[bits 16]
section .bss
readpos: resb 2
mem_pos: resb 4
readsectors: resb 1
a20_failed_cnt: resb 1

section .text
start:
cli
;既にここからA20のチェック
xor cx, cx

check_a20:
mov ax, 0
mov ds, ax
mov byte [0x0000], 0x12

mov ax, 0xFFFF
mov ds, ax
mov byte [0x0010], 0x34

; A20 が ON なら 0x0000 != 0x100000
; A20 が OFF なら 0x0000 == 0x100000
cmp eax, ebx
jne a20_check_ok
je a20_disabled

a20_disabled:
cmp byte [a20_failed_cnt], 0
je fast_a20
cmp byte [a20_failed_cnt], 1
je kbc_a20
cmp byte [a20_failed_cnt], 2
je bios_a20
cmp byte [a20_failed_cnt], 3
je a20_mendosugiru

fast_a20:
in al, 0x92
or al, 0b00000010
out 0x92, al
inc byte [a20_failed_cnt]
jmp check_a20

kbc_a20:
; 8042 の入力バッファが空くのを待つ
empty_8042:
    in al, 0x64
    test al, 0x02        ; bit1 = 1 → まだ書き込み中
    jnz empty_8042
    ret

; A20 を 8042 で ON にする
enable_a20_8042:
    call empty_8042
    mov al, 0xD1
    out 0x64, al

    call empty_8042
    mov al, 0xDF        ; A20=1 にしたい値（bit1=1）
    out 0x60, al

    ret
inc byte [a20_failed_cnt]
jmp check_a20

bios_a20:
sti
mov ax, 0x2401
int 0x15
cli
inc byte [a20_failed_cnt]
jmp check_a20

a20_mendosugiru:
cli
hlt
jmp $

a20_check_ok:
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx
xor di, di
xor si, si

mov word [readpos], 0x0003
mov word [mem_pos], 0x7E00
mov byte [readsectors], 0x01

call read_loop_ATA_PIO

jmp 0x0000:0x7E00

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
jnz read_loop_ATA_PIO

ret