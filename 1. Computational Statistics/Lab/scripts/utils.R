# Utility functions for Computational Statistics Lab

#' Check if a value is numeric and finite
#' 
#' @param x Value to check
#' @return Logical indicating if value is numeric and finite
is_valid_numeric <- function(x) {
  is.numeric(x) && is.finite(x)
}

#' Normalize a vector to [0, 1]
#' 
#' @param x Numeric vector
#' @return Normalized vector
normalize <- function(x) {
  if (all(x == 0)) return(x)
  (x - min(x)) / (max(x) - min(x))
}

#' Calculate Euclidean distance between two vectors
#' 
#' @param x First vector
#' @param y Second vector
#' @return Euclidean distance
euclidean_distance <- function(x, y) {
  sqrt(sum((x - y)^2))
}

#' Calculate squared Euclidean distance
#' 
#' @param x First vector
#' @param y Second vector
#' @return Squared Euclidean distance
squared_euclidean_distance <- function(x, y) {
  sum((x - y)^2)
}

#' Check convergence based on relative change
#' 
#' @param old_value Previous value
#' @param new_value Current value
#' @param tolerance Convergence tolerance
#' @return Logical indicating convergence
check_convergence <- function(old_value, new_value, tolerance = 1e-6) {
  if (abs(old_value) < tolerance) {
    return(abs(new_value - old_value) < tolerance)
  }
  abs((new_value - old_value) / old_value) < tolerance
}

#' Print progress message
#' 
#' @param iteration Current iteration
#' @param max_iter Maximum iterations
#' @param message Additional message
print_progress <- function(iteration, max_iter, message = "") {
  if (iteration %% max(1, floor(max_iter / 10)) == 0 || iteration == max_iter) {
    cat(sprintf("Iteration %d/%d %s\n", iteration, max_iter, message))
  }
}

