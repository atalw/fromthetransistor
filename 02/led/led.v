module blinking(clock, out_clock);
    input clock;
    output reg out_clock;

    initial
        out_clock = 1'b0;

    always @(clock)
    begin
        out_clock <= clock;
    end
endmodule
