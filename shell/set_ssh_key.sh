#!/bin/bash

USER=$1
IP=$2

ssh $USER@$IP 'mkdir -p ~/.ssh/'
scp ~/.ssh/id_rsa.pub $USER@$IP:~/.ssh/id_rsa.pub.tmp
ssh $USER@$IP 'cat ~/.ssh/id_rsa.pub.tmp >> ~/.ssh/authorized_keys'
