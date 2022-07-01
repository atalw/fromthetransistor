#include "addr.h"

.global _start

/* The exception table is defined with offsets in the documentation here
https://developer.arm.com/documentation/den0024/a/AArch64-Exception-Handling/AArch64-exception-table?lang=en */
.balign 0x800
_start:
	b		reset_handler	/* reset */
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.
	.balign 0x80
	b		.

/* LDR: Load register, STR: Store register */
/* The size of the load or store is determined by the register type X or W and the <Size> field. */
/* X is used for 32 bits and Wis used for 64 bits.*/
/* MOV: moves a constant, or the contents of another register, into the register specified.*/
/* [reg, #num] -> offset applied to base address */
/* Clock freq = 24000000 (https://github.com/qemu/qemu/blob/master/hw/arm/virt.c#L274) */
/* UART registers: https://developer.arm.com/documentation/ddi0183/g/programmers-model/summary-of-registers?lang=en */
.balign 0x800
reset_handler:
	ldr		x1, =UART_BASE  /* Load UART base address into reg 1 */
	mov		w2, #0xd        /* Baud rate = 24000000 / (16 * 115200) */
	str		w2, [x1, #0x24] /* Store IBDR at 0x24 offset from UART base */
	mov		w2, #0x0300     /* Default control register value */
	str		w2, [x1, #0x30] /* Control register location (we reset it) */

	ldr		x0, =bootloader_addr /* We place the bootloaderj just at the beginning of RAM (value defined in linker.ld) */
	mov		sp, x0          /* Set it to stack pointer */
