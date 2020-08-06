#!/bin/bash

read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

export REGION=ap-southeast-1
export ROLE_NAME=ecsTaskExecutionRole


aws iam --region $REGION create-role --role-name $ROLE_NAME --assume-role-policy-document file://task-execution-assume-role.json
aws iam --region $REGION attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
