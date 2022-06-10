from instruction_set import opcodes, conditions
from tokenizer import TokenType

class Assembler:
    def __init__(self, instructions):
        self.bin_instructions = self.encode(instructions)

    def encode(self, instructions):
        bin_instructions = []
        idx = 0
        for instruction in instructions:
            bin_instructions.append([])
            tt = instruction[0].token_type
            if tt == TokenType.LABEL:
                pass
            elif tt == TokenType.OPCODE:
                v = instruction[0].value
                if v == opcodes['ADD'] or v == opcodes['ADC']:
                    bin_instructions[idx] = self.encode_ad(instruction)
                elif v == opcodes['MOV']:
                    bin_instructions[idx] = self.encode_mov(instruction)
            else:
                pass
            idx += 1


        return bin_instructions

    '''
    -> ADC R1, R2, #<const>
    cond 00 1 0101 0  Rn  Rd    imm12
    ---- -- - ---- - ---  ---  --------
    cond       op  S reg1 reg2  const
    '''
    def encode_ad(self, instruction) -> str:
        assert(len(instruction) == 4)
        # TODO: accept dynamic condition
        cond = "1110"
        opcode = format(instruction[0].value, '04b')
        s = "0"
        rd = format(instruction[1].value, '04b')
        rn = format(instruction[2].value, '04b')
        imm12 = format(instruction[3].value, '012b')

        return cond + "001" + opcode + s + rn + rd + imm12

    '''
    -> MOV R1, R2
    cond 00 0 1101 0 (0)(0)(0)(0) Rd  00000000 Rm
    ---- -- - ---- - ------------ --  -------- --
    cond       op  S    zeros    reg1  zeros   reg2
    '''
    def encode_mov(self, instruction) -> str:
        assert(len(instruction) == 3)
        # TODO: accept dynamic condition
        cond = "1110"
        opcode = format(instruction[0].value, '04b')
        s = "0"
        rd = format(instruction[1].value, '04b')

        res = cond + "000" + opcode + s + "0000" + rd

        op2 = None
        if instruction[2].token_type == TokenType.REG:
            res += "00000000"
            op2 = format(instruction[2].value, '04b') # can be register or imm
        else:
            op2 = format(instruction[2].value, '012b') # can be register or imm

        res += op2
        return res

    # just keep following the spec and adding more opcode impls. straightforward really...
