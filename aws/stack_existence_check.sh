#!/bin/bash

STACK_NAME=$1
RUNTIME=${2:-60} # 60 seconds timeout
SLEEPTIME=${3:-10} # 10 seconds sleep time
STACK_EXISTENCE=1

echo "Waiting for Stack $STACK_NAME to be deleted..."
SECONDS=0 # Reset seconds counting
while [ $SECONDS -lt $RUNTIME ]
do
    # Add status filter is needed, e.g. "--stack-status-filter CREATE_COMPLETE"
    STACK_EXISTENCE=$(aws cloudformation list-stacks --region ap-southeast-1 | grep $STACK_NAME | wc -l)
    echo "Stack eixstence status: $STACK_EXISTENCE"
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
