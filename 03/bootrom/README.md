## BootROM

### Fundamentals

When a computer turns on, the first thing it does is it `resets` it's state, i.e it's registers, hardware, memory, etc. It does this by loading a program, called the BIOS, which is located at a specific hardcoded address (which varies chip-to-chip). This code is usually provided by the manufacturer and is baked into the read-only memory portion of the hardware. There are constraints of size (usually ranging from 8kB to to 32MB) and of speed which only makes this suitable to do the bare-minimum work before passing the execution control to another program, usually the bootloader (which is loaded into RAM).

Since there is no concept of an OS or compiler at this point, the code is directly written in Assembly and assembled down to machine code which the CPU can directly execute.

[Here](https://stackoverflow.com/a/15666043) are some real-world examples of a firmware.


### Implementation

#### Setup

Configuration of the BootROM is machine and CPU specific since there are certain presets like address of ROM and RAM baked into the chip. We used Qemu to emulate a a `virt` machine, which is a generic virtual machine mainly used for testing. The memory configuration for this machine can be found [here](https://github.com/qemu/qemu/blob/master/hw/arm/virt.c#L132). Since we're already using ARM assembly for other projects, this one is also built in ARM, specifically `aarch64 Armv8`. A CPU which supports this is `cortex-A72`. I compiled code on a Raspberry Pi 4b which matches this spec. To see the list of ARM qemu machines available, use 
```
qemu-system-aarch64 -machine help
```

To see the list of CPUs for a specific machine, use
```
qemu-system-aarch64 -machine virt -cpu help
```

Once they have been decided, a machine can be emulated using
```
qemu-system-aarch64 -machine -virt -cpu cortex-a72
```

If you run this command, a window pops up which is called the Qemu [Monitor](https://en.wikibooks.org/wiki/QEMU/Monitor). It's used for managing the emulation list devices, dumping the contents of a specific address etc. But after running the command nothing else happens. And how will it happen, there is nothing for the machine to do. The goal now is to load a program at the hardwired starting address (which for [this setup](https://qemu.readthedocs.io/en/latest/system/arm/virt.html#hardware-configuration-information-for-bare-metal-programming) is `0x00000000` for flash memory and `0x40000000` for RAM) and make it do something.

#### Code

The BIOS seems very simple — it loads an in-built [PL011 UART](https://developer.arm.com/documentation/ddi0183/g/) and just prints `"Hello world"`, but this in itself is a _challenging_ introduction to the underlying concepts. The assembly code of the firmware is in `bios.S` (note the capital S, I spent an embarrasingly long time debugging a compile issue because it was lower case. `gcc` doesn't preprocess it which is needed for the header import), and `kernel.c` contains the kernel which is loaded into RAM. There is a header file `addr.h` which simply contains the `UART` memory address and 2 linker files `bios_linker.ld` and `kernel_linker.ld` which contains the `kernel_addr` and final out binary machine code structure.

In firmware design, the `reset` interrupt is what is invoked on cold boot which handles the machine setup. In `bios.S`, we've created a `_start` function which acts as a [Interrupt vector table](https://en.wikipedia.org/wiki/Interrupt_vector_table) which invokes a `reset_handler` to do the actual work. The remaining interrupts are unimplemented and just inifinitely loop in-place. I've added some links at the bottom which describe them in more detail if you're curious. We've set the entry point in `bios_linker.ld` to `_start` and we place it at `0x00000000`. The reset handler initializes the UART and sets the stack pointer to an address in RAM. We've already placed The C code at that address so it starts executing from the `main()` function and it simply transmits character-by-character, a given string to the UART which is routed to a serial output (using the `-nographic` or `-serial stdio` flags).

Once we've creaeted the object files for the BIOS and kernel, we combine them into a 1.4 MB disk image using `dd`. There is a `Makefile` to make all the compilation and linking easier (use `make`). Then if you want to run qemu, use `make qemu`.

The full command to emulate this is
```
qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 2048 -bios ./disk.img
```

Some interesting things to note is that while the flash memory starts at `0x00000000`, the RAM starts at `0x40000000`. We place it a little beyond the starting address of RAM because Qemu automatically creates a [DTB](https://elinux.org/Device_Tree_Reference) at the address (which is used during the Linux boot). We also specify 2GB memory for the machine without which it won't work since the RAM starts at 1024MB.

Note, we use the `-bios` flag instead of `-kernel` otherwise Qemu does some setup for us which we don't want in a bare-metal setup. For some reason all the examples I saw use `-kernel` which initially worked for me as well but on further understanding was simply incorrect. In my understanding, `-kernel` loads the code in RAM even if you specify an address of `0x00000000` and starts execution that location. To further add to this confusion, the original [ARM documentation](https://developer.arm.com/documentation/den0013/d/Boot-Code/Booting-a-bare-metal-system) says the _real_ exception vector table should be loaded into RAM.
	> The _start directive in the GNU Assembler tells the linker to locate code at a particular address and can be used to place code in the vector table. 
	> The initial vector table will be in non-volatile memory and can contain branch to self instructions (other than the reset vector) as no exceptions are 
	> expected at this point. Typically, the reset vector contains a branch to the boot code in ROM. The ROM can be aliased to the address of the exception vector. 
	> **The ROM then writes to some memory-remap peripheral that maps RAM into address 0 and the real exception vector table is copied into RAM.** 
	> This means the part of the boot code that handles remapping must be position-independent, as only PC-relative addressing can be used.

I placed the actual vector table at `0x00000000` and the kernel in RAM and it seems to work fine.

Another interesting note is that the DTB table starts at `0x40000000`. If you print out the value mapped to this address you get `0xedfe0dd0` which is `0xd00dfeed` in little-endian. This is a magic value which identifies it as DTB. Parsing, understanding, and creating that is a whole other project so we'll skip that for now but it's enough to know that the [header](https://devicetree-specification.readthedocs.io/en/stable/flattened-format.html#header) contains a `totalsize` entry at a 4-byte from the beginning. Printing the value at address at address `0x40000004` gives us a value of `0x00001000` which means we can place our code anywhere after this offset. After adding a little buffer, that's where `0x40001000` comes from in the linker.

### Read
- [ADRP instruction](https://stackoverflow.com/questions/41906688/what-are-the-semantics-of-adrp-and-adrl-instructions-in-arm-assembly)
- [Why use LDR over MOV](https://stackoverflow.com/questions/14046686/why-use-ldr-over-mov-or-vice-versa-in-arm-assembly)
- [Deep discussion on memory](https://www.cs.ucr.edu/~csong/cs153/20f/lab0.html)
- [Qemu aarch64 machines](https://stackoverflow.com/questions/45206027/qemu-aarch64-supported-boards)
- [`-bios` vs `-kernel`](https://stackoverflow.com/questions/58420670/qemu-bios-vs-kernel-vs-device-loader-file)
- [`ld` linker syntax](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html)
- [ARM's implementation firmware](https://github.com/ARM-software/arm-trusted-firmware)
- [Multi-core booting](https://www.design-reuse.com/articles/38128/method-for-booting-arm-based-multi-core-socs.html)
- [Exception vector table (Aarch64 Cortex A-72)](https://developer.arm.com/documentation/den0024/a/AArch64-Exception-Handling/AArch64-exception-table?lang=en)
- [`virt` source code](https://github.com/qemu/qemu/blob/master/hw/arm/virt.c#L132)
- [`virt` documentation](https://qemu.readthedocs.io/en/latest/system/arm/virt.html)
- [ARM Cortex exception handling blog](https://interrupt.memfault.com/blog/arm-cortex-m-exceptions-and-nvic)
- [ARMv8 bare-metal booting info](http://classweb.ece.umd.edu/enee447.S2019/baremetal_boot_code_for_ARMv8_A_processors.pdf)
- [BIOS + Kernel start to end StackOverflow answer](https://stackoverflow.com/questions/33603842/how-to-make-the-kernel-for-my-bootloader/33619597#33619597)
- [PL011 UART implementation](https://krinkinmu.github.io/2020/11/29/PL011.html)
- [Linker script post](https://mcyoung.xyz/2021/06/01/linker-script/)
- [Interrupt vector table](https://en.wikipedia.org/wiki/Interrupt_vector_table)
- [Booting process of Cortex M (Video)](https://www.youtube.com/watch?v=3brOzLJmeek)
