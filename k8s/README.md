# How to setup kubernetes cluster in a single node

Step1. Building kubernetes
==========================

$git clone https://github.com/kubernetes/kubernetes.git

$cd kubernetes

$make

Generated bianries will be located in `./_output` directory. For example,
if the building was done in x86 environment, the binaries will be at
`_output/local/bin/linux/amd64/`.


Step2. Running kubernetes service
=================================

Kubernetes consists of multiple different sub-services, e.g. api-server,
kubelet, kube-proxy, kube-dns, etc.. All these sub-services can be run
manually by executing those binaries we built in step1. The following
scripts can be used to run all kubernetes sub-services in a single node
which can be either physical machine or virtual machine.

https://github.com/yanyanhu/scripts/tree/master/k8s

Please change $KUBE_HOME to the path of you own kubernetes folder and also
revise the network related parameters in *.sh scripts, like `apiserver_ip`,
`dns_ip`, `node_ip`, `etcd_server_ip`(you can simpliy change all of them
to the IP address of your host where k8s cluster is deployed in).

The script `run-k8s-allinone.sh` can be used to start all these sub-services.

NOTE: etcd service must be setup before kubernertes cluster is deployed. The
following is an example script to run etcd inside docker:

https://github.com/yanyanhu/scripts/blob/master/docker/etcd_standalone.sh

Also flannel is not configured in this setup progress. So extra work is needed
to enable inter-containers communication cross mutiple hosts.
