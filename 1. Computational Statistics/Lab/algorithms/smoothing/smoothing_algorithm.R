# Kernel Smoothing Algorithm - Main Implementation

source("smoothing_helpers.R")

#' Kernel Smoothing Algorithm
#'
#' Implements kernel smoothing following the algorithm described in the documentation.
#' For each target point, calculates weighted average of nearby data points using a kernel function.
#'
#' @param x Numeric vector of predictor values
#' @param y Numeric vector of response values
#' @param bandwidth Numeric, bandwidth parameter (h). If NULL, automatically calculated
#' @param kernel Character, kernel function name ("gaussian", "epanechnikov", "uniform", "triangular")
#' @param n_grid Integer, number of evaluation points for the smoothed curve
#' @param x_grid Optional numeric vector of evaluation points. If NULL, created automatically
#' @param verbose Logical, whether to print progress information
#' @return List containing:
#'   - x_grid: Evaluation points
#'   - y_smooth: Smoothed values at evaluation points
#'   - bandwidth: Bandwidth used
#'   - kernel: Kernel function name
#'   - x_original: Original x values
#'   - y_original: Original y values
#'
#' @examples
#' # Generate noisy data
#' x <- seq(0, 10, length.out = 50)
#' y <- sin(x) + rnorm(50, sd = 0.3)
#' result <- kernel_smooth(x, y, bandwidth = 0.5)
kernel_smooth <- function(x, y, bandwidth = NULL, kernel = "gaussian", 
                          n_grid = 100, x_grid = NULL, verbose = FALSE) {
  
  # Validate input
  validate_smoothing_input(x, y)
  
  # Remove NA values
  complete_cases <- complete.cases(x, y)
  x <- x[complete_cases]
  y <- y[complete_cases]
  
  if (length(x) < 2) {
    stop("Need at least 2 complete data points for smoothing")
  }
  
  # Get kernel function
  kernel_func <- get_kernel_function(kernel)
  
  # Calculate bandwidth if not provided
  if (is.null(bandwidth)) {
    bandwidth <- calculate_bandwidth(x)
    if (verbose) {
      cat(sprintf("Auto-calculated bandwidth: %.4f\n", bandwidth))
    }
  }
  
  if (bandwidth <= 0) {
    stop("Bandwidth must be positive")
  }
  
  # Create evaluation grid if not provided
  if (is.null(x_grid)) {
    x_grid <- create_evaluation_grid(x, n_grid = n_grid)
  }
  
  n_grid <- length(x_grid)
  n_data <- length(x)
  
  # Initialize output
  y_smooth <- numeric(n_grid)
  
  if (verbose) {
    cat(sprintf("Smoothing %d data points at %d evaluation points...\n", n_data, n_grid))
  }
  
  # Main algorithm: For each target point in grid
  for (i in 1:n_grid) {
    x0 <- x_grid[i]
    
    # Initialize accumulators
    sum_weighted_y <- 0
    sum_weights <- 0
    
    # Inner loop: For each data point
    for (j in 1:n_data) {
      # Step 1: Calculate normalized distance
      u <- (x0 - x[j]) / bandwidth
      
      # Step 2: Calculate weight using kernel function
      weight <- kernel_func(u)
      
      # Step 3: Accumulate weighted sums
      sum_weighted_y <- sum_weighted_y + (weight * y[j])
      sum_weights <- sum_weights + weight
    }
    
    # Step 4: Calculate weighted average
    if (sum_weights > 0) {
      y_smooth[i] <- sum_weighted_y / sum_weights
    } else {
      # If no weights (shouldn't happen with proper kernel), use mean
      y_smooth[i] <- mean(y)
    }
  }
  
  if (verbose) {
    cat("Smoothing complete.\n")
  }
  
  # Return results
  list(
    x_grid = x_grid,
    y_smooth = y_smooth,
    bandwidth = bandwidth,
    kernel = kernel,
    x_original = x,
    y_original = y
  )
}

