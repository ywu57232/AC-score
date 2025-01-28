import numpy as np
import cProfile

def multiply(matrix_a,matrix_b):
    # Initialize the result matrix with zeros
    result = [[0 for _ in range(len(matrix_b[0]))] for _ in range(len(matrix_a))]

    # Perform matrix multiplication
    for i in range(len(matrix_a)):
        for j in range(len(matrix_b[0])):
            for k in range(len(matrix_b)):
                result[i][j] += matrix_a[i][k] * matrix_b[k][j]

    return result


if __name__ == '__main__':
    List_N=np.array([2**7,2**8,2**9,2**10,2**11,2**12,2**13])
    t=np.zeros([6,7])

    for i in range(np.size(List_N)):
        for rp in range(6):
            N=List_N[i]
            R1=np.random.rand(N,N).tolist()
            R2=np.random.rand(N,N).tolist()

            cProfile.run('multiply(R1,R2)','figure/matrix_multiplication/python/results/plain/stats_strassen_{}_{}'.format(rp,i))




