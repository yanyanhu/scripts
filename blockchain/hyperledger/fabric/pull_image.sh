#!/bin/sh

#DOCKER_REGISTRY=bit-docker-local.artifactory.swg-devops.com/icbi-intermodal
REMOTE_TAG=x86_64-1.0.5
LOCAL_TAG=latest

dockerImagesPull() {
  for IMAGE in peer ca orderer couchdb ccenv javaenv kafka zookeeper testenv; do
      echo "==> PULLING FABRIC IMAGE: $IMAGE"
      echo
      docker pull hyperledger/fabric-$IMAGE:$REMOTE_TAG
      docker tag hyperledger/fabric-$IMAGE:$REMOTE_TAG hyperledger/fabric-$IMAGE:$LOCAL_TAG
  done
}

dockerImagesPull
