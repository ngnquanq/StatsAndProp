# Helper functions for EM Algorithm

#' Initialize means using k-means++ or random selection
#'
#' @param data Numeric matrix
#' @param k Number of components
#' @return Matrix of initial means
initialize_means <- function(data, k) {
  n <- nrow(data)
  d <- ncol(data)
  
  # Simple random initialization
  indices <- sample(n, k)
  means <- data[indices, , drop = FALSE]
  
  return(means)
}

#' Initialize covariance matrices
#'
#' @param data Numeric matrix
#' @param k Number of components
#' @return Array of covariance matrices
initialize_covariances <- function(data, k) {
  n <- nrow(data)
  d <- ncol(data)
  
  # Initialize with sample covariance
  sample_cov <- cov(data)
  
  # Create array of covariance matrices
  covariances <- array(0, dim = c(d, d, k))
  for (i in 1:k) {
    covariances[, , i] <- sample_cov
  }
  
  return(covariances)
}

#' E-step: Compute responsibilities (posterior probabilities)
#'
#' @param data Numeric matrix
#' @param means Matrix of component means
#' @param covariances Array of covariance matrices
#' @param weights Mixing weights
#' @return Matrix of responsibilities
e_step <- function(data, means, covariances, weights) {
  n <- nrow(data)
  k <- length(weights)
  
  # Compute log probabilities for each component
  log_probs <- matrix(0, nrow = n, ncol = k)
  
  for (i in 1:k) {
    # Multivariate normal log-density
    diff <- t(t(data) - means[i, ])
    inv_cov <- solve(covariances[, , i])
    log_det <- log(det(covariances[, , i]))
    
    log_probs[, i] <- -0.5 * (log_det + 
      rowSums((diff %*% inv_cov) * diff)) +
      log(weights[i])
  }
  
  # Normalize to get responsibilities (using log-sum-exp trick)
  max_log_probs <- apply(log_probs, 1, max)
  log_probs_normalized <- log_probs - max_log_probs
  probs <- exp(log_probs_normalized)
  responsibilities <- probs / rowSums(probs)
  
  return(responsibilities)
}

#' M-step: Update parameters
#'
#' @param data Numeric matrix
#' @param responsibilities Matrix of responsibilities
#' @return List with updated means, covariances, and weights
m_step <- function(data, responsibilities) {
  n <- nrow(data)
  k <- ncol(responsibilities)
  d <- ncol(data)
  
  # Effective number of points per component
  nk <- colSums(responsibilities)
  
  # Update weights
  weights <- nk / n
  
  # Update means
  means <- matrix(0, nrow = k, ncol = d)
  for (i in 1:k) {
    means[i, ] <- colSums(responsibilities[, i] * data) / nk[i]
  }
  
  # Update covariances
  covariances <- array(0, dim = c(d, d, k))
  for (i in 1:k) {
    diff <- t(t(data) - means[i, ])
    covariances[, , i] <- (t(diff) %*% (responsibilities[, i] * diff)) / nk[i]
    
    # Add small regularization to ensure positive definiteness
    covariances[, , i] <- covariances[, , i] + diag(1e-6, d)
  }
  
  return(list(means = means, covariances = covariances, weights = weights))
}

#' Compute log-likelihood
#'
#' @param data Numeric matrix
#' @param means Matrix of component means
#' @param covariances Array of covariance matrices
#' @param weights Mixing weights
#' @return Log-likelihood value
compute_log_likelihood <- function(data, means, covariances, weights) {
  n <- nrow(data)
  k <- length(weights)
  
  log_probs <- matrix(0, nrow = n, ncol = k)
  
  for (i in 1:k) {
    diff <- t(t(data) - means[i, ])
    inv_cov <- solve(covariances[, , i])
    log_det <- log(det(covariances[, , i]))
    
    log_probs[, i] <- -0.5 * (log_det + 
      rowSums((diff %*% inv_cov) * diff)) +
      log(weights[i])
  }
  
  # Log-sum-exp trick
  max_log_probs <- apply(log_probs, 1, max)
  log_likelihood <- sum(max_log_probs + log(rowSums(exp(log_probs - max_log_probs))))
  
  return(log_likelihood)
}

#' Check convergence
#'
#' @param old_value Previous log-likelihood
#' @param new_value Current log-likelihood
#' @param tolerance Convergence tolerance
#' @return Logical indicating convergence
check_convergence <- function(old_value, new_value, tolerance = 1e-6) {
  if (abs(old_value) < tolerance) {
    return(abs(new_value - old_value) < tolerance)
  }
  abs((new_value - old_value) / old_value) < tolerance
}

