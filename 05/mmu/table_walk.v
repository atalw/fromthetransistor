`include "mcu.v"
// 2 level fetch
// Table walk hardware talks to the Memory control unit (MCU) which itself
// talks to DRAM to access the page tables stored in memory.
module table_walk(
    input   wire        in_clk,         // from MMU
    input   wire        in_en,          // from MMU
    input   wire [13:0] in_mva,         // from MMU
    output  wire [13:0] out_paddr,      // to MMU

    input   wire [31:0] in_mcu_data,    // from MCU
    output  wire        out_mcu_ren,    // to MCU
    output  wire [13:0] out_mcu_addr,   // to MCU
    output  wire [1:0]  out_mcu_size,   // to MCU
    );

    // Hardcoded Translation table base address
    reg [13:0]  r_ttb_addr = 14'd0;

    reg [13:0]  r_paddr;
    reg         r_mcu_ren;
    reg [13:0]  r_mcu_addr;
    reg [1:0]   r_mcu_size;
    reg [13:0]  r_l1d; // Level one descriptor
    reg [13:0]  r_l2d; // Level one descriptor

    reg [1:0]   r_stage = 2'd0;

    mcu mcu(
        .in_dram_en(out_mcu_ren),
        .in_dram_addr(out_mcu_addr),
        .in_dram_size(out_mcu_size),
        .out_mcu_data(in_mcu_data),
        .in_dram_data(),
        .out_dram_en(),
        .out_dram_addr(),
        .out_dram_size(),
    );

    assign out_mcu_ren = r_mcu_ren;
    assign out_mcu_addr = r_mcu_addr;
    assign out_mcu_size = r_mcu_size;
    assign out_paddr = r_paddr;

    always @(posedge in_clk) begin
        if (in_en) begin
            case (r_stage):
                // Translation table stage
                2'b00: begin
                    // Enable ram read for the TTB
                    r_mcu_ren <= 1
                    r_mcu_addr <= r_ttb_addr;
                    r_mcu_size <= 2'b10; // word length

                    if (in_mcu_data) begin
                        r_l1d = {in_mcu_data[13:6], in_mva[13:9], 2'b00};
                        r_stage = 2'b01;
                    end
                end

                // Page table stage
                2'b01: begin
                    r_mcu_ren <= 1
                    r_mcu_addr <= r_l1d;
                    r_mcu_size <= 2'b10; // word length
                    if (in_mcu_data) begin
                        // TODO: domain/permission check
                        r_l2d = {in_mcu_data[13:6], in_mva[8:5], 2'b00};
                        r_stage = 2'b10;
                    end

                end

                // Page stage
                2'b10: begin
                    r_mcu_ren <= 1
                    r_mcu_addr <= r_l2d;
                    r_mcu_size <= 2'b10; // word length
                    if (in_mcu_data) begin
                        r_paddr = {in_mcu_data[13:5], in_mva[4:0]};
                        r_stage = 2'b11;
                    end
                end

                // Reset
                2'b11: begin
                    r_mcu <= 0;
                    r_mcu_addr <= 0;
                    r_mcu_size <= 0;
                    r_stage <= 0;
                end
            endcase
        end
    end
endmodule
