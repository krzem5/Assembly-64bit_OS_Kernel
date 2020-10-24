#ifndef __INSTALLER_SCREEN_H__
#define __INSTALLER_SCREEN_H__
#include <types.h>



#define SCREEN_MEM_ADDR ((char*)0xc00b8000)
#define SCREEN_MAX_ROWS 25
#define SCREEN_MAX_COLS 80



#define print_uint64(v) \
	do { \
		if ((((uint64_t)v)>>32)!=0){ \
			print_uint32(((uint64_t)v)>>32); \
		} \
		print_uint32((uint32_t)((uint64_t)v)&0xffffffff); \
	} while (0)



void print_char(char c);



void print(char* s);



void print_addr(uint32_t a);



void print_laddr(uint64_t a);



void print_uint16(uint16_t v);



void print_uint32(uint32_t v);



void print_hex8(uint8_t v);



void clear_screen(void);



#endif
