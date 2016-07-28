#!/bin/bash

MASTER_IP=$1

docker run -idt \
  --privileged=true \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --volume /usr/bin/docker:/usr/bin/docker:ro \
  --net=host \
  --name test-mesos-agent 9.186.91.246:5000/yanyanhu/mesos-agent-gpu-ppc64le:20160726 \
  --master=$MASTER_IP:5050 --containerizers=docker,mesos \
  --hostname_lookup=false \
  --executor_registration_timeout=15mins \
  --port=5051 --log_dir=/var/log/mesos \
  --no-systemd_enable_support \
  --work_dir=/mesos --resources="ports(*):[31000-32000]"
