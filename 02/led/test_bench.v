`timescale 1ns/100ps
module blinking_led;
    input wire out_clock;
    output reg clock;

    blinking bl(clock, out_clock);

    initial
        clock = 1'b0;

    always
        #10 clock = ~clock;

    initial
    begin
        $monitor($time, " clock = %b, out_clock = %b", clock, out_clock);
        #100 $finish;
    end

    initial
    begin
        $dumpfile("blinking.vcd");
        $dumpvars;
    end
endmodule
