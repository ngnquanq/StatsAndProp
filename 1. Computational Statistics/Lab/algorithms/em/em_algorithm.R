# Expectation-Maximization (EM) Algorithm Implementation
# For Gaussian Mixture Models

#' EM Algorithm for Gaussian Mixture Models
#'
#' @param data Numeric matrix or data frame with observations (rows) and features (columns)
#' @param k Integer, number of mixture components
#' @param max_iter Integer, maximum number of iterations (default: 100)
#' @param tol Numeric, convergence tolerance (default: 1e-6)
#' @param verbose Logical, whether to print progress (default: FALSE)
#' @return List containing:
#'   - means: Matrix of component means
#'   - covariances: Array of covariance matrices
#'   - weights: Mixing weights
#'   - responsibilities: Posterior probabilities
#'   - log_likelihood: Final log-likelihood
#'   - log_likelihood_history: History of log-likelihood values
#'   - iterations: Number of iterations performed
#'   - converged: Logical indicating convergence
#'
#' @examples
#' data <- matrix(rnorm(200), ncol = 2)
#' result <- em_algorithm(data, k = 2, max_iter = 100)
em_algorithm <- function(data, k, max_iter = 100, tol = 1e-6, verbose = FALSE) {
  
  # Input validation
  if (!is.matrix(data) && !is.data.frame(data)) {
    stop("data must be a matrix or data frame")
  }
  data <- as.matrix(data)
  
  if (k < 1 || k > nrow(data)) {
    stop("k must be between 1 and the number of observations")
  }
  
  n <- nrow(data)
  d <- ncol(data)
  
  # Initialize parameters
  means <- initialize_means(data, k)
  covariances <- initialize_covariances(data, k)
  weights <- rep(1/k, k)
  
  # Storage for convergence tracking
  log_likelihood_history <- numeric(max_iter)
  old_log_likelihood <- -Inf
  
  # Main EM loop
  for (iter in 1:max_iter) {
    
    # E-step: Compute responsibilities
    responsibilities <- e_step(data, means, covariances, weights)
    
    # M-step: Update parameters
    m_result <- m_step(data, responsibilities)
    means <- m_result$means
    covariances <- m_result$covariances
    weights <- m_result$weights
    
    # Compute log-likelihood
    log_likelihood <- compute_log_likelihood(data, means, covariances, weights)
    log_likelihood_history[iter] <- log_likelihood
    
    # Check convergence
    if (iter > 1) {
      if (check_convergence(old_log_likelihood, log_likelihood, tol)) {
        if (verbose) {
          cat(sprintf("Converged at iteration %d\n", iter))
        }
        log_likelihood_history <- log_likelihood_history[1:iter]
        break
      }
    }
    
    old_log_likelihood <- log_likelihood
    
    if (verbose && iter %% 10 == 0) {
      cat(sprintf("Iteration %d: Log-likelihood = %.4f\n", iter, log_likelihood))
    }
  }
  
  # Return results
  list(
    means = means,
    covariances = covariances,
    weights = weights,
    responsibilities = responsibilities,
    log_likelihood = log_likelihood,
    log_likelihood_history = log_likelihood_history,
    iterations = iter,
    converged = iter < max_iter
  )
}

