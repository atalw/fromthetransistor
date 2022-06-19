## libc + malloc

#### Concepts

- [Anatomy of a Program in Memory](https://web.archive.org/web/20180206141815/https://manybutfinite.com/post/anatomy-of-a-program-in-memory/)
- [How the Kernel Manages Memory](https://web.archive.org/web/20180128210131/https://manybutfinite.com/post/how-the-kernel-manages-your-memory/)
- [Memory management](https://en.wikipedia.org/wiki/Memory_management)
- [Virtual memory](https://en.wikipedia.org/wiki/Virtual_memory)
- [Virtual address space](https://en.wikipedia.org/wiki/Virtual_address_space)
- [Memory paging](https://en.wikipedia.org/wiki/Memory_paging)
- [Red-black tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree): A program's VMAs are stored in its memory descriptor both as a linked list in the mmap field, ordered by starting virtual address, and as a red-black tree rooted at the mm\_rb field.
- Types of memory management in C
    - [Static](https://en.wikipedia.org/wiki/Static_variable)
    - [Automatic](https://en.wikipedia.org/wiki/Automatic_variable)
    - [Dynamic](https://en.wikipedia.org/w/index.php?title=Dynamic_memory_allocation&redirect=no): `malloc` dynamically allocates space in the heap
- [RAII](https://en.wikipedia.org/wiki/Resource_acquisition_is_initialization)
- [C dynamic memory allocation](https://en.wikipedia.org/wiki/C_dynamic_memory_allocation): description of `malloc` and `calloc`

#### Additional reads
- [Return-to-libc attack](https://en.wikipedia.org/wiki/Return-to-libc_attack)
- [Buffer overflow](https://en.wikipedia.org/wiki/Buffer_overflow)
- [Stack buffer overflow](https://en.wikipedia.org/wiki/Stack_buffer_overflow)

