all: bios.o main.o bios.elf

bios.o: bios.S
	gcc -Wall -Wextra -g -c bios.S -o bios.o

main.o: main.c
	gcc -Wall -Wextra -g -c main.c

bios.elf: linker.ld bios.o main.o
	ld bios.o main.o -T linker.ld -o bios.elf

qemu: bios.elf
	qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 4096 -nographic -kernal ./bios.elf

clean:
	rm -rf bios.elf *.o
