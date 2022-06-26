`include "eth_controller.v"

module tb;
    wire          in_txen;      // mcu/cpu transmit enable
    wire [7:0]    in_txd;       // mcu/cpu transmit data
    wire          in_rxen;      // wire receive enable
    wire [7:0]    in_rxd;       // wire receive data
    wire          out_tx_ready; // mcu/cpu transmit ready (1 after preamble etc has been sent)
    wire          out_wire_txen;// phy to wire transmit enable
    wire [7:0]    out_wire_txd; // phy to wire transmit data

    reg clock;
    reg [23:0] r_offset;
    reg r_txen;
    reg [7:0] r_txd;
    reg [159:0] r_input_data;

    assign in_txen = r_txen;
    assign in_txd = r_txd;

    eth_controller eth_controller(
        .in_txen(in_txen),
        .in_txd(in_txd),
        .in_rxen(in_rxen),
        .in_rxd(in_rxd),
        .out_tx_ready(out_tx_ready),
        .out_wire_txen(out_wire_txen),
        .out_wire_txd(out_wire_txd)
    );

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;
    end

    initial begin
        clock = 0;
        r_offset = 0;
        r_txen = 0;
        r_input_data = 160'h00_01_02_03_04_05_06_07_08_09_0a_0b_0c_0d_0e_0f_10_11_12_13;
    end

    always begin
        #10 clock = ~clock;
    end

    always @(posedge clock) begin
        r_txen = 1;
        if (out_tx_ready) begin
            r_txd = r_input_data[(19-r_offset) * 8 +: 8];
            r_offset += 1;

            $display("Packet is %h", r_txd);

            if (r_offset >= 9)
                $finish;

        end else begin
            // r_txen = 0;
        end
    end

endmodule
