Kernels <- function() {
  structure(
    list(),
    class = "Kernels"
  )
}

# kernel gauss
gaussian.Kernels <- function(x) {
  kernel <- exp(-x^2 / 2) / sqrt(2 * pi)
  return(kernel)
}

# epanechnikov kernel
epanechnikov.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, 0.75 * (1 - (x^2)), 0)
  return(kernel)
}

# triangle kernel
triangle.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, 1 - abs(x), 0)
  return(kernel)
}

# quadric kernel
quartic.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, (15 / 16) * (1 - x^2)^2, 0)
  return(kernel)
}

# triweight kernel
triweight.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, (35 / 32) * (1 - x^2)^3, 0)
  return(kernel)
}

# tricube kernel
tricube.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, (70 / 81) * (1 - abs(x)^3)^3, 0)
  return(kernel)
}

# cosine kernel
cosine.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, (pi / 4) * cos(pi * x / 2), 0)
  return(kernel)
}

# uniform kernel
uniform.Kernels <- function(x) {
  kernel <- ifelse(abs(x) <= 1, 0.5, 0)
  return(kernel)
}

kernel.Kernels <- function(kernel = "gaussian") {
  kernel_methods <- list(
    "gaussian" = gaussian.Kernels,
    "epanechnikov" = epanechnikov.Kernels,
    "triangle" = triangle.Kernels,
    "quartic" = quartic.Kernels,
    "triweight" = triweight.Kernels,
    "tricube" = tricube.Kernels,
    "cosine" = cosine.Kernels,
    "uniform" = uniform.Kernels
  )

  if (kernel %in% names(kernel_methods)) {
    return(kernel_methods[[kernel]])
  } else {
    stop("Invalid kernel name")
  }
}

process.Kernels <- function(x, kernel) {
  kernel_func <- kernel.Kernels(kernel)
  return(kernel_func(x))
}



# Process function to compute KDE with data and kernel name
process.KDE <- function(data, y, h, kernel = "gaussian") {
  if (length(y) > 1) {
    return(kde_vector_func(data = data, y = y, h = h, kernel = kernel))
  }

  return(kde(data = data, y = y, h = h, kernel = kernel))
}
