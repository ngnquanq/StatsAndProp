# Helper functions for Kernel Smoothing Algorithm

#' Gaussian Kernel Function
#'
#' @param u Normalized distance
#' @return Kernel weight
gaussian_kernel <- function(u) {
  (1 / sqrt(2 * pi)) * exp(-u^2 / 2)
}

#' Epanechnikov Kernel Function
#'
#' @param u Normalized distance
#' @return Kernel weight
epanechnikov_kernel <- function(u) {
  ifelse(abs(u) <= 1, (3/4) * (1 - u^2), 0)
}

#' Uniform Kernel Function
#'
#' @param u Normalized distance
#' @return Kernel weight
uniform_kernel <- function(u) {
  ifelse(abs(u) <= 1, 1/2, 0)
}

#' Triangular Kernel Function
#'
#' @param u Normalized distance
#' @return Kernel weight
triangular_kernel <- function(u) {
  ifelse(abs(u) <= 1, (1 - abs(u)), 0)
}

#' Get kernel function by name
#'
#' @param kernel_name Name of the kernel ("gaussian", "epanechnikov", "uniform", "triangular")
#' @return Kernel function
get_kernel_function <- function(kernel_name = "gaussian") {
  kernel_name <- tolower(kernel_name)
  
  switch(kernel_name,
    "gaussian" = gaussian_kernel,
    "epanechnikov" = epanechnikov_kernel,
    "uniform" = uniform_kernel,
    "triangular" = triangular_kernel,
    {
      warning(paste("Unknown kernel:", kernel_name, "- using Gaussian"))
      gaussian_kernel
    }
  )
}

#' Calculate bandwidth using rule-of-thumb
#'
#' @param x Predictor variable
#' @param method Method for bandwidth selection ("rule_of_thumb" or "silverman")
#' @return Bandwidth value
calculate_bandwidth <- function(x, method = "rule_of_thumb") {
  n <- length(x)
  
  if (n < 2) {
    warning("Not enough data points for bandwidth calculation, using default")
    return(0.1)
  }
  
  sigma <- sd(x)
  
  if (method == "rule_of_thumb") {
    # Rule of thumb: h = 1.06 * σ * n^(-1/5)
    h <- 1.06 * sigma * n^(-1/5)
  } else if (method == "silverman") {
    # Silverman's rule of thumb: h = 0.9 * min(σ, IQR/1.34) * n^(-1/5)
    iqr <- IQR(x)
    h <- 0.9 * min(sigma, iqr / 1.34, na.rm = TRUE) * n^(-1/5)
  } else {
    stop("Unknown bandwidth method. Use 'rule_of_thumb' or 'silverman'")
  }
  
  # Ensure bandwidth is positive and reasonable
  if (h <= 0 || !is.finite(h)) {
    warning("Invalid bandwidth calculated, using default")
    h <- diff(range(x)) / 10
  }
  
  return(h)
}

#' Create evaluation grid for smoothing
#'
#' @param x Data points
#' @param n_grid Number of grid points
#' @param extend Extend grid beyond data range (as fraction of range)
#' @return Grid of evaluation points
create_evaluation_grid <- function(x, n_grid = 100, extend = 0.1) {
  x_range <- range(x, na.rm = TRUE)
  x_span <- diff(x_range)
  
  # Extend the range slightly
  x_min <- x_range[1] - extend * x_span
  x_max <- x_range[2] + extend * x_span
  
  # Create evenly spaced grid
  seq(from = x_min, to = x_max, length.out = n_grid)
}

#' Validate input data for smoothing
#'
#' @param x Predictor variable
#' @param y Response variable
#' @return Logical indicating if data is valid
validate_smoothing_input <- function(x, y) {
  if (length(x) != length(y)) {
    stop("x and y must have the same length")
  }
  
  if (length(x) < 2) {
    stop("Need at least 2 data points for smoothing")
  }
  
  if (any(is.na(x)) || any(is.na(y))) {
    warning("NA values detected in data - they will be removed")
  }
  
  return(TRUE)
}

#' Calculate appropriate degrees of freedom for spline smoothing
#'
#' @param n Number of data points
#' @param method Method for df calculation ("default" or "conservative")
#' @return Suggested degrees of freedom
calculate_spline_df <- function(n, method = "default") {
  if (method == "default") {
    # Default: use cross-validation, but suggest a range
    # Typically df ranges from 4 to n/2
    df_min <- 4
    df_max <- min(n / 2, 20)  # Cap at 20 for computational efficiency
    return(list(min = df_min, max = df_max, suggested = min(10, n / 5)))
  } else if (method == "conservative") {
    # More conservative: fewer degrees of freedom = smoother
    return(list(min = 4, max = min(n / 3, 15), suggested = min(8, n / 6)))
  } else {
    stop("Unknown method. Use 'default' or 'conservative'")
  }
}

#' Convert spar to df (approximate)
#'
#' @param spar Smoothing parameter
#' @param n Number of data points
#' @return Approximate degrees of freedom
spar_to_df <- function(spar, n) {
  # Approximate relationship: df decreases as spar increases
  # This is a rough approximation
  df_max <- n
  df_min <- 2
  df <- df_max - (df_max - df_min) * spar
  return(max(df_min, min(df_max, df)))
}
