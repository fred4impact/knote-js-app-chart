# Provisioning a Production-Ready EKS Cluster on AWS with Terraform

## Overview

This infrastructure-as-code setup provisions a robust AWS EKS (Elastic Kubernetes Service) cluster using Terraform. It automates the creation of all necessary AWS resources, including networking, security, IAM roles, and the EKS cluster itself.

## What’s Included

- **VPC** with public subnets across two availability zones for high availability.
- **Internet Gateway** and **Route Tables** for internet connectivity.
- **Security Groups** for both the EKS control plane and worker nodes.
- **EKS Cluster** with a managed node group (2–3 EC2 instances).
- **IAM Roles and Policies** for secure and proper access management.

## Why Use This Setup?

- **Scalable**: Easily adjust node group size for your workload.
- **Secure**: Follows AWS best practices for IAM and networking.
- **Automated**: Infrastructure is reproducible and version-controlled.

## Next Steps

- Deploy your workloads to the EKS cluster.
- Integrate with CI/CD pipelines.
- Enhance security and monitoring as needed.
