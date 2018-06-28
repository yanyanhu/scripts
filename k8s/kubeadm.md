# Prerequisite
Install golang and setup $GOPATH. Then install go get github.com/kubernetes-incubator/cri-tools/cmd/crictl.

Turn off swap by running `swapoff -a`.
```
$sudo swapoff -a
$sudo sed -i \'/ swap /d\' /etc/fstab
```

For the following error that could happen during `kubeadm join`, running the cmd with `--ignore-preflight-errors=cri` to ignore cri check.
```
[ERROR CRI]: unable to check if the container runtime at "/var/run/dockershim.sock" is running: exit status 1
```
