from enum import Enum, auto

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

def append_hex(s, h):
    b = bytearray(h)
    print(b)


def file_header(ei_class, ei_data, ei_version, ei_osabi, e_type, e_machine, e_entry, e_phoff, e_shoff,
        e_phentsize, e_phnum, e_shentsize, e_shnum, e_shstrndx):

    data = bytearray()

    # offset 0x00 are 4 byte magic numbers
    #  data.extend(bytes([0x7f]))
    data += bytes([0x7f])
    data += bytes([0x45, 0x4c, 0x46]) # ELF in hex

    # This byte is set to either 1 or 2 to signify 32- or 64-bit format, respectively.
    if ei_class == 0:
        data += bytes([0])
    else:
        data += bytes([1])

    # This byte is set to either 1 or 2 to signify little or big endianness, respectively. 
    # This affects interpretation of multi-byte fields starting with offset 0x10.
    data += bytes([ei_data])

    # Set to 1 for the original and current version of ELF.
    data += bytes([ei_version])

    # Identifies the target operating system ABI.
    data += bytes([ei_osabi])

    # Further specifies the ABI version. Its interpretation depends on the target ABI.
    data += bytes([0x00])

    # Reserved padding bytes. Currently unused. Should be filled with zeros and ignored when read.
    # 7 bytes
    data += bytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

    # Identifies object file type.
    data += bytes(e_type)

    # Specifies target instruction set architecture. 2 bytes
    data += bytes([0x00, e_machine])

    # Set to 1 for the original version of ELF. 4 bytes
    data += bytes([0x00, 0x00, 0x00, ei_version])

    # This is the memory address of the entry point from where the process starts executing.
    # If the file doesn't have an associated entry point, then this holds zero.
    if ei_data == 0:
        # 32-bit, 4 bytes long
        assert(len(e_entry) == 4)
        data += e_entry
    else:
        # 64-bit, 8 bytes long
        assert(len(e_entry) == 8)
        data += e_entry

    # Points to the start of the program header table.
    if ei_data == 0:
        # 32-bit, 4 bytes long
        assert(len(e_phoff) == 4)
        data += e_phoff
    else:
        # 64-bit, 8 bytes long
        assert(len(e_phoff) == 8)
        data += e_phoff

    # Points to the start of the section header table.
    if ei_data == 0:
        # 32-bit, 4 bytes long
        assert(len(e_shoff) == 4)
        data += e_shoff
    else:
        # 64-bit, 8 bytes long
        assert(len(e_shoff) == 8)
        data += e_shoff

    # Interpretation of this field depends on the target architecture. 4 bytes
    e_flag = bytes([0, 0, 0, 0])
    data += e_flag

    # Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    # 2 bytes
    e_ehsize = None
    if ei_data == 0:
        e_ehsize = 52
    else:
        e_ehsize = 64

    assert(len(bytes([0, e_ehsize])) == 2)
    data += bytes([0, e_ehsize])

    # Contains the size of a program header table entry.
    data += gb(e_phentsize, 2)

    # Contains the number of entries in the program header table.
    data += gb(e_phnum, 2)

    # Contains the size of a section header table entry.
    data += gb(e_shentsize, 2)

    # Contains the number of entries in the section header table.
    data += gb(e_shnum, 2)

    # Contains index of the section header table entry that contains the section names.
    assert(len(e_shstrndx) == 2)
    data += e_shstrndx

    if ei_data == 0:
        assert(len(data) == 52)
    else:
        assert(len(data) == 64)

    return data

class Segment:
    section_data = []
    section_headers = []

    def __init__(self):
        pass

    def new_section(self, stype, data):
        section = Section(stype, data)
        self.section_data.append(section.data)
        self.section_headers.append(section.header)


