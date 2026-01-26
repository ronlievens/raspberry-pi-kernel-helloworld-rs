#![no_std]
#![no_main]

use core::arch::asm;
use core::ptr::{read_volatile, write_volatile};

//
// ---------------------------------------------------------------------------------------------------------------------
// SETUP BASE Memory-mapped I/O (MMIO)
// ---------------------------------------------------------------------------------------------------------------------
// Kies exact één model via Cargo features of build flags
//

#[cfg(any(feature = "raspi0", feature = "raspi1"))]
const MMIO_BASE: u32 = 0x2000_0000;
#[cfg(any(feature = "raspi0", feature = "raspi1"))]
const UART_CLOCK: bool = false;

#[cfg(feature = "raspi2")]
const MMIO_BASE: u32 = 0x3F00_0000;
#[cfg(feature = "raspi2")]
const UART_CLOCK: bool = false;

#[cfg(feature = "raspi3")]
const MMIO_BASE: u32 = 0x3F00_0000;
#[cfg(feature = "raspi3")]
const UART_CLOCK: bool = true;

#[cfg(feature = "raspi4")]
const MMIO_BASE: u32 = 0xFE00_0000;
#[cfg(feature = "raspi4")]
const UART_CLOCK: bool = true;

#[cfg(feature = "raspi5")]
const MMIO_BASE: u32 = 0x7C00_0000;
#[cfg(feature = "raspi5")]
const UART_CLOCK: bool = true;

//
// ---------------------------------------------------------------------------------------------------------------------
// REGISTER OFFSETS
// ---------------------------------------------------------------------------------------------------------------------
//

const GPIO_BASE: u32 = 0x200000;

const GPPUD: u32 = GPIO_BASE + 0x94;
const GPPUDCLK0: u32 = GPIO_BASE + 0x98;

const UART0_BASE: u32 = GPIO_BASE + 0x1000;

const UART0_DR: u32 = UART0_BASE + 0x00;
const UART0_FR: u32 = UART0_BASE + 0x18;
const UART0_IBRD: u32 = UART0_BASE + 0x24;
const UART0_FBRD: u32 = UART0_BASE + 0x28;
const UART0_LCRH: u32 = UART0_BASE + 0x2C;
const UART0_CR: u32 = UART0_BASE + 0x30;
const UART0_IMSC: u32 = UART0_BASE + 0x38;
const UART0_ICR: u32 = UART0_BASE + 0x44;

const MBOX_BASE: u32 = 0xB880;
const MBOX_READ: u32 = MBOX_BASE + 0x00;
const MBOX_STATUS: u32 = MBOX_BASE + 0x18;
const MBOX_WRITE: u32 = MBOX_BASE + 0x20;

//
// ---------------------------------------------------------------------------------------------------------------------
// MMIO helpers
// ---------------------------------------------------------------------------------------------------------------------
//

#[inline(always)]
unsafe fn mmio_write(reg: u32, val: u32) {
    write_volatile((MMIO_BASE + reg) as *mut u32, val);
}

#[inline(always)]
unsafe fn mmio_read(reg: u32) -> u32 {
    read_volatile((MMIO_BASE + reg) as *const u32)
}

//
// ---------------------------------------------------------------------------------------------------------------------
// Delay loop (niet optimaliseerbaar)
// ---------------------------------------------------------------------------------------------------------------------
//

#[inline(always)]
fn delay(mut count: i32) {
    unsafe {
        asm!(
        "1:",
        "subs {0}, {0}, #1",
        "bne 1b",
        inout(reg) count,
        options(nomem, nostack)
        );
    }
}

//
// ---------------------------------------------------------------------------------------------------------------------
// Mailbox buffer (16-byte aligned)
// ---------------------------------------------------------------------------------------------------------------------
//

#[repr(align(16))]
static mut MBOX: [u32; 9] = [
    9 * 4,
    0,
    0x38002,
    12,
    8,
    2,
    3_000_000,
    0,
    0,
];

//
// ---------------------------------------------------------------------------------------------------------------------
// UART
// ---------------------------------------------------------------------------------------------------------------------
//

unsafe fn uart_init() {
    // Disable UART
    mmio_write(UART0_CR, 0);

    // GPIO pull-up/down uit
    mmio_write(GPPUD, 0);
    delay(150);

    mmio_write(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);

    mmio_write(GPPUDCLK0, 0);

    // Clear interrupts
    mmio_write(UART0_ICR, 0x7FF);

    if UART_CLOCK {
        let r = ((&MBOX as *const _ as u32) & !0xF) | 8;

        while mmio_read(MBOX_STATUS) & 0x8000_0000 != 0 {}
        mmio_write(MBOX_WRITE, r);
        while (mmio_read(MBOX_STATUS) & 0x4000_0000) != 0
            || mmio_read(MBOX_READ) != r
        {}
    }

    // Baud rate
    mmio_write(UART0_IBRD, 1);
    mmio_write(UART0_FBRD, 40);

    // 8N1 + FIFO
    mmio_write(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));

    // Mask interrupts
    mmio_write(
        UART0_IMSC,
        (1 << 1)
            | (1 << 4)
            | (1 << 5)
            | (1 << 6)
            | (1 << 7)
            | (1 << 8)
            | (1 << 9)
            | (1 << 10),
    );

    // Enable UART
    mmio_write(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}

unsafe fn uart_putc(c: u8) {
    while mmio_read(UART0_FR) & (1 << 5) != 0 {}
    mmio_write(UART0_DR, c as u32);
}

unsafe fn uart_getc() -> u8 {
    while mmio_read(UART0_FR) & (1 << 4) != 0 {}
    mmio_read(UART0_DR) as u8
}

unsafe fn uart_puts(s: &str) {
    for b in s.bytes() {
        uart_putc(b);
    }
}

//
// ---------------------------------------------------------------------------------------------------------------------
// ENTRY POINT
// ---------------------------------------------------------------------------------------------------------------------
//

#[no_mangle]
pub extern "C" fn kernel_main() -> ! {
    unsafe {
        uart_init();
        uart_puts("Hello, kernel World!\n");

        loop {
            let c = uart_getc();
            uart_putc(c);
            uart_putc(b'\n');
        }
    }
}
