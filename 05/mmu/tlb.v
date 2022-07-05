`include "table_walk.v"
// In ARM9, CPU gives MMU a Modified virtual address (MVA).
// MVA = Page table index(31:20) + Section index(19:0)
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
    input wire in_en,
    input wire in_mva,
    output wire out_paddr,
    );

    reg [31:0] cache[7:0];

    // Table walk
    table_walk table_walk();

    initial begin
        cache[0] = 0;
        cache[1] = 0;
        cache[2] = 0;
        cache[3] = 0;
        cache[4] = 0;
        cache[5] = 0;
        cache[6] = 0;
        cache[7] = 0;
    end


endmodule
