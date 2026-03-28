# Test BCa Bootstrap Implementation

source("algorithms/bootstrap/bca_bootstrap.R")

# Simulation setup
set.seed(123)
data <- rlnorm(100) # Log-normal distribution (skewed)
mean_func <- function(x) mean(x) # Statistic of interest

# Run custom BCa implementation
cat("Running custom BCa implementation...\n")
result_custom <- bca_interval(data, mean_func, R = 1000)
print(result_custom$conf_int)

# Run standard 'boot' package implementation for comparison
if (requireNamespace("boot", quietly = TRUE)) {
  cat("\nRunning 'boot' package implementation...\n")
  library(boot)
  
  boot_stat <- function(data, indices) {
    d <- data[indices]
    mean(d)
  }
  
  boot_out <- boot(data, boot_stat, R = 1000)
  boot_ci <- boot.ci(boot_out, type = "bca")
  
  print(boot_ci)
  
  # Compare limits
  custom_lower <- result_custom$conf_int[1]
  custom_upper <- result_custom$conf_int[2]
  boot_lower <- boot_ci$bca[4]
  boot_upper <- boot_ci$bca[5]
  
  cat("\nComparison:\n")
  cat(sprintf("Custom Lower: %.4f, Boot Lower: %.4f, Diff: %.4f\n", 
              custom_lower, boot_lower, abs(custom_lower - boot_lower)))
  cat(sprintf("Custom Upper: %.4f, Boot Upper: %.4f, Diff: %.4f\n", 
              custom_upper, boot_upper, abs(custom_upper - boot_upper)))
              
  if (abs(custom_lower - boot_lower) < 0.1 && abs(custom_upper - boot_upper) < 0.1) {
      cat("\nSUCCESS: Custom implementation matches 'boot' package reasonably well.\n")
  } else {
      cat("\nWARNING: Discrepancy detected.\n")
  }
} else {
  cat("\n'boot' package not installed, skipping comparison.\n")
}
