#' Simulate Bootstrap Failure for Cauchy Distribution
#'
#' @param n Sample size
#' @param B Number of bootstrap iterations
#' @param location Cauchy location parameter
#' @param scale Cauchy scale parameter
#' @return A list containing the original sample and bootstrap means
simulate_cauchy_bootstrap <- function(n, B, location = 0, scale = 1) {
    # 1. Generate original sample
    x <- rcauchy(n, location = location, scale = scale)

    # 2. Bootstrap
    bootstrap_means <- numeric(B)
    for (i in 1:B) {
        # Resample with replacement
        x_star <- sample(x, size = n, replace = TRUE)
        bootstrap_means[i] <- mean(x_star)
    }

    return(list(sample = x, bootstrap_means = bootstrap_means))
}

#' Simulate Bootstrap Failure for Uniform Distribution Max
#'
#' @param n Sample size
#' @param theta True upper bound of U(0, theta)
#' @param B Number of bootstrap iterations
#' @return A list containing the original sample, estimate theta_hat, and
#'   bootstrap estimates
simulate_uniform_max_bootstrap <- function(n, theta, B) {
    # 1. Generate original sample from U(0, theta)
    x <- runif(n, min = 0, max = theta)
    theta_hat <- max(x)

    # 2. Bootstrap
    bootstrap_thetas <- numeric(B)
    for (i in 1:B) {
        # Resample with replacement
        x_star <- sample(x, size = n, replace = TRUE)
        bootstrap_thetas[i] <- max(x_star)
    }

    return(list(sample = x, theta_hat = theta_hat, bootstrap_thetas = bootstrap_thetas))
}

# Main execution for generating plots

set.seed(123)

# Define sample sizes to experiment with
n_vals <- c(30, 100, 500)
B <- 1000

# --- Part (a): Cauchy with Varying Sample Sizes ---
# Notice how the range of the bootstrap means explodes or remains unstable
png("cauchy_bootstrap_failure_varying_n.png", width = 1200, height = 800)
par(mfcol = c(2, length(n_vals))) # 2 rows (Sample, Bootstrap), one col per n

for (n in n_vals) {
    res <- simulate_cauchy_bootstrap(n, B)
    # Original Sample Hist
    # We restrict xlim on the histogram to see the "body", but the range will show the outlier
    sample_range <- range(res$sample)
    hist(res$sample,
        main = paste0(
            "Cauchy (n=", n, ")\nRange: [",
            round(sample_range[1], 1), ", ", round(sample_range[2], 1), "]"
        ),
        col = "lightblue", border = "white", breaks = 30
    )

    # Bootstrap Means Hist
    mean_range <- range(res$bootstrap_means)
    hist(res$bootstrap_means,
        main = paste0(
            "Boot Means (n=", n, ")\nRange: [",
            round(mean_range[1], 1), ", ", round(mean_range[2], 1), "]"
        ),
        col = "salmon", border = "white", breaks = 30, xlab = "Bootstrap Means"
    )
}
dev.off()
cat("Generated cauchy_bootstrap_failure_varying_n.png\n")

# --- Part (b): Uniform Max with Varying Sample Sizes ---
theta <- 10

png("uniform_bootstrap_failure_varying_n.png", width = 1200, height = 800)
par(mfcol = c(2, length(n_vals)))

for (n in n_vals) {
    res <- simulate_uniform_max_bootstrap(n, theta, B)

    # Original Sample Hist
    hist(res$sample,
        main = paste0("Uniform (n=", n, ")\nMax Est: ", round(res$theta_hat, 4)),
        col = "lightblue", border = "white", xlim = c(0, theta), breaks = 15
    )
    abline(v = res$theta_hat, col = "red", lty = 2)

    # Bootstrap Max Hist
    # Shows the gap between the estimates and the true theta (10)
    hist(res$bootstrap_thetas,
        main = paste("Boot Max (n =", n, ")"),
        col = "salmon", border = "white",
        xlim = c(min(res$bootstrap_thetas) * 0.9, theta * 1.05),
        breaks = 30, xlab = "Max Estimates"
    )
    abline(v = res$theta_hat, col = "red", lty = 2, lwd = 2) # Sample Max
    abline(v = theta, col = "green", lty = 3, lwd = 2) # True Max
    if (n == n_vals[1]) {
        legend("topleft",
            legend = c("Sample Max", "True Theta"),
            col = c("red", "green"), lty = c(2, 3), bg = "white"
        )
    }
}
dev.off()
cat("Generated uniform_bootstrap_failure_varying_n.png\n")
