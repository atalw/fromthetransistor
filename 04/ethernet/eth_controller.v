// Encapsulates: Data-link layer <-> MAC <-> MII <-> PHY <-> Wire
// Inputs/Outputs:
// - Higher layer
// - Wire
module eth_controller(
    input   wire          in_txen,      // mcu/cpu transmit enable
    input   wire [7:0]    in_txd,       // mcu/cpu transmit data
    input   wire          in_rxen,      // wire receive enable
    input   wire [7:0]    in_rxd,       // wire receive data
);

    mac mac();

    phy phy();

    mii mii();

endmodule
