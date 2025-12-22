import numpy as np
from itertools import combinations

def ensemble_stats(ensemble):
    mean = np.mean(ensemble, axis=0)
    std = np.std(ensemble, axis=0)
    return mean, std

def pairwise_distances(ensemble):
    pairs = list(combinations(range(ensemble.shape[0]), 2))
    distances = []

    for i, j in pairs:
        dist = np.abs(ensemble[i] - ensemble[j])
        distances.append(dist)

    return np.array(distances)

def mean_distance(distances):
    return np.mean(distances, axis=0)

def fit_exponential(t, y, t_min=2, t_max=10):
    mask = (t >= t_min) & (t <= t_max)
    coeffs = np.polyfit(t[mask], np.log(y[mask]), 1)
    return coeffs[0], np.exp(coeffs[1])
