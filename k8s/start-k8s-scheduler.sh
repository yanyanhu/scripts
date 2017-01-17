#!/bin/bash

#KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
apiserver_ip=$KUBE_APISERVER
apiserver_port=8080
log_level=3

$KUBE_HOME/kube-scheduler \
--master=${apiserver_ip}:${apiserver_port} \
--v=${log_level} \
--log_dir=/var/log/kubernetes \
> /dev/null 2>&1 &
