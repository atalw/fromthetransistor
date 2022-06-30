OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
TARGET(binary)
ENTRY(_start)

/* virt cortex-a72 RAM start address is 0x4000000 */
STACKTOP = 0x51000000;
RAM_OFFSET = 0x40010000;
ROM_OFFSET = 0x00000000;

SECTIONS
{
	. = ROM_OFFSET;
	.text : { 
		*(.text) 
	}
	.data : { *(.data) }
	.bss : { *(.bss COMMON) }
	. = STACKTOP;
	stack_top = .;
}

