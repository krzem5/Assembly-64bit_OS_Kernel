section .entry
	bits 32
	extern _kmain
	global _start
	_start:
		call _kmain
		cli
		._s_loop:
			hlt
			jmp ._s_loop
