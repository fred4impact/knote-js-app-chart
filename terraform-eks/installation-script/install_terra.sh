#!/bin/bash
# eks-cluster-setup.sh

# Install prerequisites
sudo snap install terraform --classic

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws configure

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# # Create EKS cluster
# eksctl create cluster --name=EKS-1 \
#   --region=ap-south-1 \
#   --zones=ap-south-1a,ap-south-1b \
#   --without-nodegroup

# # Enable OpenID Connect
# eksctl utils associate-iam-oidc-provider \
#   --region ap-south-1 \
#   --cluster EKS-1 \
#   --approve

# # Create Node Group
# eksctl create nodegroup --cluster=EKS-1 \
#   --region=ap-south-1 \
#   --name=node2 \
#   --node-type=t3.medium \
#   --nodes=3 \
#   --nodes-min=2 \
#   --nodes-max=4 \
#   --node-volume-size=20 \
#   --ssh-access \
#   --ssh-public-key=DevOps \
#   --managed \
#   --asg-access \
#   --external-dns-access \
#   --full-ecr-access \
#   --appmesh-access \
#   --alb-ingress-access