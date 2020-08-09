#!/bin/bash
# Running unit test

set -e

echo "------ Installing dependencies for unit test..."

# Install necessary libraries
apt-get update && apt-get --assume-yes install build-essential python3-dev python3-pip libsnappy-dev libcurl4-openssl-dev libssl-dev unixodbc-dev curl libpq-dev

# Install any needed packages specified in requirements.txt
mkdir logs && pip3 install -r requirements.txt && pip3 install --no-cache-dir --compile --install-option="--with-openssl" pycurl

echo "------ Define environment variables required"

echo "------ Running unit test..."

# Run unit test
echo "------ python3 -m tests.tests"
python3 -m tests.tests

exit 0
