`include "tlb.v"
// The MMU translates VAs generated by the CPU core, and by CP15 register 13 (not implemented),
// into physical addresses to access external memory.
// It also derives and checks the access permission, using a TLB. (not implemented)
// The MMU table walking hardware is used to add entries to the TLB. The translation information,
// that comprises both the address translation data and the access permission data, resides in a
// translation table located in physical memory. The MMU provides the logic for you to traverse this
// translation table and load entries into the TLB.
//
// In ARM9, CPU gives MMU a Modified virtual address (MVA).
// MVA = Page table index(31:20) + Section index(19:0)
//
// ARM9 spec uses 32-bit addresses but that means we'll have to create
// a memory region of 2^32/32(word width) bytes. That's HUGE, so in the
// interest of dev, we'll only support 14-bit addresses = 16kB memory.
module mmu(
    input   wire        in_clk,
    input   wire        in_en,
    input   wire [13:0] in_mva,
    input   wire [13:0] in_tlb_paddr, // output of the tlb
    output  wire [13:0] out_tlb_mva, // input to the tlb
    output  wire [13:0] out_paddr
    );

    wire out_tlb_en;

    tlb tlb(out_tlb_en, out_tlb_mva, out_paddr);
endmodule