# How to Add Images to R Markdown

R Markdown supports multiple ways to include images. Here are the most common methods:

## Method 1: Markdown Syntax (Simplest)

```markdown
![Alt text describing the image](path/to/image.png)
```

**Example:**
```markdown
![Algorithm flowchart](images/em_flowchart.png)
```

**With title:**
```markdown
![Algorithm flowchart](images/em_flowchart.png "EM Algorithm Flowchart")
```

## Method 2: HTML Syntax (More Control)

```html
<img src="path/to/image.png" alt="Alt text" width="500" />
```

**Example:**
```html
<img src="images/em_flowchart.png" alt="EM Algorithm" width="600" />
```

**Centered:**
```html
<div align="center">
  <img src="images/em_flowchart.png" alt="EM Algorithm" width="600" />
</div>
```

## Method 3: Using R Code Chunks (Recommended for R Projects)

This is the best method for R Markdown because it handles paths correctly:

```r
```{r, echo=FALSE, fig.cap="Caption for the figure"}
knitr::include_graphics("images/em_flowchart.png")
```
```

**With options:**
```r
```{r, echo=FALSE, fig.cap="EM Algorithm Flowchart", out.width="80%"}
knitr::include_graphics("images/em_flowchart.png")
```
```

## Method 4: Generate Plots with R Code

The most common way - generate plots directly in R:

```r
```{r plot-example, fig.cap="Example plot", fig.width=10, fig.height=6}
library(ggplot2)
ggplot(data, aes(x = x, y = y)) +
  geom_point() +
  labs(title = "My Plot")
```
```

## Recommended Folder Structure

For your algorithm documentation, create an `images/` folder in each algorithm directory:

```
algorithms/em/
├── em_documentation.Rmd
├── em_algorithm.R
├── images/                    # Create this folder
│   ├── flowchart.png
│   ├── convergence_plot.png
│   └── example_result.png
└── ...
```

## Paths in R Markdown

### Relative to Rmd file location:

If your Rmd file is at `algorithms/em/em_documentation.Rmd`:

```markdown
![Image](images/my_image.png)              # Same directory
![Image](../shared_images/common.png)      # Parent directory
![Image](../../templates/logo.png)         # Two levels up
```

### Using R code (handles paths better):

```r
```{r, echo=FALSE}
# Path relative to Rmd file location
knitr::include_graphics("images/my_image.png")
```
```

## Examples for Your Algorithm Documentation

### Example 1: Include a flowchart diagram

```markdown
## Algorithm Flowchart

![EM Algorithm Flowchart](images/em_flowchart.png)
```

### Example 2: Include with R code chunk

```r
```{r flowchart, echo=FALSE, fig.cap="EM Algorithm Flowchart", out.width="90%"}
knitr::include_graphics("images/em_flowchart.png")
```
```

### Example 3: Generate and save plot, then include

```r
```{r generate-plot, echo=TRUE, fig.width=10, fig.height=6}
# Generate the plot
p <- plot_em_results(data, result)
print(p)

# Optionally save it
ggsave("images/em_result_plot.png", p, width = 10, height = 6, dpi = 300)
```
```

### Example 4: Multiple images side by side

```r
```{r multiple-images, echo=FALSE, fig.width=12, fig.height=4, out.width="100%"}
library(gridExtra)
p1 <- plot_clusters(data, clusters)
p2 <- plot_convergence(likelihoods)
grid.arrange(p1, p2, ncol = 2)
```
```

## Image Formats Supported

- **PNG** (recommended for plots/diagrams)
- **JPEG/JPG** (good for photos)
- **SVG** (vector graphics, scalable)
- **GIF** (animated images)
- **PDF** (vector graphics, good for LaTeX)

## Best Practices

1. **Use descriptive alt text** for accessibility
2. **Optimize image sizes** - don't use huge images
3. **Use relative paths** - makes your project portable
4. **Organize images** - put them in an `images/` folder
5. **Use R code chunks** for better path handling
6. **Add captions** using `fig.cap` option

## Image Sizing Options

### In R code chunks:

```r
```{r, out.width="50%"}           # 50% of page width
```{r, out.width="600px"}         # Fixed 600 pixels
```{r, fig.width=10, fig.height=6}  # Figure dimensions in inches
```
```

### In HTML:

```html
<img src="image.png" width="500" height="300" />
<img src="image.png" style="width: 50%;" />
```

## Creating Images for Your Documentation

### 1. Save plots from R:

```r
# In your example script
p <- plot_em_results(data, result)
ggsave("images/em_result.png", p, width = 10, height = 6)
```

### 2. Create diagrams:

- Use tools like:
  - **draw.io** (free, online)
  - **Lucidchart** (online)
  - **Inkscape** (free, vector graphics)
  - **Mermaid** (text-based diagrams in R Markdown)

### 3. Use Mermaid for flowcharts (in R Markdown):

```markdown
```{mermaid}
graph TD
    A[Initialize] --> B[E-step]
    B --> C[M-step]
    C --> D{Converged?}
    D -->|No| B
    D -->|Yes| E[Return Results]
```
```

## Example: Adding Images to EM Documentation

Here's how you could add images to your `em_documentation.Rmd`:

```markdown
# Algorithm Overview

![EM Algorithm Overview](images/em_overview.png)

The Expectation-Maximization algorithm...

## Visual Example

```{r example-plot, fig.cap="EM Algorithm Results", fig.width=10, fig.height=6}
# This plot will be included in the document
plot_em_results(data, result)
```

## Algorithm Flowchart

```{r flowchart, echo=FALSE, fig.cap="EM Algorithm Flowchart", out.width="80%"}
knitr::include_graphics("images/em_flowchart.png")
```
```

## Troubleshooting

### Image not showing:

1. **Check the path** - use relative paths from the Rmd file location
2. **Check file exists** - verify the image file is in the correct location
3. **Check file permissions** - make sure the file is readable
4. **Use absolute paths** if relative paths don't work:
   ```r
   knitr::include_graphics("/absolute/path/to/image.png")
   ```

### Image too large/small:

Adjust with `out.width` or `fig.width`/`fig.height` options.

### Image path issues:

Use `knitr::include_graphics()` instead of markdown syntax - it handles paths better in R Markdown.

## Quick Reference

```markdown
# Markdown
![Alt text](images/pic.png)

# HTML
<img src="images/pic.png" width="500" />

# R code chunk
```{r, echo=FALSE, fig.cap="Caption"}
knitr::include_graphics("images/pic.png")
```

# Generate plot
```{r}
ggplot(data, aes(x, y)) + geom_point()
```
```

