#include <types.h>
#include <screen.h>
#include <heap.h>
#include <pci.h>
#include <idt.h>
#include <irq.h>
#include <isr.h>
#include <drivers/timer.h>
#include <drivers/keyboard.h>



const data_t* bootloader_data=(data_t*)0xffffffffc0007000;



void imain(void){
	init_screen(bootloader_data->vs);
	init_heap();
	print("Mmap Data:");
	uint64_t tm=0;
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
	load_pci_devices();
	print("\r\nSetting Up IDT...\r\n");
	setup_idt();
	print("Setting Up Default ISRs...\r\n");
	setup_isr();
	print("Setting Up Default IRQs...\r\n");
	setup_irq();
	print("Setting Up IRQ Handlers...\r\n");
	setup_keyboard();
	setup_timer();
	print("Enabling IDT...\r\n");
	enable_idt();
	// *((char*)0xa00000000)=0;
	ensure_start_line();
	set_print_style(SCREEN_BG_COLOR_YELLOW|SCREEN_FG_COLOR_DARK_GRAY);
	print("Reached the End!\r\n");
	set_print_style(SCREEN_BG_COLOR_BLACK|SCREEN_FG_COLOR_WHITE);
	for (;;);
}
