#!/bin/bash

ORIGINAL_DOCKER_ID=$1
OUTPUT_IMAGE=$2

docker export $ORIGINAL_DOCKER_ID | docker import - $OUTPUT_IMAGE
