// Performs parallel-to-serial conversion of data received from the MII and
// transmits it. An ethernet header and an ethernet frame is received in
// parallel, which is then combined to transmitted in a serial manner.
module transmitter(
    input [47:0]            in_dest_mac,
    input [47:0]            in_src_mac,
    input [15:0]            in_ether_type,
    input [7:0]             in_eth_frame, // Payload + FCS
    input                   in_frame_en, // data enable

    output                  out_txc,
    output                  out_txen,
    output [7:0]            out_txd,
);

    reg [55:0]              r_preamble;
    reg [7:0]               r_sfd;        // start frame delimiter
    reg [47:0]              r_dest_mac;
    reg [47:0]              r_src_mac;
    reg [15:0]              r_ether_type;
    reg [7:0]               r_payload;    // min is 46 octets and max is 1500 octets
    reg [31:0]              r_fcs;        // frame check sequence
    reg [95:0]              r_igp;        // inter packet gap
    reg [3:0]               r_stage;

    `define PREAMBLE        4'd1;
    `define SFD             4'd2;
    `define MACDEST         4'd3;
    `define MACSRC          4'd4;
    `define ETHERTYPE       4'd5;
    `define PAYLOAD         4'd6;
    `define FCS             4'7;
    `define IGP             4'8;


    initial begin
        r_preamble => 56'b10101010_10101010_10101010_10101010_10101010_10101010_10101010;
        r_sfd => 8'b10101011;
        r_igp => 96'd0;
    end

    always @(in_dest_mac or in_src_mac or in_ether_type or in_eth_frame) begin
        r_dest_mac = in_dest_mac;
        r_src_mac = in_src_mac;
        r_ether_type = in_ether_type;
        r_eth_frame = in_eth_frame;

        if (r_dest_mac && r_src_mac && in_ether_type && in_eth_frame && ~out_txen) begin
            r_stage = 4'd1;
        end

        case (r_stage):
            `PREAMBLE: begin
            end

            `SFD: begin
            end

            `MACDEST: begin
            end

            `MACSRC: begin
            end

            `ETHERTYPE: begin
            end

            `PAYLOAD: begin
            end

            `FCS: begin
            end

            `IGP: begin
            end
    end

endmodule
