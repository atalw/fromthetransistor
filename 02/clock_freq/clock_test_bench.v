`timescale 1ns/100ps
module freq_div;
    input wire out_clock;
    output reg clock;
    output reg reset;

    freq_div_by2 freq1(clock, reset, out_clock);

    initial
        clock <= 1'b0;

    always
        #10 clock <= ~clock;

    initial
    begin
        $monitor($time, "clock = %b, reset = %b, out_clock = %b", clock, reset, out_clock);
        reset = 0;
        #20 reset = 1;
        #100 $finish;
    end

    initial
    begin
        $dumpfile("freq_div.vcd");
        $dumpvars(0, freq_div);
    end
endmodule
