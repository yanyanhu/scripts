# Fabric Deployment on K8S with TLS Enabled

## Prologue
This document briefly introduces how to deploy a simple Hyperledge Fabric network into k8s cluster with the TLS enabled. The original idea is mainly from the following developer tutorial contributed by IBM: https://developer.ibm.com/tutorials/hyperledger-fabric-kubernetes-cluster-tls-rhel/

This tutorial is based on the environment of ```Ubuntu18.04``` and ```Fabirc 1.1.0```. But it should also be applicable for other Linux distributions and Fabric 1.x release.

## Table of Content
- Install k8s cluster
- Configure CoreDNS to support TLS communication for Fabirc
- Deploy Fabric network and test

## Install k8s cluster
The installation of a test k8s cluster can be done following the [official document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/). Here we just list all those required steps for setting up a single-machine k8s cluster using ```kubeadm```.

#### Install Docker Runtime
Both Docker-CE or Docker.io will work. Please refer to the [official document](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for more detail.

#### Install kubeadm
```
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```
More customized installation, please refer to the [install-kubeadm document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

#### Disable the swap
```
1. Identify configured swap devices and files with cat /proc/swaps.
2. Turn off all swap devices and files with swapoff -a.
3. Remove any matching reference found in /etc/fstab.
4. Optional: Destroy any swap devices or files found in step 1 to prevent their reuse. Due to your concerns about leaking sensitive information, you may wish to consider performing some sort of secure wipe.
```

#### Setup the master node
Running `kubeadm init <args>` to setup the master node. The following cmd will setup master with ```Calico``` network addon.
```
kubeadm init --apiserver-advertise-address=$HOSTIP --pod-network-cidr=192.168.0.0/16
```
For more customized setup, please refer to the [official document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node)

#### Configure kubectl
Running the following cmds to make kubectl works(as cluster admin).
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Alternatively, if you are the ```root``` user, you can run:
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

#### Configure master node to work as worker node[optional]
By default, your cluster will not schedule pods on the control-plane node for security reasons. For a single-machine Kubernetes cluster, run the following cmds to remove the constraints:
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
For this tutorial, this step is **REQUIRED** since we are using a single-machine k8s cluster.

#### Let more nodes join[optional]
Simply running the following cmds in all worker nodes to let them join the cluster. All those cluster information can be found in the output of the previous running of `kubeadm init <args>`.
```
kubeadm join <master-ip>:<master-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
For this tutorial, this step is **NOT REQUIRED** since we are using a single-machine k8s cluster.

**Note**: After this step, you should be able to list all worker nodes by running ```kubectl get nodes```. However, all of them should be in `Unready` status since the pod network addon has not been installed yet.

#### Install Pod network addon
Running the following cmd to install ```Calico``` addon. For other options, please refer to the [official document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network).
```
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
```
After this step, all worker nodes should have switched to `Ready` status.

Now you should have a single-machine k8s cluster sufficient for continuing the left parts of this tutorial.
