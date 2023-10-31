#!/bin/bash

set -euo pipefail
# Check if the DEBUG env var is set to true
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

# Use the image name provided by the user or use the default one.
IMAGE_NAME="${IMAGE_NAME:-quay.io/surajd/inference-model-setup}"
TIMESTAMP=rejektsna23-"$(date '+%Y-%m-%d-%H-%M-%S')"

docker build --push -t "${IMAGE_NAME}:latest" -t "${IMAGE_NAME}:${TIMESTAMP}" -f Dockerfile .

echo "Image available at:"
echo "${IMAGE_NAME}:latest"
echo "${IMAGE_NAME}:${TIMESTAMP}"
