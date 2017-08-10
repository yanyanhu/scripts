#!/bin/bash

PROJECT_NAME=blue-audit
IMAGE_LIST=`docker images | grep $PROJECT_NAME | grep -i none | awk  '{print $3}'`

for image in $IMAGE_LIST
do
    echo $image
    docker rmi $image
done
