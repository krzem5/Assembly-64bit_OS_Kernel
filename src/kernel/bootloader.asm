[org 0x500]
%define DATA_ACIP_ID word [DATA+0]
%define DATA_MMAP_LEN word [DATA+2]
%define DATA_MMAP_PTR (DATA+12)
%define DATA_DATE dword [DATA+4]
%define DATA_TIME dword [DATA+8]
;    0 -   500 system
;  500 -  3000 stage 2 bootloader
; 3000 -  7000 stack
; 7000 -  7c00 data
; 7c00 - 7ffff kernel
section .text
	[bits 16]
	global bootloader
	bootloader:
		BOOTLOADER_START equ $
		mov byte [boot_drv], dl
		mov bp, STACK_TOP
		mov sp, bp
		mov ah, 0x01
		mov cx, 0x1000
		int 0x10
		mov ax, 0x0600
		mov bh, VIDEO_MEM_WHITE_ON_BLACK
		mov cx, 0x00
		mov dx, 0x1950
		int 0x10
		mov ah, 0x02
		mov bh, 0x00
		mov dx, 0x00
		int 0x10
		mov byte [dsp_x], 0
		mov byte [dsp_y], 0
		mov bx, REAL_MODE_START
		call .print
		mov bx, INIT_KEYBOARD
		call .print
		in al, 0x60
		in al, 0x61
		out 0x61, al
		mov bx, CPU_CHECK
		call .print
		mov eax, 1
		cpuid
		cmp ax, 0x600
		shr ebx, 24
		mov DATA_ACIP_ID, bx
		jge ._cpu_family_ok
		mov bx, UNSUPPORTED_CPU_FAMILY
		call .print
		mov bx, ax
		call .print_int16
		mov bx, UNSUPPORTED_CPU_FAMILY2
		call .print
		jmp $
	._cpu_family_ok:
		bt edx, 6
		jc ._cpu_pae_ok
		mov bx, CPU_NO_PAE
		call .print
		jmp $
	._cpu_pae_ok:
		mov bx, ENABLE_A20
		call .print
		stc
		mov ax, 0x2401
		int 15h
		jnc ._a20_ok
		mov bx, ENABLE_A20_FAIL
		call .print
		jmp $
	._a20_ok:
		mov bx, READING_MEMORY_MAP
		call .print
		call .mem_map
		mov bx, READING_TIME
		call .print
		mov ah, 4
		xor edx, edx
		int 0x1a
		jc ._time_end
		shl ecx, 16
		add ecx, edx
		mov DATA_DATE, ecx
		mov ah, 2
		int 0x1a
		jc ._time_end
		shl ecx, 16
		add ecx, edx
		mov DATA_TIME, ecx
	._time_end:
		mov bx, LOAD_KERNEL
		call .print
		mov ax, (0x200+(__KERNEL_SZ__+511)/512)
		mov bx, 0x7c00;;; Find Memory for The Kernel (Currently Simply 0x7c00 - 0x7ffff (~481 KiB))
		mov ecx, (BOOTLOADER_END-BOOTLOADER_START+511)
		shr ecx, 9
		add cl, 2
		xor ch, ch
		mov dl, byte [boot_drv]
		xor dh, dh
		int 0x13
		jc .drv_err
		cmp al, (__KERNEL_SZ__+511)/512
		jne .drv_err
		mov bx, SWITCHING_TO_32BIT
		call .print
		jmp .switch_32bit
		.mem_map:
			xor ebx, ebx
			mov word [mmap_tmp_len], 0
			mov di, (INTERNAL_DATA_START+8)
			clc
			._mem_map_next:
				xor eax, eax
				mov ax, 0xe820
				mov ecx, 0x14
				mov edx, 0x534D4150
				int 0x15
				jc ._mem_map_end
				cmp eax, 0x534D4150
				jne ._mem_map_end
				cmp ecx, 0x14
				jne ._mem_map_error
				cmp dword [di+8], 0
				jnz ._mem_map_nxt
				cmp dword [di+12], 0
				jnz ._mem_map_nxt
			._mem_map_next_rep:
				or ebx, ebx
				jnz ._mem_map_next
			._mem_map_end:
				clc
				mov si, (INTERNAL_DATA_START+8)
				mov DATA_MMAP_LEN, 0
				xor ecx, ecx
				mov cx, word [mmap_tmp_len]
				or cx, cx
				jz ._mem_map_sort_end
			._mem_map_sort:
				push cx
				mov di, DATA_MMAP_PTR
				mov cx, DATA_MMAP_LEN
				or cx, cx
				jz ._mem_map_sort_find_add_end
			._mem_map_sort_find:
				mov ebx, dword [si+4]
				cmp ebx, dword [di+12]
				jg ._mem_map_sort_find_next
				jl ._mem_map_sort_find_insert
				mov ebx, dword [si]
				cmp ebx, dword [di+8]
				jg ._mem_map_sort_find_next
				jl ._mem_map_sort_find_insert
				mov bl, byte [si+16]
				cmp bl, byte [di+16]
				jne ._mem_map_sort_find_insert
				mov eax, dword [si+12]
				add dword [di+12], eax
				mov eax, dword [si+8]
				adc dword [di+8], eax
				jmp ._mem_map_sort_find_end
				; pusha;;;;;;;;;;;;;;;;;;
				; mov ax, 0x0e41
				; int 0x10
				; jmp $;;; Extend Current
				; popa;;;;;;;;;;;;;;;;;;
			._mem_map_sort_find_next:
				dec cx
				add di, 0x11
				or cx, cx
				jnz ._mem_map_sort_find
			._mem_map_sort_find_add_end:
				inc DATA_MMAP_LEN
				push si
				mov cx, 0x11
				rep movsb
				pop si
				; pusha;;;;;;;;;;;;;;;;;;
				; mov ax, 0x0e42
				; int 0x10
				; jmp $;;; Add at the End
				; popa;;;;;;;;;;;;;;;;;;
			._mem_map_sort_find_end:
				add si, 0x11
				pop cx
				loop ._mem_map_sort
			._mem_map_sort_end:
				mov bx, DATA_MMAP_LEN
				ret
			._mem_map_sort_find_insert:
				mov bx, si
				std
				mov ax, DATA_MMAP_LEN
				mov dx, DATA_MMAP_LEN
				shl ax, 4
				add ax, dx
				add ax, 2
				add ax, DATA
				mov si, ax
				mov di, ax
				add di, dx
				rep movsb
				mov si, bx
				inc DATA_MMAP_LEN
				cld
				mov cx, 0x11
				rep movsb
				mov si, bx
				jmp ._mem_map_sort_find_end
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; 	mov bx, MEM_MAP_HEADER
			; 	call .print
			; 	mov bx, DATA_MMAP_LEN
			; 	call .print_int16
			; 	mov bx, MEM_MAP_HEADER2
			; 	call .print
			; 	xor ecx, ecx
			; 	mov cx, DATA_MMAP_LEN
			; 	xor eax, eax
			; 	mov di, (DATA+2)
			; ._mem_map_print_len:
			; 	xor bx, bx
			; 	mov edx, dword [di+4]
			; 	or edx, edx
			; 	jc ._mem_map_print_len_if
			; 	add bx, 16
			; ._mem_map_print_len_fi:
			; ._mem_map_print_len_addr:
			; 	or edx, edx
			; 	jz ._mem_map_print_len_addr_end
			; 	shr edx, 4
			; 	inc bx
			; 	jmp ._mem_map_print_len_addr
			; ._mem_map_print_len_addr_end:
			; 	or bx, bx
			; 	jz ._mem_map_print_len_zero_if
			; ._mem_map_print_len_zero_fi:
			; 	mov edx, eax
			; 	shr edx, 16
			; 	cmp bx, dx
			; 	jg ._mem_map_print_len_if2
			; ._mem_map_print_len_fi2:
			; 	add di, 0x14
			; 	loop ._mem_map_print_len
			; 	mov cx, DATA_MMAP_LEN
			; 	mov di, (DATA+2)
			; ._mem_map_print_len_len:
			; 	xor bx, bx
			; 	mov edx, dword [di+12]
			; 	or edx, edx
			; 	jc ._mem_map_print_len_len_if
			; 	add bx, 16
			; ._mem_map_print_len_len_fi:
			; ._mem_map_print_len_len_addr:
			; 	or edx, edx
			; 	jz ._mem_map_print_len_len_addr_end
			; 	shr edx, 4
			; 	inc bx
			; 	jmp ._mem_map_print_len_len_addr
			; ._mem_map_print_len_len_addr_end:
			; 	or bx, bx
			; 	jz ._mem_map_print_len_len_zero_if
			; ._mem_map_print_len_len_zero_fi:
			; 	mov edx, eax
			; 	and edx, 0xffff
			; 	cmp bx, dx
			; 	jg ._mem_map_print_len_len_if2
			; ._mem_map_print_len_len_fi2:
			; 	add di, 0x14
			; 	loop ._mem_map_print_len_len
			; 	;;;;;;;;;;;;;;;;;;
			; 	pusha
			; 	mov ebx, eax
			; 	shr ebx, 16
			; 	call .print_int16
			; 	pusha
			; 	mov ax, 0x0e2c
			; 	int 0x10
			; 	mov ax, 0x0e20
			; 	int 0x10
			; 	popa
			; 	mov bx, ax
			; 	call .print_int16
			; 	;;;;;
			; 	pusha
			; 	mov ax, 0x0e2c
			; 	int 0x10
			; 	mov ax, 0x0e20
			; 	int 0x10
			; 	popa
			; 	mov ebx, dword [DATA+2]
			; 	call .print_hex32
			; 	pusha
			; 	mov ax, 0x0e20
			; 	int 0x10
			; 	popa
			; 	mov ebx, dword [DATA+6]
			; 	call .print_hex32
			; 	;;;;
			; 	pusha
			; 	mov ax, 0x0e0a
			; 	int 0x10
			; 	mov ax, 0x0e0d
			; 	int 0x10
			; 	popa
			; 	jmp $
			; 	popa
			; 	;;;;;;;;;;;;;;;;;;
			; 	ret
			; ._mem_map_print_len_if:
			; 	mov edx, dword [di]
			; 	jmp ._mem_map_print_len_fi
			; ._mem_map_print_len_zero_if:
			; 	inc bx
			; 	jmp ._mem_map_print_len_zero_fi
			; ._mem_map_print_len_if2:
			; 	mov dx, bx
			; 	shl edx, 16
			; 	and eax, 0xffff
			; 	add eax, edx
			; 	jmp ._mem_map_print_len_fi2
			; ._mem_map_print_len_len_if:
			; 	mov edx, dword [di+8]
			; 	jmp ._mem_map_print_len_len_fi
			; ._mem_map_print_len_len_zero_if:
			; 	inc bx
			; 	jmp ._mem_map_print_len_len_zero_fi
			; ._mem_map_print_len_len_if2:
			; 	mov dx, bx
			; 	and eax, 0xffff0000
			; 	add eax, edx
			; 	jmp ._mem_map_print_len_len_fi2
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			._mem_map_nxt:
				mov eax, dword [di+16]
				or eax, eax
				jnz ._mem_map_nxt_nor_free
				mov byte [di+16], 1
			._mem_map_nxt_add:
				add di, 0x11
				inc word [mmap_tmp_len]
				jmp ._mem_map_next_rep
			._mem_map_nxt_nor_free:
				mov byte [di+16], 0
				jmp ._mem_map_nxt_add
			._mem_map_error:
				cli
				hlt
				jmp ._mem_map_error
		.drv_err:
			mov bx, DRIVE_ERROR
			call .print
			xor bh, bh
			mov bl, ah
			call .print_int16
			mov bx, DRIVE_ERROR2
			call .print
			jmp $
		.print:
			pusha
			mov ah, 0x0e
			._print_chr:
				mov al, [bx]
				cmp al, 0
				je ._print_end
				int 0x10
				add bx, 1
				cmp al, 0x0a
				je ._print_nl
				cmp al, 0x0d
				je ._print_cr
				inc byte [dsp_x]
				cmp byte [dsp_x], VIDEO_MEM_COLS
				je ._print_nlcr
				jmp ._print_chr
			._print_nlcr:
				mov byte [dsp_x], 0
				inc byte [dsp_y]
				jmp ._print_chr
			._print_nl:
				cmp byte [dsp_y], VIDEO_MEM_MAX_ROWS
				je ._print_chr
				inc byte [dsp_y]
				jmp ._print_chr
			._print_cr:
				mov byte [dsp_x], 0
				jmp ._print_chr
			._print_end:
				popa
				ret
		.print_int16:
			pusha
			mov ax, bx
			mov bx, 10
			xor cx, cx
			._print_int16_cnt_loop:
				mov dx, 0
				div bx
				push dx
				inc cx
				cmp ax, 0
				jne ._print_int16_cnt_loop
			mov ah, 0x0e
			._print_int16_chr:
				pop dx
				mov al, dl
				add al, 48
				int 0x10
				inc byte [dsp_x]
				cmp byte [dsp_x], VIDEO_MEM_COLS
				je ._print_int16_nlcr
			._print_int16_chr_fi:
				loop ._print_int16_chr
				popa
				ret
			._print_int16_nlcr:
				mov byte [dsp_x], 0
				inc byte [dsp_y]
				jmp ._print_int16_chr_fi
		.print_hex32:
			pusha
			mov cx, 4
			mov ah, 0x0e
			._print_hex32_cnt_loop:
				mov al, bl
				and al, 0x0f
				push ax
				mov al, bl
				shr al, 4
				push ax
				shr ebx, 8
				loop ._print_hex32_cnt_loop
			mov cx, 8
			._print_hex32_chr:
				pop ax
				cmp al, 0x0a
				jge ._print_hex32_chr_l
			._print_hex32_chr_fi:
				add al, 0x30
				int 0x10
				loop ._print_hex32_chr
				popa
				ret
			._print_hex32_chr_l:
				add al, 0x31
				jmp ._print_hex32_chr_fi
		.switch_32bit:
			cli
			lgdt [.gdt_descriptor]
			mov eax, cr0
			or eax, 0x1
			mov cr0, eax
			jmp (.gdt_code-.gdt_start):.start_kernel
		bits 32
		.start_kernel:
			mov ax, (.gdt_data-.gdt_start)
			mov ds, ax
			mov ss, ax
			mov es, ax
			mov fs, ax
			mov gs, ax
			mov ebp, STACK_TOP
			mov esp, ebp
			xor edx, edx
			mov dl, byte [dsp_y]
			shl edx, 5
			xor eax, eax
			mov al, byte [dsp_x]
			add eax, edx
			shl edx, 2
			add edx, eax
			add edx, VIDEO_MEM_PTR
			mov dword [dsp_ptr], edx
			mov ebx, PROTECTED_MODE_START
			call .print32
			mov ebx, START_KERNEL
			call .print32
			call 0x7c00
			jmp $
		.print32:
			pusha
			mov edx, dword [dsp_ptr]
			._print32_chr:
				mov al, [ebx]
				mov ah, VIDEO_MEM_WHITE_ON_BLACK
				cmp al, 0
				je ._print32_end
				cmp al, 0x0a
				je ._print32_nl
				cmp al, 0x0d
				je ._print32_cr
				mov [edx], ax
				inc ebx
				add edx, 2
				inc byte [dsp_x]
				cmp byte [dsp_x], VIDEO_MEM_COLS
				je ._print32_nlcr
				jmp ._print32_chr
			._print32_nlcr:
				mov byte [dsp_x], 0
				inc byte [dsp_y]
				jmp ._print32_schk
			._print32_nl:
				inc ebx
				add edx, VIDEO_MEM_COLS
				add edx, VIDEO_MEM_COLS
				cmp byte [dsp_y], VIDEO_MEM_MAX_ROWS
				je ._print32_schk
				inc byte [dsp_y]
				jmp ._print32_chr
			._print32_cr:
				inc ebx
				mov byte [dsp_x], 0
				xor edx, edx
				mov dl, byte [dsp_y]
				shl edx, 5
				mov eax, edx
				shl edx, 2
				add edx, eax
				add edx, VIDEO_MEM_PTR
				jmp ._print32_chr
			._print32_schk:
				mov esi, VIDEO_MEM_PTR+160
				mov edi, VIDEO_MEM_PTR
				mov ecx, 960
				rep movsd
				jmp ._print32_chr
			._print32_end:
				mov dword [dsp_ptr], edx
				popa
				ret
		.gdt_start:
			dq 0x0000000000000000
		.gdt_code:
			dw 0xffff
			dw 0x0000
			db 0x00
			db 0x9a
			db 0xcf
			db 0x00
		.gdt_data:
			dw 0xffff
			dw 0x0000
			db 0x00
			db 0x92
			db 0xcf
			db 0x00
		.gdt_end:
		.gdt_descriptor:
			dw .gdt_end-.gdt_start
			dd .gdt_start
