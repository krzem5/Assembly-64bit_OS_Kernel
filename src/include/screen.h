#ifndef __SCREEN_H__
#define __SCREEN_H__
#include <types.h>



#define SCREEN_MEM_ADDR ((char*)0xffffffffc00b8000)
#define SCREEN_MAX_ROWS 25
#define SCREEN_MAX_COLS 80
#define SCREEN_BG_COLOR_BLACK 0x00
#define SCREEN_BG_COLOR_DARK_BLUE 0x10
#define SCREEN_BG_COLOR_DARK_GREEN 0x20
#define SCREEN_BG_COLOR_DARK_CYAN 0x30
#define SCREEN_BG_COLOR_DARK_RED 0x40
#define SCREEN_BG_COLOR_DARK_PURPLE 0x50
#define SCREEN_BG_COLOR_DARK_YELLOW 0x60
#define SCREEN_BG_COLOR_GRAY 0x70
#define SCREEN_BG_COLOR_DARK_GRAY 0x80
#define SCREEN_BG_COLOR_BLUE 0x90
#define SCREEN_BG_COLOR_GREEN 0xa0
#define SCREEN_BG_COLOR_CYAN 0xb0
#define SCREEN_BG_COLOR_RED 0xc0
#define SCREEN_BG_COLOR_PURPLE 0xd0
#define SCREEN_BG_COLOR_YELLOW 0xe0
#define SCREEN_BG_COLOR_WHITE 0xf0
#define SCREEN_FG_COLOR_BLACK 0x00
#define SCREEN_FG_COLOR_DARK_BLUE 0x01
#define SCREEN_FG_COLOR_DARK_GREEN 0x02
#define SCREEN_FG_COLOR_DARK_CYAN 0x03
#define SCREEN_FG_COLOR_DARK_RED 0x04
#define SCREEN_FG_COLOR_DARK_PURPLE 0x05
#define SCREEN_FG_COLOR_DARK_YELLOW 0x06
#define SCREEN_FG_COLOR_GRAY 0x07
#define SCREEN_FG_COLOR_DARK_GRAY 0x08
#define SCREEN_FG_COLOR_BLUE 0x09
#define SCREEN_FG_COLOR_GREEN 0x0a
#define SCREEN_FG_COLOR_CYAN 0x0b
#define SCREEN_FG_COLOR_RED 0x0c
#define SCREEN_FG_COLOR_PURPLE 0x0d
#define SCREEN_FG_COLOR_YELLOW 0x0e
#define SCREEN_FG_COLOR_WHITE 0x0f



void init_screen(uint8_t vs);



void print_char(char c);



void print(char* s);



void print_addr(uint32_t a);



void print_laddr(uint64_t a);



void print_uint16(uint16_t v);



void print_uint32(uint32_t v);



void print_uint64(uint64_t v);



void print_hex8(uint8_t v);



void set_print_style(uint8_t s);



void clear_screen(void);



void ensure_start_line(void);



#endif
