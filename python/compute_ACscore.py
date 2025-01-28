import numpy as np

def compute_ACscore(labels, markers, positive_class):
    """
    Compute the ACscore metric for binary classifiers.

    Parameters:
    labels: Groundtruth labels (list, numpy array, or similar, 1D)
    markers: Predicted labels or scores (same format as labels)
    positive_class: Value representing the positive class

    Returns:
    ACscore: The ACscore evaluation result.
    ACscore_array: ACscore evaluations for possible cuts (if markers are scores).
    best_cut: Cut corresponding to the highest ACscore (if markers are scores).
    direction: 1 if scores >= best_cut are positive; 0 otherwise.
    best_predicted: Predicted labels for the highest ACscore (if markers are scores).
    """
    labels = np.asarray(labels)
    markers = np.asarray(markers)

    is_marker_score = not np.array_equal(np.unique(markers), [0, 1])

    if labels.ndim != 1 or markers.ndim != 1:
        raise ValueError("Input labels and markers must be 1D arrays.")

    unique_labels = np.unique(labels)
    if len(unique_labels) != 2:
        raise ValueError("The number of classes must be 2.")

    if positive_class not in unique_labels:
        raise ValueError("The specified positive class is incorrect.")

    negative_class = unique_labels[unique_labels != positive_class][0]

    mapped_labels = (labels == positive_class).astype(int)

    if not is_marker_score:
        mapped_markers = (markers == positive_class).astype(int)
        tp, tn, fp, fn = compute_confusion_matrix(mapped_labels, mapped_markers)
        ACscore = compute_ac_score(tp, tn, fp, fn)
        return ACscore, None, None, None, None

    # If markers are scores
    sorted_indices = np.argsort(markers)
    markers_sorted = markers[sorted_indices]
    labels_sorted = mapped_labels[sorted_indices]

    ACscore_array_forward, ACscore_forward, idx_max_forward = compute_ACscore_unidirectional(labels_sorted, "forward")
    ACscore_array_backward, ACscore_backward, idx_max_backward = compute_ACscore_unidirectional(labels_sorted, "backward")

    if ACscore_forward >= ACscore_backward:
        ACscore_array = ACscore_array_forward[np.argsort(sorted_indices)]
        ACscore = ACscore_forward
        idx_max = idx_max_forward
        direction = 1
    else:
        ACscore_array = ACscore_array_backward[np.argsort(sorted_indices)]
        ACscore = ACscore_backward
        idx_max = idx_max_backward
        direction = 0

    delta = 1e-6
    if idx_max == 0:
        best_cut = markers_sorted[0] - delta
    elif idx_max == len(markers) + 1:
        best_cut = markers_sorted[-1] + delta
    else:
        best_cut = (markers_sorted[idx_max - 1] + markers_sorted[idx_max]) / 2

    if direction == 1:
        best_predicted = np.concatenate((
            np.full(idx_max - 1, negative_class),
            np.full(len(markers) - idx_max + 1, positive_class)
        ))
    else:
        best_predicted = np.concatenate((
            np.full(idx_max - 1, positive_class),
            np.full(len(markers) - idx_max + 1, negative_class)
        ))

    return ACscore, ACscore_array, best_cut, direction, best_predicted

def compute_confusion_matrix(labels, predicted):
    tp = np.sum((predicted == 1) & (labels == 1))
    tn = np.sum((predicted == 0) & (labels == 0))
    fp = np.sum((predicted == 1) & (labels == 0))
    fn = np.sum((predicted == 0) & (labels == 1))
    return tp, tn, fp, fn

def compute_ac_score(tp, tn, fp, fn):
    total = tp + tn + fp + fn
    if tp + tn == total:
        return 1
    if fp + fn == total:
        return 0
    tp_tn = tp * tn
    return (2 * tp_tn) / (2 * tp_tn + tp * fp + tn * fn)

def compute_ACscore_unidirectional(mapped_labels, direction):
    n = len(mapped_labels)
    ACscore_array = np.full(n + 1, np.nan)

    if direction == "forward":
        predicted = np.ones(n, dtype=int)
    else:
        predicted = np.zeros(n, dtype=int)

    tp, tn, fp, fn = compute_confusion_matrix(mapped_labels, predicted)
    ACscore_array[0] = compute_ac_score(tp, tn, fp, fn)

    for i in range(1, n + 1):
        if direction == "forward":
            tp, tn, fp, fn = update_cm_forward(tp, tn, fp, fn, mapped_labels[i - 1])
        else:
            tp, tn, fp, fn = update_cm_backward(tp, tn, fp, fn, mapped_labels[i - 1])

        ACscore_array[i] = compute_ac_score(tp, tn, fp, fn)

    ACscore = np.nanmax(ACscore_array)
    idx_max = np.nanargmax(ACscore_array)
    return ACscore_array, ACscore, idx_max

def update_cm_forward(tp, tn, fp, fn, label):
    if label == 0:
        tn += 1
        fp -= 1
    else:
        tp -= 1
        fn += 1
    return tp, tn, fp, fn

def update_cm_backward(tp, tn, fp, fn, label):
    if label == 1:
        tp += 1
        fn -= 1
    else:
        tn -= 1
        fp += 1
    return tp, tn, fp, fn
