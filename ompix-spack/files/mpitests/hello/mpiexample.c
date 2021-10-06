/* http://www.lam-mpi.org/tutorials/one-step/ezstart.php */

#include <stdio.h>
#include <unistd.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
    int myrank=0;
    int size = 0;
	char host[256];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

	if( gethostname(host, (sizeof(host)-1)) < 0) {
		fprintf(stderr, "Error: unable to get hostname (rank=%d)\n", myrank);
	}

    printf("I am rank: %d of %d  (host=%s)\n", myrank, size, host);

    MPI_Finalize();
	return 0;
}
