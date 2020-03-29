!/bin/sh

set -x

apk update
apk add curl git python3 py-pip

curl https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_linux_amd64.zip -o terraform.zip
unzip terraform.zip
