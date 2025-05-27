#!/bin/bash

PRIVATE_KEY="secrets/automotive_mcu_private.pem"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_file>"
    exit 1
fi

ORIGINAL_FILE="$1"

if [ ! -f "$ORIGINAL_FILE" ]; then
    echo "Error: File '$ORIGINAL_FILE' does not exist."
    exit 1
fi

SIGNED_FILE="${ORIGINAL_FILE}.signed"

# copy on write
cp "$ORIGINAL_FILE" "$SIGNED_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy to '$SIGNED_FILE'"
    exit 1
fi

# check file tail magic
TAIL_MAGIC=$(tail -c 4 "$SIGNED_FILE")
if [ "$TAIL_MAGIC" = "IMCU" ]; then
    echo "Error: Target file '$SIGNED_FILE' already appears to be signed (ends with 'IMCU')"
    exit 1
fi

SIG_FILE="sigbin.bin"

# 1. sign with RSA + SHA512
openssl dgst -sha512 -sign "$PRIVATE_KEY" -out "$SIG_FILE" "$SIGNED_FILE"
if [ $? -ne 0 ]; then
    echo "Error: OpenSSL signing failed."
    rm -f "$SIG_FILE"
    exit 1
fi

SIGLEN=$(stat -c%s "$SIG_FILE")

# 2. append sigbin
dd if="$SIG_FILE" of="$SIGNED_FILE" bs=1 oflag=append conv=notrunc status=none

# 3. append 8 bytes reverse data(fill full zero)
dd if=/dev/zero bs=1 count=8 of="$SIGNED_FILE" oflag=append conv=notrunc status=none

# 4. append 4 bytes for siglen(big-endian)
printf "%08X" "$SIGLEN" | xxd -r -p | dd of="$SIGNED_FILE" bs=1 oflag=append conv=notrunc status=none

# 5. append magic "IMCU"
echo -n "IMCU" | dd of="$SIGNED_FILE" bs=1 oflag=append conv=notrunc status=none

# clean up
rm -f "$SIG_FILE"

echo "✅ Success: Signed file created as '$SIGNED_FILE'"

