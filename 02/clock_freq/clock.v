module freq_div_by2 (clock, reset, out_clock);
    input clock;
    input reset;
    output reg out_clock;

    always @(posedge clock)
    begin
        if (~reset)
            out_clock <= 1'b0;
        else
            out_clock <= ~out_clock;
    end

endmodule
