#!/bin/bash

MESOS_MASTER_IP=$1
ZOOKEEPER_IP=$2

docker run -idt --net host \
 --name test-m-01 marathon-gpu:ppc64le-latest \
 --master $MESOS_MASTER_IP:5050 --zk zk://$ZOOKEEPER_IP:2181/marathon \
 --zk_timeout 300000 --local_port_max 20000 # --logging_level debug
