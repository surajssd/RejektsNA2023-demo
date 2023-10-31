#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Compulsory env vars
: "${AZURE_RESOURCE_GROUP}:?"
: "${TARGET_ENCRYPTED_FILE}:?"

AZURE_REGION=${AZURE_REGION:-eastus}

# Remove dashes, dots and underscores from the resource group name
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-"$(echo $AZURE_RESOURCE_GROUP | tr -d '[:punct:]')enc"}
STORAGE_CONTAINER_NAME="encrypted"

# Create the Azure Resource Group
az group create \
    --name "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}"

# Create the Azure Storage Account which allows public anonymous access
az storage account create \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --sku Standard_LRS \
    --allow-blob-public-access true

# Create the Azure Storage Container
az storage container create \
    --name "${STORAGE_CONTAINER_NAME}" \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --public-access blob

# Upload the encrypted file to Azure Storage
BLOB_NAME=$(basename "${TARGET_ENCRYPTED_FILE}")
az storage blob upload \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --container-name "${STORAGE_CONTAINER_NAME}" \
    --overwrite \
    --name "${BLOB_NAME}" \
    --file "${TARGET_ENCRYPTED_FILE}"

echo "Run the following command before deploying the model:"
echo "export ENCRYPTED_FILE_URL=https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${STORAGE_CONTAINER_NAME}/${BLOB_NAME}"
