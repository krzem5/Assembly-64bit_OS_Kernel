#include <pci.h>
#include <heap.h>
#include <screen.h>
#include <types.h>



void outl(uint32_t p,uint32_t dt){
	__asm__ __volatile__("out %%eax, %%edx"::"a"(dt),"d"(p));
}



uint32_t inl(uint32_t p){
	uint32_t o;
	__asm__ __volatile__("in %%edx, %%eax":"=a"(o):"d"(p));
	return o;
}



PCIDevice pci_l=NULL;



void load_pci_devices(void){
	if (pci_l!=NULL){
		print("PCI Already Loaded!\r\n");
		return;
	}
	PCIDevice h=NULL;
	for (uint8_t b=0;b<255;b++){
		for (uint8_t d=0;d<32;d++){
			for (uint8_t f=0;f<8;f++){
				outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|0x00);
				uint32_t rv=inl(0xcfc);
				if (rv!=0xffffffff){
					if (h==NULL){
						pci_l=heap_alloc(sizeof(struct __PCI_DEVICE),32);
						h=pci_l;
					}
					else{
						h->n=heap_alloc(sizeof(struct __PCI_DEVICE),32);
						h=h->n;
					}
					h->n=NULL;
					h->vendor_id=rv&0xffff;
					h->device_id=rv>>16;
					outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|0x04);
					rv=inl(0xcfc);
					h->command=rv&0xffff;
					h->status=rv>>16;
					outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|0x08);
					rv=inl(0xcfc);
					h->revision_id=rv&0xff;
					h->prog_if=(rv>>8)&0xff;
					h->subclass=(rv>>16)&0xff;
					h->class_code=rv>>24;
					outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|0x0c);
					rv=inl(0xcfc);
					h->cache_line_size=rv&0xff;
					h->latency_timer=(rv>>8)&0xff;
					h->hedaer_type=(rv>>16)&0xff;
					h->bist=rv>>24;
					print("\r\n  Bus: ");
					print_uint16(b);
					print(", Device: ");
					print_uint16(d);
					print(", Func: ");
					print_uint16(f);
					print(", Class: ");
					print_hex8(h->class_code);
					print(", Subclass: ");
					print_hex8(h->subclass);
					print(", IF: ");
					print_hex8(h->prog_if);
				}
			}
		}
	}
}
