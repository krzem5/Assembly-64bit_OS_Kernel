section .boot
[bits 16]
[org 0x7c00]
BOOT_DRIVE db 0
boot16:
	mov [BOOT_DRIVE], dl
	mov bp, 0x9000
	mov sp, bp
	mov bx, 0x1000
	mov dh, 2
	mov dl, [BOOT_DRIVE]
	pusha
	push dx
	mov ah, 0x02
	mov al, dh
	mov cl, 0x02
	mov ch, 0
	mov dh, 0
	int 0x13
	jc err
	pop dx
	cmp al, dh
	jne err
	popa
	cli
	lgdt [gdt_pointer]
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax
	jmp (gdt_code-gdt_start):boot32
err:
	jmp $
gdt_start:
	dq 0x00
gdt_code:
	dw 0xffff
	dw 0x00
	db 0x00
	db 0x9a
	db 0xcf
	db 0x00
gdt_data:
	dw 0xffff
	dw 0x00
	db 0x00
	db 0x92
	db 0xcf
	db 0x00
gdt_end:
gdt_pointer:
	dw gdt_end-gdt_start
	dd gdt_start
disk:
	db 0x00
[bits 32]
boot32:
	mov ax, (gdt_data-gdt_start)
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000
	mov esp, ebp
	call 0x1000
	jmp $
times 510-($-$$) db 0
dw 0xaa55
global boot16
