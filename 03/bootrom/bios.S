#include "addr.h"

.section INTERRUPT_VECTOR,  "x"
.global _reset
_reset:
	b		reset_handler	/* reset */
	b		.		/* fast interrupt */
	b		.		/* interrupt */
	b		.		/* supervisor */
	b		.		/* abort */
	b		.		/* system */
	b		.		/* undefined */

/* LDR: Load register, STR: Store register */
/* The size of the load or store is determined by the register type X or W and the <Size> field. */
/* X is used for 32 bits and Wis used for 64 bits.*/
/* MOV: moves a constant, or the contents of another register, into the register specified.*/
/* [reg, #num] -> offset applied to base address */
/* Clock freq = 24000000 (https://github.com/qemu/qemu/blob/master/hw/arm/virt.c#L274) */
/* UART registers: https://developer.arm.com/documentation/ddi0183/g/programmers-model/summary-of-registers?lang=en */
reset_handler:
	ldr		x1, =UART_BASE  /* Load UART base address into reg 1 */
	mov		w2, #0xd        /* Baud rate = 24000000 / (16 * 115200) */
	str		w2, [x1, #0x24] /* Store IBDR at 0x24 offset from UART base */
	mov		w2, #0x0300     /* Default control register value */
	str		w2, [x1, #0x30] /* Control register location (we reset it) */

	ldr		x0, =stack_top  /* Load top of stack (value defined in linker.ld) */
	mov		sp, x0          /* Set it to stack pointer */
	b		c_main          /* Invoke c_main() in main.c */
