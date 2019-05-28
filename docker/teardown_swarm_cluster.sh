#!/bin/bash

# Master and Workers
export MASTER=master_ip
export WORKERS="worker1_ip worker2_ip ..."

# Setup Master Node
prepare_master() {
    MASTERIP=$1
    echo "Configuring master $MASTERIP..."
    echo "==============================="
    ssh root@$MASTERIP 'docker rm -f $(docker ps -aq); sudo systemctl restart docker.service'

    # This is for secure the network access to the swarm controller. Comment out if unnecessary.
    echo "Reconfigure iptables to clean the unused rules"
    ssh root@$MASTERIP 'iptables -D FORWARD -d 172.17.0.2/32 -p tcp --dport 8500 -j REJECT; iptables -D FORWARD -d 172.17.0.3/32 -p tcp --dport 4000 -j REJECT'
    for worker in $WORKERS
    do
        echo "Remove iptables rule for worker $worker"
        ssh root@$MASTERIP "iptables -D FORWARD -s $worker -d 172.17.0.2/32 -p tcp --dport 8500 -j ACCEPT; iptables -D FORWARD -s $worker -d 172.17.0.3/32 -p tcp --dport 4000 -j ACCEPT"
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
    ssh root@$WORKERIP 'docker rm -f $(docker ps -aq)'
    ssh root@$WORKERIP "iptables -D INPUT ! -s $MASTERIP -p tcp -d $WORKERIP --dport 2375 -j REJECT"
}

# Master
prepare_master $MASTER

# Workers
for worker in $WORKERS
do
    prepare_worker $MASTER $worker
done
