#!/bin/bash
#
# This script install docker and docker-compose in aws linux
#

# Install Docker
echo "========    Install Docker    ========"
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info

# Install docker-compose
echo "========    Install docker-compose    ========"
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
