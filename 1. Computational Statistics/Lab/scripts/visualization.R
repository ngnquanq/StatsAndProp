# Visualization utility functions for Computational Statistics Lab

library(ggplot2)

#' Create a scatter plot with clusters
#' 
#' @param data Data frame with x and y coordinates
#' @param clusters Cluster assignments
#' @param centers Optional cluster centers
#' @param title Plot title
#' @return ggplot object
plot_clusters <- function(data, clusters, centers = NULL, title = "Cluster Plot") {
  p <- ggplot(data, aes(x = x, y = y, color = factor(clusters))) +
    geom_point(size = 2, alpha = 0.6) +
    labs(title = title,
         x = "X",
         y = "Y",
         color = "Cluster") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  
  if (!is.null(centers)) {
    centers_df <- data.frame(x = centers[, 1], y = centers[, 2])
    p <- p + geom_point(data = centers_df, 
                       aes(x = x, y = y), 
                       color = "red", 
                       size = 4, 
                       shape = 17,
                       inherit.aes = FALSE)
  }
  
  return(p)
}

#' Plot convergence history
#' 
#' @param values Vector of values over iterations
#' @param title Plot title
#' @param xlabel X-axis label
#' @param ylabel Y-axis label
#' @return ggplot object
plot_convergence <- function(values, title = "Convergence", 
                             xlabel = "Iteration", ylabel = "Value") {
  df <- data.frame(iteration = 1:length(values), value = values)
  
  ggplot(df, aes(x = iteration, y = value)) +
    geom_line(color = "steelblue", size = 1) +
    geom_point(color = "steelblue", size = 2) +
    labs(title = title,
         x = xlabel,
         y = ylabel) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
}

#' Plot likelihood over iterations
#' 
#' @param likelihoods Vector of likelihood values
#' @return ggplot object
plot_likelihood <- function(likelihoods) {
  plot_convergence(likelihoods, 
                   title = "Log-Likelihood Convergence",
                   ylabel = "Log-Likelihood")
}

#' Create a heatmap of a matrix
#' 
#' @param matrix Matrix to plot
#' @param title Plot title
#' @return ggplot object
plot_heatmap <- function(matrix, title = "Heatmap") {
  library(reshape2)
  
  df <- melt(matrix)
  colnames(df) <- c("Row", "Column", "Value")
  
  ggplot(df, aes(x = Column, y = Row, fill = Value)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red") +
    labs(title = title) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(angle = 45, hjust = 1))
}

#' Plot EM algorithm results
#' 
#' @param data Numeric matrix with observations (rows) and features (columns)
#' @param result Result object from em_algorithm() function
#' @param title Plot title
#' @return ggplot object
plot_em_results <- function(data, result, title = "EM Algorithm Results") {
  # Convert data to data frame
  if (is.matrix(data)) {
    df <- data.frame(x = data[, 1], y = data[, 2])
  } else {
    df <- data
  }
  
  # Get cluster assignments from responsibilities
  clusters <- apply(result$responsibilities, 1, which.max)
  df$cluster <- factor(clusters)
  
  # Create plot with clusters
  p <- plot_clusters(df, clusters, centers = result$means, title = title)
  
  return(p)
}

