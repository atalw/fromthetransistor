OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
TARGET(binary)
ENTRY(_reset)

STACKTOP = 0x51000000;

SECTIONS
{
	/*. = 0x0;*/
	. = 0x40010000;
	.text : { 
		bios.o (INTERRUPT_VECTOR)
		*(.text)
	}
	.data : { *(.data) }
	.bss : { *(.bss COMMON) }
	. = ALIGN(8);
	/*. = . + 0x1000; */ /* 4kB of stack memory */
	. = STACKTOP;
	stack_top = .;
}

