# Script to render R Markdown documentation files
# Usage: source("scripts/render_docs.R")

library(rmarkdown)

#' Render a specific algorithm documentation
#'
#' @param algorithm_name Name of the algorithm (e.g., "em", "kmeans")
#' @param output_format Output format: "html" (default), "pdf", or "word"
render_algorithm_doc <- function(algorithm_name, output_format = "html") {
  
  # Construct file path
  rmd_file <- file.path("algorithms", algorithm_name, 
                        paste0(algorithm_name, "_documentation.Rmd"))
  
  # Check if file exists
  if (!file.exists(rmd_file)) {
    stop(sprintf("File not found: %s", rmd_file))
  }
  
  # Set output format
  format_map <- list(
    html = "html_document",
    pdf = "pdf_document",
    word = "word_document"
  )
  
  if (!output_format %in% names(format_map)) {
    stop("output_format must be 'html', 'pdf', or 'word'")
  }
  
  output_format_obj <- format_map[[output_format]]
  
  cat(sprintf("Rendering %s...\n", rmd_file))
  
  # Render the file
  render(rmd_file, output_format = output_format_obj)
  
  cat(sprintf("✓ Successfully rendered %s\n", algorithm_name))
}

#' Render all algorithm documentation files
#'
#' @param output_format Output format: "html" (default), "pdf", or "word"
render_all_docs <- function(output_format = "html") {
  
  # Find all documentation files
  algorithm_dirs <- list.dirs("algorithms", recursive = FALSE)
  
  rmd_files <- character()
  for (dir in algorithm_dirs) {
    algorithm_name <- basename(dir)
    rmd_file <- file.path(dir, paste0(algorithm_name, "_documentation.Rmd"))
    if (file.exists(rmd_file)) {
      rmd_files <- c(rmd_files, rmd_file)
    }
  }
  
  if (length(rmd_files) == 0) {
    cat("No documentation files found.\n")
    return(invisible(NULL))
  }
  
  cat(sprintf("Found %d documentation file(s).\n", length(rmd_files)))
  
  # Set output format
  format_map <- list(
    html = "html_document",
    pdf = "pdf_document",
    word = "word_document"
  )
  
  output_format_obj <- format_map[[output_format]]
  
  # Render each file
  for (rmd_file in rmd_files) {
    algorithm_name <- basename(dirname(rmd_file))
    cat(sprintf("\nRendering %s...\n", algorithm_name))
    tryCatch({
      render(rmd_file, output_format = output_format_obj)
      cat(sprintf("✓ %s rendered successfully\n", algorithm_name))
    }, error = function(e) {
      cat(sprintf("✗ Error rendering %s: %s\n", algorithm_name, e$message))
    })
  }
  
  cat("\nDone!\n")
}

# Example usage:
# source("scripts/render_docs.R")
# render_algorithm_doc("em")                    # Render EM documentation as HTML
# render_algorithm_doc("em", output_format = "pdf")  # Render as PDF
# render_all_docs()                             # Render all documentation files

cat("Render documentation script loaded.\n")
cat("Usage:\n")
cat("  render_algorithm_doc('em')              # Render specific algorithm\n")
cat("  render_all_docs()                       # Render all algorithms\n")

