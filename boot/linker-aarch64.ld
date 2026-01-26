ENTRY(_start)

SECTIONS
{
    . = 0x80000;         /* The kernel image will be loaded at this address */

    __start = .;         /* Define a global symbol marking the start. */
    __text_start = .;    /* Define a global symbol marking the start of .text section. */
    .text :
    {
        KEEP(*(.text.boot))
        *(.text)         /* .text sections (code) */
        . = ALIGN(4096); /*  "align the current location counter to the next 4096-byte (or 4-KiB) boundary". This is often used when you want to ensure that a particular memory section starts at an address that is a multiple of a certain number. */
    }
    __text_end = .;      /* Define a global symbol marking the end of .text section. */

    __rodata_start = .;  /* Define a global symbol marking the start of .rodata section. */
    .rodata :
    {
        *(.rodata)        /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4096);  /*  "align the current location counter to the next 4096-byte (or 4-KiB) boundary". This is often used when you want to ensure that a particular memory section starts at an address that is a multiple of a certain number. */
    }
     __rodata_end = .;    /* Define a global symbol marking the end of .rodata section. */

    __data_start = .;     /* Define a global symbol marking the start of .data section. */
    .data :
    {
        *(.data)          /* .data sections */
        . = ALIGN(4096);  /*  "align the current location counter to the next 4096-byte (or 4-KiB) boundary". This is often used when you want to ensure that a particular memory section starts at an address that is a multiple of a certain number. */
    }
    __data_end = .;       /* Define a global symbol marking the end of .data section. */

    __bss_start = .;      /* Define a global symbol marking the start of .bss section. */
    .bss :
    {
        bss = .;          /* sets the value of the bss symbol to the current value of the location counter. Essentially, this is marking the current address as the start of the .bss section */
        *(.bss)           /* .bss sections without initial values */
        . = ALIGN(4096);  /*  "align the current location counter to the next 4096-byte (or 4-KiB) boundary". This is often used when you want to ensure that a particular memory section starts at an address that is a multiple of a certain number. */
    }
    __bss_end = .;        /* Define a global symbol marking the end of .bss section. */
    __bss_size = __bss_end - __bss_start;
    __end = .;            /* Define a global symbol marking the end. */
}
