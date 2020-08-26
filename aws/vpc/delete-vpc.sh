#!/bin/bash
#
# Create a VPC with cloudformation template
#


read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

export REGION=ap-southeast-1
export STACK_NAME=${1:-test-vpc-stack}

aws cloudformation delete-stack --region $REGION --stack-name $STACK_NAME
