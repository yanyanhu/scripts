#!/bin/bash

PROJECT_NAME=$1
IMAGE_LIST=`docker images | grep $PROJECT_NAME | grep -i none | awk  '{print $3}'`

for image in $IMAGE_LIST
do
    echo $image
    docker rmi $image
done

# Or simply run the following cmd
# docker rmi $(docker images -f "dangling=true" -q)
