#!/bin/bash
# Helper script to create a new algorithm folder structure
# Usage: ./scripts/create_algorithm.sh <algorithm_name>
# Example: ./scripts/create_algorithm.sh linear_regression

if [ $# -eq 0 ]; then
    echo "Error: Algorithm name required"
    echo "Usage: $0 <algorithm_name>"
    echo "Example: $0 linear_regression"
    exit 1
fi

ALGORITHM_NAME="$1"
ALGORITHM_DIR="Lab/algorithms/$ALGORITHM_NAME"

# Check if algorithm already exists
if [ -d "$ALGORITHM_DIR" ]; then
    echo "Error: Algorithm directory already exists: $ALGORITHM_DIR"
    exit 1
fi

# Navigate to Lab directory
cd "$(dirname "$0")/.."

echo "Creating algorithm structure for: $ALGORITHM_NAME"
echo "================================================"

# Create directory structure
mkdir -p "$ALGORITHM_DIR/tests"
mkdir -p "$ALGORITHM_DIR/data"
touch "$ALGORITHM_DIR/data/.gitkeep"

# Copy template
if [ -f "templates/algorithm_template.Rmd" ]; then
    cp "templates/algorithm_template.Rmd" "$ALGORITHM_DIR/${ALGORITHM_NAME}_documentation.Rmd"
    echo "✓ Created documentation template"
else
    echo "⚠ Warning: Template not found, skipping documentation file"
fi

# Create implementation files
cat > "$ALGORITHM_DIR/${ALGORITHM_NAME}_algorithm.R" << EOF
# ${ALGORITHM_NAME^} Algorithm - Main Implementation

#' Brief description of what the algorithm does
#'
#' @param data Input data
#' @return List containing results
#'
#' @examples
#' data <- matrix(rnorm(100), ncol = 2)
#' result <- ${ALGORITHM_NAME}(data)
${ALGORITHM_NAME} <- function(data) {
  
  # Input validation
  if (!is.matrix(data) && !is.data.frame(data)) {
    stop("data must be a matrix or data frame")
  }
  
  # TODO: Implement your algorithm here
  
  # Return results
  list(
    result = NULL,
    converged = FALSE
  )
}
EOF
echo "✓ Created main algorithm file"

cat > "$ALGORITHM_DIR/${ALGORITHM_NAME}_helpers.R" << EOF
# Helper functions for ${ALGORITHM_NAME^} Algorithm

#' Helper function
#'
#' @param x Input
#' @return Output
helper_function <- function(x) {
  # TODO: Implement helper function
  return(x)
}
EOF
echo "✓ Created helper functions file"

cat > "$ALGORITHM_DIR/${ALGORITHM_NAME}_example.R" << EOF
# Example usage of ${ALGORITHM_NAME^} Algorithm

# Load required libraries
library(ggplot2)
source("${ALGORITHM_NAME}_algorithm.R")
source("${ALGORITHM_NAME}_helpers.R")
source("../../scripts/visualization.R")

# Generate or load sample data
set.seed(123)
data <- matrix(rnorm(200), ncol = 2)

# Run algorithm
result <- ${ALGORITHM_NAME}(data)

# TODO: Add visualization
# plot_${ALGORITHM_NAME}_results(data, result)
EOF
echo "✓ Created example file"

cat > "$ALGORITHM_DIR/tests/test_${ALGORITHM_NAME}.R" << EOF
# Unit tests for ${ALGORITHM_NAME^} Algorithm

library(testthat)
source("../${ALGORITHM_NAME}_algorithm.R")
source("../${ALGORITHM_NAME}_helpers.R")

# Test data
set.seed(123)
test_data <- matrix(rnorm(100), ncol = 2)

test_that("Algorithm runs without errors", {
  expect_error(${ALGORITHM_NAME}(test_data), NA)
})

test_that("Algorithm returns correct structure", {
  result <- ${ALGORITHM_NAME}(test_data)
  
  expect_true(is.list(result))
  # TODO: Add more specific checks
})

test_that("Input validation works", {
  expect_error(${ALGORITHM_NAME}("not a matrix"))
})
EOF
echo "✓ Created test file"

# Update documentation file if template was copied
if [ -f "$ALGORITHM_DIR/${ALGORITHM_NAME}_documentation.Rmd" ]; then
    # Update title in YAML header
    sed -i "s/Algorithm Name/${ALGORITHM_NAME^}/g" "$ALGORITHM_DIR/${ALGORITHM_NAME}_documentation.Rmd"
    # Update source paths in setup chunk
    sed -i "s/algorithm_name/${ALGORITHM_NAME}/g" "$ALGORITHM_DIR/${ALGORITHM_NAME}_documentation.Rmd"
    echo "✓ Updated documentation template"
fi

echo ""
echo "================================================"
echo "Algorithm structure created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit ${ALGORITHM_NAME}_algorithm.R to implement your algorithm"
echo "2. Edit ${ALGORITHM_NAME}_helpers.R to add helper functions"
echo "3. Edit ${ALGORITHM_NAME}_documentation.Rmd to write documentation"
echo "4. Add tests in tests/test_${ALGORITHM_NAME}.R"
echo "5. Update README.md with your new algorithm"
echo ""
echo "For detailed instructions, see HOW_TO_ADD_ALGORITHM.md"
echo ""

