#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

/* Searches the first count bytes of buf for the first occurrence of c converted to an unsigned character. */
/* Better implementation: https://code.woboq.org/userspace/glibc/string/memchr.c.html */
void *memchr(const void *buf, int c, size_t count) {
    char * buf_ptr = (char *) buf;
    const unsigned char c_char = (const unsigned char) c;

    for (int i=0; i<count; i++) {
        if (*buf_ptr == c_char) {
            return buf_ptr;
        }
    }
    return NULL;
}

/* Compares up to count bytes of buf1 and buf2. */
int memcmp(const void *buf1, const void *buf2, size_t count) {
    char * buf1_ptr = (char *) buf1;
    char * buf2_ptr = (char *) buf2;

    /* Pointing to the same location */
    if (buf1 == buf2) {
        return 0;
    }

    for (int i=0; i<count; i++) {
        if (buf1_ptr < buf2_ptr) {
            return -1;
        } else if (buf1_ptr > buf2_ptr) {
            return 1;
        } else {
            buf1_ptr++;
            buf2_ptr++;
            continue;
        }
    }

    return 0;
}

/* Copies count bytes of src to dest. */
void *memcpy(void *dest, const void *src, size_t count) {
    char * dest_char = (char *) dest;
    const char * src_char = (const char *) src;

    if (dest_char != NULL && src_char != NULL) {
        for (int i=0; i<count; i++) {
            dest_char[i] = src_char[i];
        }
    }

    return dest_char;
}

/* Copies count bytes of src to dest. Allows copying between objects that overlap. */
void *memmove(void *dest, const void *src, size_t count) {
    /* Unlike memcpy the function memmove allows overlapping memory areas, i.e. a part of the destination  */
    /* area is allowed to be a part of the source area. Therefore the implementation must make sure that  */
    /* the source area isn't overwritten by the destination area data before the source area data has been read. */
    char * dest_char = (char *) dest;
    const char * src_char = (const char *) src;

    /* We're using a temp array to prevent data loss in the case of overlapping dest and src addresses */
    char * temp = (char *) malloc(sizeof(char) * count);
    if (temp == NULL) {
        return NULL;
    }

    if (dest_char != NULL && src_char != NULL) {
        for (int i=0; i<count; i++) {
            temp[i] = src_char[i];
        }

        free((void *) src_char);

        for (int i=0; i<count; i++) {
            dest_char[i] = temp[i];
        }

        free(temp);
    }
    return dest_char;
}

/* Sets count bytes of dest to a value c. */
void *memset(void *dest, int c, size_t count) {
    char * dest_ptr = (char *) dest;

    for (int i=0; i<count; i++) {
        *dest_ptr = (unsigned char) c;
        dest_ptr++;
    }

    return dest;
}

/* For actual implementation, check */
/* https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=stdio-common/vfprintf.c;hb=3321010338384ecdc6633a8b032bb0ed6aa9b19a */
/* Formats and prints characters and values to stdout. */
int printf(const char *format, ...) {
    va_list arg;
    int done;

    va_start (arg, format);
    done = vprintf(format, arg);
    va_end (arg);

    return done;
}
