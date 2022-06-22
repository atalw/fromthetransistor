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

def append_hex(s, h):
    b = bytearray(h)
    print(b)


def elf_header(ei_class, ei_data, ei_version, ei_osabi, e_type, e_machine, e_entry, e_phoff, e_shoff,
        e_phentsize, e_phnum, e_shentsize, e_shnum, e_shstrndx):

    data = bytearray()

    # offset 0x00 are 4 byte magic numbers (0x7f + ELF in hex)
    data += bytearray([0x7f, 0x45, 0x4c, 0x46])

    # This byte is set to either 1 or 2 to signify 32- or 64-bit format, respectively.
    data += gb(ei_class, 1)

    # This byte is set to either 1 or 2 to signify little or big endianness, respectively. 
    # This affects interpretation of multi-byte fields starting with offset 0x10.
    data += gb(ei_data, 1)

    # Set to 1 for the original and current version of ELF.
    data += gb(ei_version, 1)

    # Identifies the target operating system ABI.
    data += gb(ei_osabi, 1)

    # Further specifies the ABI version. Its interpretation depends on the target ABI.
    data += gb(0, 1)

    # Reserved padding bytes. Currently unused. Should be filled with zeros and ignored when read.
    # 7 bytes
    data += gb(0, 7)

    # Identifies object file type.
    data += gb(e_type, 2)

    # Specifies target instruction set architecture. 2 bytes
    assert(len(e_machine) == 2)
    data += e_machine

    # Set to 1 for the original version of ELF. 4 bytes
    data += gb(1, 4)

    # This is the memory address of the entry point from where the process starts executing.
    # If the file doesn't have an associated entry point, then this holds zero.
    # 32-bit, 4 bytes long or 64-bit, 8 bytes long
    data += gb(e_entry, 4) if ei_class == 1 else gb(e_entry, 8)

    # Points to the start of the program header table.
    data += gb(e_phoff, 4) if ei_class == 1 else gb(e_phoff, 8)

    # Points to the start of the section header table.
    data += gb(e_shoff, 4) if ei_class == 1 else gb(e_shoff, 8)

    # Interpretation of this field depends on the target architecture. 4 bytes
    data += gb(0, 4)

    # Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format.
    # 2 bytes
    data += gb(0x34 if ei_class == 1 else 0x40, 2)

    # Contains the size of a program header table entry.
    data += gb(e_phentsize, 2)

    # Contains the number of entries in the program header table.
    data += gb(e_phnum, 2)

    # Contains the size of a section header table entry.
    data += gb(e_shentsize, 2)

    # Contains the number of entries in the section header table.
    data += gb(e_shnum, 2)

    # Contains index of the section header table entry that contains the section names.
    data += gb(e_shstrndx, 2)

    assert(len(data) == 0x34 if ei_class == 1 else len(data) == 0x40)
    return data


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
    data_offset = None
    data_size = None

    def parse(self, header_data):
        offset = 0

        self.sh_name_offset = header_data[offset:offset+4]
        offset += 4

        self.sh_type = pb(header_data[offset:offset+4])
        offset += 4

        if SHType.has_value(self.sh_type):
            self.sh_type = SHType(self.sh_type)
        else:
            raise Exception("Unknown sh type", self.sh_type)

        sh_flags = pb(header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        if sh_flags != 0:
            self.sh_flags = []
            for (pos, bit) in enumerate(bin(sh_flags)[:1:-1]):
                if int(bit) == 1:
                    val = pow(2, pos)
                else:
                    continue
                if SHFlag.has_value(val):
                    self.sh_flags.append(SHFlag(val))
                else:
                    raise Exception("Unknown flag", val)
        else:
            self.sh_flags = [SHFlag.UNDEF]

        self.sh_addr = header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8]
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_offset= pb(header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_size = pb(header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8])
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_link = header_data[offset:offset+4]
        offset += 4

        self.sh_info = header_data[offset:offset+4]
        offset += 4

        self.sh_addralign = header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8]
        offset = offset + 4 if ei_class == 1 else offset + 8

        self.sh_entsize = header_data[offset:offset+4] if ei_class == 1 else header_data[offset:offset+8]
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

        sh_name = gb(self.sh_name_offset, 4)
        data += sh_name

        sh_type = gb(self.sh_type.value, 4)
        data += sh_type

        sh_flags = None
        if ei_class == 0:
            sh_flags = gb(sum([sh_flags.value for sh_flags in self.sh_flags]), 4)
        else:
            sh_flags = gb(sum([sh_flags.value for sh_flags in self.sh_flags]), 8)

        data += sh_flags

        # TODO
        sh_addr = None
        if ei_class == 0:
            sh_addr = bytes([0, 0, 0, 0])
        else:
            sh_addr = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_addr

        sh_offset = None
        if ei_class == 0:
            sh_offset = gb(self.data_offset, 4)
        else:
            sh_offset = gb(self.data_offset, 8)
        data += sh_offset

        sh_size = None
        if ei_class == 0:
            sh_size = gb(self.data_size, 4)
        else:
            sh_size = gb(self.data_size, 8)
        data += sh_size

        sh_link = gb(0, 4)
        data += sh_link

        sh_info = gb(0, 4)
        data += sh_info

        sh_addralign = None
        if ei_class == 0:
            sh_addralign = bytes([0, 0, 0, 0])
        else:
            sh_addralign = bytes([0, 0, 0, 0, 0, 0, 0, 0])
        data += sh_addralign

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


