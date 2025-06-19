#!/bin/bash
# dns-mapping.sh

# Get Load Balancer DNS name
LB_DNS=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Load Balancer DNS: $LB_DNS"

# Instructions for GoDaddy DNS setup
echo "GoDaddy DNS Configuration Instructions:"
echo "1. Log in to your GoDaddy account"
echo "2. Navigate to your domain's DNS settings"
echo "3. Add a CNAME record with:"
echo "   - Host: argocd (or your preferred subdomain)"
echo "   - Points to: $LB_DNS"
echo "4. Save changes and wait for DNS propagation (up to 48 hours)"