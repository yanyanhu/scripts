#!/bin/bash

# Master and Workers
export MASTER=master_ip
export WORKERS="worker1_ip worker2_ip ..."

# Setup Master Node
prepare_master() {
    MASTERIP=$1
    echo "Configuring master $MASTERIP..."
    echo "==============================="
    ssh root@$MASTERIP 'sudo apt-get install -y docker.io'
    ssh root@$MASTERIP 'docker rm -f $(docker ps -aq); sudo systemctl restart docker.service'
    ssh root@$MASTERIP "docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap -advertise=$MASTERIP; docker run -d -p 4000:4000 swarm manage -H :4000 --replication --advertise $MASTERIP:4000 consul://$MASTERIP:8500"

    # This is for secure the network access to the swarm controller. Comment out if unnecessary.
    echo "Configure iptables to block all access to smarm controller and consul that is not from the worker nodes."
    ssh root@$MASTERIP 'iptables -I FORWARD -d 172.17.0.2/32 -p tcp --dport 8500 -j REJECT; iptables -I FORWARD -d 172.17.0.3/32 -p tcp --dport 4000 -j REJECT'
    for worker in $WORKERS
    do
        echo "Add iptables rule for worker $worker"
        ssh root@$MASTERIP "iptables -I FORWARD -s $worker -d 172.17.0.2/32 -p tcp --dport 8500 -j ACCEPT; iptables -I FORWARD -s $worker -d 172.17.0.3/32 -p tcp --dport 4000 -j ACCEPT"
    done
}

# Setup Worker Node
prepare_worker() {
    MASTERIP=$1
    WORKERIP=$2
    DOCKER_CONFIG_DIR=/etc/systemd/system/docker.service.d
    DOCKER_CONFIG=$DOCKER_CONFIG_DIR/override.conf
    echo "Configuring worker $WORKERIP..."
    echo "==============================="
    #ssh root@$WORKERIP 'sudo apt-get install -y docker.io'
    ssh root@$WORKERIP 'docker rm -f $(docker ps -aq)'
    ssh root@$WORKERIP "mkdir -p $DOCKER_CONFIG_DIR"
    ssh root@$WORKERIP "echo [Service]>$DOCKER_CONFIG;echo ExecStart=>>$DOCKER_CONFIG;echo 'ExecStart=/usr/bin/dockerd -H fd:// -H tcp://$WORKERIP:2375 -H unix:///var/run/docker.sock --cluster-store=consul://$MASTERIP:8500 --cluster-advertise=eth0:2375 --label nodename=$WORKERIP' >> $DOCKER_CONFIG; sudo systemctl daemon-reload"
    ssh root@$WORKERIP "sudo systemctl restart docker.service; docker run -d swarm join --advertise=$WORKERIP:2375 consul://$MASTERIP:8500"

    # Only allow master to access the worker's docker daemon remotely
    ssh root@$WORKERIP "iptables -A INPUT ! -s $MASTERIP -p tcp -d $WORKERIP --dport 2375 -j REJECT"
}

# Master
prepare_master $MASTER

# Workers
for worker in $WORKERS
do
    prepare_worker $MASTER $worker
done
