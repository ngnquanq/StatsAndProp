# How to Render R Markdown Files

This guide explains how to render (knit) the R Markdown documentation files in this project.

**Note**: RStudio is NOT required! You can render R Markdown files using:
- R console (command line)
- Terminal/Command Prompt
- Any R IDE (RStudio, VS Code, etc.)
- R scripts

RStudio is just the easiest option with a graphical interface.

## Method 1: Using RStudio (Easiest - Optional)

RStudio provides the easiest way to render R Markdown files with a graphical interface.

### Steps:

1. **Open the R Markdown file** in RStudio
   - Navigate to the algorithm folder (e.g., `algorithms/em/`)
   - Double-click on the `.Rmd` file (e.g., `em_documentation.Rmd`)

2. **Click the "Knit" button**
   - Located in the toolbar at the top of the R Markdown editor
   - Or use the keyboard shortcut: `Ctrl+Shift+K` (Windows/Linux) or `Cmd+Shift+K` (Mac)

3. **Select output format** (if prompted)
   - Choose "HTML" to generate an HTML document with the CSS styling
   - The output will be saved in the same folder as the `.Rmd` file

4. **View the output**
   - The rendered HTML file will open automatically in RStudio's viewer
   - You can also find the `.html` file in the same directory as the `.Rmd` file

### Important Notes for RStudio:

- **Working Directory**: Make sure your working directory is set correctly. The CSS path (`../../templates/styles.css`) is relative to the `.Rmd` file location.
- **Package Requirements**: Ensure you have `rmarkdown` and `knitr` packages installed:
  ```r
  install.packages(c("rmarkdown", "knitr"))
  ```

## Method 2: Using R Console (No RStudio Required)

You can render R Markdown files directly from the R console or R script. This works in any R environment - you don't need RStudio at all.

### Basic Rendering:

```r
# Load rmarkdown package
library(rmarkdown)

# Render a specific file
render("algorithms/em/em_documentation.Rmd")

# Or with full path
render("algorithms/em/em_documentation.Rmd", 
       output_file = "em_documentation.html")
```

### Render from Different Working Directory:

If you're in the root `Lab/` directory:

```r
render("algorithms/em/em_documentation.Rmd")
```

If you're in the `algorithms/em/` directory:

```r
render("em_documentation.Rmd")
```

### Specify Output Location:

```r
render("algorithms/em/em_documentation.Rmd",
       output_dir = "docs/",  # Save to docs folder
       output_file = "em_documentation.html")
```

## Method 3: Using RScript (Terminal/Command Line) - No GUI Required

You can render from the terminal/command line without any GUI or IDE. This is the most flexible method:

### On Linux/Mac:

```bash
cd "/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab"
Rscript -e "rmarkdown::render('algorithms/em/em_documentation.Rmd')"
```

### On Windows (Command Prompt):

```cmd
cd "C:\path\to\Lab"
Rscript -e "rmarkdown::render('algorithms/em/em_documentation.Rmd')"
```

### On Windows (PowerShell):

```powershell
cd "C:\path\to\Lab"
Rscript -e "rmarkdown::render('algorithms/em/em_documentation.Rmd')"
```

### Using a Shell Script (Linux/Mac):

Create a file `render.sh`:
```bash
#!/bin/bash
cd "/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab"
Rscript -e "rmarkdown::render('algorithms/em/em_documentation.Rmd')"
```

Make it executable and run:
```bash
chmod +x render.sh
./render.sh
```

### Using a Batch File (Windows):

Create a file `render.bat`:
```batch
@echo off
cd "C:\path\to\Lab"
Rscript -e "rmarkdown::render('algorithms/em/em_documentation.Rmd')"
pause
```

## Rendering Multiple Files

### Render All Documentation Files:

```r
library(rmarkdown)

# List all R Markdown documentation files
rmd_files <- list.files(
  path = "algorithms",
  pattern = "*_documentation.Rmd",
  recursive = TRUE,
  full.names = TRUE
)

# Render all files
for (file in rmd_files) {
  cat("Rendering:", file, "\n")
  render(file)
}
```

### Render All Files in a Specific Algorithm Folder:

