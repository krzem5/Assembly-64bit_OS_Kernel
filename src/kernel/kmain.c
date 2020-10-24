typedef unsigned short int uint16_t;
typedef unsigned long long int uint64_t;



__attribute__((packed)) struct data{
	uint16_t mmap_l;
	struct data_mmap{
		uint64_t ptr;
		uint64_t l;
	}* mmap;
};



const struct data* bootloader_data=(struct data*)0x7000;



void kmain(void){
	char* vga=(char*)0xb8000;
	*vga=bootloader_data->mmap_l+48;
}
