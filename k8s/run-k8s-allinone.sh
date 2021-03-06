#!/bin/bash

export KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
export ETCD_SERVER=9.186.107.219
export KUBE_APISERVER=9.186.107.219
export KUBE_DNS=9.186.107.219
export NODE_IP=9.186.107.219

echo "starting apiserver..."
./start-k8s-apiserver.sh
sleep 3

echo "starting controller-manager..."
./start-k8s-controller-manager.sh
sleep 3

echo "starting scheduler..."
./start-k8s-scheduler.sh
sleep 3

echo "starting proxy..."
./start-k8s-proxy.sh
sleep 3

echo "starting dns..."
./start-k8s-dns.sh
sleep 3

echo "starting kubelet..."
./start-k8s-kubelet.sh
sleep 3

echo "done."
