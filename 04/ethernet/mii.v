module mii(
    input       txc, // transmit clock
    output      txen, // transmit enable
    output      txd, // transmit data

    input       rxc, // receive clock
    input       rxdv, // receive data valid
    input [3:0] rxd, // receive data
    input       rxer, // receive error

    input       crs, // carrier sense
    input       col // collision detection
);


    transmitter transmitter();

    receiver receiver();


endmodule
