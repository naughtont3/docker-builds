/* Wed Sep 14 2016  11:19:43AM EDT   Thomas Naughton <naughtont@ornl.gov> */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/utsname.h>

//#ifdef _GNU_LIBC_VERSION_H
  /* gnu_get_libc_version(), and gnu_get_libc_release() */
  #include <gnu/libc-version.h>
//#endif /* _GNU_LIBC_VERSION_H */

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
    int rc = 0;
    int nsec = 0;
    int i = 0;
    int count = 0;
    pid_t pid;
    struct utsname buf;
    char hostname[64];
    size_t len = 64;

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

    rc = gethostname(hostname, len);
    if (0 != rc) {
        fprintf (stderr, "Error: Failed to get hostname\n");
        perror("Error: gethostname() failed");
        return (EXIT_FAILURE);
    }

    rc = uname(&buf);
    if (0 != rc) {
        fprintf (stderr, "Error: Failed to get kernel info\n");
        perror("Error: uname() failed");
        return (EXIT_FAILURE);
    }

//  #ifdef _GNU_LIBC_VERSION_H
    printf ("[%d] INFO: %s %s-%s  libc-%s.%s\n",
             (int)pid, hostname, buf.sysname, buf.release, 
             gnu_get_libc_version(), gnu_get_libc_release());
//#else
//  printf ("[%d] INFO: %s %s-%s\n",
//           (int)pid, hostname, buf.sysname, buf.release);
//#endif /* _GNU_LIBC_VERSION_H */

    fflush(stdout);

    i = nsec;
    count = 0;
    while (i > 0) {
        /* Loop counter */
        count++;

        if (i > 10) {
            printf ("[%d] INFO: SLEEP %d  (loopcount: %d, total: %d)\n", 
                   (int)pid, 10, count, nsec);
            fflush(stdout);
            sleep(10);
            i = i - 10;
        } else {
            /* remainder */
            printf ("[%d] INFO: SLEEP %d  (loopcount: %d, total: %d)\n", 
                   (int)pid, i, count, nsec);
            fflush(stdout);
            sleep(i);
            i = i - i;
        }

        fflush(stdout);
    }

    return (EXIT_SUCCESS);
}
