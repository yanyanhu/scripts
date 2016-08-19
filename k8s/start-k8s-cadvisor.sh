#!/bin/bash

docker run \
	--volume=/:/rootfs:ro \
	--volume=/var/run:/var/run:rw \
	--volume=/sys:/sys:ro \
	--volume=/var/lib/docker/:/var/lib/docker:ro \
	--publish=4194:8080 \
	--detach=true \
	--name=cadvisor \
	google/cadvisor:latest
