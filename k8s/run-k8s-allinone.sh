#!/bin/bash

echo "starting apiserver..."
./start-k8s-apiserver.sh
sleep 3

echo "starting controller-manager..."
./start-k8s-controller-manager.sh
sleep 3

echo "starting scheduler..."
./start-k8s-scheduler.sh
sleep 3

echo "starting proxy..."
./start-k8s-proxy.sh
sleep 3

echo "starting kubelet..."
./start-k8s-kubelet.sh
sleep 3

echo "done."
