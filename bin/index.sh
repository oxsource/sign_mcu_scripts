#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
option="$1"
path="$2"
if [[ "$path" != /* ]]; then
    path="$(pwd)/$path"
fi
$SCRIPT_DIR/sign-cli.bin -- "$option" "$path" | grep -vE '^(Verifying archive integrity|Uncompressing MCU)'
