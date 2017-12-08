#!/bin/bash

# In both Master and workers
apt-get -y install docker.io
export MASTERIP=9.1.34.139
echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=consul://${MASTERIP}:8500 --cluster-advertise=eth0:2375 --label owner=org1"' >> /etc/default/docker
sed -e 's/${MASTERIP}/'$MASTERIP'/g' /etc/default/docker > /etc/default/docker.tmp
mv /etc/default/docker.tmp /etc/default/docker
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
export MASTERIP=9.1.34.139
export WORKERIP=9.1.34.140
docker run -d swarm join --advertise=$WORKERIP:2375 consul://$MASTERIP:8500


# Verify

docker -H :4000 info
docker -H :4000 run hello-world

# To use docker-compose, set DOCKER_HOST=4000 environment variable. Otherwise,
# docker-compose will talk to default docker port rather than the one of swarm manager.
export DOCKER_HOST=":4000"
