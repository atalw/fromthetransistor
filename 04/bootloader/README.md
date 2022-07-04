## Bootloader

Update: I've decided to pick this up later. I think, the main goal of this task is to build a bootloader, implement the UDP protocol, and download the kernel from a remote host. However, what stops us from doing this is the lack of an ethernet driver. The [hardware](https://github.com/qemu/qemu/blob/master/include/hw/virtio/virtio-net.h) and [protocol](https://github.com/qemu/qemu/blob/master/include/net/eth.h) for the virtio-net ethernet device are implemented in Qemu, however, for the bootloader to send/receive packets, we will have to write the driver ourself. That's a big task and perhaps building an SD card driver first may be a better introduction.

The idea is to boot a kernel on a remote machine using UDP over Ethernet. So there are 2 files we need to consider, one is the bootloader and the other is an OS kernel binary. Since we need to send a file over the network, we'll be using TFTP which is a protocol built on top of UDP. The OS image will be baked into the machine and our bootloader will point to the correct address to load. We'll be using QEMU with it's networking capabilites to emulate a virtual machine.

### Some fundamentals
#### What is the startup process?
When a computer is turned on, the first thing it does is it reads data from a specific address which is stored in [ROM](https://en.wikipedia.org/wiki/Read-only_memory). This is usually a [BIOS](https://en.wikipedia.org/wiki/BIOS). The BIOS initializes [RAM](https://en.wikipedia.org/wiki/Random-access_memory), which is volatile memory. It does this because the CPU can only receive and execute instructions from ROM or RAM.

After setting up the RAM, data from [non-volatile memory](https://en.wikipedia.org/wiki/Non-volatile_memory) is ready to be loaded into it. This has software like the operating system, application code, and data stored in it when the computer is in a powered off state. To load it, the BIOS points to a specific address which contains a file with instructions to load the correct data. This file is called a [bootloader](https://en.wikipedia.org/wiki/Bootloader).

The bootloader loads an [operating system](https://en.wikipedia.org/wiki/Operating_system) which provides a [kernel](https://en.wikipedia.org/wiki/Kernel_(operating_system)) to manage hardware, software, and provide common services used by programs.

#### If a BIOS already initializes hardware, why do we need drivers?
It does basic initialization for the keyboard, mouse, monitor, ethernet, and storage controllers. Beyond this, initialization can become complex and highly device specific. Since it's not needed, the rest are left to the operating system. Read more [here](https://stackoverflow.com/questions/21964871/why-we-need-device-drivers-when-we-already-have-bios-services#:~:text=The%20BIOS%20only%20has%20code,your%20USB%20printer%20or%20webcam.).

#### What is SRAM and DRAM?
[SRAM](https://en.wikipedia.org/wiki/Static_random-access_memory)(Static RAM) is a type of RAM that uses latching circuitry (flip-flops) to store each bit. [DRAM](https://en.wikipedia.org/wiki/Dynamic_random-access_memory)(Dynamic RAM) is a type of RAM that uses semiconductors to store a bit. The difference lies in the fact that DRAM capacitors need to be periodically refreshed while SRAM doesn't. If the DRAM does not have an external memory refresh mechanism, data will be lost after some time. SRAM is faster but more expensive, while DRAM is slower but cheaper. As a result, SRAM is used for storing cache and CPU registers, and DRAM is used as main memory for the operating system.

#### Booting over network
Once the BIOS is loaded, if the functionality exists, the bootloader can be pointed to or transfered over Ethernet. The functionality the BIOS needs to support is called [Preboot eXecution Environment](https://en.wikipedia.org/wiki/Preboot_Execution_Environment)(PXE). Using [TFTP](https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol), we can boot the operating system over the network. Read more [here](https://en.wikipedia.org/wiki/Bootloader#Network_booting).

### Read
- [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol)
- [Kernel](https://en.wikipedia.org/wiki/Kernel_(operating_system))
- [Trivial File Transfer Protocol](https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol): Simple protocol for transferring files, implemented on top of the UDP/IP protocols using well-known port number 69.
- [GRUB](https://en.wikipedia.org/wiki/GNU_GRUB): Unified bootloader
- [EmCraft loading linux images via TFTP](https://www.emcraft.com/som/imx-8m/loading-linux-images-via-ethernet-and-tftp)
- [GCC and bare metal programming](https://cs107e.github.io/guides/gcc/)
- [Virtio vs e1000](https://unix.stackexchange.com/questions/597789/virtio-vs-e1000-vs-rtl8139-whats-the-difference)
- [Understanding Qemu devices](https://www.qemu.org/2018/02/09/understanding-qemu-devices/)
- [U-boot and TFTP network boot](https://blog.pentesteracademy.com/booting-an-emulated-arm-device-using-tftp-and-u-boot-6f6868cccd14)
- [Ethernet bootloader from ARM](https://www.ijser.org/paper/Ethernet-Boot-loader-for-ARM-Processor.html)
- [Bootloader from scratch](https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf)
- [Arduino TFTP bootloader source](https://github.com/arduino/TFTP-Bootloader/tree/master/eth-bootloader/firmware)
- [U-boot TFTP bootloader source](https://github.com/ARM-software/u-boot/blob/master/net/tftp.c)
