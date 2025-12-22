import numpy as np
from src.revenue_ensemble import *
from src.ensemble_analysis import *
from src.plots import *

# Load real revenue data
df = load_revenue_data("data/apple_revenue.csv")
revenue = df["revenue"].values

# Estimate growth parameters
growth_rates = compute_growth_rates(revenue)
mean_g, std_g = estimate_growth_params(growth_rates)

# Run ensemble forecast
ensemble = simulate_ensemble(
    R0=revenue[-1],
    mean_growth=mean_g,
    std_growth=std_g,
    n_steps=20,
    n_ensemble=50
)

# Analyze ensemble
mean, std = ensemble_stats(ensemble)
distances = pairwise_distances(ensemble)
mean_dist = mean_distance(distances)

# Fit risk amplification rate
t = np.arange(len(mean_dist))
rate, scale = fit_exponential(t, mean_dist)

# Plots
plot_ensemble(ensemble)
plot_mean_std(mean, std)
plot_divergence(t, mean_dist, rate)

print(f"Estimated Risk Amplification Rate: {rate:.3f} per quarter")
