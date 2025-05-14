#!/bin/bash

# Fetch and base64 encode secrets
USER_B64=$(pass dev/k8s/demo/mongo-user | tr -d '\n'| base64)
PASSWORD_B64=$(pass dev/k8s/demo/mongo-password | tr -d '\n' | base64)

# Export variables for envsubst
export USER_B64
export PASSWORD_B64

# Substitute and write to output file
envsubst < mongo-secret.template.yaml > mongo-secret.yaml
echo "Secret written to mongo-secret.yaml"
