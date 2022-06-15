import sys
import os
from exceptions import InvalidArgs

class Io:
    def read_file() -> [str]:
        if len(sys.argv) != 2:
            raise InvalidArgs("Expected `python3 main.py asm.s`")

        path = os.path.join(os.getcwd(), f'{sys.argv[1]}')
        with open(path) as f:
            lines = f.readlines()
            print(lines)
            return lines if lines is not None else []

    def write_file(bin_encodings):
        print(bin_encodings)
        filename = sys.argv[1].split(".")[0] + ".bin"
        with open(filename, "w") as f:
            for enc in bin_encodings:
                f.write(enc)

