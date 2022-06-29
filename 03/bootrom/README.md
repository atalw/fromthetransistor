## BootROM

When a computer turns on, the first thing it needs to do is initialize itself. By initialize, I mean connect it's components so that information can be passed to each other. There is no concept of a memory, keyboard, mouse, etc. just as it turns on. This is where a BootROM or BIOS comes in. There is code baked into the Read only memory portion of the hardware (usually this is done by the manufacturers directly inside the chip) which means it's highly hardware specific. This piece of code is also called a BIOS (Basic input/output system) and firmware. Naturally, there is also a size constraint usually of about 4kB.

Since there is no concept of an OS or compiler at this point, this code is directly written in Assembly which the CPU can directly translate to machine code. The purpose of this code is to setup basic peripheral support and most importantly, hand-off execution to the next program which is usually the Bootloader. The bootloader setups up the RAM and invokes the kernel.

Read some examples [here](https://stackoverflow.com/a/15666043).

