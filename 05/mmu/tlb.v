`include "table_walk.v"
// In ARM9, CPU gives MMU a Modified virtual address (MVA).
// Table Index = TI
//
// ARM9 version MVA
// ============
// If VA[31:25] == 0,
//      MVA = 7 bits PID + 25 bit address, for fast context switching
//      128 processes + 32MB addressable space = 4GB total VM
//      Virtual Addresses available to each process = 0x00000000 -> 0x01ffffff
//      Virtual address actually used: (PID*32MB) -> (PID*32MB+0x01ffffff)
// Else, MVA is:
// | L1 TI   |   L2 TI    |  Page index
// --------------------------------------
// 31       20 19       12 11           0
// 
// L1 TI = [31:20] = 12 bits = 4096 translation tables
// L2 TI = [19:12] = 8 bits = 256 page table entries
// Page index = [11:0] = 12 bits = 4096 subpages per page table
// The translation table has up to 4096 x 32-bit entries, each describing
// 1MB of virtual memory. This allows up to 4GB of virtual memory to be addressed.
// This means 32 tables per process.
//
// Our version MVA
// ===========
// If VA[13:11] == 0
//      MVA = 3 bits PID + 11 bit address, for fast context switching
//      8 processes + 2kb addressable space = 16kB total VM
//      Virtual Addresses available to each process = 0x0000 -> 0x0800
//      Virtual address actually used: (PID*2kB) -> (PID*2kB+0x0800)
// Else, MVA is:
// |  L1 TI  | L2 TI | Page index
// ------------------------------
// 13       9 8     5 4         0
//
// L1 TI = [13:9] = 5 bits = 32 translation tables
// L2 TI = [8:5] = 4 bits = 16 page tables
// Page index = [4:0] = 5 bits = 32 bytes per page table
// The translation table (L1) has up to 32 32-bit entries, each describing
// 512 bytes of virtual memory. This allows up to 16kB of virtual memory to be addressed.
// This means, 4 tables per process.
//
// Example, (make sure to zero index)
// 4th proc, addr 0x200 = 01101 0000 00000 (13th table, 0th page, 0 offset)
// 4th proc, addr 0x700 = 01111 1000 00000 (15th table, 8th page, 0 offset)
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
//
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

endmodule
