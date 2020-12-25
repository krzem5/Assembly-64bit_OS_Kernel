#include <heap.h>
#include <screen.h>
#include <types.h>



extern uint64_t __KERNEL_OFFSET__[];
extern uint64_t __KERNEL_END__[];
extern uint64_t __MAX_KERNEL_HEAP_SIZE__[];
uint64_t _kheap_ptr;
data_t* _b_dt=(data_t*)0xffffffffc0007000;



void init_heap(void){
	print("Initialising Heap...\r\n");
	_kheap_ptr=(uint64_t)__KERNEL_OFFSET__+(uint64_t)__KERNEL_END__;
	// size_t t=0;
	// for (uint16_t i=0;i<_b_dt->mmap_l;i++){
	// 	t+=(_b_dt->mmap+i)->l;
	// }
}



void* heap_alloc(uint64_t sz,uint8_t a){
	_kheap_ptr+=(_kheap_ptr%a!=0?a-(_kheap_ptr%a):0);
	void* o=(void*)_kheap_ptr;
	_kheap_ptr+=sz;
	if (_kheap_ptr-(uint64_t)__KERNEL_OFFSET__-(uint64_t)__KERNEL_END__>=(uint64_t)__MAX_KERNEL_HEAP_SIZE__){
		ensure_start_line();
		set_print_style(SCREEN_BG_COLOR_DARK_RED|SCREEN_FG_COLOR_WHITE);
		print("Kernel Heap Overflow!\r\n");
		for(;;);
	}
	return o;
}



void* kmalloc(size_t sz);



void* kcalloc(size_t c,size_t sz);



void* krealloc(void* p,size_t sz);



void kfree(void* p);
