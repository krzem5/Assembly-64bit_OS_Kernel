[org 0x500]
%define DATA_VERTICAL_SROLL byte [DATA]
%define DATA_ACIP_ID word [DATA+1]
%define DATA_MMAP_LEN word [DATA+3]
%define DATA_DATE dword [DATA+5]
%define DATA_TIME dword [DATA+9]
%define DATA_MMAP_PTR (DATA+12)
%define KERNEL_MEM_ADDR 0x100000
section .text
	bits 16
	align 4
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
		mov DATA_VERTICAL_SROLL, 0
		mov bx, REAL_MODE_START
		call ._print
		mov bx, INIT_KEYBOARD
		call ._print
		in al, 0x60
		in al, 0x61
		out 0x61, al
		mov bx, CPU_CHECK
		call ._print
		mov eax, 1
		cpuid
		cmp ax, 0x600
		shr ebx, 24
		mov DATA_ACIP_ID, bx
		jge ._cpu_family_ok
		mov bx, UNSUPPORTED_CPU_FAMILY
		call ._print
		mov bx, ax
		call ._print_int16
		mov bx, UNSUPPORTED_CPU_FAMILY2
		call ._print
		jmp $
	._cpu_family_ok:
		bt edx, 6
		jc ._cpu_pae_ok
		mov bx, CPU_NO_PAE
		call ._print
		jmp $
	._cpu_pae_ok:
		mov bx, ENABLE_A20
		call ._print
		stc
		mov ax, 0x2401
		int 15h
		jnc ._a20_ok
		mov bx, ENABLE_A20_FAIL
		call ._print
		jmp $
	._a20_ok:
		mov bx, CHECK_CPUID_EXTENDED
		call ._print
		mov eax, 0x80000000
		cpuid
		cmp eax, 0x80000001
		jnb ._check_long_mode
		mov bx, EXTENDED_CPUID_NOT_AVAIBLE
		call ._print
		jmp $
	._check_long_mode:
		mov bx, CHECK_LONG_MODE
		call ._print
		mov eax, 0x80000001
		cpuid
		test edx, 0x20000000
		jnz ._read_mem_map
		mov bx, LONG_MODE_NOT_SUPPORTED
		call ._print
		jmp $
	._read_mem_map:
		mov bx, READING_MEMORY_MAP
		call ._print
		xor ebx, ebx
		mov DATA_MMAP_LEN, 0
		mov di, DATA_MMAP_PTR
		clc
	._mem_map_next:
		mov eax, 0xe820
		mov ecx, 0x18
		mov edx, 0x534d4150
		int 0x15
		jc ._mem_map_end
		cmp eax, 0x534d4150
		jne ._mem_map_end
		cmp ecx, 0x14
		jne ._mem_map_err
		cmp dword [di+8], 0
		jnz ._mem_map_nxt
		cmp dword [di+12], 0
		jnz ._mem_map_nxt
	._mem_map_next_rep:
		or ebx, ebx
		jnz ._mem_map_next
	._mem_map_end:
		mov bx, READING_TIME
		call ._print
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
		mov bx, PCI_SUPPORT_CHECK
		call ._print
		xor eax, eax
		mov ax, 0xb101
		xor edi, edi
		int 0x1a
		jc ._pci_err
		xor ah, ah
		jnz ._pci_err
		cmp edx, 0x20494350
		jne ._pci_err
		bt ax, 0
		jc ._pci_ok
		mov bx, PCI_NOT_SUPPORTED
		call ._print
		jmp $
	._pci_ok:
		mov bx, LOAD_KERNEL
		call ._print
		mov eax, (0x200+(__KERNEL_SZ__+511)/512)
		mov ebx, 0x7c00
		mov ecx, (BOOTLOADER_END-BOOTLOADER_START+511)
		shr ecx, 9
		add cl, 2
		xor ch, ch
		mov dl, byte [boot_drv]
		xor dh, dh
		int 0x13
		jc ._drv_err
		cmp al, (__KERNEL_SZ__+511)/512
		jne ._drv_err
		mov bx, SWITCHING_TO_32BIT
		call ._print
		cli
		lgdt [gdt_descriptor]
		mov eax, cr0
		or eax, 0x1
		mov cr0, eax
		jmp (gdt_code-gdt_start):_start32
	._mem_map_nxt:
		cmp dword [di+16], 1
		je ._mem_map_nxt_ok
		cmp dword [di+16], 3
		jne ._mem_map_next_rep
	._mem_map_nxt_ok:
		add di, 0x10
		inc DATA_MMAP_LEN
		jmp ._mem_map_next_rep
	._mem_map_err:
		cli
		hlt
		jmp ._mem_map_err
	._drv_err:
		mov bx, DRIVE_ERROR
		call ._print
		xor bh, bh
		mov bl, ah
		call ._print_int16
		mov bx, DRIVE_ERROR2
		call ._print
		jmp $
	._pci_err:
		mov bx, PCI_ERROR
		call ._print
		jmp $
	._print:
		pusha
		mov ah, 0x0e
	._print_chr:
		mov al, byte [bx]
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
		inc DATA_VERTICAL_SROLL
		jmp ._print_chr
	._print_nl:
		cmp DATA_VERTICAL_SROLL, VIDEO_MEM_MAX_ROWS
		je ._print_chr
		inc DATA_VERTICAL_SROLL
		jmp ._print_chr
	._print_cr:
		mov byte [dsp_x], 0
		jmp ._print_chr
	._print_end:
		popa
		ret
	._print_int16:
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
		inc DATA_VERTICAL_SROLL
		jmp ._print_int16_chr_fi
	._print_hex32:
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
	bits 32
	_start32:
		mov ax, (gdt_data-gdt_start)
		mov ds, ax
		mov ss, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ebp, STACK_TOP
		mov esp, ebp
		xor edx, edx
		mov dl, DATA_VERTICAL_SROLL
		shl edx, 5
		xor eax, eax
		mov al, byte [dsp_x]
		add eax, edx
		shl edx, 2
		add edx, eax
		add edx, VIDEO_MEM_PTR
		mov dword [dsp_ptr], edx
		mov ebx, PROTECTED_MODE_START
		call ._print32
		mov ebx, REALLOC_KERNEL
		call ._print32
		mov esi, 0x7c00
		mov edi, KERNEL_MEM_ADDR
		mov ecx, ((__KERNEL_SZ__+3)/4)
		rep movsd
		mov ebx, PAGING_SETUP
		call ._print32
		mov edi, 0x1000
		mov cr3, edi
		xor eax, eax
		mov ecx, 0xc00
		rep stosd
		mov ebx, PAGING_MAP
		call ._print32
		mov dword [0x1000], 0x00002003
		mov dword [0x1ff8], 0x00003003
		mov dword [0x2000], 0x00000083
		mov dword [0x3ff8], 0x00000083
		mov eax, cr4
		or eax, 0x20
		mov cr4, eax
		mov eax, 0x7
		xor ecx, ecx
		cpuid
		test ecx, 0x10000
		jz ._setup_long_mode
		mov ebx, LEVEL_5_PAGING_AVAIBLE
		call ._print32
		jmp $
	._setup_long_mode:
		mov ebx, SETUP_LONG_MODE_START_KERNEL
		call ._print32
		mov ecx, 0xc0000080
		rdmsr
		or eax, 0x100
		wrmsr
		mov eax, cr0
		or eax, 0x80000001
		mov cr0, eax
		lgdt [gdt64_pointer]
		jmp gdt64_code:_start_64
	._print32:
		pusha
		mov edx, dword [dsp_ptr]
	._print32_chr:
		mov al, byte [ebx]
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
		inc DATA_VERTICAL_SROLL
		jmp ._print32_schk
	._print32_nl:
		inc ebx
		add edx, VIDEO_MEM_COLS
		add edx, VIDEO_MEM_COLS
		cmp DATA_VERTICAL_SROLL, VIDEO_MEM_MAX_ROWS
		je ._print32_schk
		inc DATA_VERTICAL_SROLL
		jmp ._print32_chr
	._print32_cr:
		inc ebx
		mov byte [dsp_x], 0
		xor edx, edx
		mov dl, DATA_VERTICAL_SROLL
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
	bits 64
	_start_64:
		cli
		mov ax, gdt64_data
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ss, ax
		jmp KERNEL_MEM_ADDR
	; ._print64:
	; 	push ax
	; 	push rbx
	; 	push rcx
	; 	push rdx
	; 	push rsi
	; 	push rdi
	; 	mov edx, dword [dsp_ptr]
	; ._print64_chr:
	; 	mov al, [rbx]
	; 	mov ah, VIDEO_MEM_WHITE_ON_BLACK
	; 	cmp al, 0
	; 	je ._print64_end
	; 	cmp al, 0x0a
	; 	je ._print64_nl
	; 	cmp al, 0x0d
	; 	je ._print64_cr
	; 	mov [edx], ax
	; 	inc rbx
	; 	add edx, 2
	; 	inc byte [dsp_x]
	; 	cmp byte [dsp_x], VIDEO_MEM_COLS
	; 	je ._print64_nlcr
	; 	jmp ._print64_chr
	; ._print64_nlcr:
	; 	mov byte [dsp_x], 0
	; 	inc DATA_VERTICAL_SROLL
	; 	jmp ._print64_schk
	; ._print64_nl:
	; 	inc rbx
	; 	add edx, VIDEO_MEM_COLS
	; 	add edx, VIDEO_MEM_COLS
	; 	cmp DATA_VERTICAL_SROLL, VIDEO_MEM_MAX_ROWS
	; 	je ._print64_schk
	; 	inc DATA_VERTICAL_SROLL
	; 	jmp ._print64_chr
	; ._print64_cr:
	; 	inc rbx
	; 	mov byte [dsp_x], 0
	; 	xor edx, edx
	; 	mov dl, DATA_VERTICAL_SROLL
	; 	shl edx, 5
	; 	mov eax, edx
	; 	shl edx, 2
	; 	add edx, eax
	; 	add edx, VIDEO_MEM_PTR
	; 	jmp ._print64_chr
	; ._print64_schk:
	; 	mov esi, VIDEO_MEM_PTR+160
	; 	mov edi, VIDEO_MEM_PTR
	; 	mov ecx, 480
	; 	rep movsq
	; 	jmp ._print64_chr
	; ._print64_end:
	; 	mov dword [dsp_ptr], edx
	; 	pop rdi
	; 	pop rsi
	; 	pop rdx
	; 	pop rcx
	; 	pop rbx
	; 	pop ax
	; 	ret
