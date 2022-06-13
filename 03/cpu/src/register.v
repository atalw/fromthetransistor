module registerfile();


    // Barrel shifter considerations
    //
    // Bit 25 (I). if 0, val is register, else imm8
    //
    // Immediate value
    // The immediate operand rotate field is a 4 bit unsigned integer which specifies a
    // shift operation on the 8 bit immediate value. This value is zero extended to 32 bits,
    // and then subject to a rotate right by twice the value in the rotate field.
    // Shift type is ROR
    //
    // Register
    // r_Rm = in_Op2[7:0];
    // r_Shift_type = in_Op2[6:5];
    // if (in_Op2[4] == 1)
    //      // When the shift amount is specified in the instruction, it is contained in a 5 bit
    //      // field which may take any value from 0—31.
    //      r_Shift_imm = in_Op2[11:7]
    // else
    //      r_Rs = in_Op2[11:8]
    //      shift ammount specified in bottom byte of Rs content


endmodule
