#!/bin/bash
# meta-installscript.sh

set -e

# Make all scripts executable (in case they are not)
chmod +x install_terra.sh install_docker.sh install_jenkins.sh install_nexus.sh install_sonaq.sh install_argocd.sh

# 1. Terraform, AWS CLI, kubectl, eksctl

echo "[1/6] Installing Terraform, AWS CLI, kubectl, eksctl..."
./install_terra.sh

echo "[2/6] Installing Docker..."
./install_docker.sh

echo "[3/6] Installing Jenkins..."
./install_jenkins.sh

echo "[4/6] Installing Nexus..."
./install_nexus.sh

echo "[5/6] Installing SonarQube..."
./install_sonaq.sh

echo "[6/6] Installing ArgoCD..."
./install_argocd.sh

echo "\nAll installations completed successfully!"