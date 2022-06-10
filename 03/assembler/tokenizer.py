import re
from ctypes import *
from enum import Enum, auto
from instruction_set import opcodes, conditions
from exceptions import NotSupported, IllegalToken

class TokenType(Enum):
    LABEL = auto()
    OPCODE = auto()
    REG = auto()
    IMM = auto()
    COND = auto()

    def __str__(self):
        return self.name

class Token:
    def __init__(self, literal):
        (self.token_type, self.value) = self.parse_token(literal)

    def parse_token(self, literal) -> (TokenType, str):
        token_type = None
        value = None

        if len(literal) > 1:
            if literal in opcodes.keys():
                token_type = TokenType.OPCODE
                value = opcodes[literal]
            elif literal in conditions.keys():
                token_type = TokenType.COND
                value = conditions[literal]
            elif literal[0] == 'R' and literal[1:].isdigit():
                token_type = TokenType.REG
                value = int(literal[1:])
            elif literal[0] == '#':
                token_type = TokenType.IMM
                #  value = bin(c_ushort(literal[1:]))
                value = c_ushort(int(literal[1:])).value
            else:
                raise NotSupported(literal)
        else:
            raise IllegalToken(literal)

        return (token_type, value)

class Tokenizer:
    def __init__(self, instructions):
        self.instructions = self.parse_instructions(instructions)

    def parse_instructions(self, instructions) -> [[Token]]:
        all_tokens = []

        def do_parse(instruction):
            literals = re.split('\n|, | ', instruction)
            if '' in literals:
                literals.remove('')

            inst_tokens = []
            for literal in literals:
                inst_tokens.append(Token(literal))
            all_tokens.append(inst_tokens)

        if type(instructions) == list:
            for instruction in instructions:
                do_parse(instruction)
        else:
            do_parse(instructions)


        return all_tokens
