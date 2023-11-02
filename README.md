# Image Processing Model Inferencing in Confidential Containers - Rejekts NA 2023

This repository contains the scripts and commands to deploy a confidential model for image processing in Confidential Containers.

## Deploy Infrastructure

We will deploy the Azure Kubernetes Service (AKS), Cloud API Adaptor (CAA) and Key Broker Service (KBS) other infrastructure ready before deploying the actual confidential application.

### Deploy AKS

```bash
export AZURE_RESOURCE_GROUP=REPLACE_ME
export SSH_KEY=REPLACE_ME
make deploy-aks
```

Copy the value of `CLUSTER_SPECIFIC_DNS_ZONE` from the above command's output and export it as an environment variable:

```bash
export CLUSTER_SPECIFIC_DNS_ZONE=REPLACE_ME
```

### Deploy KBS with Image Encryption / Decryption Symmetric Key

```bash
make deploy-kbs
```

### Deploy CAA

```bash
make deploy-caa
```

## Model Deployment

### Generate Key

```bash
export KEY_NAME=key.bin
echo "This is my key" > $KEY_NAME
```

### Upload Key to KBS

```bash
# This can be downloaded from within the pod: curl http://127.0.0.1:8006/cdh/resource/default/keys/key.bin
kubectl -n coco-tenant create secret generic keys --from-file=$KEY_NAME --dry-run=client -o yaml | kubectl apply -f -
kubectl -n coco-tenant rollout restart deploy/kbs
export KBS_RESOURCE_ID="/default/keys/$KEY_NAME"
```

### Encrypt Model & Upload to Azure Storage

Assuming you have done the required work to train the model and have the model files ready. Copy the model directory to [`app/models`](app/models). For the sake of this demo I have a default model copied already. Once copied you can encrypt the model using the following command:

```bash
make encrypt-model-and-upload
```

Export the environment variable `ENCRYPTED_FILE_URL` from the output of the above command.

### Deploy Triton

```bash
make deploy-triton-server
```

### Download Triton Client

```bash
make download-triton-client
```

### Running a sample inference

```bash
cd python-triton-client/src/python/examples
TRITON_SERVER_URL=$(kubectl -n default get ing triton -o jsonpath='{.spec.rules[0].host}')

curl -L -o /tmp/cat https://unsplash.com/photos/75715CVEJhI/download?ixid=M3wxMjA3fDB8MXxhbGx8fHx8fHx8fHwxNjk4Nzc5OTc1fA&force=true
python image_client.py \
    -m densenet_onnx \
    -u $TRITON_SERVER_URL \
    -c 3 -s INCEPTION /tmp/cat

curl -L -o /tmp/dog https://unsplash.com/photos/2l0CWTpcChI/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8Nnx8ZG9nfGVufDB8fHx8MTY5ODc2NjYyN3ww&force=true
python image_client.py \
    -m densenet_onnx \
    -u $TRITON_SERVER_URL \
    -c 3 -s INCEPTION /tmp/dog
```

## Troubleshooting

When running any make target if you a script fails with cryptic error then to debug what's going on, export the following environment variable and re-run the make target:

```bash
export DEBUG=true
```

## Recording

[![Alt text](https://img.youtube.com/vi/8NtBJst10Lg/0.jpg)](https://www.youtube.com/watch?v=8NtBJst10Lg)
