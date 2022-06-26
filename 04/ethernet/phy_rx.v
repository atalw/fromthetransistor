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

    reg clock;
    reg r_rxdv;
    reg [7:0] r_rxd;
    reg r_rxer;
    reg r_crs;

    assign out_rxc = clock;
    assign out_rxdv = r_rxdv;
    assign out_rxd = r_rxd;
    assign out_rxer = r_rxer;
    assign out_crs = r_crs;

    initial begin
        clock <= 0;
        r_rxdv <= 1; // TODO
        r_rxer <= 0; // TODO
        r_crs <= 0;
    end

    always begin
        #10 clock = ~clock;
        r_rxd <= in_rxd;
        r_crs <= in_rxen;
    end
endmodule
