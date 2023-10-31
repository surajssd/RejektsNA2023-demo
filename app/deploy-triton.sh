#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Compulsory env vars
: "${KBS_RESOURCE_ID}:?"
: "${ENCRYPTED_FILE_URL}:?"
: "${CLUSTER_SPECIFIC_DNS_ZONE}:?"

envsubst <app/deployment.yaml | kubectl apply -f -
echo "Waiting for the server to be ready..."
kubectl wait --for=condition=Ready --timeout=600s deploy/triton
