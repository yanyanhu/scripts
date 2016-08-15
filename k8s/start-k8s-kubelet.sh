#!/bin/bash


KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
kubelet_port=10250
apiserver_ip=127.0.0.1
apiserver_port=8080
log_level=3

$KUBE_HOME/kubelet \
--logtostderr=false \
--v=${log_level} \
--allow-privileged=false \
--log_dir=/var/log/kubernetes \
--address=0.0.0.0 \
--port=${kubelet_port} \
--hostname_override=${apiserver_ip} \
--api_servers=http://${apiserver_ip}:${apiserver_port} \
--cpu-cfs-quota=false \
--cluster-dns=8.8.8.8 \
> /dev/null 2>&1 &	
