import unittest
from fileio import Io
from tokenizer import Tokenizer
from assembler import Assembler

class TestAsm(unittest.TestCase):

    def test_adc(self):
        s = "ADC R3, R9, #2"
        expected = "11100010101010010011000000000010"

        tokenizer = Tokenizer(s)
        assembler = Assembler(tokenizer.instructions)
        binary = assembler.bin_instructions
        assert(len(binary) == 1)
        assert(len(binary[0]) == 32)
        assert(expected == binary[0])

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