#' Spline Smoothing Algorithm
#'
#' Implements smoothing splines using R's built-in smooth.spline() function.
#' Smoothing splines use penalized regression to create smooth curves.
#'
#' @param x Numeric vector of predictor values
#' @param y Numeric vector of response values
#' @param df Numeric, degrees of freedom. If NULL, automatically selected via cross-validation
#' @param spar Numeric, smoothing parameter (0-1). Higher values = smoother. If NULL, automatically selected
#' @param lambda Numeric, penalty parameter. Alternative to spar. If NULL, uses spar or df
#' @param n_grid Integer, number of evaluation points for the smoothed curve
#' @param x_grid Optional numeric vector of evaluation points. If NULL, uses original x values
#' @param verbose Logical, whether to print progress information
#' @return List containing:
#'   - x: Evaluation points
#'   - y_smooth: Smoothed values at evaluation points
#'   - df: Degrees of freedom used
#'   - spar: Smoothing parameter used
#'   - method: "spline"
#'   - x_original: Original x values
#'   - y_original: Original y values
#'   - spline_object: The smooth.spline object for predictions
#'
#' @examples
#' # Generate noisy data
#' x <- seq(0, 10, length.out = 50)
#' y <- sin(x) + rnorm(50, sd = 0.3)
#' result <- spline_smooth(x, y, df = 10)
spline_smooth <- function(x, y, df = NULL, spar = NULL, lambda = NULL,
                          n_grid = 100, x_grid = NULL, verbose = FALSE) {
  
  # Validate input
  validate_smoothing_input(x, y)
  
  # Remove NA values
  complete_cases <- complete.cases(x, y)
  x <- x[complete_cases]
  y <- y[complete_cases]
  
  if (length(x) < 2) {
    stop("Need at least 2 complete data points for smoothing")
  }
  
  # Sort by x for spline fitting
  order_x <- order(x)
  x_sorted <- x[order_x]
  y_sorted <- y[order_x]
  
  # Remove duplicates (smooth.spline requires unique x values)
  unique_idx <- !duplicated(x_sorted)
  x_unique <- x_sorted[unique_idx]
  y_unique <- y_sorted[unique_idx]
  
  if (length(x_unique) < 3) {
    warning("Too few unique x values for spline smoothing, using linear interpolation")
    if (is.null(x_grid)) {
      x_grid <- seq(min(x), max(x), length.out = n_grid)
    }
    y_smooth <- approx(x_unique, y_unique, xout = x_grid)$y
    return(list(
      x = x_grid,
      y_smooth = y_smooth,
      df = 2,
      spar = NULL,
      method = "spline",
      x_original = x,
      y_original = y,
      spline_object = NULL
    ))
  }
  
  # Fit smoothing spline
  spline_args <- list(x = x_unique, y = y_unique)
  
  if (!is.null(df)) {
    spline_args$df <- df
  } else if (!is.null(spar)) {
    spline_args$spar <- spar
  } else if (!is.null(lambda)) {
    spline_args$lambda <- lambda
  }
  # If all NULL, smooth.spline will use cross-validation
  
  if (verbose) {
    cat("Fitting smoothing spline...\n")
  }
  
  spline_fit <- do.call(smooth.spline, spline_args)
  
  # Create evaluation grid if not provided
  if (is.null(x_grid)) {
    x_grid <- seq(min(x), max(x), length.out = n_grid)
  }
  
  # Predict smoothed values
  y_smooth <- predict(spline_fit, x_grid)$y
  
  if (verbose) {
    cat(sprintf("Spline smoothing complete. df = %.2f, spar = %.4f\n", 
                spline_fit$df, spline_fit$spar))
  }
  
  # Return results
  list(
    x = x_grid,
    y_smooth = y_smooth,
    df = spline_fit$df,
    spar = spline_fit$spar,
    method = "spline",
    x_original = x,
    y_original = y,
    spline_object = spline_fit
  )
}

#' Legacy function name for backward compatibility
#'
#' @param data Data frame or matrix with x and y columns
#' @return Smoothed results
smoothing <- function(data) {
  if (is.data.frame(data)) {
    if (ncol(data) >= 2) {
      x <- data[[1]]
      y <- data[[2]]
    } else {
      stop("Data frame must have at least 2 columns")
    }
  } else if (is.matrix(data)) {
    if (ncol(data) >= 2) {
      x <- data[, 1]
      y <- data[, 2]
    } else {
      stop("Matrix must have at least 2 columns")
    }
  } else {
    stop("Data must be a data frame or matrix")
  }
  
  kernel_smooth(x, y)
}
