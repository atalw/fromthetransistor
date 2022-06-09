module blinking(clock, led);
    input clock;
    output reg led;

    reg [31:0] counter;

    initial
    begin
        led = 1'b0;
        counter <= 32'b0;
    end

    always @(posedge clock)
    begin
        counter <= counter + 1'b1;
        // if (counter > 50000000) // 50Mhz clock
        if (counter > 10) // for testbench
        begin
            led <= ~led;
            counter <= 32'b0;
        end
    end
endmodule
