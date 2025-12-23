import matplotlib.pyplot as plt
import numpy as np
import os

# Absolute path to the project root (Apple_revenue_project)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Absolute path to figures directory
FIG_DIR = os.path.join(BASE_DIR, "figures")


def ensure_fig_dir():
    """Create figures directory if it does not exist."""
    os.makedirs(FIG_DIR, exist_ok=True)


def plot_ensemble(ensemble):
    """
    Plot ensemble revenue trajectories and save figure.
    """
    ensure_fig_dir()

    plt.figure(figsize=(8, 5))
    for traj in ensemble:
        plt.plot(traj, alpha=0.3)

    plt.title("Revenue Forecast Ensemble (Apple)")
    plt.xlabel("Quarter")
    plt.ylabel("Revenue (USD Millions)")
    plt.tight_layout()

    plt.savefig(os.path.join(FIG_DIR, "ensemble_trajectories.png"))
    plt.close()


def plot_mean_std(mean, std):
    """
    Plot mean forecast with uncertainty band and save figure.
    """
    ensure_fig_dir()

    t = np.arange(len(mean))

    plt.figure(figsize=(8, 5))
    plt.plot(t, mean, label="Mean Forecast")
    plt.fill_between(
        t,
        mean - std,
        mean + std,
        alpha=0.3,
        label="Uncertainty Band"
    )

    plt.title("Mean Revenue Forecast with Uncertainty")
    plt.xlabel("Quarter")
    plt.ylabel("Revenue (USD Millions)")
    plt.legend()
    plt.tight_layout()

    plt.savefig(os.path.join(FIG_DIR, "mean_forecast_uncertainty.png"))
    plt.close()


def plot_divergence(t, mean_dist, rate):
    """
    Plot forecast divergence on log scale with exponential fit and save figure.
    """
    ensure_fig_dir()

    plt.figure(figsize=(8, 5))
    plt.semilogy(t, mean_dist, label="Mean Forecast Divergence")
    plt.semilogy(
        t,
        mean_dist[0] * np.exp(rate * t),
        "--",
        label="Exponential Risk Amplification Fit"
    )

    plt.title("Forecast Divergence and Risk Amplification")
    plt.xlabel("Quarter")
    plt.ylabel("Divergence")
    plt.legend()
    plt.tight_layout()

    plt.savefig(os.path.join(FIG_DIR, "forecast_divergence.png"))
    plt.close()
