#!/bin/bash

HOST_IP=$1

docker run -d --net host \
 --name mesos-master mesos-master-ppc64:20160726 \
 --ip=$HOST_IP --work_dir=/mesos
