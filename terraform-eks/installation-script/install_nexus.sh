#!/bin/bash
# setup-nexus.sh

# Create directory for Nexus data
sudo mkdir -p /opt/nexus-data
sudo chown -R 200:200 /opt/nexus-data

# Run Nexus container
docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v /opt/nexus-data:/nexus-data \
  sonatype/nexus3:latest

# Wait for Nexus to start
sleep 120

# Get initial admin password
echo "Nexus initial admin password:"
docker exec nexus cat /nexus-data/admin.password