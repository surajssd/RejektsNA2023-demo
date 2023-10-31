#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Get the base directory of the script.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

SOURCE_FOLDER=${SOURCE_FOLDER:-"${BASE_DIR}/models"}

# Check if the source folder exists.
if [ ! -d "${SOURCE_FOLDER}" ]; then
    echo "The source folder does not exist at: ${SOURCE_FOLDER}"
    exit 1
fi

TARGET_ENCRYPTED_FILE="${TARGET_ENCRYPTED_FILE:-${SOURCE_FOLDER}.tar.gz.enc}"
SYMMETRIC_KEY_FILE="${SYMMETRIC_KEY_FILE:-key.bin}"

# Make a tar file of the provided folder.
tmp_file="$(mktemp).tar.gz"

# NOTE: Before tarring change into the directory so that we don't tar the absolute path.
tar -czf "${tmp_file}" -C "$(dirname $SOURCE_FOLDER)" "$(basename $SOURCE_FOLDER)"

# Generate the symmetric key if it does not exists.
if [ ! -f "${SYMMETRIC_KEY_FILE}" ]; then
    echo "Generating symmetric key at: ${SYMMETRIC_KEY_FILE}"
    openssl rand 128 >"${SYMMETRIC_KEY_FILE}"
else
    echo "Using existing symmetric key at: ${SYMMETRIC_KEY_FILE}"
fi

# Encrypt the tar file.
encrypted_tmp_file="${tmp_file}.enc"
openssl enc \
    -aes-256-cbc -md sha512 -pbkdf2 -iter 250000 -salt \
    -in "${tmp_file}" \
    -out "${encrypted_tmp_file}" \
    -pass file:"${SYMMETRIC_KEY_FILE}"

rm "${tmp_file}"
mv "${encrypted_tmp_file}" "${TARGET_ENCRYPTED_FILE}"
echo "Encrypted folder stored at ${TARGET_ENCRYPTED_FILE}"
