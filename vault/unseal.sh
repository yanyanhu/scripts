#!/bin/bash

curl \
    --request POST \
    --data '{"key": "$KEY1"}' \
    http://localhost:8200/v1/sys/unseal

sleep 3

curl \
    --request POST \
    --data '{"key": "$KEY2"}' \
    http://localhost:8200/v1/sys/unseal

sleep 3

curl \
    --request POST \
    --data '{"key": "$KEY3"}' \
    http://localhost:8200/v1/sys/unseal
