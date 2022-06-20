
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
    assert(len(e_phentsize) == 2)
    data += e_phentsize

    # Contains the number of entries in the program header table.
    assert(len(e_phnum) == 2)
    data += e_phnum

    # Contains the size of a section header table entry.
    assert(len(e_shentsize) == 2)
    data += e_shentsize

    # Contains the number of entries in the section header table.
    assert(len(e_shnum) == 2)
    data += e_shnum

    # Contains index of the section header table entry that contains the section names.
    assert(len(e_shstrndx) == 2)
    data += e_shstrndx


    if ei_data == 0:
        assert(len(data) == 52)
    else:
        assert(len(data) == 64)

    return data

# The program header table tells the system how to create a process image. It is found at file offset 
# e_phoff, and consists of e_phnum entries, each with size e_phentsize. The layout is slightly 
# different in 32-bit ELF vs 64-bit ELF, because the p_flags are in a different structure location 
# for alignment reasons. Each entry is structured as:
def program_header(ei_class, p_type):
    data = bytearray()

    assert(len(p_type) == 4)
    data += p_type

    # Segment-dependent flags (position for 64-bit structure).
    if ei_class == 1:
        p_flags = bytes([0, 0, 0, 0])
        data += p_flags

    # Offset of the segment in the file image.
    p_offset = None
    if ei_class == 0:
        p_offset = bytes([0, 0, 0, 0])
    else:
        p_offset = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_offset

    # Virtual address of the segment in memory.
    p_vaddr = None
    if ei_class == 0:
        p_vaddr = bytes([0, 0, 0, 0])
    else:
        p_vaddr = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_vaddr

    # On systems where physical address is relevant, reserved for segment's physical address.
    p_paddr = None
    if ei_class == 0:
        p_paddr = bytes([0, 0, 0, 0])
    else:
        p_paddr = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_paddr

    # Size in bytes of the segment in the file image. May be 0.
    p_filesz = None
    if ei_class == 0:
        p_filesz = bytes([0, 0, 0, 0])
    else:
        p_filesz = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_filesz

    # Size in bytes of the segment in memory. May be 0.
    p_memsz = None
    if ei_class == 0:
        p_memsz = bytes([0, 0, 0, 0])
    else:
        p_memsz = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_memsz

    # Segment-dependent flags (position for 32-bit structure).
    if ei_class == 0:
        p_flags = bytes([0, 0, 0, 0])
        data += p_flags

    # 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with 
    # p_vaddr equating p_offset modulus p_align.
    p_align = None
    if ei_class == 0:
        p_align = bytes([0, 0, 0, 0])
    else:
        p_align = bytes([0, 0, 0, 0, 0, 0, 0, 0])
    data += p_align

    if ei_class == 0:
        assert(len(data) == 0x20)
    else:
        assert(len(data) == 0x38)

    return data

def section_header(ei_class):
    data = bytearray()

    # An offset to a string in the .shstrtab section that represents the name of this section.
    sh_name = bytes([0, 0, 0, 0])
    data += sh_name

    # Identifies the type of this header.
    sh_type = bytes([0, 0, 0, 0])
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

def export(data):
    f = open("elf.bin", "wb")
    f.write(data)


def main():
    ei_class = 1 # bit format
    ei_data = 1 # endiannes
    ei_version = 1
    ei_osabi = 0x03 # aarch
    e_type = bytes([0, 0x02]) # file type
    e_machine = bytes([0, 0xb7]) # isa type
    e_entry = ei_class == 0 ? bytes([0, 0, 0, 0]) : bytes([0, 0, 0, 0, 0, 0, 0, 0]) # mem addr of entry point
    e_phoff = ei_class == 0 ? bytes([0, 0, 0, 0x34]) : bytes([0, 0, 0, 0, 0, 0, 0x40]) # program header table start
    e_shoff = ei_class == 0 ? bytes([0, 0, 0, 0x34+0x20]) : bytes([0, 0, 0, 0, 0, 0, 0x40+0x38]) # section header table start
    e_phentsize = ei_class == 0 ? bytes([0, 0x20]) : bytes([0, 0x38]) # program header size
    e_phnum = 
    e_shentsize = ei_class == 0 ? bytes([0, 0x28]) : bytes([0, 0x40]) # program header size
    e_shnum = len(
    e_shstrndx = 

    ei_class = 1
    data = file_header(32, 0, ei_class, 0, bytes([0, 0x02]), 0x03, bytes([0, 0, 0, 0]), bytes([0, 0, 0, 0]), bytes([0, 0, 0, 0]), bytes([0, 0]), bytes([0, 0]), bytes([0, 0]), bytes([0, 0]), bytes([0, 0]))
    print(data)

    data += program_header(ei_class, bytes([0, 0, 0, 0]))
    print(data)

    data += section_header(ei_class)
    print(data)

    export(data)
    print("done writing")

if __name__ == "__main__":
    main()

