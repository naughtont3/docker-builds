CC=gcc
RM=rm -f
ECHO=echo

MPICC=mpicc
MPIRUN=mpirun

CFLAGS=-g
LDFLAGS=

all: a2a_test a2a_test_loop

a2a_test: a2a_test.c
	$(MPICC) $(CFLAGS) $(LDFLAGS) a2a_test.c -o a2a_test

a2a_test_loop: a2a_test_loop.c
	$(MPICC) $(CFLAGS) $(LDFLAGS) a2a_test_loop.c -o a2a_test_loop

run: run1
run1:
	$(MPIRUN) -np 4 ./a2a_test 2

run2:
	$(MPIRUN) -np 4 ./a2a_test_loop 2


# run4:
# 	-@$(ECHO) "TJN: DISABLING UCX!"
# 	$(MPIRUN) --mca pml ^ucx -np 2 ./mpiput

clean:
	$(RM) a2a_test
	$(RM) a2a_test_loop

help:
	-@$(ECHO) "Targets:"
	-@$(ECHO) "    make all   -- builds a2a_test and a2a_test_loop"
	-@$(ECHO) "    make run1  -- runs a2a_test"
	-@$(ECHO) "    make run2  -- runs a2a_test_loop"
	-@$(ECHO) "    make clean -- remove binaries"

