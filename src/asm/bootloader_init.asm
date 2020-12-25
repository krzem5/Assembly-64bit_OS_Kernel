[bits 16]
[org 0x7c00]
mov ax, (0x200+__BOOTLOADER_SZ__/512)
mov bx, 0x500
mov cx, 0x02
mov dh, 0x00
int 0x13
jc err
cmp al, (__BOOTLOADER_SZ__/512)
jne err
jmp 0x500
err:
	jmp $
times 510-($-$$) db 0
dw 0xaa55
