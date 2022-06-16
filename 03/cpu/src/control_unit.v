`include "Def_StructureParameter.v"
`include "decoder.v"
`include "register_bank.v"
`include "alu.v"
`include "barrel_shifter.v"

// Stages of the CPU pipeline
// 1. Instruction fetch (IF): get the instruction from memory
// 2. Instruction decode (ID): figure out what the instruction means + get values from registers
// 3. Execute (Ex): arithmetic operations + add up base and offest on memory references
// 4. Memory (Mem): load/store + update PC with destination address or nothing
// 5. Write back (WB): place results in the appropriate register

module control_unit(clock, in_Instruction);

    input wire clock;

    // -------------------------------
    // ------ Instruction Fetch ------
    // -------------------------------

    // wire [`InstructionWidth-1:0] in_Instruction;
    // input for now, just testing
    // TODO: fetch from mem
    input wire [`InstructionWidth-1:0] in_Instruction;

    // --------------------------------
    // ------ Instruction Decode ------
    // --------------------------------

    // ------ Decoder ------
    wire [3:0] out_Instruction_type;
    wire       out_Set_cond; // bit 20 -> 'S' (set condition codes) or 'L' (Load/store/link)
    wire [3:0] out_Opcode;
    wire [3:0] out_Rn; // 1st operand (reg address)
    wire [3:0] out_Rs; // only used in mul and mla (reg address)
    wire [3:0] out_Rm; // 2nd operand (reg address)
    wire [3:0] out_Rd; // destination register
    wire [`WordWidth-1:0] out_Imm_val; // unsigned 8-bit immediate value zero-padded
    wire [4:0] out_Shift_val; // shift to be applied to Rm
    wire [1:0] out_Shift_type;
    wire [3:0] out_Rotate; // shift to be applied to imm
    wire [3:0] out_Instr_CNZV; // condition flags

    decoder decoder(in_Instruction, out_Instruction_type, out_Set_cond, out_Opcode, out_Rn, out_Rs, 
        out_Rm, out_Rd, out_Imm_val, out_Shift_val, out_Shift_type, out_Rotate, out_Instr_CNZV);


    // ------ Register load ------
    wire [`WordWidth-1:0] in_Rn_val;
    wire [`WordWidth-1:0] in_Op2_val; // goes to barrel shifter

    register_bank register_bank(clock, out_Rn, out_Rm, out_Rd, out_Alu_res, out_Writeback, in_Rn_val, in_Op2_val);

    // --------------------------------
    // ----------- Execute ------------
    // --------------------------------

    // ------ Barrel Shifter ------
    wire [`WordWidth-1:0] out_Op2_val; // shifted val that goes from barrel to alu
    wire                  out_Carry;

    barrel_shifter shifter(in_Op2_val, out_Imm_val, out_Shift_val, out_Rotate, out_Shift_type,
        out_Instr_CNZV[3], out_Op2_val, out_Carry);

    // ------ ALU ------
    wire [`WordWidth-1:0] out_Alu_res;
    wire [3:0] out_CNZV;
    wire out_Writeback;

    alu alu(in_Rn_val, out_Op2_val, out_Carry, out_Opcode, out_Instr_CNZV, out_Set_cond, out_Alu_res,
        out_CNZV, out_Writeback);

endmodule
