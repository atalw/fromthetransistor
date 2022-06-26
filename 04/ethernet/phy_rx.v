// The PHY receives data from the wire and transmits it to the MAC. This module handles this signal
// along with generating the receive clock which is an output of the PHY.
module phy_rx(
    input   wire        in_rxen,
    input   wire [7:0]  in_rxd,
    output  wire        out_rxc,
    output  wire        out_rxdv,
    output  wire [7:0]  out_rxd,
    output  wire        out_rxer,
    output  wire        out_crs
    );

    reg r_clk;



endmodule
