#ifndef __TYPES_H__
#define __TYPES_H__



#define bool uint8_t
#define true 1
#define false 0
#define NULL ((void*)0)



typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int int16_t;
typedef unsigned short int uint16_t;
typedef signed int int32_t;
typedef unsigned int uint32_t;
typedef signed long long int int64_t;
typedef unsigned long long int uint64_t;
typedef uint64_t size_t;
typedef uint32_t physaddr_t;



typedef struct __DATA{
	uint8_t vs;
	uint16_t acip_id;
	uint16_t mmap_l;
	uint32_t date;
	uint32_t time;
	struct data_mmap{
		uint64_t ptr;
		uint64_t l;
	} __attribute__((packed)) mmap[];
} __attribute__((packed)) data_t;



#endif
