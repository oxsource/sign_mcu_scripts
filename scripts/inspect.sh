#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <signed_file_path>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

FILESIZE=$(stat -c%s "$FILE")

if [ "$FILESIZE" -lt 16 ]; then
    echo "Error: File too small to contain valid signature metadata."
    exit 1
fi

MAGIC=$(dd if="$FILE" bs=1 skip=$((FILESIZE - 4)) count=4 2>/dev/null)

if [ "$MAGIC" != "IMCU" ]; then
    echo "Error: Invalid magic value. Expected 'IMCU', got '$(echo -n "$MAGIC" | xxd -p)'"
    exit 1
fi

echo "✅ Magic value check passed: 'IMCU'"

SIGLEN_HEX=$(dd if="$FILE" bs=1 skip=$((FILESIZE - 8)) count=4 2>/dev/null | hexdump -v -e '4/1 "%02X"')
SIGLEN=$((16#$SIGLEN_HEX))

echo "🔢 Signature length (siglen): $SIGLEN bytes"

if [ "$SIGLEN" -ge "$FILESIZE" ]; then
    echo "Error: Signature length exceeds file size."
    exit 1
fi

SIG_OFFSET=$((FILESIZE - 16 - SIGLEN))

echo "📍 Signature located at offset: $SIG_OFFSET"

echo "📦 Dumping signature ($SIGLEN bytes):"
dd if="$FILE" bs=1 skip=$SIG_OFFSET count=$SIGLEN 2>/dev/null | hexdump

echo "📋 Dumping tail metadata (last 16 bytes):"
dd if="$FILE" bs=1 skip=$((FILESIZE - 16)) count=16 2>/dev/null | hexdump -C

