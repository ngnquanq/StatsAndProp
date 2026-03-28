# Unit tests for Mean_shift_clustering Algorithm

library(testthat)
source("../mean_shift_clustering_algorithm.R")
source("../mean_shift_clustering_helpers.R")

# Test data
set.seed(123)
test_data <- matrix(rnorm(100), ncol = 2)

test_that("Algorithm runs without errors", {
  expect_error(mean_shift_clustering(test_data), NA)
})

test_that("Algorithm returns correct structure", {
  result <- mean_shift_clustering(test_data)
  
  expect_true(is.list(result))
  # TODO: Add more specific checks
})

test_that("Input validation works", {
  expect_error(mean_shift_clustering("not a matrix"))
})
