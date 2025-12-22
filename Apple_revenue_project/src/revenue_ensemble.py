import numpy as np
import pandas as pd

def load_revenue_data(filepath):
    df = pd.read_csv(filepath, parse_dates=["date"])
    df = df.sort_values("date")
    return df

def compute_growth_rates(revenue):
    return np.diff(np.log(revenue))

def estimate_growth_params(growth_rates):
    mean_growth = np.mean(growth_rates)
    std_growth = np.std(growth_rates)
    return mean_growth, std_growth

def simulate_ensemble(
    R0,
    mean_growth,
    std_growth,
    n_steps=20,
    n_ensemble=50,
    perturb_scale=0.2,
    noise_scale=1.0,
    seed=42
):
    np.random.seed(seed)

    growth_perturbations = np.random.normal(
        0, perturb_scale * std_growth, size=n_ensemble
    )
    growth_rates = mean_growth + growth_perturbations

    ensemble = np.zeros((n_ensemble, n_steps))
    ensemble[:, 0] = R0

    for t in range(1, n_steps):
        noise = np.random.normal(0, noise_scale * std_growth, size=n_ensemble)
        ensemble[:, t] = ensemble[:, t-1] * np.exp(growth_rates + noise)

    return ensemble
