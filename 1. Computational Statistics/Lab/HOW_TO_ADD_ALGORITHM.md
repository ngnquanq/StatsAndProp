# How to Add a New Algorithm

This guide walks you through adding a new algorithm to the repository following the established structure and best practices.

## Step-by-Step Guide

### Step 1: Create the Algorithm Folder

Create a new folder under `algorithms/` with your algorithm name (use lowercase, underscores for spaces):

```bash
mkdir -p algorithms/your_algorithm_name/{tests,data}
```

**Example:**
```bash
mkdir -p algorithms/linear_regression/{tests,data}
```

### Step 2: Copy the Template

Copy the algorithm template to create your documentation file:

```bash
cp templates/algorithm_template.Rmd algorithms/your_algorithm_name/your_algorithm_name_documentation.Rmd
```

**Example:**
```bash
cp templates/algorithm_template.Rmd algorithms/linear_regression/linear_regression_documentation.Rmd
```

### Step 3: Create Implementation Files

Create the following files in your algorithm folder:

#### a) Main Algorithm File: `your_algorithm_name_algorithm.R`

```r
# Your Algorithm Name - Main Implementation

#' Brief description of what the algorithm does
#'
#' @param data Input data (describe format)
#' @param param1 Parameter description
#' @param param2 Parameter description
#' @return List containing results
#'
#' @examples
#' data <- matrix(rnorm(100), ncol = 2)
#' result <- your_algorithm_name(data, param1 = value1)
your_algorithm_name <- function(data, param1, param2 = default_value) {
  
  # Input validation
  if (!is.matrix(data) && !is.data.frame(data)) {
    stop("data must be a matrix or data frame")
  }
  
  # Your algorithm implementation here
  
  # Return results
  list(
    result1 = ...,
    result2 = ...,
    converged = TRUE
  )
}
```

#### b) Helper Functions: `your_algorithm_name_helpers.R`

```r
# Helper functions for Your Algorithm Name

#' Helper function 1
#'
#' @param x Input
#' @return Output
helper_function_1 <- function(x) {
  # Implementation
}

#' Helper function 2
#'
#' @param x Input
#' @return Output
helper_function_2 <- function(x) {
  # Implementation
}
```

#### c) Example Script: `your_algorithm_name_example.R`

```r
# Example usage of Your Algorithm Name

# Load required libraries
library(ggplot2)
source("your_algorithm_name_algorithm.R")
source("your_algorithm_name_helpers.R")
source("../../scripts/visualization.R")

# Generate or load sample data
data <- matrix(rnorm(200), ncol = 2)

# Run algorithm
result <- your_algorithm_name(data, param1 = value1, param2 = value2)

# Visualize results
# plot_your_algorithm_results(data, result)
```

### Step 4: Update the Documentation R Markdown File

Edit `your_algorithm_name_documentation.Rmd`:

1. **Update YAML header:**
```yaml
---
title: "Your Algorithm Name - Documentation"
author: "Your Name"
date: "`r Sys.Date()`"
output: 
  html_document:
    css: ../../templates/styles.css
    toc: true
    toc_float: true
    number_sections: true
---
```

2. **Update setup chunk** to source your files:
```r
```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  fig.width = 10,
  fig.height = 6,
  fig.align = "center"
)

# Load required libraries
library(ggplot2)

# Source utility functions
source("../../scripts/visualization.R")
source("your_algorithm_name_algorithm.R")
source("your_algorithm_name_helpers.R")
```
```

3. **Fill in the content sections:**
   - Algorithm Overview
   - Mathematical Foundation
   - Implementation details
   - Examples
   - Performance Analysis
   - References

### Step 5: Create Unit Tests

Create `tests/test_your_algorithm_name.R`:

```r
# Unit tests for Your Algorithm Name

library(testthat)
source("../your_algorithm_name_algorithm.R")
source("../your_algorithm_name_helpers.R")

# Test data
set.seed(123)
test_data <- matrix(rnorm(100), ncol = 2)

test_that("Algorithm runs without errors", {
  expect_error(your_algorithm_name(test_data, param1 = value1), NA)
})

test_that("Algorithm returns correct structure", {
  result <- your_algorithm_name(test_data, param1 = value1)
  
  expect_true(is.list(result))
  expect_true("result1" %in% names(result))
  # Add more checks
})

test_that("Input validation works", {
  expect_error(your_algorithm_name("not a matrix", param1 = value1))
})
```

