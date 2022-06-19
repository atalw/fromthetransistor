CC = gcc
CFLAGS = -O0 -W -Wall -g

OUTDIR = ./bin
EX = $(notdir $(basename $(wildcard tests/*.c)))

all: malloc.o $(EX)

clean:
	rm -rf malloc.o $(OUTDIR)/$(EX)

malloc.o: malloc.c malloc.h
	$(CC) $(FLAGS) -c malloc.c

%: tests/%.c
	$(CC) $^ malloc.o $(FLAGS) -o $(OUTDIR)/$@
