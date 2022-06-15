`include "Def_StructureParameter.v"

// 34 - 16 (alu types) = 18

`define data_proc                   1
`define multiply                    2
`define multiply_long               3
`define single_data_swap            4
`define branch_and_exchange         5
`define halfword_data_transfer_reg  6
`define halfword_data_transfer_imm  7
`define single_data_transfer        8
`define undefined                   9
`define block_data_transfer         10
`define branch                      11
`define coproc_data_transfer        12
`define coproc_data_op              13
`define coproc_reg_transfer         14
`define software_interrupt          15

// Responsible for just decoding instructions and returning the associated values to the control unit
//
// There are generally two variations to a decoder.
//
// In the first variant the bits of the instruction code are fed directly to the hardware components
// so there really is no decoder at all. All timing requirements must be met by careful programming
// of the machine code and there is no delay in execution from an instruction decoder. The necessary
// control line 'waveforms' are created directly by the sequence of instructions. As soon as the
// instruction is presented the hardware begins to respond. The bits in the instruction set directly
// represent the actual physical controls of the hardware components.
//
// The second variant includes a simple (fast) decoder between the instruction code and the hardware
// components. This decoding is usually implemented by discrete logic gates. The primary purpose of
// this decoder is to allow a 'cleaner' instruction set representation. As with the direct variant,
// each instruction still represents a single machine function but the use of a decoder will often
// significantly reduce the number of bits needed in the machine code word. This in turn may allow
// several hardware functions to be initiated in a single machine instruction.
//
// (https://en.wikibooks.org/wiki/Microprocessor_Design/Instruction_Decoder)
//
// We're doing the second one.
module decoder(in_Instruction, out_Instruction_type, out_Set_cond, out_Opcode, out_Rn, out_Rs, out_Rm,
    out_Rd, out_Imm, out_Shift_val, out_Shift_type, out_Rotate, out_CNZV);

    input wire [`InstructionWidth-1:0] in_Instruction;
    output wire [3:0] out_Instruction_type;
    output wire  out_Set_cond; // bit 20 -> 'S' (set condition codes) or 'L' (Load/store/link)
    output wire [3:0] out_Opcode; // ALU opcode
    output wire [3:0] out_Rn; // 1st operand (reg address)
    output wire [3:0] out_Rs; // only used in mul and mla (reg address)
    output wire [3:0] out_Rm; // 2nd operand (reg address)
    output wire [3:0] out_Rd; // destination register
    output wire [`WordWidth-1:0] out_Imm; // unsigned 8-bit immediate value
    output wire [4:0] out_Shift_val; // shift to be applied to Rm
    output wire [1:0] out_Shift_type; // shift type
    output wire [3:0] out_Rotate; // shift to be applied to imm
    output wire [3:0] out_CNZV; // condition flags

    reg [3:0] r_Instruction_type;
    reg r_Set_cond;
    reg [3:0] r_Opcode;
    reg [3:0] r_Rn;
    reg [3:0] r_Rs;
    reg [3:0] r_Rm;
    reg [3:0] r_Rd;
    reg [7:0] r_Imm;
    reg [7:0] r_Shift_val;
    reg [1:0] r_Shift_type;
    reg [3:0] r_Rotate;
    reg [3:0] r_CNZV;

    assign out_Instruction_type = r_Instruction_type;
    assign out_Set_cond = r_Set_cond;
    assign out_Opcode = r_Opcode;
    assign out_Rn = r_Rn;
    assign out_Rs = r_Rs;
    assign out_Rm = r_Rm;
    assign out_Rd = r_Rd;
    assign out_Imm = r_Imm;
    assign out_Shift = r_Shift_val;
    assign out_Shift_type = r_Shift_type;
    assign out_Rotate = r_Rotate;
    assign out_CNZV = r_CNZV;

    function [3:0] classify_instr(input instruction);
        begin
            if (in_Instruction[27:24] == 4'b1111)
                classify_instr = `software_interrupt;
            else if (in_Instruction[27:24] == 4'b1110) begin
                if (in_Instruction[4] == 1)
                    classify_instr = `coproc_reg_transfer;
                else
                    classify_instr = `coproc_data_op;
            end else if (in_Instruction[27:25] == 3'b110)
                classify_instr = `coproc_data_transfer;
            else if (in_Instruction[27:25] == 3'b101)
                classify_instr = `branch;
            else if (in_Instruction[27:25] == 3'b100)
                classify_instr = `block_data_transfer;
            else if (in_Instruction[27:26] == 3'b01)
                if (in_Instruction[25] == 0 || (in_Instruction[25] == 1 && in_Instruction[4] == 0)) begin
                    classify_instr = `single_data_transfer;
                end else
                    classify_instr = `undefined;
                else if (in_Instruction[27:4] == 24'b000100101111111111110001)
                    classify_instr = `branch_and_exchange;
                else if (in_Instruction[27:23] == 5'b00010 && in_Instruction[11:4] == 8'b00001001) begin
                    classify_instr = `single_data_swap;
                end else if (in_Instruction[27:23] == 5'b00001 && in_Instruction[7:4] == 4'b1001) begin
                    classify_instr = `multiply_long;
                end else if (in_Instruction[27:22] == 6'b000000 && in_Instruction[7:4] == 4'b1001) begin
                    classify_instr = `multiply;
                end else if (in_Instruction[27:26] == 2'b00 && (in_Instruction[25] == 1'b1 || (in_Instruction[25] == 1'b0 && {in_Instruction[7], in_Instruction[4]} != 2'b11))) begin
                    classify_instr = `data_proc;
                end
            else
                classify_instr = `undefined;
        end
    endfunction

    task extract_data(input instruction_type);
        begin
            r_CNZV = in_Instruction[31:28];
            r_Set_cond = in_Instruction[20];

            case (instruction_type)
                `data_proc: begin
                    r_Opcode = in_Instruction[24:21];
                    r_Rn = in_Instruction[19:16];
                    r_Rd = in_Instruction[15:12];
                    if (in_Instruction[25] == 0) begin  // operand 2 is a reg
                        if (in_Instruction[4] == 0) begin
                            r_Shift_val = in_Instruction[11:7];
                        end else begin
                            r_Rm = in_Instruction[3:0];
                        end
                        r_Shift_type = in_Instruction[6:5];
                    end else begin // operand 2 is an imm value
                        r_Imm = {{24{1'b0}}, in_Instruction[7:0]};
                        r_Rotate = in_Instruction[11:8] * 2;
                        r_Shift_type = 2'b11;
                    end
                end
            endcase
        end
    endtask

    always @(in_Instruction) begin
        $display("Result is uh oh %b", in_Instruction);
        r_Instruction_type = classify_instr(in_Instruction);
        extract_data(r_Instruction_type);
        $display("Result is uh oh %d", r_Instruction_type);
    end
endmodule


