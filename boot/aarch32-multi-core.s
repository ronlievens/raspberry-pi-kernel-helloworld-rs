// ---------------------------------------------------------------------------------------------------------------------
// To keep this in the first portion of the binary.
// ---------------------------------------------------------------------------------------------------------------------
.section ".text.boot"

// ---------------------------------------------------------------------------------------------------------------------
// Make _start global.
// ---------------------------------------------------------------------------------------------------------------------
.globl _start
    .org 0x8000           // set the program counter's offset for the specified section

_start:
    // -----------------------------------------------------------------------------------------------------------------
    // Setup the stack.
    // -----------------------------------------------------------------------------------------------------------------
    ldr r5, =_start        // This instruction uses the Load Register (LDR) operation to load the address of the _start label into the r5 register. The _start label is a common entry point in many programs, typically signifying the start of the executable portion of a program.
    mov sp, r5             // his instruction moves the value in r5 (which we know contains the address of _start from the first instruction) into the stack pointer sp. The stack pointer is a special-purpose register that points to the top of the stack.

    // -----------------------------------------------------------------------------------------------------------------
    // Clear out bss.
    // -----------------------------------------------------------------------------------------------------------------
    ldr r4, =__bss_start   // Load the address of __bss_start into r4. __bss_start is usually a symbol representing the start of the BSS (Block Started by Symbol) section in your program's memory space.
    ldr r9, =__bss_end     // Load the address of __bss_end into r9. __bss_end symbolizes the end of the BSS section.
    mov r5, #0             // Move literal value 0 into r5
    mov r6, #0             // Move literal value 0 into r6
    mov r7, #0             // Move literal value 0 into r7
    mov r8, #0             // Move literal value 0 into r8
    b       2f

1:
    // -----------------------------------------------------------------------------------------------------------------
    // store multiple at r4.
    //
    // stmia stands for Store Multiple Increment After. It's a command that stores multiple register values into consecutive memory locations, and then increments the base register afterward.
    // r4! This is the base register. The exclamation mark ! means the base register (r4 in this case) will be updated (incremented) after the store. The increment is by the number of stored bytes.
    // {r5-r8} This is a list of registers whose values will be stored into memory. In this instruction, it's the range of registers from r5 to r8.
    // -----------------------------------------------------------------------------------------------------------------
    stmia r4!, {r5-r8}

// ---------------------------------------------------------------------------------------------------------------------
// If we are still below bss_end, loop.
// ---------------------------------------------------------------------------------------------------------------------
2:
    cmp r4, r9            // CMP instruction performs a 'Compare' operation. It compares the values held in r4 and r9 by performing a subtraction operation (r4 - r9) but does not store the result. It simply updates the processor status flags based on the result of the operation. The flags that could be updated include N (Negative), Z (Zero), and C (Carry), among others.
    blo 1b                // BLO instruction stands for 'Branch if Lower'. It will cause a branch in the program execution if the Carry flag is not set, which is the case when the unsigned value in r4 is less than the unsigned value in r9. The 1b signifies a 'local backward label'. That means it will jump back to a label defined as 1: somewhere before this line in the same function.

    // -----------------------------------------------------------------------------------------------------------------
    // Call kernel_main
    // -----------------------------------------------------------------------------------------------------------------
    ldr r3, =kernel_main  // The load register (ldr) operation loads the address of the label kernel_main into the r3 register. kernel_main is assumed to be the main function or entry point of the kernel code.
    blx r3                // The branch with link and exchange (blx) operation in ARM assembly is a subroutine call that saves the return address in the lr (link register), then branches to the address specified. In this case, control is transferred to the address contained in the r3 register, which is expected to be the address of kernel_main as per the previous operation.

// ---------------------------------------------------------------------------------------------------------------------
// halt
// ---------------------------------------------------------------------------------------------------------------------
halt:
    wfe                   // This stands for "Wait For Event". It is an instruction that puts the processor in a low power sleep mode waiting for an event or interrupt to wake it up.
    b halt                // This is a branch instruction that redirects the execution back to the label halt.
