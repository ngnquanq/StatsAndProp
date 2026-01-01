# Unit tests for Mcmc Algorithm

library(testthat)
source("../mcmc_algorithm.R")
source("../mcmc_helpers.R")

# Test data
set.seed(123)
test_data <- matrix(rnorm(100), ncol = 2)

test_that("Algorithm runs without errors", {
  expect_error(mcmc(test_data), NA)
})

test_that("Algorithm returns correct structure", {
  result <- mcmc(test_data)
  
  expect_true(is.list(result))
  # TODO: Add more specific checks
})

test_that("Input validation works", {
  expect_error(mcmc("not a matrix"))
})
