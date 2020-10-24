#ifndef __INSTALLER_TYPES_H__
#define __INSTALLER_TYPES_H__



#define bool uint8_t
#define true 1
#define false 0
#define NULL ((void*)0)



typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned long int uint32_t;
typedef unsigned long long int uint64_t;
typedef uint64_t size_t;
typedef uint32_t physaddr_t;



typedef struct __DATA{
	uint16_t acip_id;
	uint16_t mmap_l;
	uint32_t date;
	uint32_t time;
	struct data_mmap{
		uint64_t ptr;
		uint64_t l;
	} __attribute__((packed)) mmap[];
} __attribute__((packed)) data_t;



typedef struct __PAGE{
	uint32_t present:1;
	uint32_t rw:1;
	uint32_t user:1;
	uint32_t accessed:1;
	uint32_t dirty:1;
	uint32_t unused:7;
	uint32_t frame:20;
} page_t;

typedef struct __PAGE_TABLE{
	page_t pg[1024];
} page_table_t;

typedef struct __PAGE_DIR{
	page_table_t* tables[1024];
	uint32_t tablesPhysical[1024];
	uint32_t physicalAddr;
} page_directory_t;



/*typedef struct __PAGE{
	uint32_t present;
	uint32_t rw;
	uint32_t user;
	uint32_t accessed;
	uint32_t dirty;
	uint32_t unused;
	uint32_t frame;
} page_t;



typedef struct __PAGE_TABLE{
	page_t dt[1024];
} page_table_t;



typedef struct __PAGE_DIR{
	page_table_t* tl[1024];
	uint32_t t[1024];
	uint32_t a;
} page_dir_t;



typedef struct __REGISTERS{
	uint32_t ds;
	uint32_t edi;
	uint32_t esi;
	uint32_t ebp;
	uint32_t esp;
	uint32_t ebx;
	uint32_t edx;
	uint32_t ecx;
	uint32_t eax;
	uint32_t int_no;
	uint32_t err_code;
	uint32_t eip;
	uint32_t cs;
	uint32_t eflags;
	uint32_t useresp;
	uint32_t ss;
} registers_t;



typedef struct __HEAP_HEADER{
	uint32_t magic;
	bool is_hole;
	uint32_t size;
} header_t;



typedef struct __HEAP_FOOTER{
	uint32_t magic;
	header_t *header;
} footer_t;



typedef struct __HEAP{
	ordered_array_t index;
	uint32_t start_address;
	uint32_t end_address;
	uint32_t max_address;
	bool supervisor;
	bool readonly;
} heap_t;



typedef void (*isr_t)(registers_t r);*/





#endif
