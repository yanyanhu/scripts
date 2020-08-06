#!/bin/bash
#
# Create a VPC with cloudformation template
#


read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

export REGION=ap-southeast-1
export STACK_NAME=sc-test-vpc-stack
export VPC_NAME=sc-test-vpc

aws cloudformation create-stack --region $REGION --stack-name $STACK_NAME --template-body file://vpc-cf-template.yaml --parameters ParameterKey=EnvironmentName,ParameterValue=$VPC_NAME
