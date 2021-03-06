// In ARM9, CPU gives MMU a Modified virtual address (MVA).
// Table Index = TI
//
// ARM9 version MVA (32-bit addresses)
// ============
// If VA[31:25] == 0,
//      MVA = 7 bits PID + 25 bit address, for fast context switching
//      = 128 processes + 32MB addressable space = 4GB total VM
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
// TTE provides base address for 256 PTEs = 1MB split into 4kB blocks
// 4 byte Translation table entry (TTE) and 4 byte Page table entry (PTE)
//
// This means 32 tables per process.
//
// Our version MVA (14 bit addresses)
// ===========
// If VA[13:11] == 0
//      MVA = 3 bits PID + 11 bit address, for fast context switching
//      = 8 processes + 2kb addressable space = 16kB total VM
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
// TTE provides base address to 16 PTEs = 512 bytes split into 32 byte blocks
// 14-bit Translation table entry (TTE) and 14-bit Page table entry (PTE)
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
    input   wire        in_clk,
    input   wire        in_ren,
    input   wire [13:0] in_mva,
    output  wire        out_err,
    output  wire [13:0] out_paddr
    );

    // L1 cache that maps virtual page numbers to physical page numbers
    // Contains complete page table entries for N pages
    reg [13:0] cache [7:0];

    reg [13:0] r_paddr;
    reg r_err; // page fault

    assign out_paddr = r_paddr;

    always @(posedge in_clk) begin
        if (in_ren) begin
            // check cache in parallel for mva

        end else begin
            r_paddr <= 0;
            r_err <= 0;
        end
    end
endmodule
