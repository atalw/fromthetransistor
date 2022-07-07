`include "dram.v"

module mcu(
    input   wire        in_dram_ren,    // from caller (eg. page-walk hardware)
    input   wire [13:0] in_dram_addr,   // from caller
    input   wire [1:0]  in_dram_size,   // from caller
    output  wire [31:0] out_mcu_data,   // to caller

    input   wire [31:0] in_dram_data,   // from DRAM
    output  wire        out_dram_ren,   // to DRAM
    output  wire [13:0] out_dram_addr,  // to DRAM
    output  wire [1:0]  out_dram_size   // to DRAM
    );

    reg clk;

    reg r_dram_ren;
    reg [13:0] r_dram_addr;
    reg [1:0] r_dram_size;
    reg [31:0] r_mcu_data;

    dram dram(
        .clock(clk),
        .in_ren(out_dram_ren),
        .in_addr(out_dram_addr),
        .in_wen(),
        .in_wdata(),
        .in_size(out_dram_size),
        .out_rdata(in_dram_data)
    );

    assign out_dram_ren = r_dram_ren;
    assign out_dram_addr = r_dram_addr;
    assign out_dram_size = r_dram_size;
    assign out_mcu_data = r_mcu_data;

    initial begin
        clk = 0;
    end

    always begin
        #10 clk = ~clk;
    end

    always @(posedge clk) begin
        if (in_dram_ren) begin
            r_dram_ren <= in_dram_ren;
            r_dram_addr <= in_dram_addr;
            r_dram_size <= in_dram_size;

            if (in_dram_data) begin
                r_mcu_data <= in_dram_data;
            end
        end else begin
            r_dram_ren <= 0;
            r_dram_addr <= 0;
            r_dram_size <= 0;
            r_mcu_data <= 0;
        end
    end
endmodule
