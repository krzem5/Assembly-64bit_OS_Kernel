#include <types.h>
#include <drivers/keyboard.h>
#include <idt.h>
#include <irq.h>
#include <ports.h>
#include <screen.h>



uint8_t KEYBOARD_CHAR_MAP[84]={
	0,
	'\e',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'0',
	'-',
	'=',
	'\b',
	'\t',
	'q',
	'w',
	'e',
	'r',
	't',
	'y',
	'u',
	'i',
	'o',
	'p',
	'(',
	')',
	'\n',
	0,
	'a',
	's',
	'd',
	'f',
	'g',
	'h',
	'j',
	'k',
	'l',
	';',
	'\'',
	'`',
	0,
	'\\',
	'z',
	'x',
	'c',
	'v',
	'b',
	'n',
	'm',
	',',
	'.',
	'/',
	0,
	'*',
	0,
	' ',
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	'7',
	'8',
	'9',
	'-',
	'4',
	'5',
	'6',
	'+',
	'1',
	'2',
	'3',
	'0',
	'.'
};



void _kb_h(registers_t* r){
	uint8_t k=port_in(0x60);
	if (k<84){
		print_char(KEYBOARD_CHAR_MAP[k]);
	}
	else{
		print_char('?');
	}
}



void setup_keyboard(void){
	regiser_irq_handler(0x01,_kb_h);
}
