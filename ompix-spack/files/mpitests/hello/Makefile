CC=gcc
RM=rm -f
ECHO=echo

MPICC=mpicc
MPIRUN=mpirun

CFLAGS=-g
LDFLAGS=

all: mpiexample

mpiexample: mpiexample.c
	$(MPICC) $(CFLAGS) $(LDFLAGS) mpiexample.c -o mpiexample

run:
	$(MPIRUN) -np 4 ./mpiexample

clean:
	$(RM) mpiexample

help:
	-@$(ECHO) "Targets:"
	-@$(ECHO) "    make all   -- builds mpiexample"
	-@$(ECHO) "    make run   -- runs mpiexample"
	-@$(ECHO) "    make clean -- remove binaries"

