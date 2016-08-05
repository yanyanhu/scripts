#!/bin/bash

HOST_IP=$1

docker run -idt --net host \
 --name test-mesos-master mesos-master-ppc64le:20160726 \
 --ip=$HOST_IP --work_dir=/mesos --hostname_lookup=false
