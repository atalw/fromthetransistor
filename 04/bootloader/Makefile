all: bios.o bios.elf bootloader.o bootloader.elf kernel.o kernel.elf disk.img

bios.o: bios.S
	gcc -Wall -Wextra -nostartfiles -nostdlib -ffreestanding -c bios.S -o bios.o

bootloader.o: bootloader.c
	gcc -Wall -Wextra -nostartfiles -nostdlib -ffreestanding -c bootloader.c

kernel.o: kernel.c
	gcc -Wall -Wextra -nostartfiles -nostdlib -ffreestanding -c kernel.c

bios.elf: bios_linker.ld bios.o
	ld bios.o -T bios_linker.ld -nostdlib --nmagic -o bios.elf
	objcopy -O binary bios.elf bios.bin

bootloader.elf: bootloader_linker.ld bootloader.o
	ld bootloader.o -T bootloader_linker.ld -nostdlib --nmagic -o bootloader.elf
	objcopy -O binary bootloader.elf bootloader.bin

kernel.elf: kernel_linker.ld kernel.o
	ld kernel.o -T kernel_linker.ld -nostdlib --nmagic -o kernel.elf
	objcopy -O binary kernel.elf kernel.bin

disk.img: bios.bin bootloader.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=bios.bin of=disk.img bs=512 conv=notrunc
	dd if=bootloader.bin of=disk.img bs=512 seek=1 conv=notrunc

qemu: disk.img
	qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 2096 -serial stdio -bios ./disk.img

clean:
	rm -rf *.elf *.bin *.o disk.img
