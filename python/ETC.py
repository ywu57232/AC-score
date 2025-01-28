import numpy as np
import matplotlib.pyplot as plt
import time

def ETC(alg, alg_data_gen, base_size, num_test, repeat):
    """
    A data-driven, model-free, and parameter-free method to evaluate how an algorithm scales
    with input size on specific hardware and configurations.

    Parameters:
    alg: Callable - Algorithm to test for empirical scalability.
    alg_data_gen: Callable - Function to generate input data for `alg` with a single size argument.
    base_size: int - The smallest dimensional size.
    num_test: int - Number of different input sizes to test.
    repeat: int - Number of repetitions for each input size.

    Returns:
    etc: np.ndarray - The Empirical Time Complexity (ETC) matrix.
    """
    # Generate input sizes
    sizes = base_size * 2 ** np.arange(num_test)
    runtimes = np.zeros((repeat+1, num_test))

    # Measure runtime for each size and repetition
    for rp in range(repeat+1):
        for k, size in enumerate(sizes):
            data = alg_data_gen(size)
            start_time = time.perf_counter()
            alg(*data)
            runtimes[rp, k] = time.perf_counter() - start_time
    runtimes = runtimes[1:][:]
    # Compute ETC as normalized runtimes
    etc = runtimes / runtimes[:, 0][:, np.newaxis]

    # Plot results
    plot_etc(sizes, etc, runtimes)

    return etc

def plot_etc(sizes, etc, runtimes):
    """
    Plot the Empirical Time Complexity (ETC) and runtime results.

    Parameters:
    sizes: np.ndarray - Array of input sizes.
    etc: np.ndarray - ETC matrix.
    runtimes: np.ndarray - Raw runtimes matrix.
    """
    x_axis_etc = sizes / sizes[0]
    x_axis_runtime = sizes

    # ETC Plot
    plt.figure(figsize=(12, 6))

    plt.subplot(1, 2, 1)
    mean_etc = np.mean(etc, axis=0)
    std_etc = np.std(etc, axis=0)
    plt.fill_between(x_axis_etc, mean_etc - std_etc, mean_etc + std_etc, color='blue', alpha=0.3)
    plt.plot(x_axis_etc, mean_etc, 'o-', label='ETC', color='blue')
    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('Number of times as the smallest input size')
    plt.ylabel('ETC')
    plt.title('Empirical Time Complexity (ETC)')
    plt.grid(True, which="both", linestyle="--", linewidth=0.5)
    plt.legend()

    # Reference lines for theoretical complexities
    plt.plot(x_axis_etc, x_axis_etc, 'k--', label='O(n)')
    plt.plot(x_axis_etc, x_axis_etc**2, 'k--', label='O(n^2)')
    plt.plot(x_axis_etc, x_axis_etc**3, 'k--.', label='O(n^3)')


    # Runtime Plot
    plt.subplot(1, 2, 2)
    mean_runtimes = np.mean(runtimes, axis=0)
    std_runtimes = np.std(runtimes, axis=0)
    plt.fill_between(x_axis_runtime, mean_runtimes - std_runtimes, mean_runtimes + std_runtimes, color='blue', alpha=0.3)
    plt.plot(x_axis_runtime, mean_runtimes, 'o-', label='Runtime', color='blue')
    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('Input data dimensional size')
    plt.ylabel('Running time (s)')
    plt.title('Running Time')
    plt.grid(True, which="both", linestyle="--", linewidth=0.5)
    plt.legend()

    plt.tight_layout()
    plt.show()
