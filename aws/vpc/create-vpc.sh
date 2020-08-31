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
export VPC_NAME=${1:-test-vpc}
export AZ_NUM=${2:-2}
export VPC_TEMPLATE="file://vpc-cf-template-${AZ_NUM}az.yaml"

aws cloudformation create-stack --region $REGION --stack-name $STACK_NAME --template-body $VPC_TEMPLATE --parameters ParameterKey=EnvironmentName,ParameterValue=$VPC_NAME
