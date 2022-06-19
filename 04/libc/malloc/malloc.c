/* https://man7.org/linux/man-pages/man3/malloc.3.html */
/* https://man7.org/linux/man-pages/man2/sbrk.2.html */
/* https://man7.org/linux/man-pages/man2/mmap.2.html */

/* Normally, malloc() allocates memory from the heap, and adjusts */
/* the size of the heap as required, using sbrk().  When allocating */
/* blocks of memory larger than MMAP_THRESHOLD bytes, the glibc */
/* malloc() implementation allocates the memory as a private */
/* anonymous mapping using mmap(2).  MMAP_THRESHOLD is 128 kB by */
/* default, but is adjustable using mallopt(3). */

/* Helpful blog post: https://danluu.com/malloc-tutorial/ */

#include <stddef.h>
#include <unistd.h>
#include <sys/mman.h>
#include <assert.h>
#include <string.h>
/* #ifdef PRINT_DEBUG */
#include <stdio.h>
/* #endif */
#include "malloc.h"


/* Naive because it does not store meta information about the block ie. size and use status. That means */
/* free and realloc cannot be done with the pointer returned from this method. */
void *naive_malloc(size_t size) {
    if (size == 0) {
        return NULL;
    }
    /* sbrk is deprecated, use mmap instead
     * brk()/sbrk() are not implemented in the kernel on the newer ports to aarch64 and risc-v
     * The jemalloc manpage (http://jemalloc.net/jemalloc.3.html) has this to say:
     * Traditionally, allocators have used sbrk(2) to obtain memory, which is suboptimal for
     * several reasons, including race conditions, increased fragmentation, and artificial limitations
     * on maximum usable memory. If sbrk(2) is supported by the operating system, this allocator
     * uses both mmap(2) and sbrk(2), in that order of preference; otherwise only mmap(2) is used.
     */
    /* void *req = sbrk(size); */
    void *req = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (req == (void *) -1) { // couldn't allocate
        return NULL;
    } else {
        return req;
    }
}

/* Now we need a header which stores meta data for the block we will allocate using malloc */
/* It contains the size of the block, a status which says whether the block is free (1) or in use (0), */
/* and a pointer to the next block. It'll form a linked list of blocks allocated in the heap by malloc. */
struct block_header {
    struct block_header *next;
    size_t size;
    int free;
};

#define HEADER_SIZE sizeof(struct block_header)

void *heap_base = NULL;

/* Search previously allocated blocks for free space >= size. Reuse if it exists, otherwise allocate new */
/* space using mmap. Note: it does not initialize the allocated space. */
void *my_malloc(size_t size) {
    if (size == 0) {
        return NULL;
    }

    struct block_header *last;
    /* if heap base is not null, then search through allocated blocks */
    if (heap_base != NULL) {
        struct block_header *current = heap_base;
        while (current != NULL && (current->free == 0 || current->size < size)) {
            last = current;
            current = current->next;
        }

        /* If we found a block which is free and >= size, update it's status to in use and return */
        if (current != NULL) {
            current->free = 0;
            return current;
        }
    }

    /* Since either there is no free space big enough or heap base is null, allocate new a memory block */
    void *req = mmap(NULL, size + HEADER_SIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (req == (void *) -1) { // couldn't allocate
        return NULL;
    } else {
        struct block_header *block = req;
        block->next = NULL;
        block->size = size; // note size here excludes header size
        block->free = 0;
        /* If this is the first block, set it as heap_base, otherwise link it to the last block */
        if (heap_base == NULL) {
            heap_base = block;
        } else {
            last->next = block;
        }
        return block;
    }
}

/* Marks the block as free to use */
void free(void *ptr) {
    if (ptr == NULL) {
        return;
    }

    struct block_header *header = ptr;
    assert(header->free == 0);
    header->free = 1;
}


/* Modify the size of the provided block in-place. If it can't because of size constraints, then find  */
/* a new block and return it's address */
void *realloc(void *ptr, size_t size) {
    if (!ptr) {
        return my_malloc(size);
    }

    struct block_header *header = (struct block_header *) ptr;
    if (header->size >= size) {
        return ptr;
    }

    void *new_ptr = my_malloc(size);
    if (new_ptr == (void *) -1) {
        return NULL;
    }

    memcpy(new_ptr, ptr, size);
    free(ptr);
    return new_ptr;
}

void print_heap() {
    if (heap_base == NULL) { return; }

    struct block_header *current = heap_base;

    while (current != NULL) {
        printf("block: %p\n"
            "   next: %p\n"
            "   size: %zu\n"
            "   free: %d\n", current, current->next, current->size, current->free);
        current = current->next;
    }
}
