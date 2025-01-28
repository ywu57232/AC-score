import numpy as np
from ETC import ETC

# Algorithm to test (plain matrix multiplication)
import os, sys
current_folder = os.path.dirname(os.path.abspath(__file__))
parent_folder = os.path.dirname(current_folder)
sys.path.append(parent_folder)
from figure.matrix_multiplication.python.matmul1 import multiply
alg = lambda A, B: multiply(A, B)

# Algorithm to generate input data
def alg_data_gen(size):
    data = [
        np.random.rand(size, size),  # Generate a random matrix A
        np.random.rand(size, size)   # Generate a random matrix B
    ]
    return data

# Parameters
base_size = 2 ** 5  # The smallest dimensional size
num_test = 3        # Number of different input sizes to test
repeat = 5          # Number of repetitions for each input size

# Run ETC calculation
outputs = ETC(alg, alg_data_gen, base_size, num_test, repeat)
