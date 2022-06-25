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
    input   wire        in_txc,
    input   wire        in_rxc,
    input   wire        in_rxdv,
    input   wire [7:0]  in_rxd,
    input   wire        in_rxer,
    output  wire        out_txen,
    output  wire [7:0]  out_txd
);

    wire w_dest_mac;
    wire w_src_mac;
    wire w_ether_type;
    wire w_eth_frame;

    transmitter transmitter(in_txc, w_dest_mac, w_src_mac, w_ether_type, in_rxd, in_rxdv, out_txen, out_txd);

    receiver receiver(in_rxc, in_rxdv, in_rxd, rxc);
endmodule
