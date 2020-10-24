ENTRY(_start_e)
SECTIONS{
    . = 0xc0100000;
    ___KERNEL_OFFSET__ = 0xc0000000;
    ___KERNEL_START__ = . - 0xc0000000;
    .text : AT(ADDR(.text) - 0xc0000000) {
        *(.entry)
        *(.text .text*)
        *(.rodata .rodata* .rdata .rdata*)
    }
    .data ALIGN (0x1000) : AT(ADDR(.data) - 0xc0000000) {
        *(.pg_data)
        *(.data)
    }
    .bss : AT(ADDR(.bss) - 0xc0000000) {
        *(.bss)
    }
    ___KERNEL_END__ = . - 0xc0000000;
}
