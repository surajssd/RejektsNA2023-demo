#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Compulsory env vars
: "${KBS_RESOURCE_ID}:?"
: "${TARGET_FOLDER}:?"
: "${ENCRYPTED_FILE_URL}:?"

export SYMMETRIC_KEY_FILE=${SYMMETRIC_KEY_FILE:-/tmp/key.bin}

# TODO: Check if the KBS_RESOURCE_ID starts with / if not then fail.

CDH_BASE_URL="http://127.0.0.1:8006/cdh/resource"
RESOURCE_URL="${CDH_BASE_URL}${KBS_RESOURCE_ID}"

curl -L -o "${SYMMETRIC_KEY_FILE}" "${RESOURCE_URL}"
echo "Attestation successful. Key saved at ${SYMMETRIC_KEY_FILE}"

# Download the data.
echo "Downloading encrypted file ..."
tmp_file="$(mktemp)"
curl -L -o "${tmp_file}" "${ENCRYPTED_FILE_URL}"

export SOURCE_ENCRYPTED_FILE="${tmp_file}"
./decrypt-folder.sh
