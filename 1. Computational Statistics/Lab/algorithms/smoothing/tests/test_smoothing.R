# Unit tests for Kernel Smoothing Algorithm

library(testthat)
source("../smoothing_algorithm.R")
source("../smoothing_helpers.R")

# Test data
set.seed(123)
test_x <- seq(0, 10, length.out = 20)
test_y <- sin(test_x) + rnorm(length(test_x), sd = 0.2)

# ============================================================================
# Tests for Kernel Functions
# ============================================================================

test_that("Gaussian kernel is non-negative", {
  u <- seq(-3, 3, length.out = 100)
  weights <- gaussian_kernel(u)
  expect_true(all(weights >= 0))
})

test_that("Gaussian kernel is symmetric", {
  u <- seq(-3, 3, length.out = 100)
  weights_pos <- gaussian_kernel(u)
  weights_neg <- gaussian_kernel(-u)
  expect_equal(weights_pos, weights_neg, tolerance = 1e-10)
})

test_that("Epanechnikov kernel is zero outside [-1, 1]", {
  u <- c(-2, -1.5, 1.5, 2)
  weights <- epanechnikov_kernel(u)
  expect_true(all(weights == 0))
})

test_that("Epanechnikov kernel is non-negative", {
  u <- seq(-2, 2, length.out = 100)
  weights <- epanechnikov_kernel(u)
  expect_true(all(weights >= 0))
})

test_that("Uniform kernel is constant in [-1, 1]", {
  u <- seq(-0.9, 0.9, length.out = 10)
  weights <- uniform_kernel(u)
  expect_true(all(abs(weights - 0.5) < 1e-10))
})

test_that("Triangular kernel is zero outside [-1, 1]", {
  u <- c(-2, 2)
  weights <- triangular_kernel(u)
  expect_true(all(weights == 0))
})

test_that("Triangular kernel peaks at zero", {
  u <- c(-0.5, 0, 0.5)
  weights <- triangular_kernel(u)
  expect_true(weights[2] > weights[1])
  expect_true(weights[2] > weights[3])
})

test_that("get_kernel_function returns correct function", {
  expect_true(is.function(get_kernel_function("gaussian")))
  expect_true(is.function(get_kernel_function("epanechnikov")))
  expect_true(is.function(get_kernel_function("uniform")))
  expect_true(is.function(get_kernel_function("triangular")))
})

test_that("get_kernel_function defaults to Gaussian for unknown kernel", {
  func <- get_kernel_function("unknown")
  expect_true(is.function(func))
  # Should be Gaussian (test by checking it's not zero at u=0)
  expect_true(func(0) > 0)
})

# ============================================================================
# Tests for Bandwidth Calculation
# ============================================================================

test_that("calculate_bandwidth returns positive value", {
  h <- calculate_bandwidth(test_x)
  expect_true(h > 0)
  expect_true(is.finite(h))
})

test_that("calculate_bandwidth works with different methods", {
  h1 <- calculate_bandwidth(test_x, method = "rule_of_thumb")
  h2 <- calculate_bandwidth(test_x, method = "silverman")
  expect_true(h1 > 0)
  expect_true(h2 > 0)
})

test_that("calculate_bandwidth handles edge cases", {
  # Very small dataset
  h_small <- calculate_bandwidth(c(1, 2, 3))
  expect_true(h_small > 0)
})

# ============================================================================
# Tests for Kernel Smoothing Algorithm
# ============================================================================

test_that("kernel_smooth runs without errors", {
  expect_error(kernel_smooth(test_x, test_y, bandwidth = 0.5), NA)
})

test_that("kernel_smooth returns correct structure", {
  result <- kernel_smooth(test_x, test_y, bandwidth = 0.5)
  
  expect_true(is.list(result))
  expect_true("x_grid" %in% names(result))
  expect_true("y_smooth" %in% names(result))
  expect_true("bandwidth" %in% names(result))
  expect_true("kernel" %in% names(result))
})

test_that("kernel_smooth returns correct dimensions", {
  result <- kernel_smooth(test_x, test_y, bandwidth = 0.5, n_grid = 50)
  
  expect_equal(length(result$x_grid), 50)
  expect_equal(length(result$y_smooth), 50)
})

test_that("kernel_smooth works with different kernels", {
  kernels <- c("gaussian", "epanechnikov", "uniform", "triangular")
  
  for (k in kernels) {
    result <- kernel_smooth(test_x, test_y, bandwidth = 0.5, kernel = k)
    expect_equal(length(result$y_smooth), length(result$x_grid))
    expect_equal(result$kernel, k)
  }
})

test_that("kernel_smooth works with auto-calculated bandwidth", {
  result <- kernel_smooth(test_x, test_y, bandwidth = NULL)
  expect_true(result$bandwidth > 0)
  expect_true(is.finite(result$bandwidth))
})

test_that("kernel_smooth handles NA values", {
  x_na <- c(test_x, NA)
  y_na <- c(test_y, NA)
  result <- kernel_smooth(x_na, y_na, bandwidth = 0.5)
  expect_true(all(is.finite(result$y_smooth)))
})

test_that("kernel_smooth input validation works", {
  expect_error(kernel_smooth(test_x, test_y[1:(length(test_y)-1)]))
  expect_error(kernel_smooth(c(1), c(1)))
})

test_that("kernel_smooth produces reasonable output", {
  # For a simple linear function, smoothing should be close to original
  x_simple <- 1:10
  y_simple <- 2 * x_simple + 1  # Linear: y = 2x + 1
  
  result <- kernel_smooth(x_simple, y_simple, bandwidth = 0.1, n_grid = 10)
  
  # Smoothed values should be in reasonable range
  expect_true(all(is.finite(result$y_smooth)))
  expect_true(min(result$y_smooth) >= min(y_simple) - 5)
  expect_true(max(result$y_smooth) <= max(y_simple) + 5)
})

test_that("kernel_smooth with custom x_grid works", {
  custom_grid <- seq(0, 10, length.out = 30)
  result <- kernel_smooth(test_x, test_y, bandwidth = 0.5, x_grid = custom_grid)
  
  expect_equal(result$x_grid, custom_grid)
  expect_equal(length(result$y_smooth), length(custom_grid))
})

# ============================================================================
# Tests for Helper Functions
# ============================================================================

test_that("create_evaluation_grid creates correct grid", {
  grid <- create_evaluation_grid(test_x, n_grid = 50)
  
  expect_equal(length(grid), 50)
  expect_true(min(grid) <= min(test_x))
  expect_true(max(grid) >= max(test_x))
})

test_that("validate_smoothing_input works correctly", {
  expect_error(validate_smoothing_input(test_x, test_y), NA)
  expect_error(validate_smoothing_input(test_x, test_y[1:(length(test_y)-1)]))
  expect_error(validate_smoothing_input(c(1), c(1)))
})

# ============================================================================
# Tests for Legacy Function
# ============================================================================

test_that("smoothing function works with data frame", {
  df <- data.frame(x = test_x, y = test_y)
  result <- smoothing(df)
  expect_true(is.list(result))
  expect_true("y_smooth" %in% names(result))
})

test_that("smoothing function works with matrix", {
  mat <- cbind(test_x, test_y)
  result <- smoothing(mat)
  expect_true(is.list(result))
  expect_true("y_smooth" %in% names(result))
})
