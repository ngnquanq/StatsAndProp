# Example usage of EM Algorithm

# Load required libraries
library(ggplot2)
library(MASS)
source("em_algorithm.R")
source("em_helpers.R")
source("../../scripts/visualization.R")

# Set seed for reproducibility
set.seed(123)

# Generate sample data from a mixture of two Gaussians
n <- 200
mu1 <- c(0, 0)
mu2 <- c(3, 3)
sigma1 <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
sigma2 <- matrix(c(1, -0.5, -0.5, 1), 2, 2)

# Generate data
data1 <- mvrnorm(n/2, mu1, sigma1)
data2 <- mvrnorm(n/2, mu2, sigma2)
data <- rbind(data1, data2)

# Convert to data frame for plotting
df <- data.frame(x = data[, 1], y = data[, 2])

# Run EM algorithm
cat("Running EM algorithm...\n")
result <- em_algorithm(data, k = 2, max_iter = 100, tol = 1e-6, verbose = TRUE)

# Get cluster assignments
clusters <- apply(result$responsibilities, 1, which.max)

# Plot results
p <- plot_clusters(df, clusters, 
                   centers = result$means, 
                   title = "EM Algorithm: Gaussian Mixture Model")
print(p)

# Plot convergence
if (length(result$log_likelihood_history) > 0) {
  p_conv <- plot_convergence(result$log_likelihood_history,
                             title = "EM Algorithm: Log-Likelihood Convergence",
                             ylabel = "Log-Likelihood")
  print(p_conv)
}

# Print summary
cat("\n=== EM Algorithm Results ===\n")
cat(sprintf("Number of iterations: %d\n", result$iterations))
cat(sprintf("Converged: %s\n", result$converged))
cat(sprintf("Final log-likelihood: %.4f\n", result$log_likelihood))
cat(sprintf("Mixing weights: [%.3f, %.3f]\n", result$weights[1], result$weights[2]))
cat("\nComponent means:\n")
print(result$means)

