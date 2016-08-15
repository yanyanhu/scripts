#!/bin/bash

KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
apiserver_ip=127.0.0.1
apiserver_port=8080
log_level=3

$KUBE_HOME/kube-proxy \
--logtostderr=false \
--v=${log_level} \
--log_dir=/var/log/kubernetes \
--hostname_override=${apiserver_ip} \
--master=http://${apiserver_ip}:${apiserver_port} \
> /dev/null 2>&1 &
