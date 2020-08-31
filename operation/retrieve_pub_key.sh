#!/bin/bash
#
# Retrieving the public key for your key pair
#

ssh-keygen -y -f /path_to_key_pair/my-key-pair.pem
chmod 400 my-key-pair.pem
