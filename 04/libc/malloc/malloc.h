#include <stddef.h>

#ifndef MALLOC_H
#define MALLOC_H

void *my_malloc(size_t);
void free(void*);
void *realloc(void*, size_t);
void print_heap();

#endif
