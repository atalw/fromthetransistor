import unittest

class TestAsm(unittest.TestCase):

    def test_simple_asm(self):
        s = "MOV R3, R9"
        expected = "111000011010000000011000000001001"
        
        # assemble it
        # see if it matches expected output


if __name__ == '__main__':
    unittest.main()
