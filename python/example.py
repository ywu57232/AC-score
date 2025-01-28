import numpy as np
import matplotlib.pyplot as plt
from compute_ACscore import compute_ACscore

# Set parameters
N = int(1e3)
np.random.seed(10086)

# Generate random markers and labels
markers = np.random.permutation(N)
labels = np.array(["red"] * (N // 2 - 1) + ["green"] + ["red"] + ["green"] * (N // 2 - 1))

# Call the compute_ACscore function
positive_class = "green"
ACscore, ACscore_array, best_cut, direction, best_predicted = compute_ACscore(labels, markers, positive_class)

# Sort markers and ACscore array for plotting
sorted_indices = np.argsort(markers)
ACscore_array_sorted = ACscore_array[sorted_indices]

# Plot the ACscore array
plt.plot(ACscore_array_sorted)
plt.xlabel("Marker ranking")
plt.ylabel("ACscore score")
plt.title("ACscore Score by Marker Ranking")
plt.show()

# Display results
print(f"ACscore score (ACscore): {ACscore}")
print(f"Best cut: {best_cut}")