```r
# Render all Rmd files in EM folder
rmd_files <- list.files(
  path = "algorithms/em",
  pattern = "*.Rmd",
  full.names = TRUE
)

for (file in rmd_files) {
  render(file)
}
```

## Output Formats

The template is configured for HTML output. You can also render to other formats:

### PDF Output:

```r
render("algorithms/em/em_documentation.Rmd",
       output_format = "pdf_document")
```

**Note**: PDF rendering requires LaTeX (e.g., TinyTeX, MiKTeX, or TeX Live). The CSS styling won't apply to PDF - you'll need a LaTeX template for PDF styling.

### Word Document:

```r
render("algorithms/em/em_documentation.Rmd",
       output_format = "word_document")
```

### Multiple Formats:

```r
render("algorithms/em/em_documentation.Rmd",
       output_format = c("html_document", "pdf_document"))
```

## Troubleshooting

### Issue: CSS Not Applied

**Problem**: The HTML output doesn't show the custom styling.

**Solutions**:
1. Check that the CSS path in the YAML header is correct relative to the `.Rmd` file location
2. For files in `algorithms/em/`, the path should be `../../templates/styles.css`
3. Verify the CSS file exists at `templates/styles.css`

### Issue: "Package Not Found" Error

**Problem**: Error about missing `rmarkdown` or `knitr` packages.

**Solution**:
```r
install.packages(c("rmarkdown", "knitr"))
```

### Issue: Code Chunks Not Running

**Problem**: Code chunks show but don't execute.

**Solution**:
- Check that `knitr::opts_chunk$set()` is properly configured in the setup chunk
- Ensure all required packages are installed
- Check for errors in the code chunks

### Issue: Working Directory Problems

**Problem**: Files can't be found or paths are incorrect.

**Solution**:
- Set the working directory before rendering:
  ```r
  setwd("/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab")
  render("algorithms/em/em_documentation.Rmd")
  ```
- Or use absolute paths in the YAML header for CSS:
  ```yaml
  css: /absolute/path/to/templates/styles.css
  ```

## Quick Reference

### Minimum Requirements:
- **R installed** (version 4.0+ recommended)
- **rmarkdown package**: `install.packages("rmarkdown")`
- **knitr package**: `install.packages("knitr")`
- **That's it!** No RStudio or other IDE needed.

### Keyboard Shortcuts (RStudio - Optional):
- **Knit**: `Ctrl+Shift+K` (Windows/Linux) or `Cmd+Shift+K` (Mac)
- **Run Current Chunk**: `Ctrl+Shift+Enter` (Windows/Linux) or `Cmd+Shift+Enter` (Mac)
- **Run All Chunks Above**: `Ctrl+Alt+P` (Windows/Linux) or `Cmd+Option+P` (Mac)

### Common R Commands (Works Anywhere):
```r
# Install required packages
install.packages(c("rmarkdown", "knitr", "ggplot2"))

# Load rmarkdown
library(rmarkdown)

# Render a file
render("path/to/file.Rmd")

# Render with custom output
render("path/to/file.Rmd", output_file = "custom_name.html")
```

## Example: Complete Workflow (No RStudio Required)

### From R Console (any R environment):

```r
# 1. Set working directory
setwd("/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab")

# 2. Install packages (if needed)
source("scripts/setup.R")

# 3. Load rmarkdown
library(rmarkdown)

# 4. Render EM documentation
render("algorithms/em/em_documentation.Rmd")

# 5. The HTML file will be created at:
# algorithms/em/em_documentation.html
```

### From Terminal/Command Line (no R GUI at all):

```bash
# Navigate to project directory
cd "/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab"

# Render directly
Rscript -e "library(rmarkdown); render('algorithms/em/em_documentation.Rmd')"
```

### One-liner (Linux/Mac/Windows):

```bash
Rscript -e "setwd('path/to/Lab'); library(rmarkdown); render('algorithms/em/em_documentation.Rmd')"
```

## Additional Resources

- [R Markdown Documentation](https://rmarkdown.rstudio.com/)
- [R Markdown Cheat Sheet](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf)
- [knitr Documentation](https://yihui.org/knitr/)

