#!/bin/bash

#KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
log_level=3
apiserver_ip=$KUBE_APISERVER
apiserver_port=8080

$KUBE_HOME/kube-dns \
--kube-master-url=http://${apiserver_ip}:${apiserver_port} \
--log_dir=/var/log/kubernetes \
--v=${log_level} \
> /dev/null 2>&1 &
