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

    reg           clock;
    reg           mac_tx_clock;
    reg [23:0]    r_offset;
    reg           r_txen;
    reg [7:0]     r_txd;
    reg [159:0]   r_input_data;

    wire          w_rx_ready;
    wire          w_rxen;
    wire [7:0]    w_rxd;

    reg           r_dll_en = 0;
    reg [7:0]     r_dll_d = 0;

    assign in_txen = r_txen;
    assign in_txd = r_txd;
    assign in_rxen = w_rxen;
    assign in_rxd = w_rxd;

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
        mac_tx_clock = 0;
        r_offset = 0;
        r_txen = 0;
        r_input_data = 160'h00_01_02_03_04_05_06_07_08_09_0a_0b_0c_0d_0e_0f_10_11_12_13;
        r_txen = 1;
        $display("--------------------------------------------------------");
        $display("Testing Wire to DLL (i.e eth_controller receive)");
        $display("--------------------------------------------------------");
    end

    always begin
        #10 clock = ~clock;
        #10 mac_tx_clock = ~mac_tx_clock;
    end

    always @(posedge clock) begin
        if (r_txen && out_tx_ready) begin
            r_txd = r_input_data[(19-r_offset) * 8 +: 8];
            r_offset += 1;
            $display("Sending %h from wire to link layer", r_txd);
            if (r_offset >= 9) begin
                r_offset = 0;
                r_txen <= 0;
            end
        end else begin
            if (~r_txen && ~w_rxen && ~r_dll_en && r_offset < 9) begin
                #100 r_dll_en = 1;
                $display("--------------------------------------------------------");
                $display("Testing DLL to Wire now (i.e eth_controller transmit)");
                $display("--------------------------------------------------------");
            end
        end
    end

    // Simulate external Data link layer to MAC connection and transmit data
    // through wire.
    mac_tx mac_tx(mac_tx_clock, r_dll_en, r_dll_d, w_rx_ready, w_rxen, w_rxd);

    always @(posedge clock) begin
        if (r_dll_en && w_rx_ready) begin
            r_dll_d = r_input_data[(9-r_offset) * 8 +: 8];
            r_offset += 1;
            // At this point, the preamble and other headers have been sent
            // and parsed by mac_rx. These packets are the actual payload.
            $display("Sending %h from DLL to wire", r_dll_d);
            if (r_offset >= 9)
                #100 r_dll_en = 0;
        end else begin
            if (~r_txen && r_offset >= 9)
                #1000 $finish;
        end
    end

    always @(out_wire_txd) begin
        if (out_wire_txen)
            $display("<=== DLL received packet: %h <===", out_wire_txd);
    end

    always @(out_dll_rxd) begin
        if (out_dll_rxen)
            $display("===> Wire received: %h ===>", out_dll_rxd);
    end

endmodule
