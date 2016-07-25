#!/bin/bash

DOCKER_LIST=`docker ps | awk  '{print $1}'`

for d in $DOCKER_LIST
do
    if [ "$d" != "CONTAINER" ]; then
        echo $d
        docker rm -f $d
    fi
done