section .data
	boot_drv: db 0x00
	mmap_tmp_len: dw 0x0000
	dsp_x: db 0x00
	dsp_ptr: dw 0x0000
	vesa:
	.sig: dd 0x00000000
	.ver: dw 0x0000
	.ptr0: dw 0x0000
	.ptr1: dw 0x0000
	.cap0: db 0x00
	.cap1: db 0x00
	.vm0: dw 0x0000
	.vm1: dw 0x0000
	.mem: dw 0x0000
	vesa_mode:
	.attr: dw 0x0000
	.winA: db 0x00
	.winB: db 0x00
	.gr: dw 0x0000
	.wsz: dw 0x0000
	.segA: dw 0x0000
	.segB: dw 0x0000
	.fptr: dd 0x00000000
	.pt: dw 0x0000
	.xres: dw 0x0000
	.yres: dw 0x0000
	.xcsz: db 0x00
	.ycsz: db 0x00
	.pn: db 0x00
	.bpp: db 0x00
	.bn: db 0x00
	.mm: db 0x00
	.bsz: db 0x00
	.ipn: db 0x00
		db 0x00
	.rmsz: db 0x00
	.ro: db 0x00
	.gmsz: db 0x00
	.go: db 0x00
	.bmsz: db 0x00
	.bo: db 0x00
	.rsvmsz: db 0x00
	.rsvo: db 0x00
	.dca: db 0x00
	.pb: dd 0x00000000
		dd 0x00000000
		dw 0x0000
	vesa_m: dd 0x0000
	gdt_start: dq 0x0000000000000000
	gdt_code: dq 0x00cf9a000000ffff
	gdt_data: dq 0x00cf92000000ffff
	gdt_descriptor:
		dw $-gdt_start-1
		dd gdt_start
	gdt64_start:
		dq 0x000100000000ffff
	gdt64_code: equ $-gdt64_start
		dq 0x00af9a0000000000
	gdt64_data: equ $-gdt64_start
		dq 0x0000920000000000
	gdt64_pointer:
		dw $-gdt64_start-1
		dq gdt64_start
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
	CHECK_CPUID_EXTENDED: db "Checking Extended CPUID Functions...",10,13,0
	EXTENDED_CPUID_NOT_AVAIBLE: db "Extended CPUID Functions Not Supported",10,13,0
	CHECK_LONG_MODE: db "Checking Long Mode Support...",10,13,0
	LONG_MODE_NOT_SUPPORTED: db "Long Mode not Supported",10,13,0
	READING_MEMORY_MAP: db "Reading Memory Layout...",10,13,0
	READING_TIME: db "Reading Time Data...",10,13,0
	PCI_SUPPORT_CHECK: db "Checking PCI Support...",10,13,0
	PCI_NOT_SUPPORTED: db "PCI Not Suported",10,13,0
	PCI_ERROR: db "Error Checking PCI",10,13,0
	LOAD_KERNEL: db "Loading Kernel...",10,13,0
	DRIVE_ERROR: db "Drive Error: ",0
	DRIVE_ERROR2: db 10,13,0
	SWITCHING_TO_32BIT: db "Switching to 32-bit Protected Mode...",10,13,0
	PROTECTED_MODE_START: db "Starting Bootloader in 32-bit Protected Mode...",10,13,0
	REALLOC_KERNEL: db "Reallocating Kernel to 1MB...",10,13,0
	PAGING_SETUP: db "Setting Up Paging...",10,13,0
	PAGING_MAP: db "Mapping Address Range 0 - 3fffffff to ffffffffc0000000 - ffffffffffffffff...",10,13,0
	LEVEL_5_PAGING_AVAIBLE: db "Level 5 Paging is Avaible!",10,13,0
	SETUP_LONG_MODE_START_KERNEL: db "Setting Up Long Mode and Starting Kernel...",10,13,0
	VESA_TMP_MEM equ 0x1000
	STACK_BOTTOM equ 0x4000
	STACK_TOP equ 0x7000
	DATA equ 0x7000
	BOOTLOADER_END equ $
