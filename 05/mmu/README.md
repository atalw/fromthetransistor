## MMU

Memory management of a computer is pretty interesting. Unlike intuition suggests, in traditional OS's, each process running does not have access to the same underlying memory (RAM). In other words, the address space a process has access to, varies. This provides protection from accidentally overwriting another process's memory. This also has the added advantage of speeding up context switching between processes since each address maps to it's actual address in memory. Such OS's are called [Single address space operating systems](https://en.wikipedia.org/wiki/Single_address_space_operating_system). There are a couple of examples of these but the most famous used OS's like Linux, MacOS, and Windows do not use this scheme. Instead, a concept of a [virtual memory](https://en.wikipedia.org/wiki/Virtual_memory) is used because of it's flexibility and security.

The idea of virtual memory is to provide a unique address space to each process, create a mapping to a real address in physical memory, and perform translations from virtual to physical memory when required. This gives a process isolation from other processes running on the same OS which frees the application from implementing shared memory logic. So as a result, each process views memory as a contiguous address space and the low-level implementation is left up to the OS and hardware. A major use case is making more memory available to a process that is actually physically present through the use of [paging](https://en.wikipedia.org/wiki/Memory_paging) or segmentation. The idea simply is to swap out data that is not being used currently in RAM with disk storage usually found in an HDD or SSD, therby extending RAM.

The hardware that performs the translation from a virtual to physical address is called a Memory Management Unit ([MMU](https://en.wikipedia.org/wiki/Memory_management_unit)). Usually, the MMU divides a virtual [address space](https://en.wikipedia.org/wiki/Address_space) into [pages](https://en.wikipedia.org/wiki/Page_(computer_memory)), each ranging from a few KB to MB (or even GB). Therefore, an address space is an array of pages, and each page is an array of addresses. A virtual address contains a page index (called a page table entry ([PTE](https://en.wikipedia.org/wiki/Page_table#Page_table_entry)) in it's high bits and an offset (address offset from the start of the page) in it's low bits. The MMU queries a Translation Lookup Buffer ([TLB](https://en.wikipedia.org/wiki/Translation_lookaside_buffer)), which is a cache of previously accessed pages to speed up the translation compute, for a particular virtual address and if it exists (TLB hit) the translation is returned. If it doesn't exist ([TLB miss](https://en.wikipedia.org/wiki/Translation_lookaside_buffer#TLB-miss_handling)), the page table walker (which is a separate unit) searches the table of translations (page table) and updates the TLB with the requested page. The instruction is reset and then the TLB returns the translation. If an address is not found even in the page table, a page fault is returned.

Each page table entry ([PTE](https://en.wikipedia.org/wiki/Page_table#Page_table_entry)) holds the mapping between a virtual address of a page and the address of a physical frame. There is also auxiliary information about the page such as a present bit, a dirty or modified bit, address space or process ID information, amongst others.

Secondary storage, such as a hard disk drive, can be used to augment physical memory. Pages can be paged in and out of physical memory and the disk. The present bit can indicate what pages are currently present in physical memory or are on disk, and can indicate how to treat these different pages, i.e. whether to load a page from disk and page another page in physical memory out.

The dirty bit allows for a performance optimization. A page on disk that is paged in to physical memory, then read from, and subsequently paged out again does not need to be written back to disk, since the page has not changed. However, if the page was written to after it is paged in, its dirty bit will be set, indicating that the page must be written back to the backing store.

### Spec

- Memory address 32-bit
- Page size 4k
- Single-level lookup
- 64 entry data TLB
- Table walk unit


### Read
- [MMU](https://en.wikipedia.org/wiki/Memory_management_unit)
- [Memory hierarchy](https://en.wikipedia.org/wiki/Memory_hierarchy)
- [Memory management lecture](https://cseweb.ucsd.edu/classes/su09/cse120/lectures/Lecture7.pdf)
- [Page table](https://en.wikipedia.org/wiki/Page_table)
- [Dirty bit](https://en.wikipedia.org/wiki/Dirty_bit)
- [Single address space OS](https://en.wikipedia.org/wiki/Single_address_space_operating_system)
- [Hash collision](https://en.wikipedia.org/wiki/Hash_collision)
- [Thrashing](https://en.wikipedia.org/wiki/Thrashing_(computer_science))
- [Working set](https://en.wikipedia.org/wiki/Working_set)
- [Page replacement algorithm](https://en.wikipedia.org/wiki/Page_replacement_algorithm)
- [Cache associativity](http://csillustrated.berkeley.edu/PDFs/handouts/cache-3-associativity-handout.pdf)
- [W^X](https://en.wikipedia.org/wiki/W%5EX)
- [Hash table](https://en.wikipedia.org/wiki/Hash_table)
    - [Associative array](https://en.wikipedia.org/wiki/Associative_array)
- [Pigeonhole principle](https://en.wikipedia.org/wiki/Pigeonhole_principle)
- [Memory-mapped files](https://en.wikipedia.org/wiki/Memory-mapped_file)
