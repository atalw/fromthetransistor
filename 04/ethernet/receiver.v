module receiver(
    input           in_clk,
    input           in_txen,    // transmit enable
    input [7:0]     in_txd,     // transmit data

    output          out_rxc,    // receive clock
    output          out_rxdv,   // receive data valid
    output [7:0]    out_rxd,    // receive data
    output          out_rxer,   // receive error
    );


    reg [55:0]              r_preamble;
    reg [7:0]               r_sfd;        // start frame delimiter
    reg [47:0]              r_dest_mac;
    reg [47:0]              r_src_mac;
    reg [15:0]              r_ether_type;
    reg [1500*8-1:0]        r_payload;    // min is 46 octets and max is 1500 octets
    reg [31:0]              r_fcs;        // frame check sequence
    reg [95:0]              r_igp;        // inter packet gap
    reg [3:0]               r_stage;
    reg [7:0]               r_data;
    reg [11:0]              r_offset;

    `define PREAMBLE        4'd1
    `define SFD             4'd2
    `define MACDEST         4'd3
    `define MACSRC          4'd4
    `define ETHERTYPE       4'd5
    `define PAYLOAD         4'd6
    `define FCS             4'd7
    `define IGP             4'd8

    initial begin
        r_stage = 4'd0;
        r_offset = 12'd0;
    end


    always @(posedge in_clk) begin
        if (in_txen) begin
            if (r_stage == 4'd0)
                r_stage = `PREAMBLE;

            case (r_stage)
                `PREAMBLE: begin
                    r_preamble[(7-offset)*8 +: 8] = in_txd;
                    offset += 12'd1;
                    if (offset == 12'd8) begin
                        if (r_preamble != 56'b10101010_10101010_10101010_10101010_10101010_10101010_10101010)
                            $finish;
                        offset = 12'd0;
                        r_stage = `SFD;
                    end
                end

                `SFD: begin
                    r_sfd = in_txd;
                    offset += 12'd1;
                    if (offset == 1) begin
                        offset = 12'd0;
                        r_stage = `MACDEST;
                    end
                end

                `MACDEST: begin
                    r_dest_mac[(5-offset)*8 +: 8] = in_txd;
                    offset += 12'd1;
                    if (offset == 12'd6) begin
                        offset = 12'd0;
                        r_stage = `MACSRC;
                    end
                end

                `MACSRC: begin
                    r_src_mac[(5-offset)*8 +: 8] = in_txd;
                    offset += 12'd1;
                    if (offset == 12'd6) begin
                        offset = 12'd0;
                        r_stage = `ETHERTYPE;
                    end
                end

                `ETHERTYPE: begin
                    r_ether_type[(1-offset)*8 +: 8] = in_txd;
                    offset += 12'd1;
                    if (offset == 12'd2) begin
                        offset = 12'd0;
                        r_stage = `PAYLOAD;
                    end
                end

                `PAYLOAD: begin
                end

                `IGP: begin
                end

            endcase

        end else begin
            r_stage = 4'd0;
            r_offset = 12'd0;
        end
    end

endmodule