# Program header: https://docs.oracle.com/cd/E19683-01/816-1386/chapter6-83432/index.html

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
        data = bytearray()

        ptype = gb(p_type.value, 4)
        data += ptype

        # Segment-dependent flags (position for 64-bit structure).
        if ei_class == 2:
            p_flags = gb(p_flags.value, 4)
            data += p_flags

        # Offset of the segment in the file image.
        if ei_class == 1:
            p_offset = gb(offset, 4)
        else:
            p_offset = gb(offset, 8)

        data += p_offset

        # Virtual address of the segment in memory.
        p_vaddr = None
        if ei_class == 1:
            p_vaddr = bytes([0, 0, 0, 0])
        else:
            p_vaddr = bytes([0, 0, 0, 0, 0, 0, 0, 0])

        data += p_vaddr

        # On systems where physical address is relevant, reserved for segment's physical address.
        p_paddr = None
        if ei_class == 1:
            p_paddr = bytes([0, 0, 0, 0])
        else:
            p_paddr = bytes([0, 0, 0, 0, 0, 0, 0, 0])

        data += p_paddr

        # Size in bytes of the segment in the file image. May be 0.
        p_filesz = None
        if ei_class == 1:
            p_filesz = bytes([0, 0, 0, 0])
        else:
            p_filesz = bytes([0, 0, 0, 0, 0, 0, 0, 0])

        data += p_filesz

        # Size in bytes of the segment in memory. May be 0.
        p_memsz = None
        if ei_class == 1:
            p_memsz = bytes([0, 0, 0, 0])
        else:
            p_memsz = bytes([0, 0, 0, 0, 0, 0, 0, 0])

        data += p_memsz

        # Segment-dependent flags (position for 32-bit structure).
        if ei_class == 1:
            p_flags = gb(p_flags, 4)
            data += p_flags

        # 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with 
        # p_vaddr equating p_offset modulus p_align.
        p_align = None
        if ei_class == 1:
            p_align = bytes([0, 0, 0, 0])
        else:
            p_align = bytes([0, 0, 0, 0, 0, 0, 0, 0])

        data += p_align

        if ei_class == 1:
            assert(len(data) == 0x20)
        else:
            assert(len(data) == 0x38)

        return data


class SType(Enum):
    TEXT = auto()
    RODATA = auto()
    DATA = auto()
    BSS = auto()
    SYMTAB = auto()
    STRTAB = auto()
    SHSTRTAB = auto()

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

class Section:
    data = None
    header = None

    def __init__(self, stype, data):
        match stype:
            case SType.TEXT:
                sh_type = SHType.SHT_PROGBITS
                self.data = self.section_data(sh_type.value, data)
                self.header = self.section_header(sh_type.value)
            case SType.RODATA:
                sh_type = SHType.SHT_PROGBITS
                pass
            case SType.DATA:
                sh_type = SHType.SHT_PROGBITS
                pass
            case SType.BSS:
                sh_type = SHType.SHT_NOBITS
                pass
            case SType.SYMTAB:
                sh_type = SHType.SHT_SYMTAB
                pass
            case SType.STRTAB:
                sh_type = SHType.SHT_STRTAB
                pass
            case SType.SHSTRTAB:
                sh_type = SHType.SHT_STRTAB
                pass

    def section_data(self, sh_type, data):
        return "hello"

    def section_header(self, sh_type):
        data = bytearray()

        # An offset to a string in the .shstrtab section that represents the name of this section.
        sh_name = bytes([0, 0, 0, 0])
        data += sh_name

        # Identifies the type of this header.
        sh_type = gb(sh_type, 4)
        data += sh_name

        # Identifies the attributes of the section.
        sh_flags = None
        if ei_class == 0:
            sh_flags = bytes([0, 0, 0, 0])
        else:
            sh_flags = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_flags

        # Virtual address of the section in memory, for sections that are loaded.
        sh_addr = None
        if ei_class == 0:
            sh_addr = bytes([0, 0, 0, 0])
        else:
            sh_addr = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_addr

        # Offset of the section in the file image.
        sh_offset = None
        if ei_class == 0:
            sh_offset = bytes([0, 0, 0, 0])
        else:
            sh_offset = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_offset

        # Size in bytes of the section in the file image. May be 0.
        sh_size = None
        if ei_class == 0:
            sh_size = bytes([0, 0, 0, 0])
        else:
            sh_size = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_size

        # Contains the section index of an associated section. This field is used for several purposes,
        # depending on the type of section.
        sh_link = bytes([0, 0, 0, 0])
        data += sh_link

        # Contains extra information about the section. This field is used for several purposes, 
        # depending on the type of section.
        sh_info = bytes([0, 0, 0, 0])
        data += sh_info

        # Contains the required alignment of the section. This field must be a power of two.
        sh_addralign = None
        if ei_class == 0:
            sh_addralign = bytes([0, 0, 0, 0])
        else:
            sh_addralign = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_addralign

        # Contains the size, in bytes, of each entry, for sections that contain fixed-size entries. 
        # Otherwise, this field contains zero.
        sh_entsize = None
        if ei_class == 0:
            sh_entsize = bytes([0, 0, 0, 0])
        else:
            sh_entsize = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_entsize

        if ei_class == 0:
            assert(len(data) == 0x28)
        else:
            assert(len(data) == 0x40)

        return data

