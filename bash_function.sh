# Enhanced cdx with tab completion and caching
CDX_CACHE_FILE="$HOME/.cdx_cache"
CDX_MAX_DEPTH=6

# Function to build/update the directory cache
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

# Main cdx function
cdx() {
    # Update cache if it doesn't exist or is older than 24 hours
    if [ ! -f "$CDX_CACHE_FILE" ] || [ $(find "$CDX_CACHE_FILE" -mtime +1 2>/dev/null | wc -l) -gt 0 ]; then
        cdx_update_cache
    fi

    if [ -z "$1" ]; then
        echo "Usage: cdx <partial_directory_name>"
        echo "       cdx --update-cache (to refresh directory cache)"
        return 1
    fi

    if [ "$1" = "--update-cache" ]; then
        cdx_update_cache
        return 0
    fi

    local search_term="$1"

    # Search for matching directories using grep for better performance
    local matches=($(grep -i ".*$search_term.*" "$CDX_CACHE_FILE" | head -20))

    case ${#matches[@]} in
        0)
            echo "No directories found matching '$search_term'"
            echo "Try running: cdx --update-cache"
            return 1
            ;;
        1)
            echo "→ ${matches[0]}"
            cd "${matches[0]}"
            ;;
        *)
            echo "Multiple matches found:"
            for i in "${!matches[@]}"; do
                printf "%2d: %s\n" "$((i+1))" "${matches[i]}"
            done
            echo -n "Select directory (1-${#matches[@]}) or Enter to cancel: "
            read -r choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#matches[@]} ]; then
                selected_dir="${matches[$((choice-1))]}"
                echo "→ $selected_dir"
                cd "$selected_dir"
            else
                echo "Cancelled"
                return 1
            fi
            ;;
    esac
}

# Tab completion for cdx
_cdx_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"

    if [ ! -f "$CDX_CACHE_FILE" ]; then
        return 0
    fi

    # Generate completions based on directory basenames
    local completions=($(grep -i ".*$cur.*" "$CDX_CACHE_FILE" | xargs -I {} basename {} | sort -u))

    COMPREPLY=($(compgen -W "${completions[*]}" -- "$cur"))
}

# Register tab completion
complete -F _cdx_completion cdx
