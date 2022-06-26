module phy_tx(
    input   wire        in_txen,
    input   wire [7:0]  in_txd,
    output  wire        out_txc,
    output  wire        out_txen,
    output  wire [7:0]  out_txd
    );

    reg clock;
    reg r_txen;
    reg [7:0] r_txd;

    assign out_txc = clock;
    assign out_txen = r_txen;
    assign out_txd = r_txd;

    initial begin
        clock <= 0;
    end

    always begin
        #10 clock = ~clock;
        r_txen <= in_txen;
        r_txd <= in_txd;
    end
endmodule
