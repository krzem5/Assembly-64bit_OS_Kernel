#include <types.h>
#include <fatal_error.h>
#include <screen.h>



void fatal_error(char* s){
	ensure_start_line();
	set_print_style(SCREEN_BG_COLOR_DARK_RED|SCREEN_FG_COLOR_WHITE);
	print(s);
	asm_halt_cpu();
}
