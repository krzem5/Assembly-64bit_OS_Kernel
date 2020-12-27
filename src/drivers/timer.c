#include <types.h>
#include <drivers/timer.h>
#include <idt.h>
#include <irq.h>
#include <ports.h>
#include <fatal_error.h>



uint64_t _tc=0;



void _tm_h(registers_t* r){
	if (_tc+1<_tc){
		fatal_error("CPU Tick Overflow!");
	}
	_tc++;
}



void setup_timer(void){
	uint64_t d=1193180/TIMER_FREQUENCY;
	port_out(0x43,0x36);
	port_out(0x40,(uint8_t)(d&0xff));
	port_out(0x40,(uint8_t)(d>>8));
	regiser_irq_handler(0x00,_tm_h);
}



uint64_t get_milliseconds(void){
	return _tc/(TIMER_FREQUENCY/1000);
}



uint64_t get_seconds(void){
	return _tc/TIMER_FREQUENCY;
}



uint64_t get_frequency(void){
	return TIMER_FREQUENCY;
}
