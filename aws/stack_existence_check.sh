#!/bin/bash

STACK_NAME=$1
RUNTIME=${2:-60} # 60 seconds timeout
SLEEPTIME=${3:-10} # 10 seconds sleep time
REGION=${4:-ap-southeast-1} # Default SG region

echo "Waiting for Stack $STACK_NAME to be deleted..."
SECONDS=0 # Reset seconds counting
STACK_STR="\"StackName\": \"$STACK_NAME\""
STACK_EXISTENCE=1
while [ $SECONDS -lt $RUNTIME ]
do
    # Check the stack existence by describing the stack.
    STACK_EXISTENCE=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep "$STACK_STR" | wc -l)

#    # Check the stack existence by counting the DELETED_COMPLETE stacks
#    STACK_AMOUNT=$(aws cloudformation list-stacks --region $REGION | grep "$STACK_STR" | wc -l)
#    echo "Total stack amount: $STACK_AMOUNT"
#    DELETED_STACK_AMOUNT=$(aws cloudformation list-stacks --stack-status-filter DELETE_COMPLETE --region $REGION | grep "$STACK_STR" | wc -l)
#    echo "DELETED stack amount: $DELETED_STACK_AMOUNT"
#    if [ "$STACK_AMOUNT" -eq "$DELETED_STACK_AMOUNT" ]; then
#        echo "Stack has been deleted successfully."
#        STACK_EXISTENCE=0
#        break
#    fi

    echo "Stack existence status: $STACK_EXISTENCE"
    if [ "$STACK_EXISTENCE" -eq 0 ]; then
        echo "Stack has been deleted successfully."
        break
    fi

    echo "sleep $SLEEPTIME seconds..."
    sleep $SLEEPTIME
done

if [ "$STACK_EXISTENCE" -ne 0 ]; then
    echo "Failed to delete Stack $STACK_NAME within $RUNTIME seconds."
fi

