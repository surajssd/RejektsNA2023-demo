#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Get the base directory of the models directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export TARGET_ENCRYPTED_FILE="${TARGET_ENCRYPTED_FILE:-${BASE_DIR}/models.tar.gz.enc}"

${BASE_DIR}/encrypt-folder.sh
${BASE_DIR}/upload-to-azure.sh
