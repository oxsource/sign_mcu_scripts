#!/bin/bash

USERNAME=""
IP="172.22.198.208"
REMOTE_PATH="~/projects/qcom_van233_s1/kit/mcu/"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u)
            USERNAME="$2"
            shift 2
            ;;
        --ip)
            IP="$2"
            shift 2
            ;;
        --path)
            REMOTE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 -u <username> [--ip <ip>] [--path <remote_path>]"
            exit 1
            ;;
    esac
done

if [ -z "$USERNAME" ]; then
    echo "Error: Username is required. Use -u <username>"
    exit 1
fi

TARGET="${USERNAME}@${IP}"
TARGET_PATH="${TARGET}:${REMOTE_PATH}"

echo "🧹 Cleaning remote path: ${TARGET}:${REMOTE_PATH}"
ssh "$TARGET" "rm -rf ${REMOTE_PATH:?}/*"

echo "📤 Sync files to: $TARGET_PATH"
scp -r ./secrets/automotive_mcu_public.pem "$TARGET_PATH"
scp -r ./bin/* "$TARGET_PATH"

echo ""
echo "✅ Sync done"