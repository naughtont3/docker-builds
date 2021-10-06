/*
 * Oct 13 2020 / Thomas Naughton  <naughtont@ornl.gov>
 *
 * Usage: mpirun -np $nprocs ./a2a_test2  [r]
 *
 *   There is one possible arguments to the test:
 *   	arg1 - positive-integer of rank to show before/after of array
 *
 *   If no arg is provided the program uses default value.
 */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main (int argc, char **argv)
{
	int rank, size;
	int *buf = NULL;
	int i;
	int showrank = 0;

	if (argc > 1) {
		showrank = atoi(argv[1]);
	}

	MPI_Init (&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	buf  = (int *) malloc ( size * sizeof(int) );
	if (NULL == buf) {
		fprintf(stderr, "Error: malloc failed (buf)\n");
		goto cleanup;
	}

	for (i=0; i < size; i++) {
		buf[i] = 100 + rank;
	}

	if (rank == showrank) {
		for (i=0; i < size; i++) {
			printf("(%d) BEFORE buf[%d] = %d\n",
				rank, i, buf[i]);
		}
	}

	MPI_Barrier(MPI_COMM_WORLD);

	printf("(%d of %d) Hello World\n", rank, size);

	MPI_Alltoall(MPI_IN_PLACE, 0, 0, buf, 1, MPI_INT, MPI_COMM_WORLD);

	MPI_Barrier(MPI_COMM_WORLD);

	if (rank == showrank) {
		for (i=0; i < size; i++) {
			printf("(%d)    AFTER buf[%d] = %d\n",
				rank, i, buf[i]);
		}
	}

cleanup:
	if (NULL != buf)
		free(buf);

	MPI_Finalize();
	return (0);
}
