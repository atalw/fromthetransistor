from fileio import Io
from tokenizer import Tokenizer
from assembler import Assembler

# free format
# one-pass or two-pass?

def main():
    contents = Io.read_file()
    tokenizer = Tokenizer(contents)
    assembler = Assembler(tokenizer.instructions)
    Io.write_file(assembler.bin_instructions)

if __name__ == "__main__":
    main()
