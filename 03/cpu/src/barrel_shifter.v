`include "Def_StructureParameter.v"

`define LogicalLeftShift     2'b00
`define LogicalRightShift    2'b01
`define ArithmeticRightShift 2'b10
`define RotateRightShift     2'b11

// 32-bit
module barrel_shifter(in_Immop, in_Op2, in_C_flag, in_Rs_contents, out_Rm, out_Imm, out_Carry);
    input  wire                  in_Immop; // bit 25 (I): if 0, in_Op2 is reg, else imm8

    // input  wire [11:0]           in_Op2;
    // input  wire [`WordWidth-1:0] in_Rs_contents; // general regsiter used for register specified shift amount

    input  wire [1:0]            in_Shift_type;
    input  wire [3:0]            in_Shift_imm; // amount to be shifted by
    input  wire [`WordWidth-1:0] in_Val; // value to be shifted. can be register content or imm
    input  wire                  in_C_flag; // C flag of CNZV (CPSR condition)


    output wire [3:0]            out_Rm;
    output wire [`WordWidth-1:0] out_Imm;
    output wire                  out_Carry;

    reg [3:0]            r_rotate;
    reg [`WordWidth-1:0] r_Imm;
    reg                  r_Carry;

    reg [7:0] r_Shift;
    reg [3:0] r_Rm;
    reg [1:0] r_Shift_type;
    reg       r_Sign_bit;

    assign out_Imm = r_Imm;
    assign out_Carry = r_Carry;

    function [`WordWidth:0] rotate_imm(input shift_len, shift_type, value, in_C_flag);
        begin
            case (shift_type)
                `RotateRightShift: begin
                    if (shift_len == 0) begin
                        // The form of the shift field which might be expected to give ROR #0 is
                        // used to encode a special function of the barrel shifter, rotate right
                        // extended (RRX). This is a rotate right by one bit position of the 33 bit
                        // quantity formed by appending the CPSR C flag to the most significant
                        // end of the contents of Rm
                        {rotate_imm, r_Carry} = {in_C_flag, value} >> 1;
                    end
                    else begin
                        {junk, out, r_Carry} = {value, value, in_C_flag} >> shift_len;
                    end
                end
            endcase
        end
    endfunction

    always @(*)
    begin
        if (in_Immop == 1) // return immediate value
        begin
            // The immediate operand rotate field is a 4 bit unsigned integer which specifies a
            // shift operation on the 8 bit immediate value. This value is zero extended to 32 bits,
            // and then subject to a rotate right by twice the value in the rotate field.
            // r_Rotate = in_Op2[11:8];
            // r_Imm = `WordWidth'd0;
            // r_Imm[7:0] = in_Op2[7:0];
            // {r_Carry, r_Imm} = rotate_imm(2*r_rotate, `RotateRight, r_Imm, in_C_flag);
            {r_Carry, r_Imm} = rotate_imm(2*in_Shift_imm, `RotateRightShift, in_Val, in_C_flag);
        end
        else // return register
        begin
            r_Rm = in_Op2[7:0];
            r_Shift_type = in_Op2[6:5];

            if (in_Op2[4] == 1) begin
                // When the shift amount is specified in the instruction, it is contained in a 5 bit
                // field which may take any value from 0—31.
                r_Shift_imm = in_Op2[11:7];
                case (r_Shift_type)
                    `LogicalLeftShift: begin
                        // LSL #0 is a special case, where the shifter carry out is the old value
                        // of the CPSR C flag. The contents of Rm are used directly as the second operand.
                        if (r_Shift_imm == 0) begin
                            r_Carry = in_C_flag;
                            r_Rm = r_Rm;
                        end
                        else begin
                            // the least significant discarded bit becomes the shifter carry output
                            {r_Carry, r_Rm} = {in_C_flag, r_Rm} << r_Shift_imm;
                        end
                    end
                    `LogicalRightShift: begin
                        // LSR #0 is used to encode LSR #32. Logical shift right zero is redundant
                        // as it is the same as LSL #0, so the assembler will convert LSR #0
                        // (and ASR #0 and ROR #0) into LSL #0, and allow LSR #32 to be specified
                        if r_Shift_imm = 5'd0 begin
                            r_Carry = r_Rm[`WordWidth-1];
                            r_Rm = `WordWidth'd0;
                        end
                        else begin
                            {r_Rm, r_Carry} = {r_Rm, in_C_flag} >> r_Shift_imm;
                        end
                    end
                    // Similar to LSR, except that the high bits are filled with bit 31 of Rm
                    // instead of zeros. This preserves the sign in 2’s complement notation
                    `ArithmeticRightShift: begin
                        // ASR #0 is used to encode ASR #32. Bit 31 of Rm is again used as the
                        // carry output, and each bit of operand 2 is also equal to bit 31 of Rm.
                        // The result is therefore all ones or all zeros, according to the value
                        // of bit 31 of Rm.
                        if r_Shift_imm = 5'd0 begin
                            r_Carry = r_Rm[`WordWidth-1];
                            if (r_Carry == 1)
                                r_Rm = `WordWidth'd1;
                            else
                                r_Rm = `WordWidth'd0;
                        end
                        else begin
                            r_Sign_bit = r_Rm[`WordWidth-1];
                            if (r_Sign_bit == 1)
                                {junk, r_Rm, r_Carry} = {32'd1, r_Rm, in_C_flag} >> r_Shift_imm;
                            else
                                {r_Rm, r_Carry} = {r_Rm, in_C_flag} >> r_Shift_imm;
                        end
                    end
                    `RotateRightShift: begin
                        {r_Carry, r_Imm} = rotate_imm(r_Shift_imm, `RotateRight, r_Rm, in_C_flag);
                    end
                endcase
            end
            else begin
                r_Rs = in_Op2[11:8];
            end
            
        end
    end

endmodule
