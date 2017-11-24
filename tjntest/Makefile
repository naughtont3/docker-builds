# Thu Nov 03 2016  11:37:33AM EDT   Thomas Naughton  <naughtont@ornl.gov>

CC=gcc
RM=rm
ECHO=echo

all: hellosleep hellosleep-static

hellosleep:  hellosleep.c
	$(CC) -o hellosleep hellosleep.c 

hellosleep-static: hellosleep.c
	$(CC) -o hellosleep-static -static hellosleep.c 

clean:
	$(RM) -f hellosleep
	$(RM) -f hellosleep-static
