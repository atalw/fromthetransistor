`include "Def_StructureParameter.v"
`include "ram.v"
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

module control_unit(clock, nreset, pc);

    input wire clock;
    input wire nreset;
    output reg [13:0] pc;

    // -------------------------------
    // ------ Instruction Fetch ------
    // -------------------------------

    reg [13:0]                      ram_Addr;
    wire                            ram_Write_enable;
    reg [`WordWidth-1:0]            ram_Wdata;
    reg [1:0]                       ram_Size;
    wire [`InstructionWidth-1:0]    w_Instruction;

    ram ram(clock, ram_Addr, ram_Write_enable, ram_Wdata, ram_Size, w_Instruction);

    // --------------------------------
    // ------ Instruction Decode ------
    // --------------------------------

    // ------ Decoder ------
    wire [3:0]              w_Instruction_type;
    wire                    w_Set_cond; // bit 20 -> 'S' (set condition codes) or 'L' (Load/store/link)
    wire [3:0]              w_Opcode;
    wire [3:0]              w_Rn; // 1st operand (reg address)
    wire [3:0]              w_Rs; // only used in mul and mla (reg address)
    wire [3:0]              w_Rm; // 2nd operand (reg address)
    wire [3:0]              w_Rd; // destination register
    wire [`WordWidth-1:0]   w_Imm_val; // unsigned 8-bit immediate value zero-padded
    wire [4:0]              w_Shift_val; // shift to be applied to Rm
    wire [1:0]              w_Shift_type;
    wire [3:0]              w_Rotate; // shift to be applied to imm
    wire [3:0]              w_Instr_CNZV; // condition flags

    decoder decoder(w_Instruction, w_Instruction_type, w_Set_cond, w_Opcode, w_Rn, w_Rs, 
        w_Rm, w_Rd, w_Imm_val, w_Shift_val, w_Shift_type, w_Rotate, w_Instr_CNZV);


    // ------ Register load ------
    wire [`WordWidth-1:0] in_Rn_val;
    wire [`WordWidth-1:0] in_Op2_val; // goes to barrel shifter
    wire [`WordWidth-1:0] w_Alu_res;
    wire                  w_Writeback;

    register_bank register_bank(clock, w_Rn, w_Rm, w_Rd, w_Alu_res, w_Writeback, in_Rn_val, in_Op2_val);

    // --------------------------------
    // ----------- Execute ------------
    // --------------------------------

    // ------ Barrel Shifter ------
    wire [`WordWidth-1:0] w_Op2_val; // shifted val that goes from barrel to alu
    wire                  w_Carry;

    barrel_shifter shifter(in_Op2_val, w_Imm_val, w_Shift_val, w_Rotate, w_Shift_type,
        w_Instr_CNZV[3], w_Op2_val, w_Carry);

    // ------ ALU ------
    wire [3:0]              w_CNZV;

    alu alu(in_Rn_val, w_Op2_val, w_Carry, w_Opcode, w_Instr_CNZV, w_Set_cond, w_Alu_res,
        w_CNZV, w_Writeback);

    always @(posedge clock) begin
        if (nreset) begin
            pc <= 0;
            ram_Size <= 2'b10;
        end

        ram_Addr <= pc;
    end

endmodule
