import numpy as np
import cProfile

def plain_matmul_8x8_man(C, A, B):
    # Check if the dimensions of matrices allow multiplication
    rows_A, cols_A = A.shape
    rows_B, cols_B = B.shape
    B = B.T

    if cols_A != rows_B:
        print('Matrix multiplication is not possible because the number of columns in matrix A is not equal to the number of rows in matrix B.')
    else:
        N = rows_A
        stride = 2**3
        for ii in range(0, N, stride):
            for jj in range(0, N, stride):
                for kk in range(0, N, stride):
                    for i in range(jj, jj+stride):
                        for j in range(ii, ii+stride):
                            for k in range(kk, kk+stride):
                                C[i, j] += A[i, k] * B[j, k]
    return C


List_N=np.array([2**7,2**8,2**9,2**10,2**11,2**12,2**13])
t=np.zeros([6,7])

for i in range(np.size(List_N)):
    N=List_N[i]
    for rp in range(6):

        A = np.random.rand(N, N)
        B = np.random.rand(N, N)
        C = np.zeros((N, N))

        cProfile.run('result = plain_matmul_8x8_man(C, A, B)','figure/matrix_multiplication/python/results/plain_8x8/stats_strassen_{}_{}'.format(rp,i))

