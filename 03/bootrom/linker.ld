OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
TARGET(binary)
ENTRY(_reset)

/* virt cortex-a72 RAM start address is 0x4000000 */
STACKTOP = 0x51000000;

SECTIONS
{
	. = 0x40010000; 
	.text : { 
		bios.o (INTERRUPT_VECTOR)
		*(.text)
	}
	.data : { *(.data) }
	.bss : { *(.bss COMMON) }
	. = ALIGN(8);
	. = STACKTOP;
	stack_top = .;
}