### Step 6: Add Visualization Function (if needed)

If your algorithm needs a custom plotting function, add it to `scripts/visualization.R`:

```r
#' Plot Your Algorithm results
#' 
#' @param data Input data
#' @param result Result object from your_algorithm_name()
#' @param title Plot title
#' @return ggplot object
plot_your_algorithm_results <- function(data, result, title = "Your Algorithm Results") {
  # Your plotting code here
  # Use ggplot2 for consistency
}
```

### Step 7: Update Main README

Add your algorithm to the list in `README.md`:

```markdown
### Implemented Algorithms

- **EM Algorithm** (`algorithms/em/`) - Expectation-Maximization algorithm
- **K-means** (`algorithms/kmeans/`) - K-means clustering algorithm
- **Your Algorithm Name** (`algorithms/your_algorithm_name/`) - Brief description
```

### Step 8: Test Your Implementation

1. **Test the algorithm:**
```r
source("algorithms/your_algorithm_name/your_algorithm_name_example.R")
```

2. **Run unit tests:**
```r
library(testthat)
test_dir("algorithms/your_algorithm_name/tests")
```

3. **Render documentation:**
```bash
./render_example.sh algorithms/your_algorithm_name/your_algorithm_name_documentation.Rmd
```

Or in R:
```r
library(rmarkdown)
render("algorithms/your_algorithm_name/your_algorithm_name_documentation.Rmd")
```

## Quick Checklist

- [ ] Created algorithm folder with `tests/` and `data/` subfolders
- [ ] Created `your_algorithm_name_documentation.Rmd` from template
- [ ] Created `your_algorithm_name_algorithm.R` with main function
- [ ] Created `your_algorithm_name_helpers.R` with helper functions
- [ ] Created `your_algorithm_name_example.R` with usage examples
- [ ] Created `tests/test_your_algorithm_name.R` with unit tests
- [ ] Updated documentation R Markdown file
- [ ] Updated `README.md` with new algorithm
- [ ] Added custom visualization function (if needed)
- [ ] Tested the algorithm implementation
- [ ] Rendered documentation successfully
- [ ] All tests pass

## File Structure Summary

After adding your algorithm, the structure should look like:

```
algorithms/your_algorithm_name/
├── your_algorithm_name_documentation.Rmd  # R Markdown documentation
├── your_algorithm_name_algorithm.R         # Main implementation
├── your_algorithm_name_helpers.R           # Helper functions
├── your_algorithm_name_example.R           # Usage examples
├── tests/
│   └── test_your_algorithm_name.R         # Unit tests
└── data/                                    # Sample data (optional)
    └── .gitkeep
```

## Tips

1. **Follow Naming Conventions:**
   - Use lowercase with underscores: `linear_regression`, `gradient_descent`
   - Keep names descriptive but concise

2. **Documentation:**
   - Include mathematical formulations
   - Provide clear examples
   - Add references to papers/books

3. **Code Style:**
   - Follow R style guide
   - Add comments for complex logic
   - Use meaningful variable names

4. **Testing:**
   - Test edge cases
   - Test input validation
   - Test convergence (if iterative)

5. **Visualization:**
   - Use consistent styling (via `visualization.R`)
   - Make plots informative and clear
   - Include convergence plots for iterative algorithms

## Example: Adding "Linear Regression"

Here's a quick example of what files you'd create:

```bash
# 1. Create folder
mkdir -p algorithms/linear_regression/{tests,data}

# 2. Copy template
cp templates/algorithm_template.Rmd algorithms/linear_regression/linear_regression_documentation.Rmd

# 3. Create implementation files
touch algorithms/linear_regression/linear_regression_algorithm.R
touch algorithms/linear_regression/linear_regression_helpers.R
touch algorithms/linear_regression/linear_regression_example.R
touch algorithms/linear_regression/tests/test_linear_regression.R

# 4. Edit files with your implementation
# 5. Update documentation
# 6. Test and render
```

## Need Help?

- Check the EM algorithm implementation as a reference: `algorithms/em/`
- Look at the template: `templates/algorithm_template.Rmd`
- Review the visualization functions: `scripts/visualization.R`

Happy coding! 🚀

