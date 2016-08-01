#!/bin/bash

HOST_IP=172.17.0.1
MESOS_AGENT_NUM=5

# Start mesos master which is running in host network mode.
echo "Starting mesos master..."
./mesos_master_standalone.sh $HOST_IP
sleep 3

# Start mesos agents.
echo "Starting mesos agents..."
/home/huyanyan/marathon_mesos_test/docker_create_mesos_slave.sh $HOST_IP $MESOS_AGENT_NUM
sleep 3

# Start zookeeper. Zookeeper is also running in host network mode.
echo "Starting zookeeper..."
./zookeeper_standalone.sh
sleep 3

# Start marathon.
echo "Starting marathon..."
./marathon_standalone.sh $HOST_IP $HOST_IP
sleep 3

echo done
