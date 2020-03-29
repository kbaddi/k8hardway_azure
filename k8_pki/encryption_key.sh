#!/bin/bash

export DEBIAN_FRONTEND="noninteractive" 
export resource_group="k8hardway-RG"

# The Encryption Key

# Generate a Random key


ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc: 
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF


for instance in master-0 master-1 master-2; do
    EXTERNAL_IP=$(az vm show -d -g $resource_group -n $instance  --query publicIps -o tsv)
    scp encryption-config.yaml kadmin@${EXTERNAL_IP}:~/
done
