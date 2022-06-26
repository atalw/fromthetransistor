`include "mac_rx.v"
`include "mac_tx.v"

// The MAC sublayer provides a control abstraction of the physical layer such that the complexities
// of physical link control are invisible to the LLC and upper layers of the network stack. Thus any
// LLC sublayer (and higher layers) may be used with any MAC. In turn, the medium access control block
// is formally connected to the PHY via a media-independent interface.
//
// When sending data to another device on the network, the MAC sublayer encapsulates higher-level
// frames into frames appropriate for the transmission medium (i.e. the MAC adds a syncword preamble
// and also padding if necessary), adds a frame check sequence to identify transmission errors, and
// then forwards the data to the physical layer as soon as the appropriate channel access method permits it.
//
// When receiving data from the physical layer, the MAC block ensures data integrity by verifying the
// sender's frame check sequences, and strips off the sender's preamble and padding before passing
// the data up to the higher layers.
//
// https://en.wikipedia.org/wiki/Medium_access_control
module mac(
    input   wire        in_txc,         // transmit clock (higher layer to mac)
    input   wire        in_txen,        // higher layer to mac transmit enable
    input   wire [7:0]  in_txd,         // higher layer to mac transmit data
    input   wire        in_rxc,         // receive clock (mii/phy to mac)
    input   wire        in_rxdv,        // mii/phy to mac receive data valid
    input   wire [7:0]  in_rxd,         // mii/phy to mac receive data
    input   wire        in_rxer,        // mii/phy to mac receive err
    input   wire        in_crs,         // mii/phy to mac carrier sense
    output  wire        out_tx_ready,   // mac to higher layer signalling payload can be received
    output  wire        out_txen,       // mac to mii/phy transmit enable
    output  wire [7:0]  out_txd         // mac to mii/phy transmit data
    );

    // When data is received from the from the MII(PHY), we need to deconstruct the frame into it's
    // constituents for the MII to pass it forward to the data-link layer of the OSI model.
    mac_rx mac_rx(in_rxc, in_rxdv, in_rxd, in_rxer, in_crs, out_txen, out_txd);

    // When data is received from the data-link layer of the OSI, we need to construct an ethernet
    // frame and pass it to the MII so that it can forward it to the PHY.
    mac_tx mac_tx(in_txc, in_txen, in_txd, out_tx_ready, out_txen, out_txd);

endmodule
