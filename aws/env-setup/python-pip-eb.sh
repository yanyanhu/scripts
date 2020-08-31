#!/bin/bash
#
# source: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-linux.html
#

echo "==== Start ===="

# Determine whether Python is already installed.
python --version

# Install python

# On Red Hat and derivatives, use yum.
sudo yum install python37

# On Debian derivatives, such as Ubuntu, use APT.
#sudo apt-get install python3.7

# On SUSE and derivatives, use zypper.
#sudo zypper install python3-3.7

# To verify that Python installed correctly, open a terminal or shell and run the following command.
python3 --version

# To install pip and the EB CLI
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user

# Add the executable path, ~/.local/bin, to your PATH variable.
ls -a ~
export LOCAL_PATH=~/.local/bin
echo "export PATH=$LOCAL_PATH:$PATH" >> ~/.bashrc
source ~/.bashrc

# Verify that pip is installed correctly.
pip --version

# Use pip to install the EB CLI
pip install awsebcli --upgrade --user

# Verify that the EB CLI installed correctly.
eb --version

# To upgrade to the latest version, run the installation command again.
pip install awsebcli --upgrade --user

echo "==== Done ===="
