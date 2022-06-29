#include "addr.h"

int puts(const char *str) {
	while (*str) {
		*((unsigned int *) UART_BASE) = *str++;
	}
	return 0;
}

void c_main() {
	puts("Hello world\n");
	while(1);
}
