from enum import Enum

# Structure:
# ----
# ELF header -> indentify as an elf type + specify the arch
#   * 52/64 bytes long for 32/64 bit binaries
#   * https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header
# Program header table -> execution information
# ----
# Code -> executable information
# Data -> information used by the code
# Section names
# ----
# Section header table -> linking (connecting program objects) information
# ----

ei_class = None
ei_data = None


class ELFHeader:
    # offset 0x00 are 4 byte magic numbers (0x7f + ELF in hex)
    magic = None
    # This byte is set to either 1 or 2 to signify 32- or 64-bit format, respectively.
    ei_class = None
    # This byte is set to either 1 or 2 to signify little or big endianness, respectively.
    # This affects interpretation of multi-byte fields starting with offset 0x10.
    ei_data = None
    # Set to 1 for the original and current version of ELF.
    ei_version = None
    # Identifies the target operating system ABI.
    ei_osabi = None
    # Further specifies the ABI version. Its interpretation depends on the target ABI.
    ei_abiversion = None
    # Identifies object file type.
    e_type = None
    # Specifies target instruction set architecture. 2 bytes
    e_machine = None
    # This is the memory address of the entry point from where the process starts executing.
    # If the file doesn't have an associated entry point, then this holds zero.
    # 32-bit, 4 bytes long or 64-bit, 8 bytes long
    e_entry = None
    # Points to the start of the program header table.
    e_phoff = None
    # Points to the start of the section header table.
    e_shoff = None
    # Interpretation of this field depends on the target architecture. 4 bytes
    e_flags = None
    # Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    e_ehsize = None
    # Contains the size of a program header table entry.
    e_phentsize = None
    # Contains the number of entries in the program header table.
    e_phnum = None
    # Contains the size of a section header table entry.
    e_shentsize = None
    # Contains the number of entries in the section header table.
    e_shnum = None
    # Contains index of the section header table entry that contains the section names.
    e_shstrndx = None

    def __init__(self, data):
        self.magic = bytearray([0x7f, 0x45, 0x4c, 0x46])
        self.ei_class = data[4]
        self.ei_data = data[5]
        self.ei_version = data[6]
        self.ei_osabi = data[7] # Unix - System V
        self.ei_abiversion = data[8]
        self.e_type = 0x03 # shared object file
        self.e_machine = data[0x12:0x14] # isa type: aarch64
        self.e_entry = gb(0, 4) if self.ei_class == 1 else gb(0, 8) # mem addr of entry point TODO
        self.e_phoff = 0x34 if self.ei_class == 1 else 0x40 # program header table start
        self.e_phentsize = 0x20 if self.ei_class == 1 else 0x38 # program header size
        self.e_shentsize = 0x28 if self.ei_class == 1 else 0x40 # section header size
        self.e_flags = 0
        self.eh_size = 0x34 if self.ei_class == 1 else 0x40

        global ei_class, ei_data
        ei_class = self.ei_class
        ei_data = self.ei_data

    def to_bin(self):
        assert(len(self.e_machine) == 2)

        data = bytearray()
        data += self.magic
        data += gb(self.ei_class, 1)
        data += gb(self.ei_data, 1)
        data += gb(self.ei_version, 1)
        data += gb(self.ei_osabi, 1)
        data += gb(self.ei_abiversion, 1)
        data += gb(0, 7) # padding
        data += gb(self.e_type, 2)
        data += self.e_machine
        data += gb(self.ei_version, 4)
        data += gb(self.e_entry, 4) if self.ei_class == 1 else gb(self.e_entry, 8)
        data += gb(self.e_phoff, 4) if self.ei_class == 1 else gb(self.e_phoff, 8)
        data += gb(self.e_shoff, 4) if self.ei_class == 1 else gb(self.e_shoff, 8)
        data += gb(self.e_flags, 4)
        data += gb(self.eh_size, 2)
        data += gb(self.e_phentsize, 2)
        data += gb(self.e_phnum, 2)
        data += gb(self.e_shentsize, 2)
        data += gb(self.e_shnum, 2)
        data += gb(self.e_shstrndx, 2)

        assert(len(data) == 0x34 if ei_class == 1 else len(data) == 0x40)
        return data


