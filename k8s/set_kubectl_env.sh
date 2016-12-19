#!/bin/bash

APISERVER_IP=20.20.104.1
APISERVER_PORT=8080

kubectl --server $APISERVER_IP:$APISERVER_PORT config set-cluster default-cluster --server=$APISERVER_IP:$APISERVER_PORT --insecure-skip-tls-verify=true
kubectl config set-context default-context --cluster=default-cluster
kubectl config set current-context default-context
