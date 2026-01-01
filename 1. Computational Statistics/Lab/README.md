# Computational Statistics Lab

This repository contains implementations of various computational statistics algorithms as part of the Computational Statistics course.

## Project Structure

```
Lab/
├── algorithms/          # Algorithm-specific implementations
│   ├── em/             # Expectation-Maximization
│   ├── kmeans/         # K-means clustering
│   ├── gradient_descent/  # Gradient descent
│   └── newton_raphson/    # Newton-Raphson method
├── R/                  # Reusable R functions
├── data/               # Datasets (raw and processed)
├── tests/              # Global test suite
├── docs/               # Additional documentation
├── scripts/         # Utility scripts
├── templates/        # Template files (CSS, R Markdown)
└── notebooks/        # R Markdown notebooks
```

## Algorithms

Each algorithm is contained in its own folder under `algorithms/` with:
- **R Markdown documentation** (`.Rmd`) - Algorithm theory, implementation, and examples
- **Implementation files** (`.R`) - Core algorithm code
- **Helper functions** - Supporting utilities
- **Examples** - Usage demonstrations
- **Tests** - Unit tests using testthat

### Implemented Algorithms

- **EM Algorithm** (`algorithms/em/`) - Expectation-Maximization algorithm
- **K-means** (`algorithms/kmeans/`) - K-means clustering algorithm
- **Gradient Descent** (`algorithms/gradient_descent/`) - Gradient descent optimization
- **Newton-Raphson** (`algorithms/newton_raphson/`) - Newton-Raphson method

## Getting Started

### Prerequisites

- R (>= 4.0.0)
- RStudio (recommended)
- Required R packages (see `scripts/setup.R`)

### Setup

1. Clone or download this repository
2. Open `Lab.Rproj` in RStudio
3. Run the setup script to install dependencies:

```r
source("scripts/setup.R")
```

### Using an Algorithm

Each algorithm folder contains:
- A documentation R Markdown file (e.g., `em_documentation.Rmd`)
- Implementation files (`.R`)
- Example scripts

To use an algorithm:

```r
# Source the algorithm
source("algorithms/em/em_algorithm.R")

# Use the function
result <- em_algorithm(data, k = 3, max_iter = 100)
```

Or view the full documentation by opening and knitting the R Markdown file in RStudio.

### Rendering Documentation

To render (knit) the R Markdown documentation files:

**In RStudio:**
1. Open the `.Rmd` file (e.g., `algorithms/em/em_documentation.Rmd`)
2. Click the "Knit" button (or press `Ctrl+Shift+K` / `Cmd+Shift+K`)

**From R Console:**
```r
library(rmarkdown)
render("algorithms/em/em_documentation.Rmd")
```

**Using the helper script:**
```r
source("scripts/render_docs.R")
render_algorithm_doc("em")        # Render specific algorithm
render_all_docs()                  # Render all documentation
```

For detailed instructions, see [HOW_TO_RENDER_RMD.md](HOW_TO_RENDER_RMD.md).

## Documentation Style

All algorithm documentation uses R Markdown with a consistent styling template:
- **Headers (H1-H3)**: Source Sans Pro font, red color (RGB 237, 0, 0)
- **Body text**: Arial font, 13pt

The CSS template is located at `templates/styles.css` and is automatically applied to all documentation files.

## Testing

Tests are organized at two levels:
- **Algorithm-specific tests**: Located in each algorithm's `tests/` folder
- **Global tests**: Located in the root `tests/` folder

Run tests using:

```r
library(testthat)
test_dir("algorithms/em/tests")
```

## Contributing

When adding a new algorithm:

1. Create a new folder under `algorithms/`
2. Copy `templates/algorithm_template.Rmd` as your documentation file
3. Implement the algorithm following the existing structure
4. Add tests in the `tests/` subfolder
5. Update this README with the new algorithm

## License

[Add your license information here]

## Contact

[Add contact information here]

