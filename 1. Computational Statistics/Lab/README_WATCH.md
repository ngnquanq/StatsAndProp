# File Watcher for Auto-Rendering

The `watch_and_render.sh` script automatically watches your R Markdown files and re-renders them whenever you make changes.

## Quick Start

```bash
./watch_and_render.sh algorithms/em/em_documentation.Rmd
```

## How It Works

1. **Initial Render**: Renders the file immediately when you start the watcher
2. **File Watching**: Monitors the `.Rmd` file and related `.R` files for changes
3. **Auto-Render**: Automatically calls `render_example.sh` when changes are detected
4. **Continuous**: Keeps watching until you press `Ctrl+C`

## Features

- ✅ Watches `.Rmd` files for changes
- ✅ Watches related `.R` files in the same directory (algorithm files, helpers, etc.)
- ✅ Uses `inotifywait` for real-time file monitoring (Linux)
- ✅ Falls back to polling mode if `inotifywait` is not available
- ✅ Calls `render_example.sh` for rendering (reuses existing script)
- ✅ Shows timestamps for each render
- ✅ Handles file save events properly

## Requirements

### For Best Performance (Linux):

```bash
sudo apt-get install inotify-tools
```

This enables real-time file watching. Without it, the script falls back to polling mode (checks every 2 seconds).

### Basic Requirements:

- Bash shell
- R with `rmarkdown` package
- `render_example.sh` script (included in repo)

## Usage Examples

### Watch a specific file:

```bash
./watch_and_render.sh algorithms/em/em_documentation.Rmd
```

### Workflow:

1. Start the watcher:
   ```bash
   ./watch_and_render.sh algorithms/em/em_documentation.Rmd
   ```

2. Edit your `.Rmd` file or related `.R` files in your editor

3. Save the file - it automatically renders!

4. Check the HTML output - it's updated automatically

5. Press `Ctrl+C` to stop watching

## What Files Are Watched?

The script watches:
- The main `.Rmd` file you specify
- All `.R` files in the same directory (algorithm files, helpers, examples)

For example, if you watch `algorithms/em/em_documentation.Rmd`, it will also watch:
- `algorithms/em/em_algorithm.R`
- `algorithms/em/em_helpers.R`
- `algorithms/em/em_example.R`
- Any other `.R` files in that directory

## Output

Each time a file changes, you'll see:

```
==========================================
2024-01-15 14:30:25 - Rendering: algorithms/em/em_documentation.Rmd
==========================================
Rendering: algorithms/em/em_documentation.Rmd
Done! Output saved to: algorithms/em/em_documentation.html
✓ Successfully rendered: algorithms/em/em_documentation.html
```

## Tips

1. **Keep the terminal open**: The watcher runs in the foreground
2. **Edit in your IDE**: Make changes in your editor, save, and watch it auto-render
3. **Check for errors**: If rendering fails, fix the error and save again
4. **Multiple files**: Run multiple watchers in different terminals for different files

## Troubleshooting

### "inotifywait is not installed"

Install it:
```bash
sudo apt-get install inotify-tools
```

Or use the basic watch mode (slower, but works everywhere).

### "render_example.sh not found"

Make sure you're running the script from the `Lab/` directory:
```bash
cd "/home/nhatquang/Desktop/HCMUS Course/1. Computational Statistics/Lab"
./watch_and_render.sh algorithms/em/em_documentation.Rmd
```

### Multiple renders for one save

This can happen if your editor saves multiple times. The script includes a small delay to minimize this, but some editors may still trigger multiple events.

### Script stops watching

If the script stops unexpectedly, check:
- File permissions
- Disk space
- R errors during rendering

## Combining with Live Preview

For the best experience, combine with the live preview:

1. **Terminal 1**: Start live preview
   ```r
   source("scripts/live_preview.R")
   live_preview("algorithms/em/em_documentation.Rmd")
   ```

2. **Terminal 2**: Start file watcher
   ```bash
   ./watch_and_render.sh algorithms/em/em_documentation.Rmd
   ```

Now:
- Edit and save → Watcher auto-renders → Browser auto-refreshes! ✨

## Stopping the Watcher

Press `Ctrl+C` in the terminal where the watcher is running.

