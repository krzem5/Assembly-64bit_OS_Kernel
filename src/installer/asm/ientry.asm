%define KERNEL_VIRTUAL_BASE 0xc0000000
%define KERNEL_PAGE_NUMBER (KERNEL_VIRTUAL_BASE>>22)
%define STACKSIZE 0x4000
section .entry
	align 4
	bits 32
	global _start_e
	extern _imain
	_start_e equ (_start-KERNEL_VIRTUAL_BASE)
	_start:
		mov eax, cr4
		or eax, 0x10 ; |0x20 (PAE)
		mov cr4, eax
		mov ecx, (boot_page-KERNEL_VIRTUAL_BASE)
		mov cr3, ecx
		mov eax, cr0
		bts eax, 31
		mov cr0, eax
		lea eax, [_start_high]
		jmp eax
	_start_high:
		mov dword [boot_page], 0
		invlpg [0]
		mov ebp, (stack+STACKSIZE)
		mov esp, ebp
		call _imain
		cli
		._s_loop:
			hlt
			jmp ._s_loop
			section .data_pg
section .pg_data
	align 0x1000
	boot_page:
		dd 0x00000083
		times (KERNEL_PAGE_NUMBER-1) dd 0x00000000
		dd 0x00000083
		times (1024-KERNEL_PAGE_NUMBER-1) dd 0x00000000
section .bss
	align 32
	stack:
		resb STACKSIZE
