# Mean Shift Clustering Presentation

LaTeX Beamer presentation for Mean Shift Clustering algorithm (7-10 minutes).

## Structure

The presentation is modular, with separate files for each section:

```
presentation/
├── main.tex                          # Main presentation file (compile this)
├── sections/
│   ├── 00_preamble.tex              # Theme, colors, fonts, packages
│   ├── 01_introduction.tex          # Introduction & Intuition
│   ├── 02_mathematics.tex           # Mathematical Foundation
│   ├── 03_advantages_limitations.tex # Advantages & Limitations
│   ├── 04_experimental_results.tex  # Experimental Results
│   ├── 05_conclusion.tex            # Conclusion & References
│   └── 06_backup_slides.tex         # Backup slides (optional)
└── README.md                         # This file
```

## Styling

Matches the `templates/styles.css` color scheme from the documentation:
- **Color**: Red (RGB 237, 0, 0) for headings and accents
- **Fonts**: Standard LaTeX sans-serif fonts
- **Theme**: Clean Beamer default with custom red color scheme

## Installation & Compilation

### Install Required Packages

If you get errors about missing packages, install them:

```bash
sudo apt install texlive-science  # For algorithm package
```

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

### Compilation Command

```bash
pdflatex main.tex
pdflatex main.tex  # Run twice for TOC and references
```

Or use your LaTeX editor (TeXShop, Overleaf, TeXStudio, etc.).

**Quick tip:** Use Overleaf for zero-setup compilation!

## Content Overview

1. **Introduction & Intuition** (2-3 min)
   - What is Mean Shift?
   - Visual intuition and core concepts

2. **Mathematical Foundation** (2 min)
   - Kernel density estimation
   - Mean shift vector
   - Algorithm steps
   - Common kernels

3. **Advantages & Limitations** (2 min)
   - Key advantages
   - Limitations with detailed explanations
   - When to use/avoid

4. **Experimental Results** (2-3 min)
   - Synthetic data
   - Iris dataset
   - Wine dataset
   - Image segmentation
   - Bandwidth sensitivity

5. **Conclusion** (1 min)
   - Summary
   - References
   - Thank you slide

6. **Backup Slides** (if time permits or for Q&A)
   - Adaptive bandwidth
   - Implementation tips
   - Comparison with other methods
   - Mathematical details

## Customization

### To Edit a Section
Simply open the corresponding file in `sections/` and modify.

### To Add Images
1. Create an `images/` folder
2. Add your figures
3. Reference them in the section files:
```latex
\includegraphics[width=0.8\textwidth]{images/your_image.png}
```

### To Change Colors
Edit `sections/00_preamble.tex` and modify:
```latex
\definecolor{customred}{RGB}{237,0,0}
```

### To Use Custom Fonts (Optional)
If you want to use specific fonts like Arial or Source Sans Pro:
1. Uncomment and modify font settings in `sections/00_preamble.tex`
2. Use XeLaTeX instead of pdfLaTeX for compilation
3. Ensure fonts are installed on your system

## Notes

- Presentation designed for 7-10 minutes
- Focus on intuition, brief math, pros/cons with explanations
- Experimental results use placeholder data (add your own)
- Image segmentation slide needs actual images
- Bandwidth sensitivity plot needs to be generated
- All comparison tables use example numbers (replace with real data)

## Tips for Presenting

1. **Timing**:
   - Introduction: 2-3 min
   - Math: 1.5-2 min (keep it brief!)
   - Pros/Cons: 2 min (emphasize why limitations matter)
   - Results: 2-3 min (focus on key insights)
   - Conclusion: 1 min

2. **Emphasis**:
   - Stress the automatic cluster discovery
   - Explain why limitations happen (not just list them)
   - Show curse of dimensionality with Wine dataset
   - Highlight practical applications

3. **Backup Slides**:
   - Use during Q&A if asked about:
     - Adaptive bandwidth
     - Implementation details
     - Comparison with other methods
     - Mathematical convergence
