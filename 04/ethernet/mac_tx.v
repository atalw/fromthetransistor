// Receives payload data from higher layers of the OSI model. Packages it into
// an ethernet frame and transmits it to the MII which then passes it on to
// the PHY.
module mac_tx(
    input                   in_clk,
    input                   in_txen,
    input [7:0]             in_txd,
    output                  out_tx_ready,   // tell the higher layer to send or stop sending data
    output                  out_txen,
    output [7:0]            out_txd
);

    reg                     r_tx_ready;     // 1 when we're sending payload, 0 in all other cases
    reg                     r_txen;
    reg [7:0]               r_txd;
    reg [55:0]              r_preamble;
    reg [7:0]               r_sfd;        // start frame delimiter
    reg [47:0]              r_dest_mac;
    reg [47:0]              r_src_mac;
    reg [15:0]              r_ether_type;
    reg [7:0]               r_payload;    // min is 46 octets and max is 1500 octets
    reg [31:0]              r_fcs;        // frame check sequence
    reg [95:0]              r_ipg;        // inter packet gap
    reg [3:0]               r_stage;
    reg [7:0]               r_data;

    `define IDLE            4'd0
    `define PREAMBLE        4'd1
    `define SFD             4'd2
    `define MACDEST         4'd3
    `define MACSRC          4'd4
    `define ETHERTYPE       4'd5
    `define PAYLOAD         4'd6
    `define FCS             4'd7
    `define IPG             4'd8

    assing out_tx_ready = r_tx_ready;
    assign out_txen = r_txen;
    assign out_txd = r_txd;

    initial begin
        r_txen = 0;
        r_tx_ready = 1;
        r_dest_mac <= 48'd0; // TODO
        r_src_mac <= 48'd0; // TODO
        r_ether_type <= 16'd0; // TODO
        r_preamble <= 56'b10101010_10101010_10101010_10101010_10101010_10101010_10101010;
        r_sfd <= 8'b10101011;
        r_ipg <= 96'd0;
        r_stage <= 4'd0;
    end

    always @(posedge in_clk) begin
        if (in_txen) begin
            if (r_stage == `IDLE)
                r_stage = `PREAMBLE;

            case (r_stage)
                `PREAMBLE: begin
                    r_txen = 1;
                    r_tx_ready = 0;
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
                    r_txen = 1;
                    r_tx_ready = 0;
                    r_data = r_sfd;
                    r_stage = `MACDEST;
                end

                `MACDEST: begin
                    r_txen = 1;
                    r_tx_ready = 0;
                    r_data = r_dest_mac[5*8 +: 8];
                    r_data = r_dest_mac[4*8 +: 8];
                    r_data = r_dest_mac[3*8 +: 8];
                    r_data = r_dest_mac[2*8 +: 8];
                    r_data = r_dest_mac[1*8 +: 8];
                    r_data = r_dest_mac[0*8 +: 8];
                    r_stage = `MACSRC;
                end

                `MACSRC: begin
                    r_txen = 1;
                    r_tx_ready = 0;
                    r_data = r_src_mac[5*8 +: 8];
                    r_data = r_src_mac[4*8 +: 8];
                    r_data = r_src_mac[3*8 +: 8];
                    r_data = r_src_mac[2*8 +: 8];
                    r_data = r_src_mac[1*8 +: 8];
                    r_data = r_src_mac[0*8 +: 8];
                    r_stage = `ETHERTYPE;
                end

                `ETHERTYPE: begin
                    r_txen = 1;
                    r_tx_ready = 0;
                    r_data = r_ether_type[1*8 +: 8];
                    r_data = r_ether_type[0*8 +: 8];
                    r_stage = `PAYLOAD;
                end

                `PAYLOAD: begin
                    r_txen = 1;
                    r_tx_ready = 1;
                    if (in_frame_en) begin
                        r_data = in_eth_frame;
                    end else begin
                        r_stage = `IPG;
                    end
                end

                `IPG: begin
                    r_txen = 1;
                    r_tx_ready = 0;
                    r_data = r_ipg[11*8 +: 8];
                    r_data = r_ipg[10*8 +: 8];
                    r_data = r_ipg[9*8 +: 8];
                    r_data = r_ipg[7*8 +: 8];
                    r_data = r_ipg[6*8 +: 8];
                    r_data = r_ipg[5*8 +: 8];
                    r_data = r_ipg[4*8 +: 8];
                    r_data = r_ipg[3*8 +: 8];
                    r_data = r_ipg[2*8 +: 8];
                    r_data = r_ipg[1*8 +: 8];
                    r_data = r_ipg[0*8 +: 8];
                    r_data = 8'd0;
                    r_txen = 0;
                end
            endcase
        end else begin
            r_stage = `IDLE;
            r_txen = 0;
            r_tx_ready = 1;
        end

    end

    always @(posedge in_clk) begin
        r_txd <= r_data;
    end

endmodule
