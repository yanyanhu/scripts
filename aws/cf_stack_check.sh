#!/bin/bash
#
# This is a script to check the status of a given
# cloudformation stack
#


OP=$1
STACK_NAME=$2
REGION=${3:-ap-southeast-1} # Default SG region
RUNTIME=${4:-60} # 60 seconds timeout
SLEEPTIME=${5:-10} # 10 seconds sleep time


wait_stack_create ()
{
    echo "Waiting for Stack $STACK_NAME to be created..."
    SECONDS=0 # Reset seconds counting
    STACK_STR="StackStatus"
    while [ $SECONDS -lt $RUNTIME ]
    do
        # Check the stack status by describing the stack.
        STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep "$STACK_STR" | awk '{print $2}')

        echo "Stack status: $STACK_STATUS"
        if [ "$STACK_STATUS" == "\"CREATE_COMPLETE\"," ]; then
            echo "Stack has been created successfully."
            break
        fi

        echo "sleep $SLEEPTIME seconds..."
        sleep $SLEEPTIME
    done

    if [ "$STACK_STATUS" != "\"CREATE_COMPLETE\"," ]; then
        echo "Failed to create the Stack $STACK_NAME within $RUNTIME seconds."
    fi
}


wait_stack_update ()
{
    echo "Waiting for Stack $STACK_NAME to be updated..."
    SECONDS=0 # Reset seconds counting
    STACK_STR="StackStatus"
    while [ $SECONDS -lt $RUNTIME ]
    do
        # Check the stack status by describing the stack.
        STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep "$STACK_STR" | awk '{print $2}')

        echo "Stack status: $STACK_STATUS"
        if [ "$STACK_STATUS" == "\"UPDATE_COMPLETE\"," ]; then
            echo "Stack has been updated successfully."
            break
        fi

        echo "sleep $SLEEPTIME seconds..."
        sleep $SLEEPTIME
    done

    if [ "$STACK_STATUS" != "\"UPDATE_COMPLETE\"," ]; then
        echo "Failed to update the Stack $STACK_NAME within $RUNTIME seconds."
    fi
}


wait_stack_delete ()
{
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
}



if [ "$OP" == "create" ]; then
    wait_stack_create
elif [ "$OP" == "update" ]; then
    wait_stack_update
elif [ "$OP" == "delete" ]; then
    wait_stack_delete
fi
