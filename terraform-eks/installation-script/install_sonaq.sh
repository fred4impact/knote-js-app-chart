#!/bin/bash
# setup-sonarqube.sh

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Create directory for SonarQube data
sudo mkdir -p /opt/sonarqube/data /opt/sonarqube/extensions /opt/sonarqube/logs
sudo chown -R 999:999 /opt/sonarqube

# Run SonarQube container
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -v /opt/sonarqube/data:/opt/sonarqube/data \
  -v /opt/sonarqube/extensions:/opt/sonarqube/extensions \
  -v /opt/sonarqube/logs:/opt/sonarqube/logs \
  sonarqube:lts-community

echo "SonarQube is running at http://$(curl -s ifconfig.me):9000"