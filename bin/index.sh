#!/bin/bash

if [ $# -lt 2 ]; then
    echo "usage: $0 <--sign|--inspect> <path>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
option="$1"
path="$2"
if [[ "$path" != /* ]]; then
    path="$(pwd)/$path"
fi
$SCRIPT_DIR/sign-cli.bin -- "$option" "$path" | grep -vE '^(Verifying archive integrity|Uncompressing MCU)'
