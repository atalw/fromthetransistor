from instruction_set import opcodes, conditions

class Assembler:
    def __init__(self, instructions):
        self.bin_instructions = self.encode(instructions)

    def encode(self, instructions):
        bin_instructions = [[]]
        idx = 0
        for instruction in instructions:
            bin_instructions[idx] = ""
            for token in instruction:
                bin_instructions[idx] += f'{token.value}'

        return bin_instructions
