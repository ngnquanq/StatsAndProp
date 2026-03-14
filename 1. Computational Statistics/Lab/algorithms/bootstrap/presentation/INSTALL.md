# Installation Guide

## Install Missing LaTeX Packages

The presentation requires the `algorithm` and `algpseudocode` packages, which are part of the `texlive-science` collection.

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install texlive-science
```

This will install:
- `algorithm.sty` - For algorithm environments
- `algpseudocode.sty` - For pseudocode formatting
- Additional math and science packages

### Verify Installation

After installation, verify the packages are available:

```bash
kpsewhich algorithm.sty
kpsewhich algpseudocode.sty
```

Both commands should return file paths if installed correctly.

## Compile the Presentation

Once packages are installed:

```bash
cd algorithms/mean_shift_clustering/presentation
pdflatex main.tex
pdflatex main.tex  # Run twice for table of contents
```

## Alternative: Use Overleaf

If you don't want to install packages locally, you can use [Overleaf](https://www.overleaf.com):

1. Create a new project on Overleaf
2. Upload all files from the `presentation/` directory
3. The presentation will compile automatically with all packages available

## Required Packages Summary

| Package | Purpose | Included In |
|---------|---------|-------------|
| beamer | Presentation class | texlive-latex-recommended |
| amsmath, amssymb | Math symbols | texlive-latex-base |
| graphicx | Images | texlive-latex-base |
| booktabs | Professional tables | texlive-latex-extra |
| algorithm | Algorithm environment | texlive-science |
| algpseudocode | Pseudocode formatting | texlive-science |
| tikz | Diagrams | texlive-pictures |

## Troubleshooting

### Error: `algorithm.sty not found`
**Solution:** Install `texlive-science` package

### Error: `tikz.sty not found`
**Solution:** Install `texlive-pictures` package
```bash
sudo apt install texlive-pictures
```

### Error: `booktabs.sty not found`
**Solution:** Install `texlive-latex-extra` package
```bash
sudo apt install texlive-latex-extra
```

### Compilation hangs or errors
1. Delete auxiliary files: `rm *.aux *.log *.nav *.out *.snm *.toc`
2. Recompile: `pdflatex main.tex`
