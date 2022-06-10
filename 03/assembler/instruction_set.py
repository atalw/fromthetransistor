
# Conditional execution: Section A8.3
conditions = {
    # Equal
    "EQ": 0b0000,
    # Not equal
    "NE": 0b0001,
    # Carry set
    "CS": 0b0010,
    # Carry clear
    "CC": 0b0011,
    # Minus, negative
    "MI": 0b0100,
    # Plus, positive or zero
    "PL": 0b0101,
    # Overflow
    "VS": 0b0110,
    # No overflow
    "VC": 0b0111,
    # Unsigned higher
    "HI": 0b1000,
    # Unsigned lower or same
    "LS": 0b1001,
    # Signed greater than or equal
    "GE": 0b1010,
    # Signed less than
    "LT": 0b1011,
    # Signed greater than
    "GT": 0b1100,
    # Signed less than or equal
    "LE": 0b1101,
    # Always (unconditional)
    "AL": 0b1110,
}

# Data-processing instructions: Section A5.2.1
dpi_instructions = {
    # Bitwise AND
    "AND": 0b0000,
    # Bitwise Exclusive OR
    "EOR": 0b0001,
    # Subtract
    "SUB": 0b0010,
    # Reverse Subtract
    "RSB": 0b0011,
    # Add
    "ADD": 0b0100,
    # Add with Carry
    "ADC": 0b0101,
    # Subtract with Carry
    "SBC": 0b0110,
    # Reverse Substract with Carry
    "RSC": 0b0111,
    # Test
    "TST": 0b10001,
    # Test Equivalence
    "TEQ": 0b10011,
    # Compare
    "CMP": 0b10101,
    # Compare Negative
    "CMN": 0b10111,
    # Bitwise OR
    "ORR": 0b1100,
    # Move (op2 = 00, imm5 = 00000)
    "MOV": 0b1101,
    # Logical Shift Left (op2 = 00, imm5 = !00000)
    "LSL": 0b1101,
    # Logical Shift Right (op2 = 01)
    "LSR": 0b1101,
    # Arithmetic Shift Right (op2 = 10)
    "ASR": 0b1101,
    # Rotate Right with Extend (op2 = 11, imm5 = 00000)
    "RRX": 0b1101,
    # Rotate Right (op2 = 11, imm5 = !00000)
    "ROR": 0b1101,
    # Bitwise Bit Clear
    "BIC": 0b1110,
    # Bitwise NOT
    "MVN": 0b1111,
}

# Multiply instructions: Section A5.2.5
mul_instructions = {
    # Multiply
    "MUL": 0b000,
    # Multiply Accumulate
    "MLA": 0b001,
    # Multiple and Subtract
    "MLS": 0b0110,
}

opcodes = {**dpi_instructions, **mul_instructions}
