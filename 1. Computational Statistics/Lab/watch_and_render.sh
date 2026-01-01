#!/bin/bash
# Watch for changes and automatically render R Markdown files
# Usage: ./watch_and_render.sh <path_to_rmd_file>
# Example: ./watch_and_render.sh algorithms/em/em_documentation.Rmd

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No R Markdown file specified"
    echo "Usage: $0 <path_to_rmd_file>"
    echo "Example: $0 algorithms/em/em_documentation.Rmd"
    exit 1
fi

# Get the Rmd file path from argument
RMD_FILE="$1"

# Navigate to Lab directory (script location)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

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

# Get absolute path
RMD_ABS_PATH="$(cd "$(dirname "$RMD_FILE")" && pwd)/$(basename "$RMD_FILE")"
RMD_DIR="$(dirname "$RMD_ABS_PATH")"
RMD_BASENAME="$(basename "$RMD_FILE")"

# Check if inotifywait is available (Linux)
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed"
    echo "Install it with: sudo apt-get install inotify-tools"
    echo ""
    echo "Alternatively, you can use the basic watch mode (slower, polls every 2 seconds)"
    read -p "Use basic watch mode? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    USE_BASIC_WATCH=true
else
    USE_BASIC_WATCH=false
fi

# Function to render the file
render_file() {
    echo ""
    echo "=========================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Rendering: $RMD_FILE"
    echo "=========================================="
    
    # Call render_example.sh (use absolute path to be safe)
    RENDER_SCRIPT="$SCRIPT_DIR/render_example.sh"
    if [ -f "$RENDER_SCRIPT" ]; then
        # Capture output to see what's happening
        if bash "$RENDER_SCRIPT" "$RMD_FILE" 2>&1; then
            OUTPUT_FILE="${RMD_FILE%.*}.html"
            if [ -f "$OUTPUT_FILE" ]; then
                echo "✓ Successfully rendered: $OUTPUT_FILE"
                echo "✓ HTML file updated at $(date '+%H:%M:%S')"
            else
                echo "⚠ Warning: Render completed but HTML file not found: $OUTPUT_FILE"
            fi
            echo ""
        else
            echo "✗ Rendering failed - check errors above"
            echo ""
        fi
    else
        echo "Error: render_example.sh not found at $RENDER_SCRIPT"
        exit 1
    fi
}

# Initial render
echo "Starting file watcher for: $RMD_FILE"
echo "Initial render..."
render_file

# Determine which files to watch
# Watch the .Rmd file and related .R files in the same directory
WATCH_DIR="$RMD_DIR"
WATCH_PATTERNS="*.Rmd|*.rmd|*.R"

echo ""
echo "Watching for changes in: $WATCH_DIR"
echo "Watching patterns: $WATCH_PATTERNS"
echo "Press Ctrl+C to stop"
echo ""

if [ "$USE_BASIC_WATCH" = true ]; then
    # Basic watch mode using a loop (works on all systems but slower)
    echo "Using basic watch mode (checks every 1 second)..."
    LAST_MODIFIED=$(stat -c %Y "$RMD_ABS_PATH" 2>/dev/null || stat -f %m "$RMD_ABS_PATH" 2>/dev/null)
    
    # Track last modified times for all R files
    declare -A R_FILE_TIMES
    for R_FILE in "$WATCH_DIR"/*.R; do
        if [ -f "$R_FILE" ]; then
            R_FILE_TIMES["$R_FILE"]=$(stat -c %Y "$R_FILE" 2>/dev/null || stat -f %m "$R_FILE" 2>/dev/null)
        fi
    done
    
    while true; do
        sleep 1
        
        # Check main Rmd file
        CURRENT_MODIFIED=$(stat -c %Y "$RMD_ABS_PATH" 2>/dev/null || stat -f %m "$RMD_ABS_PATH" 2>/dev/null)
        if [ "$CURRENT_MODIFIED" != "$LAST_MODIFIED" ]; then
            echo "Change detected in: $RMD_BASENAME"
            LAST_MODIFIED=$CURRENT_MODIFIED
            render_file
        fi
        
        # Check all R files in the directory
        for R_FILE in "$WATCH_DIR"/*.R; do
            if [ -f "$R_FILE" ]; then
                R_CURRENT_MOD=$(stat -c %Y "$R_FILE" 2>/dev/null || stat -f %m "$R_FILE" 2>/dev/null)
                R_LAST_MOD="${R_FILE_TIMES["$R_FILE"]}"
                
                if [ -n "$R_CURRENT_MOD" ] && [ "$R_CURRENT_MOD" != "$R_LAST_MOD" ]; then
                    echo "Change detected in: $(basename "$R_FILE")"
                    R_FILE_TIMES["$R_FILE"]=$R_CURRENT_MOD
                    render_file
                    break
                fi
            fi
        done
    done
else
    # Advanced watch mode using inotifywait (Linux only, faster)
    echo "Using inotifywait (real-time file watching)..."
    echo "Watching: $RMD_ABS_PATH"
    echo "Watching directory: $WATCH_DIR"
    echo ""
    echo "DEBUG MODE: All file events will be shown"
    echo "Press Ctrl+C to stop"
    echo ""
    
    # Watch the directory and filter for relevant files
    # inotifywait outputs: directory event filename
    # Watch for all write-related events to catch any save mechanism
    inotifywait -m -e close_write,modify,moved_to,create \
        "$WATCH_DIR" 2>&1 | while read -r line; do
        # Parse the inotifywait output
        # Format: directory EVENT filename
        if [[ "$line" =~ ^(.*)\ (.*)\ (.*)$ ]]; then
            directory="${BASH_REMATCH[1]}"
            event="${BASH_REMATCH[2]}"
            file="${BASH_REMATCH[3]}"
            
            # Show all events for debugging
            echo "DEBUG: [$directory] [$event] [$file]"
            
            # Skip HTML files to avoid re-rendering when HTML is created
            if [[ "$file" =~ \.(html|HTML)$ ]]; then
                continue
            fi
            
            # Check if the changed file matches our patterns
            if [[ "$file" =~ \.(Rmd|rmd|R)$ ]]; then
                # If it's the main Rmd file or any R file in the same directory
                if [ "$file" = "$RMD_BASENAME" ] || [[ "$file" =~ \.R$ ]]; then
                    echo ""
                    echo ">>> Change detected: $file (event: $event) <<<"
                    echo ">>> Triggering render... <<<"
                    # Small delay to avoid multiple triggers for the same save
                    sleep 0.5
                    render_file
                    echo ">>> Waiting for next change... <<<"
                    echo ""
                fi
            fi
        fi
    done
fi

