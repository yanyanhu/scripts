#!/bin/bash

export KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
export ETCD_SERVER=9.186.107.219
export KUBE_APISERVER=9.186.107.219
export KUBE_DNS=9.186.107.219
export NODE_IP=$1

echo "starting proxy..."
./start-k8s-proxy.sh
sleep 3

echo "starting kubelet..."
./start-k8s-kubelet.sh
sleep 3

echo "done."
