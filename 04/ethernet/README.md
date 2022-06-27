## Ethernet controller

This is an Ethernet controller built from a PHY, a MAC, and a MII.

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

Systems communicating over Ethernet divide a stream of data into shorter pieces called frames. 
Each frame contains source and destination addresses, and error-checking data so that damaged frames 
can be detected and discarded; most often, higher-layer protocols trigger retransmission of lost frames.

The implementation is inspired by 10BASE-T whose data sheet is in this repo.

### How to use
- Compile using
```
iverilog -o tb.vvp tv.v
```
- Run
```
vvp tb.vvp
```
- View signals
```
gtkwave tb.vcd
```

### TODO
- Error detection
    - Cycle redundancy check
    - Collision detection
- Timing
- MAC address checks (source and destination)

### Read

- [OSI model](https://en.wikipedia.org/wiki/OSI_model): Understand the different layers. We're building a physical layer.
- [PHY](https://en.wikipedia.org/wiki/Physical_layer#PHY)
- [MMIO](https://en.wikipedia.org/wiki/Memory-mapped_I/O)
- [MAC address](https://en.wikipedia.org/wiki/MAC_address)
    - Ethernet stations communicate by sending each other data packets: blocks of data individually 
    sent and delivered. As with other IEEE 802 LANs, adapters come programmed with globally unique 
    48-bit MAC address so that each Ethernet station has a unique address.[b] The MAC addresses are 
    used to specify both the destination and the source of each data packet. Ethernet establishes 
    link-level connections, which can be defined using both the destination and source addresses. 
    On reception of a transmission, the receiver uses the destination address to determine whether 
    the transmission is relevant to the station or should be ignored. A network interface normally 
    does not accept packets addressed to other Ethernet stations.
- [Ethernet frame](https://en.wikipedia.org/wiki/Ethernet_frame)
    - An EtherType field in each frame is used by the operating system on the receiving station to 
    select the appropriate protocol module (e.g., an Internet Protocol version such as IPv4). Ethernet 
    frames are said to be self-identifying, because of the EtherType field. Self-identifying frames 
    make it possible to intermix multiple protocols on the same physical network and allow a single 
    computer to use multiple protocols together. Despite the evolution of Ethernet technology, all 
    generations of Ethernet (excluding early experimental versions) use the same frame formats. 
    Mixed-speed networks can be built using Ethernet switches and repeaters supporting the desired 
    Ethernet variants.
- [Cyclic redundancy check](https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
- [10BASE5](https://en.wikipedia.org/wiki/10BASE5): Where it all started
- [Vampire tap](https://en.wikipedia.org/wiki/Vampire_tap): Interesting
- [Ethernet over twisted pair](https://en.wikipedia.org/wiki/Ethernet_over_twisted_pair)
- [Media-independent interface](https://en.wikipedia.org/wiki/Media-independent_interface)


### Structure for Ethernet frame

[Wiki reference](https://en.wikipedia.org/wiki/Ethernet_frame#Structure)

Packet is sent with most significant byte first, but individual bytes made up of bits are in 
little-endian. However, the FCS field is in big-endian.


#### Preamble
The preamble consists of a 56-bit (seven-byte) pattern of alternating 1 and 0 bits, allowing devices 
on the network to easily synchronize their receiver clocks, providing bit-level synchronization.

#### Start frame delimiter (SFD)
The SFD is the eight-bit (one-byte) value that marks the end of the preamble, which is the first field 
of an Ethernet packet, and indicates the beginning of the Ethernet frame. The SFD is designed to 
break the bit pattern of the preamble and signal the start of the actual frame. SFD provides byte-level 
synchronization marks a new incoming frame.

Preamble + SFD = 10101010 10101010 10101010 10101010 10101010 10101010 10101010 10101011
Preamble + SFD = 0x55 0x55 0x55 0x55 0x55 0x55 0x55 0xD5

#### MAC addresses
MAC destination followed by MAC source, both of which are 6 octets each.

#### 802.1Q tag (optional, not implementing)
The IEEE 802.1Q tag or IEEE 802.1ad tag, if present, is a four-octet field that indicates virtual 
LAN (VLAN) membership and IEEE 802.1p priority. The first two octets of the tag are called the Tag 
Protocol IDentifier (TPID) and double as the EtherType field indicating that the frame is either 
802.1Q or 802.1ad tagged. 802.1Q uses a TPID of 0x8100. 802.1ad uses a TPID of 0x88a8.

#### EtherType field
The EtherType field is two octets long and it can be used for two different purposes. Values of 1500 
and below mean that it is used to indicate the size of the payload in octets, while values of 1536 
and above indicate that it is used as an EtherType, to indicate which protocol is encapsulated in 
the payload of the frame. When used as EtherType, the length of the frame is determined by the 
location of the interpacket gap and valid frame check sequence (FCS).

Possible values for EtherType [here](https://en.wikipedia.org/wiki/Ethernet_frame#Types).

#### Payload
Payload is a variable-length field. Its minimum size is governed by a requirement for a minimum 
frame transmission of 64 octets. With header and FCS taken into account, the minimum payload is 42 
octets when an 802.1Q tag is present[e] and 46 octets when absent. When the actual payload is less 
than the minimum, padding octets are added accordingly. IEEE standards specify a maximum payload of 
1500 octets. Non-standard jumbo frames allow for larger payloads on networks built to support them.

#### Interpacket gap
Interpacket gap (IPG) is idle time between packets. After a packet has been sent, transmitters are 
required to transmit a minimum of 96 bits (12 octets) of idle line state before transmitting the next packet.

#### Frame check sequence (FCS)
The frame check sequence (FCS) is a four-octet cyclic redundancy check (CRC) that allows detection 
of corrupted data within the entire frame as received on the receiver side. According to the standard, 
the FCS value is computed as a function of the protected MAC frame fields: source and destination 
address, length/type field, MAC client data and padding (that is, all fields except the FCS).

#### End of frame
The end of a frame is usually indicated by the end-of-data-stream symbol at the physical layer or 
by loss of the carrier signal; an example is 10BASE-T, where the receiving station detects the end 
of a transmitted frame by loss of the carrier. Later physical layers use an explicit end of data or 
end of stream symbol or sequence to avoid ambiguity, especially where the carrier is continually sent 
between frames; an example is Gigabit Ethernet with its 8b/10b encoding scheme that uses special 
symbols which are transmitted before and after a frame is transmitted.
