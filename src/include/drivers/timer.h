#ifndef __DRIVER_TIMER_H__
#define __DRIVER_TIMER_H__
#define TIMER_FREQUENCY 10000



void setup_timer(void);



uint64_t get_milliseconds(void);



uint64_t get_seconds(void);



uint64_t get_frequency(void);



#endif
