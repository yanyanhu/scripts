#!/bin/bash

ORIGINAL_IMAGE_ID=$1
OUTPUT_IMAGE=$2

docker export $ORIGINAL_IMAGE_ID | docker import - $OUTPUT_IMAGE
