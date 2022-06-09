// A UART transmitter and receiver built with a 50MHz clock which sends a byte
// of data asynchronously.
// https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter

`timescale 1ns/1ps
module uart_test_bench;

    // 50Mhz clock
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD = 9600; // bits per second
    // CLOCKS_PER_BIT = CLOCK_FREQ / UART Freq
    parameter CLOCKS_PER_BIT = CLOCK_FREQ / (16 * BAUD); 

    reg r_clock;
    reg r_tx_bit;
    reg [7:0] r_tx_byte;
    wire serial;
    wire r_tx_done;
    wire [7:0] w_rx_byte;

    transmitter #(.CLOCKS_PER_BIT(CLOCKS_PER_BIT)) tx (
        .clock(r_clock),
        .tx_bit(r_tx_bit),
        .tx_data_byte(r_tx_byte),
        .serial(serial),
        .tx_done(r_tx_done)
    );
    receiver #(.CLOCKS_PER_BIT(CLOCKS_PER_BIT)) rx (
        .clock(r_clock),
        .serial(serial),
        .w_rx_byte(w_rx_byte)
    );

    initial
    begin
        r_clock = 0;
    end

    always
        #(CLOCK_FREQ/2) r_clock = ~r_clock;

    initial
    begin
        $dumpfile("uart.vcd");
        $dumpvars;
    end

    initial
    begin
        #1;
        // Test transmitter
        @(posedge r_clock);
        @(posedge r_clock);
        r_tx_bit <= 1'b1; // idle active bit
        r_tx_byte <= 8'hAB; // data
        @(posedge r_clock);
        r_tx_bit <= 1'b0; // stop bit
        @(posedge r_tx_done);
        $display("Transmitter sent \"%h\".", 8'hAB);

        // Test receiver
        if (w_rx_byte == 8'hAB)
            $display("Test passed! Received \"%h\"", w_rx_byte);
        else
            $display("Test failed! Received \"%h\"", w_rx_byte);

        $finish;
    end
endmodule