# Only supporting export of these sections for simplicity
# .text: Opcodes (binary assembly) that can be executed
# .rodata: Read Only data like string constants
# .data: Initialized global variables, space for values
# .bss: Un-initialized global variables, no space for values
# .symtab: Table of publicly available symbols for funcs/vars
# .strtab: Null-terminated strings, often names of things in .symtab
# .shstrab: Null-terminated strings, often names section headers
supported_sections = [SHName.TEXT, SHName.RODATA, SHName.DATA, SHName.BSS, SHName.SYMTAB, SHName.STRTAB, SHName.SHSTRTAB]

class Section:
    def __init__(self, data, header):
        self.data = data
        self.header = header
        self.header.data_size = len(data)

class Segment:
    section_data = []
    section_headers = []

    def new_section(self, section):
        self.section_headers.append(section.header)
        self.section_data.append(section.data)


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
def parse_input(data, e_shentsize) -> [Section]:
    shnum = pb(data[0x30:0x30+2]) if ei_class == 1 else pb(data[0x3c:0x3c+2])
    shoff = pb(data[0x20:0x20+4]) if ei_class == 1 else pb(data[0x28:0x28+8])

    shs = [] # section headers
    offset = shoff
    shstrtab = None

    for i in range(shnum):
        sh = SectionHeader()
        sh.parse(data[offset:offset+e_shentsize])
        offset += e_shentsize
        shs.append(sh)
        if sh.sh_type == SHType.SHT_STRTAB: # what about multiple sht_strtab sections? TODO
            shstrtab = sh

    # Extract section names
    assert(shstrtab is not None)
    shstrtab_data = data[shstrtab.sh_offset:shstrtab.sh_offset+shstrtab.sh_size]
    sections = [] # section headers with data

    for sh in shs:
        # parse data from offset
        sh.update_header_name(shstrtab_data)
        sh_offset = sh.sh_offset
        sh_size = sh.sh_size
        s = Section(data[sh_offset:sh_offset+sh_size], sh)
        sections.append(s)

    return sections

def main():
    global ei_class, ei_data
    obj = import_obj("linux-main.o")
    print(obj)

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

    # now we have to parse the input obj file, extract the sections to use them for our
    # final elf file

    input_sections = parse_input(obj, e_shentsize)

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
            s.header.data_offset = data_offset
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

    #  print(len(segments), segments[0].section_headers)

    section_offset = e_phoff + (len(segments) * e_phentsize)
    pht = ProgramHeaderTable(segments, section_offset)
    e_phnum = len(pht.headers)

    section_header_offset = section_offset + sum([len(data) for seg in segments for data in seg.section_data])

    #  print(e_phoff, e_phentsize, section_offset, section_header_offset)

    e_shoff = section_header_offset
    e_shnum = sum([len(seg.section_headers) for seg in segments])

    #  print(e_shoff, e_shnum)


    file_header = elf_header(ei_class, ei_data, ei_version, ei_osabi, e_type, e_machine, e_entry, e_phoff,
            e_shoff, e_phentsize, e_phnum, e_shentsize, e_shnum, e_shstrndx)

    program_headers = b''.join(pht.headers)
    section_data = b''.join(segments[0].section_data)
    section_headers = b''.join([header.to_bin() for header in segments[0].section_headers])

    #  print(program_headers)
    #  print("section data", section_data)

    data = file_header + program_headers + section_data + section_headers
    print("--------------------------------------")
    print(data)

    print("e_shnum: ", e_shnum)

    export_exec(data)
    print("done writing")

if __name__ == "__main__":
    main()

