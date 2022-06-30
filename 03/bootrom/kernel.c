#include "addr.h"

/* declaration function needs to be before call */
int puts(const char *str);

/* main needs to be the first function in the file since the kernel 
 * is place at address 0x40001000 */
int main() {
	puts("Hello world!\n");
	return 0;
}

int puts(const char *str) {
	while (*str != '\n') {
		*((unsigned int *) UART_BASE) = *str++;
	}
	return 0;
}
