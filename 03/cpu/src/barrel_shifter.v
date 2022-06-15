`include "Def_StructureParameter.v"
`include "Def_BarrelShifter.v"

// 32-bit barrel shifter used to shift and rotate n-bits within a single clock cycle.
// https://en.wikipedia.org/wiki/Barrel_shifter
//
// Eg of a pipelined shifter (6 clock cycles) just for reference:
// https://www.cs.uregina.ca/Links/class-info/301/guili/BarrelShPipeline.html
module barrel_shifter(in_Reg_val, in_Imm_val, in_Shift_val, in_Rotate, in_Shift_type, in_C_flag,
    out_Op2, out_Carry);
    // in_Shift_val: amount to be shifted by. if op2 is imm, amount = 4-bit rotate * 2, else it is
    //               5-bit shift amount
    // in_C_flag: C flag of CNZV (CPSR condition)
    // in_Reg_val: value to be shifted which comes from register
    // in_Imm_val: value to be shifted which comes from decoder 

    input  wire [`WordWidth-1:0] in_Reg_val; // register content
    input  wire [`WordWidth-1:0] in_Imm_val; // zero-padded imm8
    input  wire [1:0]            in_Shift_type;
    input  wire [4:0]            in_Shift_val;
    input  wire [3:0]            in_Rotate; // rotate to be applied to imm
    input  wire                  in_C_flag;
    output wire [`WordWidth-1:0] out_Op2;
    output wire                  out_Carry;

    reg [`WordWidth-1:0] r_Op2;
    reg                  r_Carry;

    assign out_Op2 = r_Op2;
    assign out_Carry = r_Carry;

    task exec_shift(input [`WordWidth-1:0] val, input [4:0] shift_val);
        begin
            if (shift_val == 0) begin
                case (in_Shift_type)
                    // LSL #0 is a special case, where the shifter carry out is the old value
                    // of the CPSR C flag. The contents of Rm are used directly as the second operand.
                    `LogicalLeftShift: begin
                        r_Carry = in_C_flag;
                        r_Op2 = val;
                    end

                    // LSR #0 is used to encode LSR #32. Logical shift right zero is redundant
                    // as it is the same as LSL #0, so the assembler will convert LSR #0
                    // (and ASR #0 and ROR #0) into LSL #0, and allow LSR #32 to be specified
                    `LogicalRightShift: begin
                        r_Carry = val[`WordWidth-1];
                        r_Op2 = `WordWidth'd0;
                    end

                    // Similar to LSR, except that the high bits are filled with bit 31 of Rm
                    // instead of zeros. This preserves the sign in 2’s complement notation
                    `ArithmeticRightShift: begin
                        // ASR #0 is used to encode ASR #32. Bit 31 of Rm is again used as the
                        // carry output, and each bit of operand 2 is also equal to bit 31 of Rm.
                        // The result is therefore all ones or all zeros, according to the value
                        // of bit 31 of Rm.
                        r_Carry = val[`WordWidth-1];
                        r_Op2 = {32{r_Carry}};
                    end

                    `RotateRightShift: begin
                        // The form of the shift field which might be expected to give ROR #0 is
                        // used to encode a special function of the barrel shifter, rotate right
                        // extended (RRX). This is a rotate right by one bit position of the 33 bit
                        // quantity formed by appending the CPSR C flag to the most significant
                        // end of the contents of Rm
                        r_Carry = val[0];
                        r_Op2 = {r_Carry, in_C_flag, val[`WordWidth-1:2]};
                    end
                endcase
            end
            else begin
                // Manually encode shift operations using concat of the input value instead of using shift
                // operators for efficiency I think. Using shift operations felt like cheating. It's
                // there in git history if you want to check it out.

                // $display("here %d %d", val, shift_val);
                r_Op2 = val;
                r_Carry = in_C_flag;

                // Shift 16 bits
                if (shift_val[4] == 1) begin
                    case (in_Shift_type)
                        `LogicalLeftShift: begin
                            r_Carry = r_Op2[`WordWidth-16];
                            r_Op2 = {r_Op2[`WordWidth-1-16:0], 16'h0000};
                        end

                        `LogicalRightShift: begin
                            r_Carry = r_Op2[15];
                            r_Op2 = {16'h0000, r_Op2[`WordWidth-1:16]};
                        end

                        `ArithmeticRightShift: begin
                            r_Carry = r_Op2[15];
                            r_Op2 = {{16{r_Op2[`WordWidth-1]}}, r_Op2[`WordWidth-1:16]};
                        end

                        `RotateRightShift: begin
                            r_Carry = r_Op2[15];
                            r_Op2 = {r_Op2[15:0], r_Op2[`WordWidth-1:16]};
                        end
                    endcase
                end

                // Shift 8 bits
                if (shift_val[3] == 1) begin
                    case (in_Shift_type)
                        `LogicalLeftShift: begin
                            r_Carry = r_Op2[`WordWidth-8];
                            r_Op2 = {r_Op2[`WordWidth-1-8:0], 8'h00};
                        end

                        `LogicalRightShift: begin
                            r_Carry = r_Op2[7];
                            r_Op2 = {8'h00, r_Op2[`WordWidth-1:8]};
                        end

                        `ArithmeticRightShift: begin
                            r_Carry = r_Op2[7];
                            r_Op2 = {{8{r_Op2[`WordWidth-1]}}, r_Op2[`WordWidth-1:8]};
                        end

                        `RotateRightShift: begin
                            r_Carry = r_Op2[7];
                            r_Op2 = {r_Op2[7:0], r_Op2[`WordWidth-1:8]};
                        end
                    endcase
                end

                // Shift 4 bits
                if (shift_val[2] == 1) begin
                    case (in_Shift_type)
                        `LogicalLeftShift: begin
                            r_Carry = r_Op2[`WordWidth-4];
                            r_Op2 = {r_Op2[`WordWidth-1-4:0], 4'h0};
                        end

                        `LogicalRightShift: begin
                            r_Carry = r_Op2[3];
                            r_Op2 = {4'h0, r_Op2[`WordWidth-1:4]};
                        end

                        `ArithmeticRightShift: begin
                            r_Carry = r_Op2[3];
                            r_Op2 = {{4{r_Op2[`WordWidth-1]}}, r_Op2[`WordWidth-1:4]};
                        end

                        `RotateRightShift: begin
                            r_Carry = r_Op2[3];
                            r_Op2 = {r_Op2[3:0], r_Op2[`WordWidth-1:4]};
                        end
                    endcase
                end

                // Shift 2 bits
                if (shift_val[1] == 1) begin
                    case (in_Shift_type)
                        `LogicalLeftShift: begin
                            r_Carry = r_Op2[`WordWidth-2];
                            r_Op2 = {r_Op2[`WordWidth-1-2:0], 2'b00};
                        end

                        `LogicalRightShift: begin
                            r_Carry = r_Op2[1];
                            r_Op2 = {2'b00, r_Op2[`WordWidth-1:2]};
                        end

                        `ArithmeticRightShift: begin
                            r_Carry = r_Op2[1];
                            r_Op2 = {{2{r_Op2[`WordWidth-1]}}, r_Op2[`WordWidth-1:2]};
                        end

                        `RotateRightShift: begin
                            r_Carry = r_Op2[1];
                            r_Op2 = {r_Op2[1:0], r_Op2[`WordWidth-1:2]};
                        end
                    endcase
                end

                // Shift 1 bit
                if (shift_val[0] == 1) begin
                    case (in_Shift_type)
                        `LogicalLeftShift: begin
                            r_Carry = r_Op2[`WordWidth-1];
                            r_Op2 = {r_Op2[`WordWidth-1-1:0], 1'b0};
                        end

                        `LogicalRightShift: begin
                            r_Carry = r_Op2[0];
                            r_Op2 = {1'b0, r_Op2[`WordWidth-1:1]};
                        end

                        `ArithmeticRightShift: begin
                            r_Carry = r_Op2[0];
                            r_Op2 = {r_Op2[`WordWidth-1], r_Op2[`WordWidth-1:1]};
                        end

                        `RotateRightShift: begin
                            r_Carry = r_Op2[0];
                            r_Op2 = {r_Op2[0], r_Op2[`WordWidth-1:1]};
                        end
                    endcase
                end
            end
        end
    endtask

    always @(in_Reg_val or in_Shift_val or in_Imm_val or in_Rotate or in_C_flag) begin
        if (in_Reg_val[0] !== 1'bX && in_Shift_val[0] !== 1'bX)
            exec_shift(in_Reg_val, in_Shift_val);
        else if (in_Imm_val[0] !== 1'bX && in_Rotate[0] !== 1'bX)
            exec_shift(in_Imm_val, in_Rotate);

    end
endmodule