def sections():
    # .text: Opcodes (binary assembly) that can be executed
    # .rodata: Read Only data like string constants
    # .data: Initialized global variables, space for values
    # .bss: Un-initialized global variables, no space for values
    # .symtab: Table of publicly available symbols for funcs/vars
    # .strtab: Null-terminated strings, often names of things in .symtab
    # .shstrab: Null-terminated strings, often names section headers
    # # .debug: Debug info from gcc -g in DWARF format
    # # .rel.text: Relocation information for .text section
    # # .rel.data: Relocation information for .data section


    pass

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
    ba = b
    if type(b) == int:
        ba = bytearray([b])

    assert(len(ba) <= size)
    ret = bytearray(size - len(ba)) + ba
    if ei_data == 1: # little endian
        return ret[::-1]
    else:
        return ret

def main():
    global ei_class, ei_data
    obj = import_obj("linux-main.o")

    ei_class = obj[4]
    ei_data = obj[5]
    ei_version = obj[6]
    ei_osabi = obj[7] # Unix - System V
    e_type = 0x03 # shared object file
    e_machine = obj[0x12:0x14] # isa type: aarch64
    e_entry = gb(0, 4) if ei_class == 1 else gb(0, 8) # mem addr of entry point TODO
    e_phoff = 0x34 if ei_class == 1 else 0x40 # program header table start

    e_phentsize = 0x20 if ei_class == 1 else 0x38 # program header size
    e_shentsize = 0x28 if ei_class == 1 else 0x40 # section header size

    section_types = [SType.TEXT, SType.TEXT]
    segments = []
    data = ""

    segment = Segment()

    for stype in section_types:
        segment.new_section(stype, data)

    segments.append(segment)

    print(len(segments), segments[0].section_headers)

    section_offset = e_phoff + (len(segments) * e_phentsize)
    pht = ProgramHeaderTable(segments, section_offset)
    e_phnum = len(pht.headers)

    section_header_offset = section_offset + sum([len(data) for seg in segments for data in seg.section_data])

    print(e_phoff, e_phentsize, section_offset, section_header_offset)

    e_shoff = section_header_offset
    e_shnum = sum([len(seg.section_headers) for seg in segments])
    #  e_shstrndx = 28 # TODO?

    print(e_shoff, e_shnum)

    exit()

    file_header = file_header(ei_class, ei_data, ei_version, ei_osabi, e_type, e_machine, e_entry, e_phoff,
            e_shoff, e_phentsize, e_phnum, e_shentsize, e_shnum, e_shstrndx)


    data = file_header + program_header + sections + section_header

    export_exec(data)
    print("done writing")

if __name__ == "__main__":
    main()

