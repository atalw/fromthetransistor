#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "../malloc.h"

int main(int argc, char *argv[]) {
	int i;
	char *array = my_malloc(10);

	if (array == NULL) {
		fprintf(stderr, "call to my_malloc() failed\n");
		fflush(stderr);
		exit(1);
	}

	for(i=0; i<9; i++) {
		array[i] = 'a' + i;
	}
	array[9] = 0;

	printf("my new string: %s\n",array);

	free(array);
	return(0);
}
