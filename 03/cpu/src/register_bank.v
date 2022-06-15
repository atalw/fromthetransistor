`include "Def_StructureParameter.v"

// 37 total registers
// - 31 general-purpose 32-bit registers
// - 6 status registers
//
// 16 general directly-accessible registers: r0 to r15
// - r0 to r13 hold either data or address values
// - r14 is Link Register (LR)
//      - r14 receives a copy of r15 when a Branch with Link (BL) instruction is executed.
//      At all other times you can treat r14 as a general-purpose register. The corresponding banked 
//      registers r14_svc, r14_irq, r14_fiq, r14_abt, and r14_und are similarly used to hold the 
//      return values of r15 when interrupts and exceptions arise, or when BL instructions are 
//      executed within interrupt or exception routines.
// - r15 is Program Counter (PC)
//      - In ARM state, bits [1:0] of r15 are zero. Bits [31:2] contain the PC.
//
// In privileged modes, another register, the Saved Program Status Register (SPSR), is accessible. 
// This contains the condition code flags, and the mode bits saved as a result of the exception 
// that caused entry to the current mode.
//
// 1 Current Program Status Register (CSPR) contains condition code flags and current mode bits
//
// Helpful: https://class.ece.uw.edu/469/hauck/labs/lab1.pdf


// 2 read ports and 1 write port corresponding to the ALU operations
module register_bank(clock, in_Read_address1, in_Read_address2, in_Write_address1, in_Write_data1, out_Data1, out_Data2);

    // Since reading of a register-stored value does not change the state of the register, no 
    // "safety mechanism" is needed to prevent inadvertent overwriting of stored data, and we need 
    // only supply the register number to obtain the data stored in that register.
    //
    // However, when writing to a register, we need 
    // (1) a register number, 
    // (2) an authorization bit, for safety (because the previous contents of the register selected 
    //     for writing are overwritten by the write operation), and 
    // (3) a clock pulse that controls writing of data into the register.

    // Clock input synchronizes the registers. Note that the clock and the write enable are separate 
    // signals. The clock is a pure, periodic signal with no glitches or other weird behaviors. 
    //
    // The write enable may have glitches and hazards, and thus must be moderated by the
    // clock – make sure that random transitions of the write enable, as long as they are not
    // simultaneous with the activating clock edge (positive edge), do not cause the register
    // to spuriously grab a new value. 
    input wire clock;
    input wire [3:0] in_Read_address1;
    input wire [3:0] in_Read_address2;
    input wire [3:0] in_Write_address1;
    input wire [`WordWidth-1:0] in_Write_data1;
    input wire in_Write_enable;
    // What is output reg? https://stackoverflow.com/a/5360623
    output reg [`WordWidth-1:0] out_Data1;
    output reg [`WordWidth-1:0] out_Data2;

    // Each register is simply an array of 32 D flip-flops with enables, where the D input of each 
    // D flip-flop corresponds to a single bit in the 32 bit data input bus and the Q output of each 
    // D flip-flop corresponds to the appropriate bit in the 32 bit data output bus.
    //
    // The enable of every D flip-flop is connected to the same write enable input signal.
    reg [`WordWidth-1:0] R [15:0];
    reg [`WordWidth-1:0] CSPR; // Current program status register
    reg [`WordWidth-1:0] SSPR; // Saved program status register

    initial begin
        R[0] = `WordZero;
        R[1] = `WordZero;
        R[2] = `WordZero;
        R[3] = `WordZero;
        R[4] = `WordZero;
        R[5] = `WordZero;
        R[6] = `WordZero;
        R[7] = `WordZero;
        R[8] = `WordZero;
        R[9] = `WordZero;
        R[10] = `WordZero;
        R[11] = `WordZero;
        R[12] = `WordZero;
        R[13] = `WordZero; // stack pointer
        R[14] = `WordZero; // link register
        R[15] = `WordZero; // program counter
    end

    always @(in_Read_address1) begin
        case (in_Read_address1)
            4'b0000: out_Data1 = R[0];
            4'b0001: out_Data1 = R[1];
            4'b0010: out_Data1 = R[2];
            4'b0011: out_Data1 = R[3];
            4'b0100: out_Data1 = R[4];
            4'b0101: out_Data1 = R[5];
            4'b0110: out_Data1 = R[6];
            4'b0111: out_Data1 = R[7];
            4'b1000: out_Data1 = R[8];
            4'b1001: out_Data1 = R[9];
            4'b1010: out_Data1 = R[10];
            4'b1011: out_Data1 = R[11];
            4'b1100: out_Data1 = R[12];
            4'b1101: out_Data1 = R[13];
            4'b1110: out_Data1 = R[14];
            4'b1111: out_Data1 = R[15];
        endcase
    end


    always @(in_Read_address2) begin
        case (in_Read_address1)
            4'b0000: out_Data2 = R[0];
            4'b0001: out_Data2 = R[1];
            4'b0010: out_Data2 = R[2];
            4'b0011: out_Data2 = R[3];
            4'b0100: out_Data2 = R[4];
            4'b0101: out_Data2 = R[5];
            4'b0110: out_Data2 = R[6];
            4'b0111: out_Data2 = R[7];
            4'b1000: out_Data2 = R[8];
            4'b1001: out_Data2 = R[9];
            4'b1010: out_Data2 = R[10];
            4'b1011: out_Data2 = R[11];
            4'b1100: out_Data2 = R[12];
            4'b1101: out_Data2 = R[13];
            4'b1110: out_Data2 = R[14];
            4'b1111: out_Data2 = R[15];
        endcase
    end


    always @(negedge clock) begin
        if (in_Write_enable == 1)
            R[in_Write_address1] = in_Write_data1;
    end

endmodule
