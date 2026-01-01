# Example usage of Kernel Smoothing Algorithm

# Load required libraries
library(ggplot2)
source("smoothing_algorithm.R")
source("smoothing_helpers.R")
source("../../scripts/visualization.R")

# Set seed for reproducibility
set.seed(123)

# ============================================================================
# Example 1: Sinusoidal function with noise
# ============================================================================
cat("Example 1: Sinusoidal function with noise\n")
cat("==========================================\n")

# Generate data: y = sin(2πx) + ε
x1 <- seq(0, 2, length.out = 50)
true_y1 <- sin(2 * pi * x1)
y1 <- true_y1 + rnorm(length(x1), sd = 0.3)

# Apply kernel smoothing
result1 <- kernel_smooth(x1, y1, bandwidth = 0.15, kernel = "gaussian", verbose = TRUE)

# Plot results
p1 <- plot_smoothing_results(x1, y1, result1, 
                             title = "Kernel Smoothing: Sinusoidal Function",
                             true_function = function(x) sin(2 * pi * x))
print(p1)

# ============================================================================
# Example 2: Comparison of different bandwidths
# ============================================================================
cat("\nExample 2: Comparison of different bandwidths\n")
cat("==============================================\n")

# Generate polynomial data: y = x² - 2x + 1 + ε
x2 <- seq(-1, 3, length.out = 60)
true_y2 <- x2^2 - 2*x2 + 1
y2 <- true_y2 + rnorm(length(x2), sd = 0.5)

# Smooth with different bandwidths
bandwidths <- c(0.1, 0.3, 0.6)
results2 <- list()

for (h in bandwidths) {
  results2[[as.character(h)]] <- kernel_smooth(x2, y2, bandwidth = h, kernel = "gaussian")
}

# Create comparison plot
df_comparison <- data.frame()
for (h in names(results2)) {
  df_temp <- data.frame(
    x = results2[[h]]$x_grid,
    y = results2[[h]]$y_smooth,
    bandwidth = paste("h =", h)
  )
  df_comparison <- rbind(df_comparison, df_temp)
}

p2 <- ggplot() +
  geom_point(data = data.frame(x = x2, y = y2), 
            aes(x = x, y = y), color = "gray", alpha = 0.5, size = 1.5) +
  geom_line(data = df_comparison, aes(x = x, y = y, color = bandwidth), size = 1) +
  geom_line(data = data.frame(x = x2, y = true_y2), 
           aes(x = x, y = y), linetype = "dashed", color = "green", size = 1) +
  labs(title = "Kernel Smoothing: Effect of Bandwidth",
       subtitle = "True function: y = x² - 2x + 1",
       x = "X",
       y = "Y",
       color = "Bandwidth") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

print(p2)

# ============================================================================
# Example 3: Comparison of different kernel functions
# ============================================================================
cat("\nExample 3: Comparison of different kernel functions\n")
cat("====================================================\n")

# Generate data: y = cos(πx) + ε
x3 <- seq(0, 4, length.out = 40)
true_y3 <- cos(pi * x3)
y3 <- true_y3 + rnorm(length(x3), sd = 0.25)

# Smooth with different kernels
kernels <- c("gaussian", "epanechnikov", "uniform", "triangular")
results3 <- list()

for (k in kernels) {
  results3[[k]] <- kernel_smooth(x3, y3, bandwidth = 0.4, kernel = k)
}

# Create comparison plot
df_kernels <- data.frame()
for (k in names(results3)) {
  df_temp <- data.frame(
    x = results3[[k]]$x_grid,
    y = results3[[k]]$y_smooth,
    kernel = k
  )
  df_kernels <- rbind(df_kernels, df_temp)
}

