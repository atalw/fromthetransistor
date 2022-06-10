from fileio import Io
from tokenizer import Tokenizer
from assembler import Assembler

# free format
# one-pass or two-pass?


class Instruction:
    # Optional. If present it's equal to the address into which the first byte of object code
    # generated for the instruction will be loaded.
    label = None
    opcode = None


# whitespace separates label, opcode, operand, and comment
# comma separates operands
# asterisk before an entire line of comment
# semicolon marks the start of comment
def parse_line():
    label = None
    opcode = None

def main():
    contents = Io.read_file()
    tokenizer = Tokenizer(contents)
    print(tokenizer.instructions)
    assembler = Assembler(tokenizer.instructions)
    Io.write_file(assembler.bin_instructions)

def read_file():
    pass

if __name__ == "__main__":
    main()
