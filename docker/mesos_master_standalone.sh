#!/bin/bash

HOST_IP=$1

docker run -d --net host \
 --name test-mesos-master 9.186.91.246:5000/yanyanhu/mesos-master-gpu-ppc64le:20160726 \
 --ip=$HOST_IP --work_dir=/mesos
