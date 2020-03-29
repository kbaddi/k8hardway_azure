#Dockerfile to run Terraform with environment variables

FROM mcr.microsoft.com/azure-cli
WORKDIR /
RUN apk update && apk add curl git && \
    curl https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/bin
WORKDIR /Terraform  
ENTRYPOINT [ "/bin/bash" ]