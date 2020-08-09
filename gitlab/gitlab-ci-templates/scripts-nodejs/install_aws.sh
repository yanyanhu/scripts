#!/bin/bash

set -e

# Install aws commandline
mkdir -p /app && export WORK_DIR=$(pwd) && cd /app && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip > /dev/null && ./aws/install && cd $WORK_DIR
apt-get update -y
apt-get install -y groff
aws --version

exit 0
