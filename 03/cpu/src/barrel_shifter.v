`include "Def_StructureParameter.v"
`include "Def_BarrelShifter.v"

// 32-bit barrel shifter
// Not sure if this implementation is properly done. Should probably pipeline it and not use '>>'
// and '<<'. Eg. https://www.cs.uregina.ca/Links/class-info/301/guili/BarrelShPipeline.html
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
        r_Op2 = 0;
        r_Carry = 0;

        case (in_Shift_type)
            `LogicalLeftShift: begin
                // LSL #0 is a special case, where the shifter carry out is the old value
                // of the CPSR C flag. The contents of Rm are used directly as the second operand.
                if (in_Shift_imm == 0) begin
                    r_Carry = in_C_flag;
                    r_Op2 = in_Val;
                end
                else begin
                    // the least significant discarded bit becomes the shifter carry output
                    {r_Carry, r_Op2} = {r_Carry, in_Val} << in_Shift_imm;
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
                else begin
                    // the most significant discarded bit becomes the shifter carry output
                    {r_Op2, r_Carry} = {in_Val, r_Carry} >> in_Shift_imm;
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
                    if (r_Carry == 1)
                        r_Op2 = `WordWidth'h11111111;
                    else
                        r_Op2 = `WordWidth'd0;
                end
                else begin
                    r_Sign = in_Val[`WordWidth-1];
                    if (r_Sign == 1)
                        {r_junk, r_Op2, r_Carry} = {32'd1, in_Val, r_Carry} >> in_Shift_imm;
                    else
                        {r_Op2, r_Carry} = {in_Val, r_Carry} >> in_Shift_imm;

                end
            end

            `RotateRightShift: begin
                // The form of the shift field which might be expected to give ROR #0 is
                // used to encode a special function of the barrel shifter, rotate right
                // extended (RRX). This is a rotate right by one bit position of the 33 bit
                // quantity formed by appending the CPSR C flag to the most significant
                // end of the contents of Rm
                if (in_Shift_imm == 0) begin
                    {r_junk, r_Op2, r_Carry} = {in_Val, in_C_flag, in_Val} >> 1;
                end
                else begin
                    // carry out should be equal to most significant bit after rotate
                    {r_junk, r_Op2, r_Carry} = {in_Val, in_Val, r_Carry} >> in_Shift_imm;
                end
            end
        endcase
    end
endmodule
