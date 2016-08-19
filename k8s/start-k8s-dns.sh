#!/bin/bash

KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
log_level=3

$KUBE_HOME/kube-dns \
--log_dir=/var/log/kubernetes \
--v=${log_level} \
> /dev/null 2>&1 &
