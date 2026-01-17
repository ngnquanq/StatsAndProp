# Mean Shift Clustering Algorithm - Main Implementation

source("mean_shift_clustering_helpers.R")

#' Mean Shift Clustering
#'
#' Performs Mean Shift clustering on the input data. The algorithm finds modes
#' (peaks) of the data density and assigns each point to its nearest mode.
#'
#' @param data Input data matrix (n x d)
#' @param bandwidth Bandwidth parameter h. If NULL, uses Scott's rule
#' @param kernel Kernel function name: "gaussian", "flat", or "epanechnikov"
#' @param max_iter Maximum number of iterations per point (default: 100)
#' @param tol Convergence tolerance (default: 1e-4)
#' @param mode_tolerance Distance threshold to merge nearby modes (default: bandwidth/2)
#'
#' @return List containing:
#'   - cluster_labels: Vector of cluster assignments for each point
#'   - modes: Matrix of converged modes (cluster centers)
#'   - n_clusters: Number of clusters found
#'   - converged_points: Matrix of converged points for each data point
#'   - iterations: Vector of iterations needed for each point
#'   - computation_time: Time taken in seconds
#'
#' @examples
#' data <- matrix(rnorm(200), ncol = 2)
#' result <- mean_shift_clustering(data, bandwidth = 0.5)
#' plot(data, col = result$cluster_labels)
mean_shift_clustering <- function(data,
                                   bandwidth = NULL,
                                   kernel = "gaussian",
                                   max_iter = 100,
                                   tol = 1e-4,
                                   mode_tolerance = NULL) {

  # Input validation
  if (!is.matrix(data) && !is.data.frame(data)) {
    stop("data must be a matrix or data frame")
  }

  data <- as.matrix(data)
  n <- nrow(data)
  d <- ncol(data)

  # Set bandwidth if not provided
  if (is.null(bandwidth)) {
    bandwidth <- scotts_rule(data)
    message(sprintf("Using Scott's rule: bandwidth = %.4f", bandwidth))
  }

  # Set mode tolerance if not provided
  if (is.null(mode_tolerance)) {
    mode_tolerance <- bandwidth / 2
  }

  # Get kernel function
  kernel_func <- get_kernel(kernel)

  # Start timing
  start_time <- Sys.time()

  # Initialize storage
  converged_points <- matrix(0, nrow = n, ncol = d)
  iterations_per_point <- numeric(n)

  # For each data point, perform mean shift until convergence
  for (i in 1:n) {
    # Initialize at data point
    y <- data[i, ]

    iter <- 0
    converged <- FALSE

    while (!converged && iter < max_iter) {
      iter <- iter + 1
      y_old <- y

      # Compute distances to all data points
      distances <- apply(data, 1, function(x) euclidean_distance(x, y))

      # Normalize distances by bandwidth
      normalized_dist <- distances / bandwidth

      # Compute kernel weights
      weights <- kernel_func(normalized_dist)

      # Avoid division by zero
      if (sum(weights) == 0) {
        break
      }

      # Compute mean shift vector
      # m(y) = [sum(x_i * g(||x-y||/h)) / sum(g(||x-y||/h))] - y
      weighted_sum <- colSums(data * weights) / sum(weights)

      # Update position: y_new = y_old + m(y_old)
      y <- weighted_sum

      # Check convergence
      shift_distance <- euclidean_distance(y, y_old)
      if (shift_distance < tol) {
        converged <- TRUE
      }
    }

    converged_points[i, ] <- y
    iterations_per_point[i] <- iter
  }

  # Merge nearby modes
  modes <- converged_points[1, , drop = FALSE]
  cluster_labels <- rep(1, n)

  for (i in 2:n) {
    current_point <- converged_points[i, ]

    # Find closest existing mode
    distances_to_modes <- apply(modes, 1, function(m) euclidean_distance(m, current_point))
    min_dist <- min(distances_to_modes)
    closest_mode <- which.min(distances_to_modes)

    # If close enough to existing mode, assign to that cluster
    if (min_dist <= mode_tolerance) {
      cluster_labels[i] <- closest_mode
    } else {
      # Create new cluster
      modes <- rbind(modes, current_point)
      cluster_labels[i] <- nrow(modes)
    }
  }

  # End timing
  end_time <- Sys.time()
  computation_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Return results
  list(
    cluster_labels = cluster_labels,
    modes = modes,
    n_clusters = nrow(modes),
    converged_points = converged_points,
    iterations = iterations_per_point,
    mean_iterations = mean(iterations_per_point),
    computation_time = computation_time,
    bandwidth = bandwidth,
    kernel = kernel
  )
}

#' Evaluate clustering quality using Silhouette Score
#'
#' @param data Data matrix
#' @param labels Cluster labels
#' @return Average silhouette score
compute_silhouette <- function(data, labels) {
  if (!requireNamespace("cluster", quietly = TRUE)) {
    stop("Package 'cluster' is required for silhouette score")
  }

  if (length(unique(labels)) == 1) {
    return(0)  # Only one cluster, silhouette is undefined
  }

  sil <- cluster::silhouette(labels, dist(data))
  return(mean(sil[, 3]))
}

#' Evaluate clustering quality using Adjusted Rand Index
#'
#' @param true_labels True cluster labels
#' @param pred_labels Predicted cluster labels
#' @return Adjusted Rand Index
compute_ari <- function(true_labels, pred_labels) {
  if (!requireNamespace("mclust", quietly = TRUE)) {
    stop("Package 'mclust' is required for ARI")
  }

  mclust::adjustedRandIndex(true_labels, pred_labels)
}
