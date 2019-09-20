# Fabric Deployment on K8S with TLS Enabled

## Prologue
This document briefly introduces how to deploy a simple Hyperledge Fabric network into k8s cluster with the TLS enabled. The original idea is mainly from the following developer tutorial contributed by IBM: https://developer.ibm.com/tutorials/hyperledger-fabric-kubernetes-cluster-tls-rhel/

This tutorial is based on the environment of ```Ubuntu18.04``` and ```Fabirc 1.1.0```. But it should be applicable for other Linux distributions and Fabric 1.x release as well.

## Table of Content
- Install k8s cluster
- Fabric deployment preparation
- Configure CoreDNS to support TLS communication for Fabirc
- Deploy Fabric network and test

## Install k8s cluster
The installation of a test k8s cluster can be done following the [official document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/). Here we just list all those required steps for setting up a single-machine k8s cluster using ```kubeadm```.

### Install Docker Runtime
Both Docker-CE or Docker.io will work. Please refer to the [official document](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for more detail.

### Install kubeadm
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

### Disable the swap
```
1. Identify configured swap devices and files with cat /proc/swaps.
2. Turn off all swap devices and files with swapoff -a.
3. Remove any matching reference found in /etc/fstab.
4. Optional: Destroy any swap devices or files found in step 1 to prevent their reuse. Due to your concerns about leaking sensitive information, you may wish to consider performing some sort of secure wipe.
```

### Setup the master node
Running `kubeadm init <args>` to setup the master node. The following cmd will setup master with ```Calico``` network addon.
```
kubeadm init --apiserver-advertise-address=$HOSTIP --pod-network-cidr=192.168.0.0/16
```
For more customized setup, please refer to the [official document](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node)

### Configure kubectl
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

### Configure master node to work as worker node
By default, your cluster will not schedule pods on the control-plane node for security reasons. For a single-machine Kubernetes cluster, run the following cmds to remove the constraints:
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
For this tutorial, this step is **REQUIRED** since we are using a single-machine k8s cluster.

### Let more nodes join the cluster[optional]
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

#### Test your Kubernetes installation
Now you should have a single-machine k8s cluster sufficient for continuing the left parts of this tutorial. Running the following cmd to test it:
```
kubectl run my-nginx --image=nginx --replicas=2 --port=80
```
This command creates a deployment for running the NginX web server on two pods and exposing the service on port 80. If the command executes successfully, you should be able to see one deployment and two pods running as shown here:
```
 $ kubectl get deployments
 NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
 my-nginx   2         2         2            2           30s
```

## Fabric deployment preparation
Download the [tutorial example of Fabric deployment](https://github.com/yanyanhu/hlf-k8s-custom-crypto). 

***Note***: all those materials are originally contributed by [hyp0th3rmi4](https://github.com/hyp0th3rmi4/hlf-k8s-custom-crypto).
```
git clone git@github.com:yanyanhu/hlf-k8s-custom-crypto.git
```

This example defines a Fabric network with 2 orgs which each of them has two peer nodes. The orderer will run in solo mode.

Download Fabric docker images. In this tutorial, we are using ```1.1.0``` version release.
```
curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.1.0 1.1.0 1.1.0
```

For more detail about Fabric network configuration and setup, please refer to the [Fabric official document](https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html)


## Configure CoreDNS to support TLS communication for Fabirc
The main obstacle to enable Fabric TLS in k8s cluster is the mismatch between the hostname of Fabric service components(e.g. peer nodes, orderer) defined in their TLS certs and the one assgined by k8s DNS service.

For example, in our example configuration, the hostname defined in the TLS cert of ```peer0.org1``` will be ```org1.kopernik.ibm.org``` per the definition of [cryptoconfig.yaml](https://github.com/yanyanhu/hlf-k8s-custom-crypto/blob/master/crypto-config.yaml#L32). However, the hostname assgined by the k8s DNS service will be ```fabric-peer1-org1.default.svc.cluster.local``` per the [service definition](https://github.com/yanyanhu/hlf-k8s-custom-crypto/blob/master/fabric-peer0-org1.yaml#L10). In this case, when other Fabric components(e.g. other peers or orderer) or exteral requestors(e.g. Fabric client) talk with ```peer0.org1```, the hostname mismatch will happen and thus fail the TLS connection.

To resolve this problem, we can leverage the ```rewrite``` capability of ```coreDNS``` which is the default DNS service provider of k8s since 1.13 release.

The rewrite plugin has interesting capabilities: It enables you to write domain-name translation maps that resolve the name mismatch problems experienced with KubeDNS. By rewriting domain names, you can reference a service with its fully qualified name matching the certificate(e.g. ```peer0.org1.kopernik.ibm.org```) and translate it into the fully qualified name of the service used cluster(e.g. ```fabric-peer0-org1.default.svc.cluster.local```). For instance, you could rewrite the expected names of the services as follows:
```
    rewrite {
        name regex peer0.org1.kopernik.ibm.org fabric-peer0-org1.default.svc.cluster.local
    }
```
This configuration enables the translation of the query, but the response will still be based on the original name of the service. As a result, this still results in a naming conflict with the certificate name associated with the service. To achieve complete transparency, you need to translate back the returned DNS name, mapped to the IP of the original service name. You can do this by adding a directive to translate the DNS answer and group them together:
```
    rewrite {
        name regex peer0.org1.kopernik.ibm.org fabric-peer0-org1.default.svc.cluster.local
        answer name fabric-peer0-org1.default.svc.cluster.local peer0.org1.kopernik.ibm.org
    }
```

```coreDNS``` uses ```Corefile``` to configure its behavior. The default configuration is defined as the following ```configMap```:
```
$kubectl describe cm coredns --namespace=kube-system

Corefile:
----
.:53 {
    errors
    health
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       upstream
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
```
To enable the hostname rewrite, run ```kubectl edit cm coredns -n kube-system``` or ```kubectl patch cm coredns -n kube-system``` to make the following changes to the ```coredns``` configmap:

```
$kubectl describe cm coredns --namespace=kube-system

Corefile:
----
.:53 {
    errors
    health
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       upstream
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    rewrite {
        name regex peer0.org1.kopernik.ibm.org fabric-peer0-org1.default.svc.cluster.local
        answer name fabric-peer0-org1.default.svc.cluster.local peer0.org1.kopernik.ibm.org
    }
    rewrite {
        name regex peer1.org1.kopernik.ibm.org fabric-peer1-org1.default.svc.cluster.local
        answer name fabric-peer1-org1.default.svc.cluster.local peer1.org1.kopernik.ibm.org
    }
    rewrite {
        name regex peer0.org2.kopernik.ibm.org fabric-peer0-org2.default.svc.cluster.local
        answer name fabric-peer0-org2.default.svc.cluster.local peer0.org2.kopernik.ibm.org
    }
    rewrite {
        name regex peer1.org2.kopernik.ibm.org fabric-peer1-org2.default.svc.cluster.local
        answer name fabric-peer1-org2.default.svc.cluster.local peer1.org2.kopernik.ibm.org
    }
    rewrite {
        name regex orderer.kopernik.ibm.org fabric-orderer.default.svc.cluster.local
        answer name fabric-orderer.default.svc.cluster.local orderer.kopernik.ibm.org
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
```
As you can see, several ```rewrite``` policies have been added to fix the hostname mismatch problem. Now we are ready to deploy the example Fabric network into k8s cluster with TLS enabled.

For more information about coreDNS usage in k8s, please refer to the [document](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns). And for more information about ```rewrite``` plugin of ```coreDNS```, please refer to the [plugin description](https://github.com/coredns/coredns/tree/master/plugin/rewrite).

## Deploy Fabric network and test
To deploy the example network, create the following folder in your system and copy all those required materials including channel artifacts, cryptos, example chaincode and test scripts into it.
```
$mkdir -p /home/hlbcadmin/Downloads/mysolution/fabric-e2e-custom/
$cp -r channel-artifacts/ /home/hlbcadmin/Downloads/mysolution/fabric-e2e-custom/
$cp -r crypto-config/ /home/hlbcadmin/Downloads/mysolution/fabric-e2e-custom/
$cp -r examples/ /home/hlbcadmin/Downloads/mysolution/fabric-e2e-custom/
$cp -r scripts/ /home/hlbcadmin/Downloads/mysolution/fabric-e2e-custom/
```
You can change the location by tweaking the mount point defined in peer configuration files, e.g. [fabric-peer0-org1.yaml](https://github.com/yanyanhu/hlf-k8s-custom-crypto/blob/master/fabric-peer0-org1.yaml#L115).

One last todo before launching the deployment is configuring the host DNS for chaincode container. In the Fabric architecture, a peer runs a smart contract (chaincode) in an isolated container environment, and a peer can achieve this by directly deploying the container through the Docker daemon’s Unix socket interface. This chaincode container needs to have a way to contact the peer so that it can be managed by it, but a DNS query to the Docker network for the peer that is running on Kubernetes cannot be resolved. You need to configure the chaincode container with the DNS server IP address of the Kubernetes cluster so that it can call home. 

For every peer in the network, you need to specify the environment variable ```CORE_VM_DOCKER_HOSTCONFIG_DNS```, which is used to inject the IP address of the DNS server into the chaincode container during start-up. Here is an example: [fabric-peer0-org1.yaml](https://github.com/yanyanhu/hlf-k8s-custom-crypto/blob/master/fabric-peer0-org1.yaml#L75).

```
        - name: CORE_VM_DOCKER_HOSTCONFIG_DNS
          value: "10.96.0.10" # Change this to the actual DNS service IP in your cluster
```

You can get the DNS service IP by running the following cmd:
```
$kubectl get service/kube-dns --namespace=kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   24h
```

Now you can launch the network and initialize the test process by running the following shell script:
```
$./start-fabric.sh
```
If the test passes, the following output will be displayed in the terminal:
```
===================== All GOOD, End-2-End execution completed ===================== 


 _____   _   _   ____            _____   ____    _____ 
| ____| | \ | | |  _ \          | ____| |___ \  | ____|
|  _|   |  \| | | | | |  _____  |  _|     __) | |  _|  
| |___  | |\  | | |_| | |_____| | |___   / __/  | |___ 
|_____| |_| \_| |____/          |_____| |_____| |_____|
```
