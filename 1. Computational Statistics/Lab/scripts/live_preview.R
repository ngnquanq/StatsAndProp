# Live Preview Script for R Markdown Files
# Usage: source("scripts/live_preview.R")
#        live_preview("algorithms/em/em_documentation.Rmd")

library(servr)
library(rmarkdown)

#' Start live preview for an R Markdown file
#'
#' @param rmd_file Path to the .Rmd file
#' @param port Port number for the web server (default: 4321)
#' @param daemon Run in background (default: FALSE)
#' @param open_browser Open browser automatically (default: TRUE)
live_preview <- function(rmd_file, port = 4321, daemon = FALSE, open_browser = TRUE) {
  
  # Check if file exists
  if (!file.exists(rmd_file)) {
    stop(sprintf("File not found: %s", rmd_file))
  }
  
  # Get directory and filename
  rmd_dir <- dirname(rmd_file)
  rmd_basename <- basename(rmd_file)
  html_basename <- sub("\\.Rmd$", ".html", rmd_basename)
  html_file <- file.path(rmd_dir, html_basename)
  
  cat("Rendering R Markdown file...\n")
  cat(sprintf("  Input:  %s\n", rmd_file))
  
  # Render the file
  render(rmd_file)
  
  cat(sprintf("  Output: %s\n", html_file))
  cat("\nStarting live preview server...\n")
  cat(sprintf("  URL: http://localhost:%d/%s\n", port, html_basename))
  cat("  Press Ctrl+C to stop\n\n")
  
  # Start the server
  servr::httw(
    dir = rmd_dir,
    pattern = html_basename,
    port = port,
    daemon = daemon,
    browser = open_browser
  )
}

#' Render and open HTML in browser (quick preview)
#'
#' @param rmd_file Path to the .Rmd file
quick_preview <- function(rmd_file) {
  if (!file.exists(rmd_file)) {
    stop(sprintf("File not found: %s", rmd_file))
  }
  
  cat("Rendering...\n")
  html_file <- render(rmd_file)
  
  cat(sprintf("Opening: %s\n", html_file))
  
  # Open in default browser
  if (Sys.info()["sysname"] == "Windows") {
    shell.exec(html_file)
  } else if (Sys.info()["sysname"] == "Darwin") {
    system(sprintf("open %s", shQuote(html_file)))
  } else {
    system(sprintf("xdg-open %s", shQuote(html_file)))
  }
}

cat("Live preview functions loaded.\n")
cat("Usage:\n")
cat("  live_preview('algorithms/em/em_documentation.Rmd')  # Start live server\n")
cat("  quick_preview('algorithms/em/em_documentation.Rmd')   # Quick render & open\n")

