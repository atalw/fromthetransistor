// The Ethernet PHY is a component that operates at the physical layer of the OSI network model.
// It implements the physical layer portion of the Ethernet. Its purpose is to provide analog signal
// physical access to the link. It is usually interfaced with a media-independent interface (MII)
// to a MAC chip in a microcontroller or another system that takes care of the higher layer functions.
//
// More specifically, the Ethernet PHY is a chip that implements the hardware send and receive function
// of Ethernet frames; it interfaces between the analog domain of Ethernet's line modulation and the
// digital domain of link-layer packet signaling. The PHY usually does not handle MAC addressing,
// as that is the link layer's job. Similarly, Wake-on-LAN and Boot ROM functionality is implemented
// in the network interface card (NIC), which may have PHY, MAC, and other functionality integrated
// into one chip or as separate chips.
//
// https://en.wikipedia.org/wiki/Physical_layer#PHY
module phy(
    input   wire        in_txen,
    input   wire [7:0]  in_txd,
    output  wire        out_txc
    output  wire        out_rxc,
    output  wire        out_rxdv,
    output  wire [7:0]  out_rxd,
    output  wire        out_rxer
    );

    // transmitter transmitter(txc, w_dest_mac, w_src_mac, w_ether_type, w_eth_frame, w_txen, w_txd);

    // receiver receiver(txc, w_txen, w_txd, rxc);
endmodule
