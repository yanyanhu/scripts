#!/bin/sh

REMOTE_TAG=x86_64-1.0.5
LOCAL_TAG=latest

dockerImagesPull() {
  for IMAGE in peer ca orderer couchdb ccenv javaenv kafka zookeeper tools; do
      echo "==> PULLING FABRIC IMAGE: $IMAGE"
      echo
      docker pull hyperledger/fabric-$IMAGE:$REMOTE_TAG
      docker tag hyperledger/fabric-$IMAGE:$REMOTE_TAG hyperledger/fabric-$IMAGE:$LOCAL_TAG
  done
}

dockerImagesPull
