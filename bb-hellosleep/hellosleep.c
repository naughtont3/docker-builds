/* Wed Sep 14 2016  11:19:43AM EDT   Thomas Naughton <naughtont@ornl.gov> */
#include <stdio.h>
#include <stdlib.h>

char *progname = "hellosleep";

int usage(void) {
    fprintf (stdout, "\n");
    fprintf (stdout, "Usage: %s SECONDS\n", progname);
    fprintf (stdout, "   SECONDS -- Number of seconds to sleep\n");
    fprintf (stdout, "   (Must be positive non-zero integer)\n");
    fprintf (stdout, "\n");
    return (0);
}

int main (int argc, char **argv) 
{
    int nsec = 0;
    int i = 0;
    int count = 0;
    pid_t pid;

    if (argc < 2) {
        fprintf (stderr, "Error: Missing arg 'SECONDS'\n");
        usage();
        return (EXIT_FAILURE);
    }

    nsec = (int)strtol(argv[1], NULL, 10);
    if (nsec <= 0) {
        fprintf (stderr, "Error: Bad arg 'SECONDS' (%d) is zero or negative\n",
                 nsec);
        usage();
        return (EXIT_FAILURE);
    }

    pid = getpid();
    printf ("[%d] INFO: PID = %d\n", (int)pid, (int)pid);

    i = nsec;
    count = 0;
    while (i > 0) {
        /* Loop counter */
        count++;

        if (i > 10) {
            printf ("[%d] INFO: SLEEP %d  (loopcount: %d, total: %d)\n", 
                   (int)pid, 10, count, nsec);
            sleep(10);
            i = i - 10;
        } else {
            /* remainder */
            printf ("[%d] INFO: SLEEP %d  (loopcount: %d, total: %d)\n", 
                   (int)pid, i, count, nsec);
            sleep(i);
            i = i - i;
        }

        fflush(stdout);
    }

    return (EXIT_SUCCESS);
}
