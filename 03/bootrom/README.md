## BootROM

### Fundamentals

When a computer turns on, the first thing it needs to do is initialize itself. By initialize, I mean connect it's components so that information can be passed around to each other. There is no concept of a keyboard, mouse, RAM etc. just as it turns on. There is some flash memory added by the manufacturer that exists on chip but which is usually slow. This is where a BootROM or BIOS comes in. There is code baked into the read-only memory portion of the hardware which does the basic setup and hand off to other programs which are more complex. Usually this program has to be very simple because ROM is really small (usually ranging from 8kB to only 32MB) and slow.

Since there is no concept of an OS or compiler at this point, the code is written in Assembly which the CPU can directly translate to machine code. It's purpose is to setup basic peripheral support and memory, after which it hands-off execution to the next program, usually the Bootloader.

Read some examples [here](https://stackoverflow.com/a/15666043).


### Implementation

#### Setup

Configuration of the BootROM is machine and CPU specific since there are certain presets like address of RAM load baked into the chip. We used Qemu to emulate a a `virt` machine, which is a generic virtual machine mainly used for testing (unless a specific device needs to be tested). Since all the other projects are using ARM assembly, this one is also built in ARM, specifically `aarch64 Armv8`. I compiled code on a Raspberry Pi 4b which matches this spec. To see the list of ARM qemu machines available, use 
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

The BIOS seems very simple — it loads an in-built [PL011 UART](https://developer.arm.com/documentation/ddi0183/g/) and just prints `"Hello world"`, but this in itself is a _challenging_ introduction to the underlying concepts. The assembly code of the firmware is in `bios.S` (note the capital S, I spent an embarrasingly long time debugging a compile issue because it was lower case. `gcc` doesn't preprocess it which is needed for the header import), and `main.c` contains the rest. There is a header file `addr.h` which simply contains the `UART` memory address and a `linker.ld` which contains the `stack_top` and linker structure.

In firmware design, the `reset` interrupt is what usually invokes the firmware. In `boot.S`, we've created a `_reset` function which invokes a `reset_handler` to do the actual work. The remaining interrupts just inifinitely loop in-place. We've set the entry point in `linker.ld` to `_reset` to reflect this. The reset handler initializes the UART, sets the stack pointer, and hands off execution to the C function `c_main()`. The C code simply transmits character-by-character, a given string to the UART which is routed to a serial output (using the `-nographic` or `-serial stdio` flags).

There is a `Makefile` to make compilation and linking easier (use `make`). Then if you want to run qemu, use `make qemu`.

The full command to emulate this is
```
qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 2048 -nographic -kernel ./bios.elf
```

Some interesting things to note is that while the flash memory starts at `0x00000000`, the RAM starts at `0x40000000`. This BIOS only works if it is placed in RAM (I think it's because we are using the UART, not sure). For a deeper discussion on memory, refer [here](https://www.cs.ucr.edu/~csong/cs153/20f/lab0.html). We place is a little beyond the starting address of RAM because Qemu automatically creates a [DTB](https://elinux.org/Device_Tree_Reference) at the address (which is used during the Linux boot). We also specify 2GB memory for the machine without which it won't work since the RAM is loaded at that address.

This doesn't feel accurate to me yet. The BIOS should load with the `-bios` flag since it's not a `-kernel`. However, when trying that out it just wouldn't work. After a little more digging around, I learnt a couple of more things.

When the core has been reset (i.e on every boot), it starts execution at the reset vector of the exception vector table. The branch table we've defined in the `bios.S` file is the exception vector table. The Program Counter (PC) values are precoded for different interrupt requests and cannot be changed. For this CPU they it starts at `0x00000000` or `0xFFFF0000` depending on a certain signal. Why then do we set the starting position of the code (in `linker.ld`) to an address in the RAM? It took me a while to find an answer to this but it's simply that the memory in the ROM is already premapped and there is no space. Check the implementation [here](https://github.com/qemu/qemu/blob/master/hw/arm/virt.c#L132). So the the starting address points the actual location of the vector table which we place in RAM.Which means to say that the BIOS always goes in RAM (well at least legacy). I tried placing it at the start of RAM but it just wouldn't work either. Something as simple as loading a value into a register wouldn't even work (you can check by running `info registers` in the monitor). The DTB cannot be overwritten and cannot be disabled I guess. If you print out the value mapped to address `0x40000000` you get `0xedfe0dd0` which is `0xd00dfeed` in little-endian. This is a magic value which identifies it as DTB. Parsing, understanding, and creating that is a whole other project so we'll skip that for now but it's enough to know that the [header](https://devicetree-specification.readthedocs.io/en/stable/flattened-format.html#header) contains `totalsize` entry 4-bytes after the beginning. Printing the value at address at address `0x40000004` gives us a value of `0x00001000` which means we can place our code at this offset. That's where `0x40001000` comes from in the `linker.ld` file.

### Read
- [ADRP instruction](https://stackoverflow.com/questions/41906688/what-are-the-semantics-of-adrp-and-adrl-instructions-in-arm-assembly)
- [Why use LDR over MOV](https://stackoverflow.com/questions/14046686/why-use-ldr-over-mov-or-vice-versa-in-arm-assembly)
- [Qemu aarch64 machines](https://stackoverflow.com/questions/45206027/qemu-aarch64-supported-boards)
https://stackoverflow.com/questions/58420670/qemu-bios-vs-kernel-vs-device-loader-file
