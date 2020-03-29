#!/bin/bash

# Install jq (move it to pre-req.sh )
 sudo apt update && sudo apt install jq -y


# Download etcd binaries

wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"

# untar the binary

tar -xvf etcd-v3.4.0-linux-amd64.tar.gz

#Move to /usr/local/bin 

sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/

# Configure the etcd Server

sudo mkdir -p /etc/etcd /var/lib/etcd

sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

# Get the private data from within the VM

INTERNAL_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/?api-version=2017-08-01"  | jq -r '.[] | .ipv4.ipAddress[0].privateIpAddress')

#assign Hostname to ETCD_NAME

ETCD_NAME=$(hostname -s)

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master-0=https://10.240.0.10:2380,master-1=https://10.240.0.11:2380,master-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF









sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd


# Verification

sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem