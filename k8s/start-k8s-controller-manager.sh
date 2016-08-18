#!/bin/bash

KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
apiserver_ip=172.17.42.1
apiserver_port=8080
log_level=3

$KUBE_HOME/kube-controller-manager  \
--v=${log_level} \
--logtostderr=false \
--log_dir=/var/log/kubernetes \
--master=${apiserver_ip}:${apiserver_port} \
> /dev/null 2>&1 &
