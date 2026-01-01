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
Rscript -e "library(rmarkdown); render('$RMD_FILE')"

if [ $? -eq 0 ]; then
    # Get output filename (replace .Rmd with .html)
    OUTPUT_FILE="${RMD_FILE%.*}.html"
    echo "Done! Output saved to: $OUTPUT_FILE"
else
    echo "Error: Rendering failed"
    exit 1
fi

