#include <types.h>
#include <drivers/timer.h>
#include <idt.h>
#include <irq.h>
#include <ports.h>
#include <screen.h>



void _tm_h(registers_t* r){
	print("A\r\n");
}



void setup_timer(void){
	uint64_t d=1193180/TIMER_FREQUENCY;
	port_out(0x43,0x36);
	port_out(0x40,(uint8_t)(d&0xff));
	port_out(0x40,(uint8_t)(d>>8));
	regiser_irq_handler(0x00,_tm_h);
}
