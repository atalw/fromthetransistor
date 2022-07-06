`include "table_walk.v"
// In ARM9, CPU gives MMU a Modified virtual address (MVA).
// MVA = Page table index(31:20) + Section index(19:0)
//
// Table Index = TI
//
// ARM9 version MVA
// ============
// | L1 TI   |   L2 TI    |  Page index
// --------------------------------------
// 31       20 19       12 11           0
// 
// L1 TI = [31:20] = 12 bits = 4096 translation tables
// L2 TI = [19:12] = 8 bits = 256 page table entries
// Page index = [11:0] = 12 bits = 4096 addresses per page table
// Multiply all of these and we get 4GB addressable space.
//
// Our version MVA
// ===========
// |  L1 TI  | L2 TI | Page index
// ------------------------------
// 13       9 8     5 4         0
//
// L1 TI = [13:9] = 5 bits = 32 translation tables
// L2 TI = [8:5] = 4 bits = 16 page tables
// Page index = [4:0] = 5 bits = 32 addresses per page table
// Multiply all of these and we get 16kB addressable space.
//
// Level one descriptor = TTB[31:14] + Table index[31:20] + (bit 1 and 0 set to 0)
// Level two descriptor (L2D) = Section/table base address + section/table index
//      - MVA if it ends with
//          - 00 -> invalid
//          - 10 -> section (not implemented)
//          - 01 -> coarse page table -> read VA[19:12]
//              - 00 -> invalid
//              - 01 -> 64kb subpage -> read VA[15:0]
//              - 10 -> 4kb subpage -> read VA[11:0]
//              - 11 -> invalid
//          - 11 -> fine page table -> read VA[19:10]
//              - 00 -> invalid
//              - 01 -> 64kb subpage
//              - 10 -> 4kb subpage
//              - 11 -> 1kb subpage -> read VA[9:0]
module tlb(
    input wire in_clk,
    input wire in_en,
    input wire [13:0] in_mva,
    input wire [31:0] in_ram_data,
    output wire         out_ram_ren,
    output wire [13:0] out_ram_addr,
    output wire [1:0] out_ram_size,
    output wire [13:0] out_paddr,
    output wire out_walk_en,
    );

    reg [31:0] cache[7:0];

    reg [13:0] r_out_ram_addr;
    reg [1:0] r_out_ram_size;

    reg [13:0] r_l1d; // Level one descriptor
    reg [13:0] r_l2d; // Level one descriptor

    // After l1d, we get a page table desc which we convert to l2d
    reg [13:0] r_page_table_desc;

    ram ram(
        .in_clk(in_clk),
        .in_ren(out_ram_ren),
        .in_addr(out_ram_addr),
        .in_write(), 
        .in_wdata(),
        .in_size(out_ram_size),
        .out_rdata(in_ram_data)
    );


    // Table walk
    table_walk table_walk();

    initial begin
        // Hardcoding memory index 3 as TTB register.
        r_out_ram_addr = 14'd3;
        r_out_ram_size = 2'b10;

    end

    assign out_ram_ren = r_out_ram_ren;
    assign out_ram_addr = r_out_ram_addr;
    assign out_ram_size = r_out_ram_size;

    always @(posedge in_clk) begin
        if (in_en) begin
            // Enable ram read for the TTB
            r_out_ram_ren <= 1
            // if we've got the TTB, do the first level descriptor fetch
            if (in_ram_data && ~r_l1d) begin
                // r_l1d = {in_ram_data[31:14], in_mva[31:20], 2'b00};
                r_l1d = {in_ram_data[13:6], in_mva[13:9], 2'b01};
                r_out_ram_addr = r_l1d;
            end 
            // after first level fetch, do second level fetch
            else if (in_ram_data && r_l1d && ~rl2d) begin
                r_page_table_desc = in_ram_data;
                r_l2d = {r_page_table_desc[13:5],in_mva[5:3], 2'b01};
            end
        end else begin
            r_out_ram_ren <= 0
        end
    end


endmodule