# Identifies the type of the segment.
class PType(Enum):
    PT_NULL = 0
    PT_LOAD = 1
    PT_DYNAMIC = 2
    PT_INTERP = 3
    PT_NOTE = 4
    PT_SHLIB = 5
    PT_PHDR = 6
    PT_TLS = 7
    PT_LOOS = 0x60000000
    PT_HIOS = 0x6FFFFFFF
    PT_LOPROC = 0x70000000
    PT_HIPROC = 0x7FFFFFFF

# A program to be loaded by the system must have at least one loadable segment, although this is not
# required by the file format. When the system creates loadable segment memory images, it gives access
# permissions, as specified in the p_flags member. All bits included in the PF_MASKPROC mask are
# reserved for processor-specific semantics.
class PFlags(Enum):
    PF_X = 1 # execute
    PF_W = 2 # write
    PF_WX = 3 # write + exec
    PF_R = 4 # read
    PF_RX = 5 # read + exec
    PF_RW = 6 # read + write
    PF_RWX = 7 # read + write + exec
    PF_MASKPROC = 0xf0000000

# Program header: https://docs.oracle.com/cd/E19683-01/816-1386/chapter6-83432/index.html
class ProgramHeader:
    # Identifies the type of the segment.
    p_type = None
    # Segment-dependent flags (position for 64-bit structure).
    p_flags = None
    # Offset of the segment in the file image.
    p_offset = None
    # Virtual address of the segment in memory.
    p_vaddr = None
    # On systems where physical address is relevant, reserved for segment's physical address.
    p_paddr = None
    # Size in bytes of the segment in the file image. May be 0.
    p_filesz = None
    # Size in bytes of the segment in memory. May be 0.
    p_memsz = None
    # Segment-dependent flags (position for 32-bit structure).
    p_flags = None
    # 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with 
    # p_vaddr equating p_offset modulus p_align.
    p_align = None

    def __init__(self, p_type, p_flags, offset):
        self.p_type = p_type
        self.p_flags = p_flags
        self.offset = offset

        # TODO
        self.p_vaddr = 0
        self.p_paddr = 0
        self.p_filesz = 0
        self.p_memsz = 0
        self.p_align = 0

    def to_bin(self):
        data = bytearray()

        data += gb(self.p_type.value, 4)
        if ei_class == 2:
            data += gb(self.p_flags.value, 4)
        data += gb(self.offset, 4) if ei_class == 1 else gb(self.offset, 8)
        data += gb(self.p_vaddr, 4) if ei_class == 1 else gb(self.p_vaddr, 8)
        data += gb(self.p_paddr, 4) if ei_class == 1 else gb(self.p_paddr, 8)
        data += gb(self.p_filesz, 4) if ei_class == 1 else gb(self.p_filesz, 8)
        data += gb(self.p_memsz, 4) if ei_class == 1 else gb(self.p_memsz, 8)
        if ei_class == 1:
            data += gb(self.p_flags.value, 4)
        data += gb(self.p_align, 4) if ei_class == 1 else gb(self.p_align, 8)
        assert(len(data) == 0x20 if ei_class == 1 else len(data) == 0x38)

        return data

# The program header table tells the system how to create a process image. It is found at file offset
# e_phoff, and consists of e_phnum entries, each with size e_phentsize. The layout is slightly
# different in 32-bit ELF vs 64-bit ELF, because the p_flags are in a different structure location
# for alignment reasons. Each entry is structured as:
class ProgramHeaderTable:
    headers = []

    def __init__(self, segments, offset):
        for seg in segments:
            header = self.new_header(PType.PT_LOAD, PFlags.PF_RX, offset)
            self.headers.append(header)
            offset += sum([len(x) for x in seg.section_data])

    def new_header(self, p_type, p_flags, offset):
        return ProgramHeader(p_type, p_flags, offset)

    def to_bin(self):
        data = bytearray()
        for header in self.headers:
            data += header.to_bin()
        return data

