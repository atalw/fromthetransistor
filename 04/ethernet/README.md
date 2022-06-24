## Ethernet controller

The Ethernet PHY is a component that operates at the physical layer of the OSI network model. 
It implements the physical layer portion of the Ethernet. Its purpose is to provide analog signal 
physical access to the link. It is usually interfaced with a media-independent interface (MII) to a 
MAC chip in a microcontroller or another system that takes care of the higher layer functions.

More specifically, the Ethernet PHY is a chip that implements the hardware send and receive function 
of Ethernet frames; it interfaces between the analog domain of Ethernet's line modulation and the 
digital domain of link-layer packet signaling. The PHY usually does not handle MAC addressing, 
as that is the link layer's job. Similarly, Wake-on-LAN and Boot ROM functionality is implemented 
in the network interface card (NIC), which may have PHY, MAC, and other functionality integrated 
into one chip or as separate chips.

### Read

- [OSI model](https://en.wikipedia.org/wiki/OSI_model): Understand the different layers. We're building a physical layer.
- [PHY](https://en.wikipedia.org/wiki/Physical_layer#PHY)
- [MMIO](https://en.wikipedia.org/wiki/Memory-mapped_I/O)
