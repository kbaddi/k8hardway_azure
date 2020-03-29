#!/bin/bash


# Install OS dependencies

sudo apt-get update &&  sudo apt-get -y install socat conntrack ipset

#By default the kubelet will fail to start if swap is enabled. It is recommended that swap be disabled to ensure Kubernetes can provide proper resource allocation and quality of service.

# Verify if swap is enabled:

sudo swapon --show

# If output is empthy then swap is not enabled. If swap is enabled run the following command to disable swap immediately:

sudo swapoff -a

# Download and Install Worker Binaries

wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
  https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet



POD_CIDR=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/?api-version=2017-08-01" | jq -r .tags | cut -d ":" -f 2)
