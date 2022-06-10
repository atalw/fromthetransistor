import unittest
from fileio import Io
from tokenizer import Tokenizer
from assembler import Assembler

class TestAsm(unittest.TestCase):

    def test_ad(self):
        s = "ADC R3, R9, #2"
        expected = "11100010101010010011000000000010"

        tokenizer = Tokenizer(s)
        assembler = Assembler(tokenizer.instructions)
        binary = assembler.bin_instructions
        assert(len(binary) == 1)
        assert(len(binary[0]) == 32)
        assert(expected == binary[0])

        s = "ADC R3, R9, #2\nADD R1, R2, #10"
        expected = "1110001010101001001100000000001011100010100000100001000000001010"

        tokenizer = Tokenizer(s)
        assembler = Assembler(tokenizer.instructions)
        binary = assembler.bin_instructions
        assert(len(binary) == 2)
        assert(len(binary[0]) == 32 and len(binary[1]) == 32)
        assert(expected == binary[0] + binary[1])

    def test_mov(self):
        s = "MOV R3, R9"
        expected = "11100001101000000011000000001001"

        tokenizer = Tokenizer(s)
        assembler = Assembler(tokenizer.instructions)
        binary = assembler.bin_instructions
        assert(len(binary) == 1)
        assert(len(binary[0]) == 32)
        assert(expected == binary[0])

if __name__ == '__main__':
    unittest.main()
