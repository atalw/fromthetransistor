// Performs parallel-to-serial conversion of data received from the MII and
// transmits it. An ethernet header and an ethernet frame is received in
// parallel, which is then combined to transmitted in a serial manner.
module transmitter(
    input                   in_clk,
    input [47:0]            in_dest_mac,
    input [47:0]            in_src_mac,
    input [15:0]            in_ether_type,
    input [7:0]             in_eth_frame, // Payload + FCS
    input                   in_frame_en,  // data enable

    output                  out_txen,
    output [7:0]            out_txd
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

    `define PREAMBLE        4'd1
    `define SFD             4'd2
    `define MACDEST         4'd3
    `define MACSRC          4'd4
    `define ETHERTYPE       4'd5
    `define PAYLOAD         4'd6
    `define FCS             4'd7
    `define IGP             4'd8

    assign out_txen = r_txen;
    assign out_txd = r_txd;

    initial begin
        r_txen = 0;
        r_preamble <= 56'b10101010_10101010_10101010_10101010_10101010_10101010_10101010;
        r_sfd <= 8'b10101011;
        r_igp <= 96'd0;
        r_stage <= 4'd0;
    end

    always @(in_dest_mac or in_src_mac or in_ether_type or in_eth_frame) begin
        r_dest_mac = in_dest_mac;
        r_src_mac = in_src_mac;
        r_ether_type = in_ether_type;
        // r_eth_frame = in_eth_frame;

        if (r_dest_mac && r_src_mac && in_ether_type && in_eth_frame && ~out_txen) begin
            r_stage = 4'd1;
        end

        case (r_stage)
            `PREAMBLE: begin
                r_txen = 1;
                r_data = r_preamble[6*8 +: 8];
                r_data = r_preamble[5*8 +: 8];
                r_data = r_preamble[4*8 +: 8];
                r_data = r_preamble[3*8 +: 8];
                r_data = r_preamble[2*8 +: 8];
                r_data = r_preamble[1*8 +: 8];
                r_data = r_preamble[0*8 +: 8];
                r_stage = `SFD;
            end

            `SFD: begin
                r_data = r_sfd;
                r_stage = `MACDEST;
            end

            `MACDEST: begin
                r_data = r_dest_mac[5*8 +: 8];
                r_data = r_dest_mac[4*8 +: 8];
                r_data = r_dest_mac[3*8 +: 8];
                r_data = r_dest_mac[2*8 +: 8];
                r_data = r_dest_mac[1*8 +: 8];
                r_data = r_dest_mac[0*8 +: 8];
                r_stage = `MACSRC;
            end

            `MACSRC: begin
                r_data = r_src_mac[5*8 +: 8];
                r_data = r_src_mac[4*8 +: 8];
                r_data = r_src_mac[3*8 +: 8];
                r_data = r_src_mac[2*8 +: 8];
                r_data = r_src_mac[1*8 +: 8];
                r_data = r_src_mac[0*8 +: 8];
                r_stage = `ETHERTYPE;
            end

            `ETHERTYPE: begin
                r_data = r_ether_type[1*8 +: 8];
                r_data = r_ether_type[0*8 +: 8];
                r_stage = `PAYLOAD;
            end

            `PAYLOAD: begin
                if (in_frame_en) begin
                    r_data = in_eth_frame;
                end else begin
                    r_stage = `IGP;
                end
            end

            `IGP: begin
                r_data = r_igp[11*8 +: 8];
                r_data = r_igp[10*8 +: 8];
                r_data = r_igp[9*8 +: 8];
                r_data = r_igp[7*8 +: 8];
                r_data = r_igp[6*8 +: 8];
                r_data = r_igp[5*8 +: 8];
                r_data = r_igp[4*8 +: 8];
                r_data = r_igp[3*8 +: 8];
                r_data = r_igp[2*8 +: 8];
                r_data = r_igp[1*8 +: 8];
                r_data = r_igp[0*8 +: 8];
                r_data = 8'd0;
                r_txen = 0;
            end
        endcase
    end

    always @(posedge in_clk) begin
        r_txd <= r_data;
    end

endmodule
