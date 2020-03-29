#K8s Setup on Azure

## Tools:
Terraform: To provision infrastructure.
Dockerfile: To setup Azure CLI container and install terraform
docker-compose: To start docker container with environment variables and Terraform config directory as a Volume. 
open-ssl to generate certificates.

## Azure Setup

Create Azure Service Principal with contributor Role to run Terraform.
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<Azure_Subscription_ID>"

Export Azure Service Principal credentials

export ARM_CLIENT_ID=<Azure_CLIENT_ID>
export ARM_CLIENT_SECRET=<Azure_CLIENT_SECRET>
export ARM_SUBSCRIPTION_ID=<Azure_Subscription_ID>
export ARM_TENANT_ID=<Azure_Tenant_ID>

Run docker-compose up after exporting the above environment values.

Known issue : docker-compose is stuck at Attaching to <container>. Ctrl+C and then start docker container

```bash
docker start <container-name>
```

then use docker exec to connect to the container
```bash
docker exec -it <container-name> sh
```
## Running Terraform

Once you attach to the container, cd into Terraform folder:

```bash
export TF_VAR_subscription_id=ARM_SUBSCRIPTION_ID
export ARM_CLIENT_SECRET=<Azure_CLIENT_SECRET>
export ARM_SUBSCRIPTION_ID=<Azure_Subscription_ID>
export ARM_TENANT_ID=<Azure_Tenant_ID>
```

`cd Terraform`
Initialize Terraform
`terraform init`
Run Terraform plan
`terraform plan`
Apply the configuration
`terraform apply`

## Setting up K8s with kubeadm

After installing docker, kubectl, kubeapi, kubeadm

- Initialize kubeadm

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

- Configure kubectl

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Install calico

```bash
kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml
```

## PKI

### CA Certificate

Genreate a key for ca

```bash
openssl genrsa -out ca.key
```

Create csr

```bash
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
```

Generate ca certificate with the abvoe key and certificate.

```bash
openssl x509 -req -in ca.csr -signkey ca.key  -CAcreateserial -out ca.crt -days 750
```

ca.crt being the public key needs to be copied in multiple and ca.key needs to be copied in master nodes as master nodes acts as CA server.

### Admin User Client Certificate

Generate a key for admin

```bash
openssl genrsa -out admin.key 2048
```

Generate a CSR

```bash
openssl -req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
```

Generate a Certificate

```bash
openssl x509 -req -in admin.csr -signkey admin.key -CA ca.crt -CAkey ca.key  -CAcreateserial -out admin.crt -days 750
```

### Kubelet client certificates

### kube-controller-manager client certificates

Generate a private key

```bash
openssl genrsa -out kube-controller-manager.key 2048
```

Generate a CSR

```bash
openssl req -new -key kube-controller-manager -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
```

Note: prefix system to the CN

Generate a Certificate

```bash
openssl x509 -req -signkey kube-controller-manager.key -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key  -CAcreateserial -out kube-controller-manager.crt -days 750
```

### kube-proxy client certificate

Generate a private key

```bash
openssl genrsa -out kube-proxy.key 2048

openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr

openssl x509 -req -in kube-proxy.csr -signkey kube-proxy.key -CA ca.crt -CAkey ca.key  -CAcreateserial -out kube-proxy.crt -days 750

```

### kube-scheduler client certificates

```
openssl genrsa -out kube-scheduler 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -signkey kube-scheuduler.key -CA ca.crt -CAkey ca.key  -CAcreateserial -out kube-scheduler.crt -days 750
```


### kube-api server certificate

kube-api server needs to have Subject alt names passed so a file needs to be created to pass to `openssl req ....` to create csr.

Contents of the file, name it as `openssl.cnf` 

```bash
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 192.168.5.11
IP.3 = 192.168.5.12
IP.4 = 192.168.5.30
IP.5 = 127.0.0.1
```

Generate a Key 

```bash
openssl genrsa -out kube-apiserver.key 2048
```

Generate CSR with openssl.cnf file to add alternate names

```bash
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 750
```

Generate crt with the above csr

```bash
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 750
```



### The Service Account Key Pair

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as describe in the managing service accounts documentation.

Generate the service-account certificate and private key:

```bash
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 750
```