#!/bin/bash
#
# Install aws and eb cli
# source: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-linux.html
#

echo "==== Start ===="

# Use pip to install the EB and AWS CLIs
pip install awsebcli --upgrade --user
pip install awscli --upgrade --user

# Add the executable path, ~/.local/bin, to your PATH variable.
export LOCAL_PATH=~/.local/bin
echo "export PATH=$LOCAL_PATH:$PATH" >> ~/.bashrc
source ~/.bashrc

# Verify that the EB and AWS CLIs installed correctly.
eb --version
aws --version

echo "==== Done ===="
