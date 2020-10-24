#ifndef __INSTALLER_MEMORY_H__
#define __INSTALLER_MEMORY_H__
#include <types.h>



uint64_t* upd;
uint64_t* kpd;
uint64_t* PML4;
uint8_t* kernel_heap_ptr;
extern uint64_t total_mem;
extern uint64_t total_usable_mem;
extern uint32_t kernel_size;
extern uint32_t heap_addr;
extern uint32_t heap_size;
extern uint32_t kernel_heap_size;
extern uint32_t vma;
uint64_t kernel_end;



void init_heap(void);



void* kmalloc(size_t sz);



void kfree(void* p);



#endif
