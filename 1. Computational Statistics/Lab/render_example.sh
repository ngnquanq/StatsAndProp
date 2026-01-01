#!/bin/bash
# Example script to render R Markdown files WITHOUT RStudio
# Usage: ./render_example.sh <path_to_rmd_file>
# Example: ./render_example.sh algorithms/em/em_documentation.Rmd

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No R Markdown file specified"
    echo "Usage: $0 <path_to_rmd_file>"
    echo "Example: $0 algorithms/em/em_documentation.Rmd"
    exit 1
fi

# Get the Rmd file path from argument
RMD_FILE="$1"

# Navigate to Lab directory
cd "$(dirname "$0")"

# Check if file exists
if [ ! -f "$RMD_FILE" ]; then
    echo "Error: File not found: $RMD_FILE"
    exit 1
fi

# Check if file has .Rmd extension
if [[ ! "$RMD_FILE" =~ \.(Rmd|rmd)$ ]]; then
    echo "Warning: File does not have .Rmd extension: $RMD_FILE"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Render the R Markdown file
echo "Rendering: $RMD_FILE"
echo "Working directory: $(pwd)"
echo ""

# Render with explicit output directory to ensure HTML is created in the same folder
# Capture both stdout and stderr to see all output
Rscript -e "library(rmarkdown); setwd('$(pwd)'); result <- render('$RMD_FILE'); cat('Output file:', result, '\n')" 2>&1 | tee /tmp/rmd_render_output.log

RENDER_EXIT_CODE=${PIPESTATUS[0]}

if [ $RENDER_EXIT_CODE -eq 0 ]; then
    # Get output filename (replace .Rmd with .html)
    OUTPUT_FILE="${RMD_FILE%.*}.html"
    
    # Check if file actually exists
    if [ -f "$OUTPUT_FILE" ]; then
        echo ""
        echo "✓ Done! Output saved to: $OUTPUT_FILE"
        echo "✓ File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    else
        echo ""
        echo "⚠ Warning: Render reported success but HTML file not found at: $OUTPUT_FILE"
        echo "Checking for HTML files in the directory..."
        ls -lh "$(dirname "$OUTPUT_FILE")"/*.html 2>/dev/null || echo "No HTML files found"
    fi
else
    echo ""
    echo "✗ Error: Rendering failed with exit code: $RENDER_EXIT_CODE"
    exit 1
fi

