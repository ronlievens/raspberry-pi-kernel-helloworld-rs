// ---------------------------------------------------------------------------------------------------------------------
// To keep this in the first portion of the binary.
// ---------------------------------------------------------------------------------------------------------------------
.section ".text.boot"

// ---------------------------------------------------------------------------------------------------------------------
// Make _start global.
// ---------------------------------------------------------------------------------------------------------------------
.globl _start
    .org 0x80000          // set the program counter's offset for the specified section

_start:
    // -----------------------------------------------------------------------------------------------------------------
    // Setup the stack.
    // -----------------------------------------------------------------------------------------------------------------
    ldr     x5, =_start   // This instruction loads the address of the _start label into the x5 register. The _start label typically denotes the entry point of a program, where execution should begin.
    mov     sp, x5        // This instruction moves the value stored in the x5 register to the stack pointer register (sp). The stack pointer is a special register which points to the top of the current stack in memory -- the place where local variables (for calls and interrupts) get stored

    // -----------------------------------------------------------------------------------------------------------------
    // Clear out bss.
    // -----------------------------------------------------------------------------------------------------------------
    ldr     x5, =__bss_start   // The address of __bss_start is loaded into x5. __bss_start is a symbol that may be provided by the linker script, it's the starting address of a BSS section in memory. The BSS section is used for variables that were declared without a value and will be initialized with zero before the program starts executing.
    ldr     w6, =__bss_size    // The value of __bss_size is loaded into w6. __bss_size represents the size of BSS section.
1:  cbz     w6, 2f             // This compares w6 (the size of the BSS) to zero, if it is zero, it branches (jumps) to label 2f. If it is not zero, it continues execution with the next instruction.
    str     xzr, [x5], #8      // This stores the value in xzr register (which is always zero) into the memory location pointed to by x5 (which is __bss_start). After storing, x5 is post-incremented by 8. This is assumed to be 64-bit memory operation, so 8 bytes are cleared in BSS section.
    sub     w6, w6, #1         // This subtracts 1 from w6 and stores the result back to w6.
    cbnz    w6, 1b             // This compares w6 to zero, if it is not zero, it branches (jumps) back to label 1b. In other words, if there are still elements left to initialize (since w6 is being decremented), it continues the loop.

    // -----------------------------------------------------------------------------------------------------------------
    // Call kernel_main
    // -----------------------------------------------------------------------------------------------------------------
2:  bl      kernel_main   // The bl instruction stands for "Branch with Link". It calls the subroutine at the address labeled kernel_main. The bl instruction also stores the return address into the lr (link register), so once kernel_main finishes execution and a return instruction (ret) is called in kernel_main, execution will continue at the point right following this bl instruction.

// ---------------------------------------------------------------------------------------------------------------------
// halt
// ---------------------------------------------------------------------------------------------------------------------
halt:
    wfe                   // This stands for "Wait For Event." The processor that executes this instruction enters a low-power sleep state until some event occurs, like an interrupt. This is used here to halt the processor in an energy-efficient manner.
    b halt                // This is an unconditional branch instruction that jumps back to the halt label, effectively creating an infinite loop. In short, once this loop is entered, the processor will continually halt and wait for an event, then halt again, indefinitely.
