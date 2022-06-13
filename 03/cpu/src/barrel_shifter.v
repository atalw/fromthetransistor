`include "Def_StructureParameter.v"
`include "Def_BarrelShifter.v"

// 32-bit barrel shifter used to shift and rotate n-bits within a single clock cycle.
// https://en.wikipedia.org/wiki/Barrel_shifter
//
// Eg of a pipelined shifter (6 clock cycles) just for reference:
// https://www.cs.uregina.ca/Links/class-info/301/guili/BarrelShPipeline.html
module barrel_shifter(in_Val, in_Shift_type, in_Shift_imm, in_C_flag, out_Op2, out_Carry);
    // in_Shift_imm: amount to be shifted by. if op2 is imm, amount = 4-bit rotate * 2, else it is
    //               5-bit shift amount
    // in_C_flag: C flag of CNZV (CPSR condition)
    // in_Val: value to be shifted. can be register content or imm

    input  wire [`WordWidth-1:0] in_Val;
    input  wire [1:0]            in_Shift_type;
    input  wire [4:0]            in_Shift_imm;
    input  wire                  in_C_flag;

    output wire [`WordWidth-1:0] out_Op2;
    output wire                  out_Carry;

    reg [`WordWidth-1:0] r_Op2;
    reg                  r_Carry;
    reg                  r_Sign;
    reg [`WordWidth-1:0] r_junk;

    assign out_Op2 = r_Op2;
    assign out_Carry = r_Carry;

    always @(*) begin
        r_Op2 = in_Val;
        r_Carry = 0;

        if (in_Shift_imm == 0) begin
            case (in_Shift_type)
                `LogicalLeftShift: begin
                    // LSL #0 is a special case, where the shifter carry out is the old value
                    // of the CPSR C flag. The contents of Rm are used directly as the second operand.
                    if (in_Shift_imm == 0) begin
                        r_Carry = in_C_flag;
                        r_Op2 = in_Val;
                    end
                end

                `LogicalRightShift: begin
                    // LSR #0 is used to encode LSR #32. Logical shift right zero is redundant
                    // as it is the same as LSL #0, so the assembler will convert LSR #0
                    // (and ASR #0 and ROR #0) into LSL #0, and allow LSR #32 to be specified
                    if (in_Shift_imm == 0) begin
                        r_Carry = in_Val[`WordWidth-1];
                        r_Op2 = `WordWidth'd0;
                    end
                end

                // Similar to LSR, except that the high bits are filled with bit 31 of Rm
                // instead of zeros. This preserves the sign in 2’s complement notation
                `ArithmeticRightShift: begin
                    // ASR #0 is used to encode ASR #32. Bit 31 of Rm is again used as the
                    // carry output, and each bit of operand 2 is also equal to bit 31 of Rm.
                    // The result is therefore all ones or all zeros, according to the value
                    // of bit 31 of Rm.
                    if (in_Shift_imm == 0) begin
                        r_Carry = in_Val[`WordWidth-1];
                        r_Op2 = {32{r_Carry}};
                    end
                end

                `RotateRightShift: begin
                    // The form of the shift field which might be expected to give ROR #0 is
                    // used to encode a special function of the barrel shifter, rotate right
                    // extended (RRX). This is a rotate right by one bit position of the 33 bit
                    // quantity formed by appending the CPSR C flag to the most significant
                    // end of the contents of Rm
                    if (in_Shift_imm == 0) begin
                        r_Carry = in_Val[0];
                        r_Op2 = {r_Carry, in_C_flag, in_Val[`WordWidth-1:2]};
                    end
                end
            endcase
        end
        else begin
            // Manually encode shift operations using concat of the input value instead of using shift
            // operators for efficiency I think. Using shift operations felt like cheating. It's
            // there in git history if you want to check it out.

            // Shift 16 bits
            if (in_Shift_imm[4] == 1) begin
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
            if (in_Shift_imm[3] == 1) begin
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
            if (in_Shift_imm[2] == 1) begin
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
            if (in_Shift_imm[1] == 1) begin
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
            if (in_Shift_imm[0] == 1) begin
                case (in_Shift_type)
                    `LogicalLeftShift: begin
                        r_Carry = r_Op2[`WordWidth-1];
                        r_Op2 = {r_Op2[`WordWidth-1-1:0], 2'b0};
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
endmodule
