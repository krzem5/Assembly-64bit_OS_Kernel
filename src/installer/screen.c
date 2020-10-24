#include <screen.h>
#include <types.h>



uint8_t _vmem_x=0;
uint8_t _vmem_y=0;



void print_char(char c){
	bool cs=false;
	if (c=='\n'){
		_vmem_y++;
		if (_vmem_y==SCREEN_MAX_COLS){
			cs=true;
		}
	}
	else if (c=='\r'){
		_vmem_x=0;
	}
	else{
		*(SCREEN_MEM_ADDR+(_vmem_y*SCREEN_MAX_COLS+_vmem_x)*2)=c;
		*(SCREEN_MEM_ADDR+(_vmem_y*SCREEN_MAX_COLS+_vmem_x)*2+1)=0x0f;
		_vmem_x++;
		if (_vmem_x==SCREEN_MAX_COLS){
			_vmem_x=0;
			_vmem_y++;
			if (_vmem_y==SCREEN_MAX_COLS){
				cs=true;
			}
		}
	}
	if (cs==true){
		_vmem_y--;
		for (uint16_t i=SCREEN_MAX_COLS*2;i<SCREEN_MAX_COLS*SCREEN_MAX_ROWS*2;i++){
			*(SCREEN_MEM_ADDR+i-SCREEN_MAX_COLS*2)=*(SCREEN_MEM_ADDR+i);
		}
		for (uint16_t i=SCREEN_MAX_COLS*(SCREEN_MAX_ROWS-1)*2;i<SCREEN_MAX_COLS*SCREEN_MAX_ROWS*2;i+=2){
			*(SCREEN_MEM_ADDR+i)=' ';
			*(SCREEN_MEM_ADDR+i+1)=0x0f;
		}
	}
}



void print(char* s){
	while (*s!=0){
		print_char(*s);
		s++;
	}
}



void print_addr(uint32_t a){
	for (signed char i=sizeof(uint32_t)*8-4;i>=0;i-=4){
		unsigned char v=(a>>i)%16;
		if (v<=9){
			print_char(v+48);
		}
		else{
			print_char(v+87);
		}
	}
}



void print_laddr(uint64_t a){
	for (signed char i=sizeof(uint64_t)*8-4;i>=0;i-=4){
		unsigned char v=(a>>i)%16;
		if (v<=9){
			print_char(v+48);
		}
		else{
			print_char(v+87);
		}
	}
}



void print_uint16(uint16_t v){
	if (v==0){
		print_char('0');
	}
	else{
		uint8_t sz=1;
		uint16_t pw=10;
		while (pw<v+1){
			sz++;
			if (sz==5){
				break;
			}
			pw*=10;
		}
		if (sz!=5){
			pw/=10;
		}
		while (sz>0){
			print_char(48+(v/pw)%10);
			sz--;
			pw/=10;
		}
	}
}



void print_uint32(uint32_t v){
	if (v==0){
		print_char('0');
	}
	else{
		uint8_t sz=1;
		uint32_t pw=10;
		while (pw<v+1){
			sz++;
			if (sz==10){
				break;
			}
			pw*=10;
		}
		if (sz!=10){
			pw/=10;
		}
		while (sz>0){
			print_char(48+(v/pw)%10);
			sz--;
			pw/=10;
		}
	}
}



void print_hex8(uint8_t p){
	for (signed char i=4;i>=0;i-=4){
		unsigned char v=(p>>i)%16;
		if (v<=9){
			print_char(48+v);
		}
		else{
			print_char(87+v);
		}
	}
}



void clear_screen(void){
	for (uint16_t i=0;i<SCREEN_MAX_COLS*SCREEN_MAX_ROWS*2;i+=2){
		*(SCREEN_MEM_ADDR+i)=' ';
		*(SCREEN_MEM_ADDR+i+1)=0x0f;
	}
	_vmem_x=0;
	_vmem_y=0;
}
