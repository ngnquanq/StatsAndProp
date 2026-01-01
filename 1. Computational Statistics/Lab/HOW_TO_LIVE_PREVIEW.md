# Real-Time Rendering and Live Preview for R Markdown

This guide explains how to get real-time or near real-time updates when working with R Markdown files.

## Options for Real-Time Updates

### Option 1: RStudio's "Run All" + Auto-Knit (Easiest)

**How it works:**
1. Run code chunks individually or "Run All Chunks"
2. When ready, click "Knit" to update HTML
3. HTML automatically refreshes in RStudio viewer

**Setup:**
1. In RStudio, open your `.Rmd` file
2. Run chunks as you work: `Ctrl+Shift+Enter` (or `Cmd+Shift+Enter` on Mac)
3. Click "Knit" when you want to update the HTML
4. The HTML preview will auto-refresh

**Pros:**
- Built into RStudio
- No additional setup
- Works immediately

**Cons:**
- Not truly "real-time" - requires manual knit
- HTML only updates when you click "Knit"

### Option 2: Live Preview with `servr` Package (Recommended)

This creates a local web server that watches your HTML file and auto-refreshes.

**Setup:**

1. **Install the package:**
```r
install.packages("servr")
```

2. **Create a preview script** (`scripts/live_preview.R`):
```r
library(servr)
library(rmarkdown)

# Render the R Markdown file
render("algorithms/em/em_documentation.Rmd")

# Start live preview server
servr::httw(dir = "algorithms/em", 
            pattern = "em_documentation.html",
            daemon = FALSE)  # Set to TRUE to run in background
```

3. **Usage:**
```r
source("scripts/live_preview.R")
```

**How it works:**
- Renders the HTML file
- Starts a local web server
- Opens browser with live preview
- When you re-render, browser auto-refreshes

**Pros:**
- Auto-refreshes when HTML is updated
- Works in any browser
- Can view on other devices on same network

**Cons:**
- Requires re-rendering to see changes
- Still need to run chunks and knit

### Option 3: RStudio's "Run All" + Browser Auto-Refresh

**Setup:**
1. Render HTML: `Ctrl+Shift+K` (or click Knit)
2. Open HTML in external browser (not RStudio viewer)
3. Use browser extension for auto-refresh:
   - Chrome: "Auto Refresh Plus" or "Live Server"
   - Firefox: "Auto Reload" or "Tab Reloader"

**Pros:**
- Simple setup
- Works with any HTML file

**Cons:**
- Requires browser extension
- Still need to manually knit

### Option 4: Interactive Documents with `flexdashboard`

For more interactive, real-time documents, use `flexdashboard`:

**Setup:**
1. Install: `install.packages("flexdashboard")`
2. Change output format in YAML:
```yaml
output: 
  flexdashboard::flex_dashboard:
    css: ../../templates/styles.css
```

**Pros:**
- More interactive
- Better for dashboards
- Can have reactive elements

**Cons:**
- Different format (not standard HTML)
- May not match your current styling exactly

### Option 5: Shiny Integration (Most Interactive)

For truly interactive, real-time documents:

**Setup:**
1. Install: `install.packages("shiny")`
2. Use `runtime: shiny` in YAML:
```yaml
output: 
  html_document:
    runtime: shiny
    css: ../../templates/styles.css
```

**Pros:**
- Fully interactive
- Real-time updates
- Can have user inputs

**Cons:**
- Requires Shiny server for deployment
- More complex
- Different from static documentation

## Recommended Workflow

For your use case (algorithm documentation), I recommend:

### Workflow 1: Development Mode (Quick Iteration)

```r
# In RStudio console, while editing .Rmd file:

# 1. Run chunks as you work
#    - Click "Run Current Chunk" or Ctrl+Shift+Enter
#    - Or "Run All Chunks Above" to test up to current point

# 2. When ready to see HTML:
library(rmarkdown)
render("algorithms/em/em_documentation.Rmd", 
       output_options = list(self_contained = FALSE))  # Faster rendering

# 3. HTML auto-opens in RStudio viewer
```

### Workflow 2: Live Preview Mode (Best for Final Review)

```r
# Start live preview server
source("scripts/live_preview.R")

# Now:
# 1. Edit .Rmd file
# 2. Run chunks
# 3. Re-render: render("algorithms/em/em_documentation.Rmd")
# 4. Browser auto-refreshes!
```

## Quick Setup Script

I'll create a helper script that combines rendering + live preview for you.

## Tips for Faster Iteration

1. **Use `eval=FALSE` for slow chunks during development:**
```r
```{r slow_chunk, eval=FALSE}
# This won't run during render
```

2. **Use `cache=TRUE` for expensive computations:**
```r
```{r expensive_computation, cache=TRUE}
# Results cached, won't recompute unless code changes
```

3. **Render with `quiet=TRUE` for faster output:**
```r
render("file.Rmd", quiet = TRUE)
```

4. **Use incremental rendering:**
   - Only render when you make significant changes
   - Use "Run Chunk" for quick testing

## Limitations

**Important:** True "real-time" rendering (like Jupyter notebooks) isn't natively supported in R Markdown because:
- R Markdown is designed for reproducible documents
- Full rendering requires complete execution
- HTML is static output

However, the workflows above give you the best approximation of real-time updates while maintaining the benefits of R Markdown.

