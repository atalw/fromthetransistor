OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
TARGET(binary)

/* virt cortex-a72 RAM start address is 0x4000000 and there is DTB */
RAM_OFFSET = 0x40010000;

SECTIONS
{
	. = RAM_OFFSET;
	.text : { kernel.o (.text) }
	.data : { kernel.o (.data) }
	.bss : { kernel.o (.bss) }
}

