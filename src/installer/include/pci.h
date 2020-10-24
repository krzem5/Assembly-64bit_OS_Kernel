#ifndef __INSTALLER_PCI_H__
#define __INSTALLER_PCI_H__
#include <types.h>



typedef struct __PCI_DEVICE PCIDevice;
typedef struct __PCI_DEVICE_LIST PCIDeviceList;



struct __PCI_DEVICE{
	uint16_t v_id;
	uint16_t d_id;
	uint16_t s;
	uint16_t cmd;
	uint8_t cc;
	uint8_t sc;
	uint8_t pif;
	uint8_t r_id;
	uint8_t bist;
	uint8_t t;
	uint8_t lt;
	uint8_t cls;
	union __tu{
		struct __t0{
			uint32_t b0;
			uint32_t b1;
			uint32_t b2;
			uint32_t b3;
			uint32_t b4;
			uint32_t b5;
			uint32_t ccp;
			uint16_t ss_id;
			uint16_t ss_v_id;
			uint32_t eba;
			uint8_t cp;
			uint8_t mx_l;
			uint8_t mn_g;
			uint8_t ip;
			uint8_t il;
		} t0;
		struct __t1{
			uint32_t b0;
			uint32_t b1;
			uint8_t lt2;
			uint8_t sobn;
			uint8_t	sbn;
			uint8_t pbn;
			uint16_t s2;
			uint8_t iol;
			uint8_t iob;
			uint16_t ml;
			uint16_t mb;
			uint16_t pml;
			uint16_t pmb;
			uint32_t pbu;
			uint32_t plu;
			uint16_t iolu;
			uint16_t iobu;
			uint8_t cp;
			uint32_t eba;
			uint16_t bc;
			uint8_t ip;
			uint8_t il;
		} t1;
	} dt;
};



struct __PCI_DEVICE_LIST{
	uint16_t l;
	PCIDevice* e;
};



extern PCIDeviceList pci_l;



void load_pci_devices(void);



#endif
