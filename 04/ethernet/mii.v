`include "mac.v"
`include "phy.v"

// The media-independent interface (MII) is a standard interface to connect a Ethernet media access 
// control (MAC) block to a PHY chip.
// The original MII transfers network data using 4-bit nibbles in each direction (4 transmit data 
// bits, 4 receive data bits). The data is clocked at 25 MHz to achieve 100 Mbit/s throughput.
// https://en.wikipedia.org/wiki/Media-independent_interface
// We're using 8-bit nibbles.
module mii;
    // The transmit clock is a free-running clock generated by the PHY based on the link speed
    // (25 MHz for 100 Mbit/s, 2.5 MHz for 10 Mbit/s).
    // The remaining transmit signals are driven by the MAC synchronously on the rising edge of TXC.
    // This arrangement allows the MAC to operate without having to be aware of the link speed.
    // The transmit enable signal is held high during frame transmission and low when the transmitter
    // is idle.
    wire        w_txc;      // transmit clock
    wire        w_txen;     // transmit enable
    wire [7:0]  w_txd;      // transmit data

    // The first seven receiver signals are entirely analogous to the transmitter signals, except
    // RX_ER is not optional and used to indicate the received signal could not be decoded to valid
    // data. The receive clock is recovered from the incoming signal during frame reception. When
    // no clock can be recovered (i.e. when the medium is silent), the PHY must present a free-running
    // clock as a substitute.
    wire        w_rxc;      // receive clock
    wire        w_rxdv;     // receive data valid
    wire [7:0]  w_rxd;      // receive data
    wire        w_rxer;     // receive error
    wire        w_crs;      // carrier sense

    // Not entirely sure if the modules get made anew in this case. In the
    // eth_controller we've instantiated the mac and phy modules so that we
    // can connect them to the mcu/cpu and the wire. The purpose of the mii is
    // to connect the mac with the phy. We could just specify the common wires
    // in eth_controller and connect them there, but I didn't want to do that
    // since the concept of mii would not be clearly visible. I did it anyway
    // since reinstantiating mac and phy seemed incorrect. So, as a result,
    // this module is not being used.

    mac mac(
        .in_txc(w_txc),
        .in_txen(),         // Leave empty since it is input from higher layer to the MAC
        .in_txd(),          // Leave empty since it is input from higher layer to the MAC
        .in_rxc(w_rxc),
        .in_rxdv(w_rxdv),
        .in_rxd(w_rxd),
        .in_rxer(w_rxer),
        .in_crs(w_crs),
        .out_tx_ready(),    // Leave empty since it is output from MAC to higher layer
        .out_txen(w_txen),
        .out_txd(w_txd)
    );

    phy phy(
        .in_txen(w_txen),
        .in_txd(w_txd),
        .in_rxen(),         // Leave empty since (wire to phy) is not handled in MII
        .in_rxd(),          // Leave empty since (wire to phy) is not handled in MII
        .out_txc(w_txc),
        .out_txen(),        // Leave empty since (phy to wire) is not handled in MII
        .out_txd(),         // Leave empty since (phy to wire) is not handled in MII
        .out_rxc(w_rxc),
        .out_rxdv(w_rxdv),
        .out_rxd(w_rxd),
        .out_rxer(w_rxer),
        .out_crs(w_crs)
    );

endmodule
