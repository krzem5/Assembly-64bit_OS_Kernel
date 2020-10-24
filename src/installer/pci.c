#include <pci.h>
#include <heap.h>
#include <types.h>



void outl(uint32_t p,uint32_t dt){
	__asm__("out %%eax, %%edx"::"a"(dt),"d"(p));
}



uint32_t inl(uint32_t p){
	uint32_t o;
	__asm__("in %%edx, %%eax":"=a"(o):"d"(p));
	return o;
}



PCIDeviceList pci_l={
	0,
	NULL
};



void load_pci_devices(void){
	if (pci_l.e!=NULL){
		// free(pci_l.e);
		pci_l.e=NULL;
	}
	pci_l.l=0;
	for (uint8_t b=0;b<255;b++){
		for (uint8_t d=0;d<32;d++){
			for (uint8_t f=0;f<8;f++){
				uint8_t off=0;
				outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|(off&0xfc));
				uint32_t dv=inl(0xcfc);
				if (dv!=0xffffffff){
					pci_l.l++;
					// pci_l.e=realloc(pci_l.e,pci_l.l*sizeof(PCIDevice));
					// (pci_l.e+pci_l.l-1)->v_id=dv&0xffff;
					// (pci_l.e+pci_l.l-1)->d_id=dv>>16;
					////////////////////////////
					// off=0x08;
					// outl(0xcf8,0x80000000|(b<<16)|(d<<11)|(f<<8)|(off&0xfc));
					// uint32_t dt=inl(0xcfc);
					// print("\r\n  Bus: ");
					// print_uint16(b);
					// print(", Device: ");
					// print_uint16(d);
					// print(", Func: ");
					// print_uint16(f);
					// print(", Class: ");
					// print_hex8(dt>>24);
					// print(", Subclass: ");
					// print_hex8((dt>>16)&0xff);
					// print(", IF: ");
					// print_hex8((dt>>8)&0xff);
				}
			}
		}
	}
}
