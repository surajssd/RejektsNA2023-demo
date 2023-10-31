#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Fail script if the env var is not exported.
: "${SOURCE_ENCRYPTED_FILE}:?"
: "${SYMMETRIC_KEY_FILE}:?"
: "${TARGET_FOLDER:=.}"

# Check if the source file exists.
if [ ! -f "${SOURCE_ENCRYPTED_FILE}" ]; then
    echo "The source file does not exist at: ${SOURCE_ENCRYPTED_FILE}"
    exit 1
fi

# Check if the symmetric key file exists.
if [ ! -f "${SYMMETRIC_KEY_FILE}" ]; then
    echo "The symmetric key file does not exist at: ${SYMMETRIC_KEY_FILE}"
    exit 1
fi

tmp_file="$(mktemp).tar.gz"
openssl enc \
    -d -aes-256-cbc -md sha512 -pbkdf2 -iter 250000 -salt \
    -in "${SOURCE_ENCRYPTED_FILE}" \
    -out "${tmp_file}" \
    -pass file:"${SYMMETRIC_KEY_FILE}"

# Extract the tar file.
echo "Folder stored in:"
echo
tar xvzf "${tmp_file}" -C "${TARGET_FOLDER}"
