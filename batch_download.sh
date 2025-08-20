#!/bin/bash

# Batch download script for wayback-machine-downloader
# Reads URLs from a text file and downloads them sequentially

# Check if URL file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <url_file.txt>"
    echo "  url_file.txt should contain one URL per line"
    exit 1
fi

URL_FILE="$1"

# Check if file exists
if [ ! -f "$URL_FILE" ]; then
    echo "Error: File '$URL_FILE' not found!"
    exit 1
fi

# Check if wayback_machine_downloader exists
if ! command -v ruby >/dev/null 2>&1; then
    echo "Error: Ruby is not installed or not in PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOADER="$SCRIPT_DIR/bin/wayback_machine_downloader"

if [ ! -f "$DOWNLOADER" ]; then
    echo "Error: wayback_machine_downloader not found at $DOWNLOADER"
    exit 1
fi

# Count total URLs
TOTAL_URLS=$(wc -l < "$URL_FILE")
CURRENT=0

echo "Starting batch download of $TOTAL_URLS URLs from $URL_FILE"
echo "Options: -e -s -f 20180525000000"
echo "----------------------------------------"

# Read URLs and process sequentially
while IFS= read -r url; do
    # Skip empty lines and comments
    if [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    ((CURRENT++))
    echo "[$CURRENT/$TOTAL_URLS] Processing: $url"
    
    # Run wayback_machine_downloader with specified options
    ruby "$DOWNLOADER" "$url" -e -s -f 20180525000000 --keep
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✓ Successfully completed: $url"
    else
        echo "✗ Failed (exit code $EXIT_CODE): $url"
    fi
    
    echo "----------------------------------------"
done < "$URL_FILE"

echo "Batch download completed. Processed $CURRENT URLs."
