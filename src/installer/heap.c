#include <heap.h>
#include <types.h>



extern uint64_t __KERNEL_OFFSET__;
extern uint64_t __KERNEL_END__;
uint8_t* _kheap_ptr;
uint8_t* bitmap;
uint64_t bitmap_frames_count;
data_t* _b_dt=(data_t*)0xc0007000;
// uint32_t page_directory[1024] __attribute__((aligned(4096)));
// uint32_t first_page_table[1024] __attribute__((aligned(4096)));




void* heap_alloc(uint32_t sz){
	void* o=_kheap_ptr;
	_kheap_ptr+=sz;
	return o;
}



void init_heap(void){
	_kheap_ptr=(uint8_t*)(uint32_t)(__KERNEL_OFFSET__+__KERNEL_END__);
	size_t t=0;
	for (uint16_t i=0;i<_b_dt->mmap_l;i++){
		t+=(_b_dt->mmap+i)->l;
	}
	// bitmap_frames_count = t/4096/8*8;
	// bitmap=(uint8_t*)heap_alloc(bitmap_frames_count/8);
	// for (size_t i=0;i<bitmap_frames_count/8;i++){
	// 	*(bitmap+i)=0;
	// }
	// memset(bitmap,0,bitmap_frames_count/8);
	// for (uint16_t i=0;i<1024;i++){
	// 	*(page_directory+i)=0x00000002;
	// 	*(first_page_table+i)=(i*0x1000)|0x3;
	// }
	// *page_directory=((uint32_t)first_page_table)|0x3;
}



void* kmalloc(size_t sz);



void kfree(void* p);
