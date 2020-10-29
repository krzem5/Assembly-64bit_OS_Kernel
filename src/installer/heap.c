#include <heap.h>
#include <types.h>



extern uint32_t __KERNEL_OFFSET__[];
extern uint32_t __KERNEL_END__[];
uint32_t _kheap_ptr;
uint8_t* bitmap;
uint64_t bitmap_frames_count;
data_t* _b_dt=(data_t*)0xc0007000;




uint64_t bitmap_clear(uint64_t a){
	uint64_t o=a;
	a/=0x1000;
	if (a>bitmap_frames_count){
		return 0;
	}
	*(bitmap+a/8)&=~(1<<(a%8));
	return o;
}




void* heap_alloc(uint64_t sz){
	void* o=(void*)_kheap_ptr;
	_kheap_ptr+=sz;
	return o;
}



void init_heap(void){
	_kheap_ptr=(uint32_t)__KERNEL_OFFSET__+(uint32_t)__KERNEL_END__;
	size_t t=0;
	for (uint16_t i=0;i<_b_dt->mmap_l;i++){
		t+=(_b_dt->mmap+i)->l;
	}
	bitmap_frames_count=t/4096/8*8;
	bitmap=(uint8_t*)heap_alloc(bitmap_frames_count/8);
	for (uint32_t i=0;i<bitmap_frames_count/8;i++){
		*(bitmap+i)=0;
	}
	for (uint16_t i=0;i<_b_dt->mmap_l;i++){
		uint64_t a=(_b_dt->mmap+i)->ptr;
		for (uint32_t j=(_b_dt->mmap+i)->l/4096;j>0;j--){
			bitmap_clear(a);
			a+=0x1000;
		}
	}
	uint64_t a=0;
	uint64_t sz=kernel_end+heap_size+kernel_heap_size*0x1000;
	for (uint32_t i=sz/4096;i>0;i--){
		bitmap_clear(a);
		a+=0x1000;
	}
	// bitmap_frames_count=t/4096/8*8;
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
