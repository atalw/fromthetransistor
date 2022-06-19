#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "../malloc.h"

int main(int argc, char *argv[]) {
	char *a1;
	char *a2;
	char *a3;
	char *a4;

	a1 = (char *) my_malloc(128);
	if(a1 == NULL) {
		fprintf(stderr,"call to my_malloc(128) failed\n");
		fflush(stderr);
		exit(1);
	}

	printf("---> HEAP after malloc(128)\n");
    print_heap();

	a2 = (char *) my_malloc(32);
	if(a2 == NULL)
	{
		fprintf(stderr,"call to my_malloc(32) failed\n");
		fflush(stderr);
		exit(1);
	}

	printf("---> HEAP after malloc(32)\n");
    print_heap();

	free(a1);

	printf("---> HEAP after FREE of first 128 malloc()\n");
	print_heap();

	a3 = (char *) my_malloc(104);
	if(a3 == NULL)
	{
		fprintf(stderr,"call to my_malloc(104) failed\n");
		fflush(stderr);
		exit(1);
	}

	printf("---> HEAP after malloc(104)\n");
	print_heap();

	a4 = (char *)my_malloc(8);
	if(a4 == NULL)
	{
		fprintf(stderr,"call to my_malloc(8) failed\n");
		fflush(stderr);
		exit(1);
	}
	printf("---> HEAP after malloc(8)\n");
	print_heap();

	free(a2);
	free(a3);
	free(a4);
	printf("---> HEAP after all free\n");
	print_heap();


	return(0);
}

	

