import matplotlib.pyplot as plt
import numpy as np

def plot_ensemble(ensemble):
    plt.figure()
    for traj in ensemble:
        plt.plot(traj, alpha=0.3)
    plt.title("Revenue Forecast Ensemble")
    plt.xlabel("Quarter")
    plt.ylabel("Revenue (USD Millions)")
    plt.show()

def plot_mean_std(mean, std):
    t = np.arange(len(mean))
    plt.figure()
    plt.plot(t, mean, label="Mean Forecast")
    plt.fill_between(t, mean - std, mean + std, alpha=0.3, label="Uncertainty Band")
    plt.title("Mean Revenue Forecast and Uncertainty")
    plt.xlabel("Quarter")
    plt.ylabel("Revenue (USD Millions)")
    plt.legend()
    plt.show()

def plot_divergence(t, mean_dist, rate):
    plt.figure()
    plt.semilogy(t, mean_dist, label="Mean Forecast Divergence")
    plt.semilogy(t, mean_dist[0] * np.exp(rate * t), '--', label="Exponential Fit")
    plt.title("Forecast Divergence and Risk Amplification")
    plt.xlabel("Quarter")
    plt.ylabel("Divergence")
    plt.legend()
    plt.show()
