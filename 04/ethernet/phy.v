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
    input   wire        in_txen,    // mii/mac to phy transmit enable
    input   wire [7:0]  in_txd,     // mii/mac to phy transmit data
    input   wire        in_rxen,    // wire to phy receive enable
    input   wire [7:0]  in_rxd,     // wire to phy receive data
    output  wire        out_txc,    // transmit clock (phy to mii/mac)
    output  wire        out_txen,   // phy to wire transmit enable
    output  wire [7:0]  out_txd,    // phy to wire transmit data
    output  wire        out_rxc,    // receive clock (phy to mac/mii)
    output  wire        out_rxdv,   // phy to mii/mac receive data valid
    output  wire [7:0]  out_rxd,    // phy to mii/mac receive data
    output  wire        out_rxer,   // phy to mii/mac receiver err
    output  wire        out_crs,    // phy to mii/mac carrier sense
    );

    // Receive data from analog wire and output to mii
    phy_rx phy_rx(in_rxen, in_rxd, out_rxc, out_rxdv, out_rxd, our_rxer, out_crs);

    // Transmit data from Mii to analog wire
    phy_tx phy_tx(in_txen, in_txd, out_txc, out_txen, out_txd);

endmodule
