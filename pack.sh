#!/bin/bash

TARGET_DIR="tmps"
OUTPUT_DIR="bin"
OUTPUT_FILE="$OUTPUT_DIR/sign-cli.bin"

mkdir -p "$TARGET_DIR"
mkdir -p "$OUTPUT_DIR"

items=(
    "scripts"
    "secrets"
    "main.sh"
    "README.md"
    "version.txt"
)

for item in "${items[@]}"; do
    if [ -e "$item" ]; then
        cp -rf "$item" "$TARGET_DIR/"
        echo "Copied: $item"
    else
        echo "Warning: $item not found, skipped"
    fi
done

if ./makeself/makeself.sh --nox11 --quiet --noprogress "$TARGET_DIR" "$OUTPUT_FILE" "MCU sign cli tool" ./main.sh; then
    rm -rf "$TARGET_DIR"
    echo "Packaging done. Output file: $OUTPUT_FILE"
else
    echo "Packaging failed, $TARGET_DIR kept for debugging."
fi