class SHName(Enum):
    UNDEF = ""
    BSS = ".bss"
    COMMENT = ".comment"
    CTORS = ".ctors"
    DATA = ".data"
    DATA1 = ".data1"
    DEBUG = ".debug"
    DTORS = ".dtors"
    DYNAMIC = ".dynamic"
    DYNSTR = ".dynstr"
    DYNSYM = ".dynsym"
    FINI = ".fini"
    GNUVER = ".gnu.version"
    GNUVERD = ".gnu.version.d"
    GNUVERR = ".gnu.version.r"
    GOT = ".got"
    HASH = ".hash"
    INIT = ".init"
    INTERP = ".interp"
    LINE = ".line"
    NOTE = ".note"
    NOTEABI = ".note.ABI-tag"
    NOTEGNUB = ".note.gnu.build-id"
    NOTEGNUS = ".note.GNU-stack"
    NOTEBSD = ".note.openbsd.ident"
    PLT = ".plt"
    RELTEXT = ".rel.text" # shortcut (only support .rel.text)
    RELATEXT = ".rela.text"
    RODATA = ".rodata"
    RODATA1 = ".rodata1"
    SHSTRTAB = ".shstrtab"
    STRTAB = ".strtab"
    SYMTAB = ".symtab"
    TEXT = ".text"

    def __str__(self):
        return "." + self.name.lower()

    @classmethod
    def has_value(cls, value):
        return value in cls._value2member_map_

class SHType(Enum):
    SHT_NULL = 0
    SHT_PROGBITS = 1
    SHT_SYMTAB = 2
    SHT_STRTAB = 3
    SHT_RELA = 4
    SHT_HASH = 5
    SHT_DYNAMIC = 6
    SHT_NOTE = 7
    SHT_NOBITS = 8
    SHT_REL = 9

    @classmethod
    def has_value(cls, value):
        return value in cls._value2member_map_ 

class SHFlag(Enum):
    UNDEF = 0
    SHF_WRITE = 0x1
    SHF_ALLOC = 0x2
    SHF_EXECINSTR = 0x4
    SHF_MERGE = 0x10
    SHF_STRINGS = 0x20
    SHF_INFO_LINK = 0x40
    SHF_LINK_ORDER = 0x80
    SHF_OS_NONCONFORMING = 0x100
    SHF_GROUP = 0x200
    SHF_TLS = 0x400
    SHF_MASKOS = 0x0FF00000
    SHF_MASKPROC = 0xF0000000
    SHF_ORDERED = 0x4000000
    SHF_EXCLUDE = 0x8000000

    @classmethod
    def has_value(cls, value):
        return value in cls._value2member_map_ 

