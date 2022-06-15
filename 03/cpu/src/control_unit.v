`include "Def_StructureParameter.v"
`include "decoder.v"
`include "alu.v"
`include "barrel_shifter.v"

// Stages of the CPU pipeline
// 1. Instruction fetch (IF): get the instruction from memory
// 2. Instruction decode (ID): figure out what the instruction means + get values from registers
// 3. Execute (Ex): arithmetic operations + add up base and offest on memory references
// 4. Memory (Mem): load/store + update PC with destination address or nothing
// 5. Write back (WB): place results in the appropriate register

module control_unit();

    // -------------------------------
    // ------ Instruction Fetch ------
    // -------------------------------

    wire [`InstructionWidth-1:0] in_Instruction;

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
    wire [7:0] out_Imm; // unsigned 8-bit immediate value
    wire [7:0] out_Shift; // shift to be applied to Rm
    wire [3:0] out_Rotate; // shift to be applied to imm
    wire [3:0] out_Instr_CNZV; // condition flags

    decoder decoder(in_Instruction, out_Instruction_type, out_Set_cond, out_Opcode, out_Rn, out_Rs, out_Rm, out_Rd, out_Imm,
                    out_Shift, out_Rotate, out_Instr_CNZV);


    // ------ Register load ------
    assign in_Rn_val = `WordWidth'd0;
    assign in_Op2_val = `WordWidth'd5;
    assign in_Shift_type = 2'b11;
    assign in_Shift_imm = 4'd1;


    // --------------------------------
    // ----------- Execute ------------
    // --------------------------------

    // ------ Barrel Shifter ------
    wire [`WordWidth-1:0] in_Op2_val; // goes to barrel shifter
    wire [1:0]            in_Shift_type;
    wire [4:0]            in_Shift_imm;
    wire [`WordWidth-1:0] out_Op2_val; // shifted val that goes from barrel to alu
    wire                  out_Carry;

    barrel_shifter shifter(in_Op2_val, in_Shift_type, in_Shift_imm, out_Instr_CNZV[3], out_Op2_val, out_Carry);

    // ------ ALU ------
    wire [`WordWidth-1:0] in_Rn_val;
    wire [`WordWidth-1:0] out_Alu_res;
    wire [3:0] out_CNZV;

    alu alu(in_Rn_val, out_Op2_val, out_Carry, out_Opcode, out_Instr_CNZV, in_Set_cond, out_Alu_res, out_CNZV);

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
    // ADD R0, R0, #4
    // 00000010100000000000000000000100


    #100;
    $display("Result is %d", out_Alu_res);
    end

    assign in_Instruction = `InstructionWidth'b00000010100000000000000000000100;
endmodule
