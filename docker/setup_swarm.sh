#!/bin/bash

apt-get -y install docker.io
echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=consul://9.1.34.129:8500 --cluster-advertise=eth0:2376 --label owner=org1"' >> /etc/default/docker
/etc/init.d/docker restart

# For label based node filtering, using the following format definition in docker-compose file
#    environment:
#      - "constraint:owner==org1"

# ifconfig eth0:0 | grep -i "inet addr"

# In Master
export MASTERIP=9.1.34.139
docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap -advertise=$MASTERIP
docker run -d -p 4000:4000 swarm manage -H :4000 --replication --advertise $MASTERIP:4000 consul://$MASTERIP:8500

# In Workers
export WORKERIP=9.1.34.140
docker run -d swarm join --advertise=$WORKERIP:2375 consul://$MASTERIP:8500


# Verify

docker -H :4000 info
docker -H :4000 run hello-world
