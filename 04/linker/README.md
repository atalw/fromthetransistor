## ELF File

Programming this was unexpectedly hard but not because of the actual implementation. 
That is fairly straightforward. The main complexity arised due to the lack of reliable, in-depth, 
exhaustive resources on the subject. There is a certain degree of attention to detail required to 
implement this from the documentation since an important implementation detail which translates to 
20+ lines of code is mentioned as a single line in some obscure documentation.

That said, implementing this was a great exercise in figuring out a topic on my own since I couldn't 
find any relevent implementations, reliable stack overflow answers or blog posts. For future reference 
I've added links to all the resources I've used incase you're learning or I revisit to extend it.

### How to use
- First, compile a program without linking. This will generate an object file. So for C, use
```
gcc -c main.c
```
- Pass `main.o` to `linker.py` (right now the file name is hardcoded in) and run
```
python3 linker.py
```
- This will generate an `elf.out` file which can be inspected using
```
readelf -a elf.out
```
- Execute using
```
./elf.out
```

You may have to give permissions to the executable using `chmod`.

### Links
- [Binutils readelf implementation](https://github.com/bminor/binutils-gdb/blob/master/binutils/readelf.c): Really helpful in understanding `readelf`'s error messages
- [ELF Wikipedia](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format): Implementation barebones from here
- [Oracle ELF documentation](https://docs.oracle.com/cd/E19683-01/816-1386/6m7qcoblh/index.html): Only resource I could find with details like `p_flag`, `sh_name` values etc. It's a careful read. A lot is communicated in a to-the-point manner.
- [Oracle Dynamic linking documentation](https://docs.oracle.com/cd/E19683-01/816-1386/6m7qcoblk/index.html)
- [An Evil Copy: How the Loader Betrays You](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/12/corev-ndss17.pdf): Interesting read
- [Linking](http://pld.cs.luc.edu/courses/264/spr19/notes/linking.html)
- [How to execute an object file (Cloudflare blog)](https://blog.cloudflare.com/how-to-execute-an-object-file-part-1/): Wish I found this sooner

### TODO
- Relocation sections
- Multiple segments
- Offset (`addralign`)
- Parsing symbol table
- Expand supported sections
    - Right now, only these are supported: `.text, .rodata, .data, .bss, .symtab, .strtab, .shstrab`
- Virtual address
- Combining multiple object files
