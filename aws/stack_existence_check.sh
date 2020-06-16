#!/bin/bash

STACK_NAME=example-stack
STACK_EXISTENCE=1
RUNTIME=20 # 20 seconds timeout
SECONDS=0 # Reset seconds counting

echo "Waiting for Stack $STACK_NAME to be deleted..."
while [ $SECONDS -lt $RUNTIME ]
do
    STACK_EXISTENCE=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --region ap-southeast-1 | grep $STACK_NAME | wc -l)
    echo "Stack eixstence status: $STACK_EXISTENCE"
    if [ "$STACK_EXISTENCE" -eq 0 ]; then
        echo "Stack has been deleted successfully."
        break
    fi
    echo "sleep 5 seconds..."
    sleep 5
done

if [ "$STACK_EXISTENCE" -ne 0 ]; then
    echo "Failed to delete Stack $STACK_NAME within $RUNTIME seconds."
fi