class SectionHeader:
    sh_name = None
    # An offset to a string in the .shstrtab section that represents the name of this section.
    sh_name_offset = None
    # Identifies the type of this header.
    sh_type = None
    # Identifies the attributes of the section.
    sh_flags = None
    # Virtual address of the section in memory, for sections that are loaded.
    sh_addr = None
    # Offset of the section in the file image.
    sh_offset = None
    # Size in bytes of the section in the file image. May be 0.
    sh_size = None
    # Contains the section index of an associated section.
    sh_link = None
    # Contains extra information about the section.
    sh_info = None
    # Contains the required alignment of the section. This field must be a power of two.
    sh_addralign = None
    # Contains the size, in bytes, of each entry, for sections that contain fixed-size entries. 
    # Otherwise, this field contains zero.
    sh_entsize = None

    def __init__(self, data):
        offset = 0

        self.sh_name_offset = data[offset:offset+4]
        offset += 4

        self.sh_type = pb(data[offset:offset+4])
        offset += 4

        if SHType.has_value(self.sh_type):
            self.sh_type = SHType(self.sh_type)
        else:
            raise Exception("Unknown sh type", self.sh_type)

        sh_flags = pb(data[offset:offset+4] if ei_class == 1 else data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        if sh_flags != 0:
            self.sh_flags = []
            for (pos, bit) in enumerate(bin(sh_flags)[:1:-1]):
                if int(bit) != 1:
                    continue
                val = pow(2, pos)
                if SHFlag.has_value(val):
                    self.sh_flags.append(SHFlag(val))
                else:
                    raise Exception("Unknown flag", val)
        else:
            self.sh_flags = [SHFlag.UNDEF]

        self.sh_addr = data[offset:offset+4] if ei_class == 1 else data[offset:offset+8]
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_offset= pb(data[offset:offset+4] if ei_class == 1 else data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_size = pb(data[offset:offset+4] if ei_class == 1 else data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_link = data[offset:offset+4]
        offset += 4

        self.sh_info = data[offset:offset+4]
        offset += 4

        self.sh_addralign = data[offset:offset+4] if ei_class == 1 else data[offset:offset+8]
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_entsize = data[offset:offset+4] if ei_class == 1 else data[offset:offset+8]
        offset = offset + 4 if ei_class == 1 else offset + 8

    def update_header_name(self, shstrtab_data):
        # parse name from shstrtab
        sh_name_start = pb(self.sh_name_offset)
        sh_name_end = sh_name_start
        if shstrtab_data[sh_name_start] != 0:
            while (shstrtab_data[sh_name_end]):
                sh_name_end += 1

        self.sh_name = shstrtab_data[sh_name_start:sh_name_end].decode('ascii')
        if SHName.has_value(self.sh_name):
            self.sh_name = SHName(self.sh_name)
        else:
            self.sh_name = SHName.UNDEF

    # Convert object to binary stream
    def to_bin(self):
        data = bytearray()
        data += gb(self.sh_name_offset, 4)
        data += gb(self.sh_type.value, 4)
        data += (gb(sum([sh_flags.value for sh_flags in self.sh_flags]), 4) 
                if ei_class == 1 else gb(sum([sh_flags.value for sh_flags in self.sh_flags]), 8))
        data += gb(0, 4) if ei_class ==1 else gb(0, 8) # sh_addr TODO
        data += gb(self.sh_offset, 4) if ei_class == 1 else gb(self.sh_offset, 8)
        data += gb(self.sh_size, 4) if ei_class == 1 else gb(self.sh_size, 8)
        data += gb(0, 4) # sh_link
        data += gb(0, 4) # sh_info
        data += gb(0, 4) if ei_class == 1 else gb(0, 8) # sh_addralign TODO
        data += gb(0, 4) if ei_class == 1 else gb(0, 8) # sh_entsize TODO

        assert(len(data) == 0x28 if ei_class == 1 else len(data) == 0x40)
        return data


class Section:
    def __init__(self, data, header):
        self.data = data
        self.header = header
        self.header.sh_size = len(data)

class Segment:
    section_data = []
    section_headers = []

    def new_section(self, section):
        self.section_headers.append(section.header)
        self.section_data.append(section.data)

    def data_to_bin(self):
        return bytearray().join(self.section_data)

    def headers_to_bin(self):
        data = bytearray()
        for header in self.section_headers:
            data += header.to_bin()
        return data


def import_obj(filename):
    f = open(filename, "rb")
    while True:
        content = f.read(-1)
        if not content:
            break
        return content
    return None

def export_exec(data):
    f = open("elf.bin", "wb")
    f.write(data)


# generate bytes given bytearray and size
def gb(b, size):
    if type(b) == int:
        return b.to_bytes(size, "little" if ei_data == 1 else "big")

    assert(len(b) <= size)
    ret = bytearray(size - len(b)) + b
    return ret[::-1] if ei_data == 1 else ret

# parse bytes
def pb(b):
    if type(b) == bytes:
        return int.from_bytes(b, "little" if ei_data == 1 else "big")
    elif type(b) == int:
        return b

    return int.from_bytes(b, "little" if ei_data ==1 else "big")

# ---- Parse the input object file ----
def parse_input(data) -> (ELFHeader, [Section]):
    elf_header = ELFHeader(data)

    shnum = pb(data[0x30:0x30+2] if ei_class == 1 else data[0x3c:0x3c+2])
    shoff = pb(data[0x20:0x20+4] if ei_class == 1 else data[0x28:0x28+8])

    section_headers = [] # section headers
    offset = shoff
    shstrtab = None

    for i in range(shnum):
        sh = SectionHeader(data[offset:offset+elf_header.e_shentsize])
        offset += elf_header.e_shentsize
        section_headers.append(sh)
        if sh.sh_type == SHType.SHT_STRTAB: # what about multiple sht_strtab sections? TODO
            shstrtab = sh

    print(len(section_headers))

    # Extract section names
    assert(shstrtab is not None)
    shstrtab_data = data[shstrtab.sh_offset:shstrtab.sh_offset+shstrtab.sh_size]
    sections = [] # section headers with data

    for sh in section_headers:
        # parse data from offset
        sh.update_header_name(shstrtab_data)
        sh_offset = sh.sh_offset
        sh_size = sh.sh_size
        s = Section(data[sh_offset:sh_offset+sh_size], sh)
        sections.append(s)

    return (elf_header, sections)

# Only supporting export of these sections for simplicity
# .text: Opcodes (binary assembly) that can be executed
# .rodata: Read Only data like string constants
# .data: Initialized global variables, space for values
# .bss: Un-initialized global variables, no space for values
# .symtab: Table of publicly available symbols for funcs/vars
# .strtab: Null-terminated strings, often names of things in .symtab
# .shstrab: Null-terminated strings, often names section headers
supported_sections = [SHName.TEXT, SHName.RODATA, SHName.DATA, SHName.BSS, SHName.SYMTAB, SHName.STRTAB, SHName.SHSTRTAB]

def main():
    obj = import_obj("linux-main.o")
    print(obj)

    elf_header, input_sections = parse_input(obj)

    segments = []
    shstrtab = None
    shstrtab_data = bytearray()

    # hardcode one segment
    segment = Segment()

    data_offset = 0
    sh_name_offset = 0
    idx = 0
    e_shstrndx = None
    for s in input_sections:
        if s.header.sh_name == SHName.SHSTRTAB:
            pass
        elif s.header.sh_name == SHName.STRTAB:
            symtab_idx = next((idx for idx, x in enumerate(segment.section_headers) if x.sh_name == SHName.SYMTAB), None)
            assert(symtab_idx is not None)
            print(symtab_idx)
            segment.section_headers[symtab_idx].sh_link = idx
            segment.section_headers[symtab_idx].sh_info = 12 # hardcoding just cuz
            strtab_index = len(input_sections) - idx

        if s.header.sh_name in supported_sections:
            s.header.sh_offset = data_offset
            segment.new_section(s)
            data_offset += len(s.data)

            str_name = bytearray(s.header.sh_name.value, 'ascii') + b'\x00'
            #  str_name = bytearray(s.header.sh_name.value, 'ascii')
            shstrtab_data += str_name
            sh_name_offset += len(str_name)
            if s.header.sh_name == SHName.SHSTRTAB:
                print("hereeeeeeee")
                print(s.header.sh_type)
                e_shstrndx = idx
            idx += 1

    assert(e_shstrndx is not None)

    segments.append(segment)

    section_offset = elf_header.e_phoff + (len(segments) * elf_header.e_phentsize)
    pht = ProgramHeaderTable(segments, section_offset)

    # update Elf header
    elf_header.e_phnum = len(pht.headers)
    elf_header.e_shoff = section_offset + sum([len(data) for seg in segments for data in seg.section_data])
    elf_header.e_shnum = sum([len(seg.section_headers) for seg in segments])
    elf_header.e_shstrndx = e_shstrndx

    data = elf_header.to_bin() + pht.to_bin() + segments[0].data_to_bin() + segments[0].headers_to_bin()
    print("--------------------------------------")
    print(data)

    # TODO
    # drain read function

    export_exec(data)
    print("done writing")

if __name__ == "__main__":
    main()

