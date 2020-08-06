#!/bin/bash

read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

export REGION=ap-southeast-1
export APP_NAME=${1:-fargate-example-app}
export IMAGE_NAME=$APP_NAME
export IMAGE_TAG=latest
export ECS_CLUSTER_NAME=ecs-cluster-$APP_NAME

aws ecs register-task-definition --region $REGION --cli-input-json file://example-app-task.json

aws ecs --region $REGION list-task-definitions
