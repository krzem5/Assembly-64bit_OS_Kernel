%define STACKSIZE 0x4000
section .entry
	bits 64
	global _start_e
	extern imain
	_start_e equ (_start)
	_start:
		mov rbp, (stack+STACKSIZE)
		mov rsp, rbp
		call imain
		cli
		._s_loop:
			hlt
			jmp ._s_loop
section .bss
	align 32
	stack:
		resb STACKSIZE
