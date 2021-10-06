/*
 * Oct 13 2020 / Thomas Naughton  <naughtont@ornl.gov>
 *
 * Usage: mpirun -np $nprocs ./a2a_test2  [r] [N]
 *
 *   Loops over MPI_Alltoall() 'MAX_NLOOP' times.
 *
 *   There are two possible position-sensitive arguments to the test:
 *   	arg1 - positive-integer of rank to show before/after of array
 *      arg2 - positive-integer for number of loops
 *
 *   If no args are provided the program uses default values.
 */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int MAX_NLOOP = 100;

int main (int argc, char **argv)
{
	int rank, size;
	int *inbuf = NULL;
	int *outbuf = NULL;
	int i;
	int showrank = 0;
	int nloop;

	if (argc > 1) {
		showrank = atoi(argv[1]);
	}

	if (argc > 2) {
		MAX_NLOOP = atoi(argv[2]);
	}

	MPI_Init (&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	inbuf  = (int *) malloc ( size * sizeof(int) );
	if (NULL == inbuf) {
		fprintf(stderr, "Error: malloc failed (inbuf)\n");
		goto cleanup;
	}

	outbuf  = (int *) malloc ( size * sizeof(int) );
	if (NULL == outbuf) {
		fprintf(stderr, "Error: malloc failed (outbuf)\n");
		goto cleanup;
	}

	for (i=0; i < size; i++) {
		inbuf[i] = 100 + rank;
		outbuf[i] = 0;
	}

	if (rank == showrank) {
		for (i=0; i < size; i++) {
			printf("(%d) BEFORE inbuf[%d] = %d\n",
				rank, i, inbuf[i]);
		}
	}

	MPI_Barrier(MPI_COMM_WORLD);

	printf("(%d of %d) Hello World\n", rank, size);

	MPI_Barrier(MPI_COMM_WORLD);

	for (nloop=0; nloop < MAX_NLOOP; nloop++) {
		MPI_Barrier(MPI_COMM_WORLD);

		MPI_Alltoall(inbuf, 1, MPI_INT, outbuf, 1, MPI_INT, MPI_COMM_WORLD);

		MPI_Barrier(MPI_COMM_WORLD);
		if (rank == 0) {
            if ((MAX_NLOOP < 10) || ( !(nloop % 10) )) {
			    printf("Finished loop: %d\n", nloop);
            }
		}
	}

	MPI_Barrier(MPI_COMM_WORLD);

	if (rank == showrank) {
		for (i=0; i < size; i++) {
			printf("(%d)    AFTER outbuf[%d] = %d\n",
				rank, i, outbuf[i]);
		}
	}

cleanup:
	if (NULL != inbuf)
		free(inbuf);

	if (NULL != outbuf)
		free(outbuf);

	MPI_Finalize();
	return (0);
}
