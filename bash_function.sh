#!/bin/bash

CDX_CACHE_FILE="$HOME/.cdx_cache"
CDX_MAX_DEPTH=6

cdx_update_cache() {
    echo "Updating directory cache..."
    local search_paths=("$HOME" "/usr" "/opt" "/var")
    
    # Clear existing cache
    > "$CDX_CACHE_FILE"
    
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path" ]; then
            find "$base_path" -maxdepth "$CDX_MAX_DEPTH" -type d 2>/dev/null >> "$CDX_CACHE_FILE"
        fi
    done
    
    # Sort and remove duplicates
    sort -u "$CDX_CACHE_FILE" -o "$CDX_CACHE_FILE"
    echo "Cache updated with $(wc -l < "$CDX_CACHE_FILE") directories"
}

cdx() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install fzf first."
        echo "Ubuntu/Debian: sudo apt install fzf"
        echo "macOS: brew install fzf"
        return 1
    fi
    
    # Update cache if it doesn't exist or is older than 24 hours
    if [ ! -f "$CDX_CACHE_FILE" ] || [ $(find "$CDX_CACHE_FILE" -mtime +1 2>/dev/null | wc -l) -gt 0 ]; then
        cdx_update_cache
    fi
    
    local initial_query="$1"
    
    # Use fzf to select directory with initial query
    local selected_dir
    if [ -n "$initial_query" ]; then
        selected_dir=$(cat "$CDX_CACHE_FILE" | fzf --query="$initial_query" --select-1 --exit-0 --height=40% --border --preview='ls -la {}' --preview-window=right:50%)
    else
        selected_dir=$(cat "$CDX_CACHE_FILE" | fzf --height=40% --border --preview='ls -la {}' --preview-window=right:50%)
    fi
    
    if [ -n "$selected_dir" ] && [ -d "$selected_dir" ]; then
        echo "→ $selected_dir"
        cd "$selected_dir"
    else
        echo "No directory selected"
        return 1
    fi
}

# Alternative: cdx with real-time directory search (no cache)
cdx_live() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed."
        return 1
    fi
    
    local search_paths=("$HOME" "/usr" "/opt" "/var")
    local initial_query="$1"
    
    # Real-time directory search
    local selected_dir
    selected_dir=$(find "${search_paths[@]}" -maxdepth "$CDX_MAX_DEPTH" -type d 2>/dev/null | \
        fzf --query="$initial_query" --height=40% --border --preview='ls -la {}' --preview-window=right:50%)
    
    if [ -n "$selected_dir" ] && [ -d "$selected_dir" ]; then
        echo "→ $selected_dir"
        cd "$selected_dir"
    else
        echo "No directory selected"
        return 1
    fi
}