section .data
	boot_drv: db 0
	mmap_tmp_len: dw 0
	dsp_x: db 0
	dsp_y: db 0
	dsp_ptr: dw 0
section .rdata
	VIDEO_MEM_PTR equ 0xb8000
	VIDEO_MEM_MAX_ROWS equ 24
	VIDEO_MEM_COLS equ 80
	VIDEO_MEM_WHITE_ON_BLACK equ 0x0f
	REAL_MODE_START: db "Starting Bootloader...",10,13,0
	INIT_KEYBOARD: db "Initialising Keyboard...",10,13,0
	CPU_CHECK: db "Checking CPU...",10,13,0
	UNSUPPORTED_CPU_FAMILY: db "Unsupported CPU Family: ",0
	UNSUPPORTED_CPU_FAMILY2: db 10,13,0
	CPU_NO_PAE: db "CPU doesn't support PAE",10,13,0
	ENABLE_A20: db "Enabling A20...",10,13,0
	ENABLE_A20_FAIL: db "Failed to Enable A20",10,13,0
	READING_MEMORY_MAP: db "Reading Memory Layout...",10,13,0
	MEM_MAP_HEADER: db "Memory Map (",0
	MEM_MAP_HEADER2: db " chunks):",10,13,0
	READING_TIME: db "Reading Time Data...",10,13,0
	LOAD_KERNEL: db "Loading Kernel...",10,13,0
	DRIVE_ERROR: db "Drive Error: ",0
	DRIVE_ERROR2: db 10,13,0
	SWITCHING_TO_32BIT: db "Switching to 32-bit Protected Mode...",10,13,0
	PROTECTED_MODE_START: db "Starting Bootloader in 32-bit Protected Mode...",10,13,0
	START_KERNEL: db "Starting Kernel...",10,13,0
	INTERNAL_DATA_START equ 0x3000
	STACK_BOTTOM equ 0x3000
	STACK_TOP equ 0x7000
	DATA equ 0x7000
	BOOTLOADER_END equ $
