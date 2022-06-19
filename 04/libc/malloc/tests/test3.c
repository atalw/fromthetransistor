#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "../malloc.h"

#define MAX_MALLOC_SIZE (1024*1024*16)
/* #define MAX_MALLOC_SIZE 1000 */

int main(int argc, char *argv[]) {
	int size;
	int lsize;
	int curr;
	void *ptr[10];
	int i;

	/*
	 * try mallocing four pieces, each 1/4 of total size
	 */
	size = MAX_MALLOC_SIZE / 4;

	ptr[0] = my_malloc(size);
	if (ptr[0] == NULL) {
		printf("malloc of ptr[0] failed for size %d\n", size);
		exit(1);
	}

	print_heap();
	printf("\n");

	ptr[1] = my_malloc(size);
	if (ptr[1] == NULL) {
		printf("malloc of ptr[1] failed for size %d\n", size);
		exit(1);
	}

	print_heap();
	printf("\n");

	ptr[2] = my_malloc(size);
	if (ptr[2] == NULL) {
		printf("malloc of ptr[2] failed for size %d\n", size);
		exit(1);
	}

	print_heap();
	printf("\n");

	/*
	 * this one should fail due to rounding
	 */
	ptr[3] = my_malloc(size);
	if (ptr[3] == NULL) {
		printf("malloc of ptr[3] fails correctly for size %d\n", size);
	} else {
        /* print_heap(); */
        /* exit(1); */
    }

	print_heap();
	printf("\n");

	/*
	 * free the first block
	 */
	free(ptr[0]);

	print_heap();
	printf("\n");

	/*
	 * free the third block
	 */
	free(ptr[2]);

	print_heap();
	printf("\n");

	/*
	 * now free second block
	 */
	free(ptr[1]);

	print_heap();
	printf("freed\n");

	/*
	 * re-malloc first pointer
\	 */
	ptr[0] = my_malloc(size);
	if (ptr[0] == NULL) {
		printf("re-malloc of ptr[0] failed for size %d\n", size);
		exit(1);
	}
	print_heap();
	printf("did this\n");

	/*
	 * try splitting the second block
	 */
	ptr[1] = my_malloc(size/2);
	if (ptr[1] == NULL) {
		printf("split second block ptr[1] failed for size %d\n", size/2);
		exit(1);
	}
	print_heap();
	printf("\n");

	/*
	 * free first block and split of second
	 */
	free(ptr[0]);
	free(ptr[1]);

	print_heap();
	printf("\n");

	/*
	 * try mallocing a little less to make sure no split occurs
	 * first block from previous print should not be split
	 */
	ptr[0] = my_malloc(size-1);
	if (ptr[0] == NULL) {
		printf("slightly smaller malloc of ptr[0] failed for size %d\n", size);
		exit(1);
	}
	print_heap();
	printf("\n");

	/*
	 * free it and make sure it comes back as the correct size
	 */
	free(ptr[0]);
	
	print_heap();
	printf("\n");

	/*
	 * okay -- malloc up all but the last available blocks
	 */
	ptr[0] = my_malloc(size);
	if (ptr[0] == NULL) {
		printf("run-up malloc of ptr[0] failed for size %d\n", size);
		exit(1);
	}
	ptr[1] = my_malloc(size/2);
	if (ptr[1] == NULL) {
		printf("run-up malloc of ptr[1] failed for size %d\n", size/2);
		exit(1);
	}
	ptr[2] = my_malloc(size/2);
	if (ptr[2] == NULL) {
		printf("run-up malloc of ptr[2] failed for size %d\n", size/2);
		exit(1);
	}
	ptr[3] = my_malloc(size/2);
	if (ptr[3] == NULL) {
		printf("run-up malloc of ptr[3] failed for size %d\n", size/2);
		exit(1);
	}

	/*
	 * this one should fail by a smidge
	 */
	ptr[4] = my_malloc(size/2);
	if (ptr[4] == NULL) {
		printf("run-up malloc of ptr[4] failed for size %d\n", size/2);
	}

	print_heap();
	printf("\n");

	exit(0);
}
