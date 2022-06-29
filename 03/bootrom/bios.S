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

reset_handler:
	ldr		x4, =UART_BASE
	mov		w5, #0x10
	str		w5, [x4, #0x24]
	mov		w5, #0xc300
	orr		w5, w5, #0x001
	str		w5, [x4, #0x30]

	ldr		x0, =stack_top
	mov		sp, x0
	b		c_main
