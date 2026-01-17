# Helper functions for Mean Shift Clustering Algorithm

#' Gaussian Kernel
#'
#' @param u Input vector (normalized distance)
#' @return Kernel value
#'
#' @examples
#' gaussian_kernel(0.5)
gaussian_kernel <- function(u) {
  exp(-u^2 / 2)
}

#' Flat (Uniform) Kernel
#'
#' @param u Input vector (normalized distance)
#' @return Kernel value
#'
#' @examples
#' flat_kernel(0.5)
flat_kernel <- function(u) {
  ifelse(u <= 1, 1, 0)
}

#' Epanechnikov Kernel
#'
#' @param u Input vector (normalized distance)
#' @return Kernel value
#'
#' @examples
#' epanechnikov_kernel(0.5)
epanechnikov_kernel <- function(u) {
  ifelse(u <= 1, 1 - u^2, 0)
}

#' Get kernel function by name
#'
#' @param kernel_name Name of kernel ("gaussian", "flat", "epanechnikov")
#' @return Kernel function
get_kernel <- function(kernel_name) {
  switch(
    tolower(kernel_name),
    "gaussian" = gaussian_kernel,
    "flat" = flat_kernel,
    "uniform" = flat_kernel,
    "epanechnikov" = epanechnikov_kernel,
    stop("Unknown kernel. Choose from: gaussian, flat, epanechnikov")
  )
}

#' Compute Euclidean distance
#'
#' @param x Point 1
#' @param y Point 2
#' @return Euclidean distance
euclidean_distance <- function(x, y) {
  sqrt(sum((x - y)^2))
}

#' Scott's Rule for bandwidth selection
#'
#' @param data Data matrix (n x d)
#' @return Optimal bandwidth
scotts_rule <- function(data) {
  n <- nrow(data)
  d <- ncol(data)
  sigma <- apply(data, 2, sd)
  h <- mean(sigma) * n^(-1/(d + 4))
  return(h)
}

#' Silverman's Rule for bandwidth selection
#'
#' @param data Data matrix (n x d)
#' @return Optimal bandwidth
silvermans_rule <- function(data) {
  n <- nrow(data)
  sigma <- apply(data, 2, sd)
  h <- 1.06 * mean(sigma) * n^(-1/5)
  return(h)
}
