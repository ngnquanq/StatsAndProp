#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "=========================================="
echo "  Adversarial LLM Robustness Benchmark"
echo "=========================================="

# Step 1: Run benchmark
echo ""
echo "[1/3] Running benchmark pipeline..."
python -m src.benchmark "$@"

# Step 2: Generate charts
echo ""
echo "[2/3] Generating charts..."
python scripts/generate_charts.py

# Step 3: Compile LaTeX report (if latexmk available)
echo ""
if command -v latexmk &> /dev/null; then
    echo "[3/3] Compiling LaTeX report..."
    cd report
    latexmk -pdf -interaction=nonstopmode main.tex
    cd "$PROJECT_DIR"
    echo "Report compiled: report/main.pdf"
else
    echo "[3/3] Skipping LaTeX compilation (latexmk not found)"
    echo "  Install with: sudo apt install texlive-full latexmk"
fi

echo ""
echo "=========================================="
echo "  Pipeline complete!"
echo "=========================================="
echo "  Results: data/results/"
echo "  Charts:  report/figures/"
echo "  Report:  report/main.pdf"
echo "=========================================="
