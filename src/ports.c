#include <types.h>
#include <ports.h>



uint8_t port_in(uint16_t p){
	uint8_t o;
	__asm__ __volatile__("inb %1, %0":"=a"(o):"dN"(p));
	return o;
}



void port_out(uint16_t p,uint8_t v){
	__asm__ __volatile__("outb %1, %0"::"dN"(p),"a"(v));
}