#' Plot kernel smoothing results
#' 
#' @param x Original predictor values
#' @param y Original response values
#' @param result Result object from kernel_smooth() or spline_smooth() function
#' @param title Plot title
#' @param show_original Logical, whether to show original data points
#' @param true_function Optional function to plot true underlying function
#' @return ggplot object
plot_smoothing_results <- function(x, y, result, title = "Kernel Smoothing", 
                                    show_original = TRUE, true_function = NULL) {
  # Create data frame for original data
  df_original <- data.frame(x = x, y = y)
  
  # Handle both kernel and spline results
  if ("x_grid" %in% names(result)) {
    # Kernel smoothing result
    x_smooth <- result$x_grid
    y_smooth <- result$y_smooth
    subtitle_text <- sprintf("Bandwidth: %.3f, Kernel: %s", 
                            result$bandwidth, result$kernel)
  } else if ("x" %in% names(result)) {
    # Spline smoothing result
    x_smooth <- result$x
    y_smooth <- result$y_smooth
    subtitle_text <- sprintf("df: %.2f, spar: %.3f", 
                            result$df, result$spar)
  } else {
    stop("Result object must have either 'x_grid' (kernel) or 'x' (spline)")
  }
  
  # Create data frame for smoothed curve
  df_smooth <- data.frame(x = x_smooth, y = y_smooth)
  
  # Start plot
  p <- ggplot() +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  
  # Add true function if provided
  if (!is.null(true_function)) {
    x_true <- seq(min(x_smooth), max(x_smooth), length.out = 200)
    y_true <- true_function(x_true)
    df_true <- data.frame(x = x_true, y = y_true)
    
    p <- p + geom_line(data = df_true, aes(x = x, y = y), 
                   color = "green", linetype = "dashed", linewidth = 1, 
                   alpha = 0.7) +
      labs(color = "Type")
  }
  
  # Add original data points
  if (show_original) {
    p <- p + geom_point(data = df_original, aes(x = x, y = y), 
                       color = "steelblue", alpha = 0.6, size = 2)
  }
  
  # Add smoothed curve
  p <- p + geom_line(data = df_smooth, aes(x = x, y = y), 
                    color = "red", linewidth = 1.2) +
    labs(title = title,
         x = "X",
         y = "Y",
         subtitle = subtitle_text)
  
  return(p)
}

#' Plot comparison between kernel and spline smoothing
#' 
#' @param x Original predictor values
#' @param y Original response values
#' @param result_kernel Result object from kernel_smooth() function
#' @param result_spline Result object from spline_smooth() function
#' @param title Plot title
#' @param show_original Logical, whether to show original data points
#' @param true_function Optional function to plot true underlying function
#' @return ggplot object
plot_smoothing_comparison <- function(x, y, result_kernel, result_spline, 
                                      title = "Smoothing Comparison: Kernel vs Spline",
                                      show_original = TRUE, true_function = NULL) {
  # Create data frame for original data
  df_original <- data.frame(x = x, y = y)
  
  # Create data frame for kernel smoothed curve
  df_kernel <- data.frame(
    x = result_kernel$x_grid,
    y = result_kernel$y_smooth,
    method = "Kernel"
  )
  
  # Create data frame for spline smoothed curve
  df_spline <- data.frame(
    x = result_spline$x,
    y = result_spline$y_smooth,
    method = "Spline"
  )
  
  # Combine smoothed curves
  df_smooth <- rbind(df_kernel, df_spline)
  
  # Start plot
  p <- ggplot() +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))
  
  # Add true function if provided
  if (!is.null(true_function)) {
    x_range <- range(c(result_kernel$x_grid, result_spline$x))
    x_true <- seq(x_range[1], x_range[2], length.out = 200)
    y_true <- true_function(x_true)
    df_true <- data.frame(x = x_true, y = y_true)
    
    p <- p + geom_line(data = df_true, aes(x = x, y = y), 
                   color = "green", linetype = "dashed", linewidth = 1, 
                   alpha = 0.7)
  }
  
  # Add original data points
  if (show_original) {
    p <- p + geom_point(data = df_original, aes(x = x, y = y), 
                       color = "gray", alpha = 0.5, size = 1.5)
  }
  
  # Add smoothed curves with different colors/linetypes
  p <- p + 
    geom_line(data = df_smooth, aes(x = x, y = y, color = method, linetype = method), 
              linewidth = 1.2) +
    scale_color_manual(values = c("Kernel" = "red", "Spline" = "blue")) +
    scale_linetype_manual(values = c("Kernel" = "solid", "Spline" = "solid")) +
    labs(title = title,
         x = "X",
         y = "Y",
         color = "Method",
         linetype = "Method",
         subtitle = sprintf("Kernel: h=%.3f, %s | Spline: df=%.2f, spar=%.3f",
                           result_kernel$bandwidth, result_kernel$kernel,
                           result_spline$df, result_spline$spar))
  
  return(p)
}
