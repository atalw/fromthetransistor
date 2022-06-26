`include "eth_controller.v"

module tb;
    wire          in_txen;      // mcu/cpu transmit enable
    wire [7:0]    in_txd;       // mcu/cpu transmit data
    wire          in_rxen;      // wire receive enable
    wire [7:0]    in_rxd;       // wire receive data
    wire          out_tx_ready; // mcu/cpu transmit ready (1 after preamble etc has been sent)
    wire          out_wire_txen;// phy to wire transmit enable
    wire [7:0]    out_wire_txd; // phy to wire transmit data
    wire          out_dll_rxen; // mac to data-link layer receive enable
    wire [7:0]    out_dll_rxd;  // mac to data-link layer receive data

    reg clock;
    reg [23:0] r_offset;
    reg r_txen;
    reg [7:0] r_txd;
    reg r_rxen;
    reg [7:0] r_rxd;
    reg [159:0] r_input_data;

    assign in_txen = r_txen;
    assign in_txd = r_txd;
    assign in_rxen = r_rxen;
    assign in_rxd = r_rxd;

    eth_controller eth_controller(
        .in_txen(in_txen),
        .in_txd(in_txd),
        .in_rxen(in_rxen),
        .in_rxd(in_rxd),
        .out_tx_ready(out_tx_ready),
        .out_dll_rxen(out_dll_rxen),
        .out_dll_rxd(out_dll_rxd),
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
        r_txen = 1;
        r_rxen = 0;
    end

    always begin
        #10 clock = ~clock;
    end

    always @(posedge clock) begin
        if (r_txen && out_tx_ready) begin
            r_txd = r_input_data[(19-r_offset) * 8 +: 8];
            r_offset += 1;
            $display("Packet from link layer is %h", r_txd);
            if (r_offset >= 9) begin
                r_offset = 0;
                r_txen <= 0;
            end
        end else begin
            if (~r_txen && ~r_rxen) begin
                #100 r_rxen = 1;
            end
        end
    end

    always @(posedge clock) begin
        if (in_rxen) begin
            r_rxd = r_input_data[(9-r_offset) * 8 +: 8];
            r_offset += 1;
            $display("Packet from wire is %h", r_rxd);
            if (r_offset >= 9)
                #100 r_rxen = 0;
        end else begin
            if (~r_txen && r_offset >= 9)
                #100 $finish;
        end
    end

endmodule