p3 <- ggplot() +
  geom_point(data = data.frame(x = x3, y = y3), 
            aes(x = x, y = y), color = "gray", alpha = 0.5, size = 1.5) +
  geom_line(data = df_kernels, aes(x = x, y = y, color = kernel), size = 1) +
  geom_line(data = data.frame(x = x3, y = true_y3), 
           aes(x = x, y = y), linetype = "dashed", color = "green", size = 1) +
  labs(title = "Kernel Smoothing: Comparison of Kernel Functions",
       subtitle = "True function: y = cos(πx), Bandwidth = 0.4",
       x = "X",
       y = "Y",
       color = "Kernel") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

print(p3)

# ============================================================================
# Example 4: Real-world scenario - Time series with trend
# ============================================================================
cat("\nExample 4: Time series with trend\n")
cat("==================================\n")

# Simulate time series data with trend and noise
time <- 1:100
trend <- 0.05 * time + 10
seasonal <- 3 * sin(2 * pi * time / 20)
noise <- rnorm(length(time), sd = 1.5)
y4 <- trend + seasonal + noise

# Smooth the time series with kernel
result4_kernel <- kernel_smooth(time, y4, bandwidth = 5, kernel = "gaussian", n_grid = 200)

# Smooth the time series with spline
result4_spline <- spline_smooth(time, y4, df = 15, n_grid = 200)

# Compare both methods
p4 <- plot_smoothing_comparison(time, y4, result4_kernel, result4_spline,
                               title = "Kernel vs Spline: Time Series Data")
print(p4)

# ============================================================================
# Example 5: Kernel vs Spline Comparison - Sinusoidal Function
# ============================================================================
cat("\nExample 5: Kernel vs Spline Comparison\n")
cat("========================================\n")

# Generate noisy sinusoidal data
set.seed(999)
x5 <- seq(0, 2, length.out = 50)
true_y5 <- sin(2 * pi * x5)
y5 <- true_y5 + rnorm(length(x5), sd = 0.3)

# Apply both methods
result5_kernel <- kernel_smooth(x5, y5, bandwidth = 0.15, kernel = "gaussian")
result5_spline <- spline_smooth(x5, y5, df = 10)

# Compare
p5 <- plot_smoothing_comparison(x5, y5, result5_kernel, result5_spline,
                               title = "Kernel vs Spline: Sinusoidal Function",
                               true_function = function(x) sin(2 * pi * x))
print(p5)

# ============================================================================
# Example 6: Spline Smoothing with Different Parameters
# ============================================================================
cat("\nExample 6: Spline Smoothing with Different Parameters\n")
cat("======================================================\n")

# Generate data
x6 <- seq(0, 4, length.out = 50)
true_y6 <- cos(pi * x6)
y6 <- true_y6 + rnorm(length(x6), sd = 0.3)

# Smooth with different degrees of freedom
df_values <- c(5, 10, 20)
results6_spline <- list()

for (df_val in df_values) {
  results6_spline[[as.character(df_val)]] <- spline_smooth(x6, y6, df = df_val)
}

# Create comparison plot
df_spline_params <- data.frame()
for (df_val in names(results6_spline)) {
  df_temp <- data.frame(
    x = results6_spline[[df_val]]$x,
    y = results6_spline[[df_val]]$y_smooth,
    df = paste("df =", df_val)
  )
  df_spline_params <- rbind(df_spline_params, df_temp)
}

p6 <- ggplot() +
  geom_point(data = data.frame(x = x6, y = y6), 
            aes(x = x, y = y), color = "gray", alpha = 0.5, size = 1.5) +
  geom_line(data = df_spline_params, aes(x = x, y = y, color = df), size = 1) +
  geom_line(data = data.frame(x = x6, y = true_y6), 
           aes(x = x, y = y), linetype = "dashed", color = "green", size = 1) +
  labs(title = "Spline Smoothing: Effect of Degrees of Freedom",
       subtitle = "True function: y = cos(πx)",
       x = "X",
       y = "Y",
       color = "Degrees of Freedom") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

print(p6)

cat("\nAll examples completed!\n")
