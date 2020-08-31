#!/bin/bash
# 
# Self-contained eb cli installation
#
# Reference: https://github.com/aws/aws-elastic-beanstalk-cli-setup
#


echo "==== Start ===="

# Install prerequisites
apt-get install build-essential zlib1g-dev libssl-dev libncurses-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev

# Close installer repository
git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git

# Run installer
./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer

# Include `eb` to the $PATH
echo 'export PATH="/root/.ebcli-virtual-env/executables:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

# Verify that the EB and AWS CLIs installed correctly.
eb --version

echo "==== Done ===="
