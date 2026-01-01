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
