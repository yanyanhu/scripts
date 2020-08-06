#!/bin/bash

read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

export REGION=ap-southeast-1
export APP_NAME=fargate-example-app
export IMAGE_NAME=$APP_NAME
export IMAGE_TAG=latest
export ECR_REPO_NAME=$APP_NAME

# Go to ECR web portal to get this information required to login and
# push image after the ECR repo is created
export ECR_REG=$1

## Create ECR repository
#aws ecr create-repository --region $REGION --repository-name $ECR_REPO_NAME

## Build docker image for application
#cd ./example-app-flask
#docker build -t $IMAGE_NAME:$IMAGE_TAG .
#
## Login to remote ECR registry
#aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REG
#
## Tag image
#docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_REG/$IMAGE_NAME:$IMAGE_TAG
#
## Push image
#docker push $ECR_REG/$IMAGE_NAME:$IMAGE_TAG

# View image
aws ecr describe-images --region $REGION --repository-name $ECR_REPO_NAME
