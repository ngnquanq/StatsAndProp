# Unit tests for EM Algorithm

library(testthat)
source("../em_algorithm.R")
source("../em_helpers.R")

# Test data
set.seed(123)
test_data <- matrix(rnorm(100), ncol = 2)

test_that("EM algorithm runs without errors", {
  expect_error(em_algorithm(test_data, k = 2, max_iter = 10), NA)
})

test_that("EM algorithm returns correct structure", {
  result <- em_algorithm(test_data, k = 2, max_iter = 10)
  
  expect_true(is.list(result))
  expect_true("means" %in% names(result))
  expect_true("covariances" %in% names(result))
  expect_true("weights" %in% names(result))
  expect_true("log_likelihood" %in% names(result))
  expect_true("converged" %in% names(result))
})

test_that("EM algorithm returns correct dimensions", {
  result <- em_algorithm(test_data, k = 3, max_iter = 10)
  
  expect_equal(nrow(result$means), 3)
  expect_equal(ncol(result$means), 2)
  expect_equal(length(result$weights), 3)
  expect_equal(dim(result$covariances), c(2, 2, 3))
})

test_that("Weights sum to 1", {
  result <- em_algorithm(test_data, k = 2, max_iter = 10)
  expect_equal(sum(result$weights), 1, tolerance = 1e-6)
})

test_that("Responsibilities sum to 1 for each observation", {
  result <- em_algorithm(test_data, k = 2, max_iter = 10)
  row_sums <- rowSums(result$responsibilities)
  expect_equal(row_sums, rep(1, nrow(test_data)), tolerance = 1e-6)
})

test_that("Log-likelihood increases (or stays same)", {
  result <- em_algorithm(test_data, k = 2, max_iter = 20)
  
  if (length(result$log_likelihood_history) > 1) {
    # Log-likelihood should be non-decreasing
    diffs <- diff(result$log_likelihood_history)
    expect_true(all(diffs >= -1e-6))  # Allow small numerical errors
  }
})

test_that("Input validation works", {
  expect_error(em_algorithm(test_data, k = 0))
  expect_error(em_algorithm(test_data, k = nrow(test_data) + 1))
  expect_error(em_algorithm("not a matrix", k = 2))
})

