#!/bin/bash

STACK_NAME=$1
RUNTIME=${2:-60} # 60 seconds timeout
SLEEPTIME=${3:-10} # 10 seconds sleep time

echo "Waiting for Stack $STACK_NAME to be deleted..."
SECONDS=0 # Reset seconds counting
STACK_STR='"StackName": "gitlab-example"'
while [ $SECONDS -lt $RUNTIME ]
do
    STACK_AMOUNT=$(aws cloudformation list-stacks --region ap-southeast-1 | grep "$STACK_STR" | wc -l)
    echo "Total stack amount: $STACK_AMOUNT"
    DELETED_STACK_AMOUNT=$(aws cloudformation list-stacks --stack-status-filter DELETE_COMPLETE --region ap-southeast-1 | grep "$STACK_STR" | wc -l)
    echo "DELETED stack amount: $DELETED_STACK_AMOUNT"
    if [ "$STACK_AMOUNT" -eq "$DELETED_STACK_AMOUNT" ]; then
        echo "Stack has been deleted successfully."
        break
    fi
    echo "sleep $SLEEPTIME seconds..."
    sleep $SLEEPTIME
done

if [ "$STACK_AMOUNT" -ne "$DELETED_STACK_AMOUNT" ]; then
    echo "Failed to delete Stack $STACK_NAME within $RUNTIME seconds."
fi

