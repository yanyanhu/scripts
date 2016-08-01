#!/bin/bash

MESOS_MASTER_IP=$1
ZOOKEEPER_IP=$2

docker run -idt -p 8080:8080\
 --name test-marathon marathon-ppc64le-auto:0.13.0 \
 --master $MESOS_MASTER_IP:5050 --zk zk://$ZOOKEEPER_IP:2181/marathon
 --zk_timeout 300000 --local_port_max 40000
