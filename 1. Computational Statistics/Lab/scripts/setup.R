# Setup script for Computational Statistics Lab
# This script installs and loads required R packages

# List of required packages
required_packages <- c(
  "testthat",      # Testing framework
  "ggplot2",       # Data visualization
  "dplyr",         # Data manipulation
  "knitr",         # R Markdown
  "rmarkdown",     # R Markdown rendering
  "MASS",          # Statistical functions
  "Matrix",        # Matrix operations
  "servr"          # Live preview server (optional but recommended)
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  } else {
    cat("All required packages are already installed.\n")
  }
}

# Install missing packages
install_if_missing(required_packages)

# Load packages
cat("Loading packages...\n")
for(pkg in required_packages) {
  library(pkg, character.only = TRUE)
  cat("  ✓", pkg, "\n")
}

cat("\nSetup complete! All required packages are installed and loaded.\n")

