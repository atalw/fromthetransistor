// When data is received from the from the PHY, we need to deconstruct the frame into it's 
// constituents for the MII to pass it forward
module mac_rx(
    input  wire          in_rxc,
    input  wire          in_rxdv,    // receive data valid
    input  wire [7:0]    in_rxd,     // receive data
    input  wire          in_rxer,    // receive error
    input  wire          in_crs,     // carrier sense
    output wire          out_txen,   // transmit enable
    output wire [7:0]    out_txd     // transmit data
    );


    reg                     r_txen;
    reg [7:0]               r_txd;
    reg [55:0]              r_preamble;
    reg [7:0]               r_sfd;        // start frame delimiter
    reg [47:0]              r_dest_mac;
    reg [47:0]              r_src_mac;
    reg [15:0]              r_ether_type;
    reg [7:0]               r_payload;    // min is 46 octets and max is 1500 octets
    reg [31:0]              r_fcs;        // frame check sequence
    reg [95:0]              r_igp;        // inter packet gap
    reg [3:0]               r_stage;
    reg [7:0]               r_data;
    reg [11:0]              r_offset;

    `define IDLE            4'd0
    `define PREAMBLE        4'd1
    `define SFD             4'd2
    `define MACDEST         4'd3
    `define MACSRC          4'd4
    `define ETHERTYPE       4'd5
    `define PAYLOAD         4'd6
    `define FCS             4'd7
    `define IPG             4'd8

    initial begin
        r_stage = `IDLE;
        r_offset = 12'd0;
    end

    assign out_txen = r_txen;
    assign out_txd = r_txd;

    always @(posedge in_rxc) begin
        if (in_crs) begin
            if (r_stage == `IDLE)
                r_stage = `PREAMBLE;

            case (r_stage)
                `IDLE: begin
                    r_txen = 1'b0;
                    r_offset = 12'd0;
                end

                `PREAMBLE: begin
                    r_txen = 1'b0;
                    r_preamble[(6-r_offset)*8 +: 8] = in_rxd;
                    r_offset += 12'd1;
                    if (r_offset == 12'd7) begin
                        if (r_preamble != 56'b10101010_10101010_10101010_10101010_10101010_10101010_10101010)
                            #10000 $finish;
                        r_offset = 12'd0;
                        r_stage = `SFD;
                    end
                end

                `SFD: begin
                    r_txen = 1'b0;
                    r_sfd = in_rxd;
                    r_offset += 12'd1;
                    if (r_offset == 1) begin
                        r_offset = 12'd0;
                        r_stage = `MACDEST;
                    end
                end

                `MACDEST: begin
                    r_txen = 1'b0;
                    r_dest_mac[(5-r_offset)*8 +: 8] = in_rxd;
                    r_offset += 12'd1;
                    if (r_offset == 12'd6) begin
                        r_offset = 12'd0;
                        r_stage = `MACSRC;
                    end
                end

                `MACSRC: begin
                    r_txen = 1'b0;
                    r_src_mac[(5-r_offset)*8 +: 8] = in_rxd;
                    r_offset += 12'd1;
                    if (r_offset == 12'd6) begin
                        r_offset = 12'd0;
                        r_stage = `ETHERTYPE;
                    end
                end

                `ETHERTYPE: begin
                    r_txen = 1'b0;
                    r_ether_type[(1-r_offset)*8 +: 8] = in_rxd;
                    r_offset += 12'd1;
                    if (r_offset == 12'd2) begin
                        r_offset = 12'd0;
                        r_stage = `PAYLOAD;
                    end
                end

                `PAYLOAD: begin
                    r_txen = 1'b1;
                    r_txd = in_rxd;
                end

                `IPG: begin
                    $display("should never be here");
                    $finish;
                end
            endcase
        end else begin
            r_stage = `IDLE;
            r_offset = 12'd0;
        end
    end

endmodule
