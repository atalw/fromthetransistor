all: bios.o bios.elf kernel.o kernel.elf disk.img

bios.o: bios.S
	gcc -Wall -Wextra -c -nostartfiles -nostdlib -ffreestanding bios.S -o bios.o

kernel.o: kernel.c
	gcc -Wall -Wextra -nostartfiles -nostdlib -ffreestanding -c kernel.c

bios.elf: bios_linker.ld bios.o
	ld bios.o -T bios_linker.ld -nostdlib --nmagic -o bios.elf
	objcopy -O binary bios.elf bios.bin

kernel.elf: kernel_linker.ld kernel.o
	ld kernel.o -T kernel_linker.ld -nostdlib --nmagic -o kernel.elf
	objcopy -O binary kernel.elf kernel.bin

disk.img: bios.bin kernel.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=bios.bin of=disk.img bs=512 conv=notrunc
	dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc

qemu: bios
	qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 2096 -serial stdio -semihosting -bios ./bios -S -s

clean:
	rm -rf bios.bin bios.elf kernel.bin kernel.elf *.o disk.img
