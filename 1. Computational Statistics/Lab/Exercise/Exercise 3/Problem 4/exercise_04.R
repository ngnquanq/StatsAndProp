# Exercise 4: Monte Carlo Stock Option Pricing (Black-Scholes)
# Author: Quang Nguyen

set.seed(42)

# --- Parameters ---
S0 <- 50      # Initial stock price
K  <- 52      # Strike price
sigma <- 0.5  # Volatility
r  <- 0.05    # Risk-free rate
T_days <- 30  # Days to expiration
n <- 100000   # Number of Monte Carlo simulations

# ============================================================
# Part (a): European Call Option
# ============================================================
# S(T) = S(0) * exp((r - sigma^2/2) * T/365 + sigma * Z * sqrt(T/365))
# C = exp(-r*T/365) * max(0, S(T) - K)

cat("=== Part (a): European Call Option ===\n\n")

# Generate Z ~ N(0,1)
Z <- rnorm(n)

# Simulate S(T)
S_T <- S0 * exp((r - sigma^2 / 2) * T_days / 365 + sigma * Z * sqrt(T_days / 365))

# Compute payoffs
payoff_european <- pmax(0, S_T - K)

# Discounted payoffs
C_i <- exp(-r * T_days / 365) * payoff_european

# Monte Carlo estimate
C_hat <- mean(C_i)
se_european <- sd(C_i) / sqrt(n)
ci_lower <- C_hat - 1.96 * se_european
ci_upper <- C_hat + 1.96 * se_european

cat(sprintf("Monte Carlo estimate E(C): %.4f\n", C_hat))
cat(sprintf("Standard Error:            %.4f\n", se_european))
cat(sprintf("95%% Confidence Interval:   [%.4f, %.4f]\n", ci_lower, ci_upper))
cat(sprintf("Theoretical value:         2.10\n"))
cat(sprintf("Absolute error:            %.4f\n", abs(C_hat - 2.10)))
cat("\n")

# Convergence plot data
cumulative_mean <- cumsum(C_i) / (1:n)

# ============================================================
# Part (b): Asian Call Option
# ============================================================
# S(t+1) = S(t) * exp((r - sigma^2/2)/365 + sigma * Z(t) / sqrt(365))
# A = exp(-r*T/365) * max(0, mean(S(1:T)) - K)

cat("=== Part (b): Asian Call Option ===\n\n")

A_i <- numeric(n)

for (i in 1:n) {
    # Simulate daily path S(1), S(2), ..., S(T)
    S_path <- numeric(T_days)
    S_current <- S0

    Z_daily <- rnorm(T_days)
    for (t in 1:T_days) {
        S_current <- S_current * exp((r - sigma^2 / 2) / 365 + sigma * Z_daily[t] / sqrt(365))
        S_path[t] <- S_current
    }

    # Average price over the path
    S_avg <- mean(S_path)

    # Discounted payoff
    A_i[i] <- exp(-r * T_days / 365) * max(0, S_avg - K)
}

# Monte Carlo estimate
A_hat <- mean(A_i)
se_asian <- sd(A_i) / sqrt(n)
ci_lower_a <- A_hat - 1.96 * se_asian
ci_upper_a <- A_hat + 1.96 * se_asian

cat(sprintf("Monte Carlo estimate E(A): %.4f\n", A_hat))
cat(sprintf("Standard Error:            %.4f\n", se_asian))
cat(sprintf("95%% Confidence Interval:   [%.4f, %.4f]\n", ci_lower_a, ci_upper_a))
cat("\n")

# Comparison
cat("=== Comparison ===\n")
cat(sprintf("European Call Price: %.4f\n", C_hat))
cat(sprintf("Asian Call Price:    %.4f\n", A_hat))
cat(sprintf("Difference (European - Asian): %.4f\n", C_hat - A_hat))
cat("Asian < European because averaging reduces the effective volatility.\n")

# ============================================================
# Plots
# ============================================================

# Plot 1: European Call convergence
png("european_convergence.png", width = 800, height = 500)
plot(1:n, cumulative_mean, type = "l", col = "blue",
     xlab = "Number of simulations (n)",
     ylab = "Estimated E(C)",
     main = "European Call: Monte Carlo Convergence")
abline(h = 2.10, col = "red", lty = 2, lwd = 2)
legend("topright",
       legend = c("MC Estimate", "Theoretical (2.10)"),
       col = c("blue", "red"), lty = c(1, 2), lwd = c(1, 2))
grid()
dev.off()
cat("Generated european_convergence.png\n")

# Plot 2: European vs Asian comparison (histograms of payoffs)
png("option_comparison.png", width = 900, height = 500)
par(mfrow = c(1, 2))

# European payoff distribution
hist(C_i[C_i > 0], breaks = 50, col = "lightblue", border = "white",
     main = "European Call Payoffs (C > 0)",
     xlab = "Discounted Payoff", prob = TRUE)
abline(v = C_hat, col = "red", lty = 2, lwd = 2)
legend("topright", legend = paste("E(C) =", round(C_hat, 4)),
       col = "red", lty = 2, bg = "white")

# Asian payoff distribution
hist(A_i[A_i > 0], breaks = 50, col = "lightgreen", border = "white",
     main = "Asian Call Payoffs (A > 0)",
     xlab = "Discounted Payoff", prob = TRUE)
abline(v = A_hat, col = "red", lty = 2, lwd = 2)
legend("topright", legend = paste("E(A) =", round(A_hat, 4)),
       col = "red", lty = 2, bg = "white")

dev.off()
cat("Generated option_comparison.png\n")
