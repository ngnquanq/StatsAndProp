#' Accelerated Bias-Corrected Percentile (BCa) Bootstrap Confidence Interval
#'
#' Calculates the BCa confidence interval for a given statistic using bootstrap resampling.
#'
#' @param data Input vector or matrix (n x d).
#' @param statistic Function to compute the statistic of interest (must accept data as first argument).
#' @param R Number of bootstrap replicates (default: 2000).
#' @param alpha Significance level (default: 0.05).
#' @param ... Additional arguments passed to the statistic function.
#'
#' @return A list containing:
#'   - conf_int: The BCa confidence interval (lower, upper).
#'   - estimate: The observed statistic estimate.
#'   - bootstrap_replicates: The vector of bootstrap statistics.
#'   - z0: The bias-correction value.
#'   - a: The acceleration value.
#'
#' @examples
#' data <- rnorm(100)
#' mean_func <- function(x) mean(x)
#' result <- bca_interval(data, mean_func)
#' print(result$conf_int)
bca_interval <- function(data, statistic, R = 2000, alpha = 0.05, ...) {
  
  # 1. Observed statistic
  theta_hat <- statistic(data, ...)
  n <- length(data) # Assumes vector input for now; can be adapted for matrix rows if needed
  
  # Check if data is matrix/data.frame for n
  if (is.matrix(data) || is.data.frame(data)) {
    n <- nrow(data)
  }

  # 2. Bootstrap Resampling
  theta_star <- numeric(R)
  for (i in 1:R) {
    # Resample with replacement
    if (is.matrix(data) || is.data.frame(data)){
        indices <- sample(1:n, n, replace = TRUE)
        resample <- data[indices, , drop = FALSE]
    } else {
        resample <- sample(data, n, replace = TRUE)
    }
    theta_star[i] <- statistic(resample, ...)
  }
  
  # 3. Bias Correction (z0)
  # Proportion of bootstrap estimates less than observed estimate
  prop_less <- mean(theta_star < theta_hat)
  
  # Handle edge cases where prop_less is 0 or 1
  if (prop_less == 0) {
      z0 <- -Inf
  } else if (prop_less == 1) {
      z0 <- Inf
  } else {
      z0 <- qnorm(prop_less)
  }
  
  # 4. Acceleration (a)
  # Use Jackknife (leave-one-out)
  theta_jack <- numeric(n)
  for (i in 1:n) {
    if (is.matrix(data) || is.data.frame(data)){
        jack_sample <- data[-i, , drop = FALSE]
    } else {
        jack_sample <- data[-i]
    }
    theta_jack[i] <- statistic(jack_sample, ...)
  }
  
  avg_theta_jack <- mean(theta_jack)
  num <- sum((avg_theta_jack - theta_jack)^3)
  denom <- 6 * (sum((avg_theta_jack - theta_jack)^2))^1.5
  
  a <- num / denom
  
  # Handle potential division by zero or NaN in acceleration
  if (is.nan(a)) a <- 0 
  
  # 5. BCa Interval Limits
  z_alpha_lower <- qnorm(alpha / 2)
  z_alpha_upper <- qnorm(1 - alpha / 2)
  
  # Calculate adjusted quantiles
  # If z0 is Inf or -Inf, we can't really proceed with standard formula, 
  # usually implies lack of overlap or extreme bias. 
  # For now, let's assume valid z0 unless edge case handling is requested.
  
  if (is.infinite(z0)) {
     warning("Bias correction z0 is infinite. Returning percentile interval.")
     alpha1 <- alpha / 2
     alpha2 <- 1 - alpha / 2
  } else {
      adj_alpha_lower <- pnorm(z0 + (z0 + z_alpha_lower) / (1 - a * (z0 + z_alpha_lower)))
      adj_alpha_upper <- pnorm(z0 + (z0 + z_alpha_upper) / (1 - a * (z0 + z_alpha_upper)))
      
      # Constrain alphas to (0, 1) to avoid quantile errors
      alpha1 <- max(min(adj_alpha_lower, 1), 0)
      alpha2 <- max(min(adj_alpha_upper, 1), 0)
  }

  conf_int <- quantile(theta_star, c(alpha1, alpha2), na.rm = TRUE)
  names(conf_int) <- c(paste0(100 * alpha/2, "%"), paste0(100 * (1 - alpha/2), "%"))
  
  list(
    conf_int = conf_int,
    estimate = theta_hat,
    bootstrap_replicates = theta_star,
    z0 = z0,
    a = a
  )
}
