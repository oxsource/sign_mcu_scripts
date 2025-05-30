#!/bin/bash

if [ $# -lt 2 ]; then
    echo "usage: $0 <--sign|--inspect> <path>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
option="$1"
path="$2"

case "$option" in
    --sign)
        $SCRIPT_DIR/scripts/sign.sh "$path"
        ;;
    --inspect)
        $SCRIPT_DIR/scripts/inspect.sh "$path"
        ;;
    *)
        echo "unknown option: $option"
        exit 1
        ;;
esac
