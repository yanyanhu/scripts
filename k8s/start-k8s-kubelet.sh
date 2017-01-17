#!/bin/bash


#KUBE_HOME=/home/huyanyan/k8s/kubernetes/_output/local/bin/linux/amd64
kubelet_port=10250
apiserver_ip=$KUBE_APISERVER
apiserver_port=8080
dns_ip=$KUBE_DNS
node_ip=$NODE_IP
log_level=3

$KUBE_HOME/kubelet \
--logtostderr=false \
--v=${log_level} \
--allow-privileged=false \
--log_dir=/var/log/kubernetes \
--address=0.0.0.0 \
--port=${kubelet_port} \
--hostname_override=${node_ip} \
--api_servers=http://${apiserver_ip}:${apiserver_port} \
--cpu-cfs-quota=false \
--cluster-dns=${dns_ip} \
--cluster-domain=cluster.local \
--node-ip=${node_ip} \
--cadvisor-port=4194 \
> /dev/null 2>&1 &
