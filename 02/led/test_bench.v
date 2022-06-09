`timescale 10ms/1ms
module blinking_led;
    input wire led;
    output reg clock;

    blinking bl(clock, led);

    initial
        clock = 1'b0;

    always
        #10 clock <= ~clock;

    initial
    begin
        $monitor($time, " clock = %b, led = %b", clock, led);
        #1000 $finish;
    end

    initial
    begin
        $dumpfile("blinking.vcd");
        $dumpvars;
    end
endmodule
