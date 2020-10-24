#include <types.h>
#include <screen.h>
#include <heap.h>
#include <pci.h>



const data_t* bootloader_data=(data_t*)0xc0007000;



void imain(void){
	*((char*)0xc00b8000)='X';
	init_heap();
	clear_screen();
	print("Mmap Data:");
	size_t tm=0;
	for (uint16_t i=0;i<bootloader_data->mmap_l;i++){
		print("\r\n  From: ");
		print_laddr((bootloader_data->mmap+i)->ptr);
		print(", To: ");
		print_laddr((bootloader_data->mmap+i)->ptr+(bootloader_data->mmap+i)->l);
		tm+=(bootloader_data->mmap+i)->l;
	}
	print("\r\nTotal: ");
	print_uint64(tm);
	print(" bytes\r\nPCI Ports: ");
}
