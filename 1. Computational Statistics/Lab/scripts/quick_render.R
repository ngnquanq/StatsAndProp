# Quick render script for faster iteration
# Usage: source("scripts/quick_render.R")
#        quick_render("algorithms/em/em_documentation.Rmd")

library(rmarkdown)

#' Quick render with optimized settings for development
#'
#' @param rmd_file Path to the .Rmd file
#' @param open_browser Open HTML in browser after rendering
quick_render <- function(rmd_file, open_browser = TRUE) {
  
  if (!file.exists(rmd_file)) {
    stop(sprintf("File not found: %s", rmd_file))
  }
  
  cat("Quick rendering (optimized for speed)...\n")
  cat(sprintf("  File: %s\n", rmd_file))
  
  # Render with faster settings
  html_file <- render(
    rmd_file,
    quiet = TRUE,                    # Less verbose output
    envir = new.env(),              # Clean environment
    output_options = list(
      self_contained = FALSE       # Faster, but requires CSS file
    )
  )
  
  cat(sprintf("  Output: %s\n", html_file))
  
  if (open_browser) {
    cat("Opening in browser...\n")
    if (Sys.info()["sysname"] == "Windows") {
      shell.exec(html_file)
    } else if (Sys.info()["sysname"] == "Darwin") {
      system(sprintf("open %s", shQuote(html_file)))
    } else {
      system(sprintf("xdg-open %s", shQuote(html_file)))
    }
  }
  
  return(html_file)
}

cat("Quick render function loaded.\n")
cat("Usage: quick_render('algorithms/em/em_documentation.Rmd')\n")

