#!/bin/bash

#KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
apiserver_port=8080
etcd_server_ip=$ETCD_SERVER
etcd_client_port=2379
service_ip_range=$SERVICE_IP_RANGE
log_level=3

$KUBE_HOME/kube-apiserver \
--service-cluster-ip-range=${service_ip_range} \
--insecure-bind-address=0.0.0.0 \
--insecure-port=${apiserver_port} \
--log_dir=/var/log/kubernetes \
--v=${log_level} \
--logtostderr=false \
--etcd_servers=http://${etcd_server_ip}:${etcd_client_port} \
--allow_privileged=false \
> /dev/null 2>&1 &
