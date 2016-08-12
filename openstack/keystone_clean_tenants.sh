#!/bin/bash

TENANT_LIST=`keystone tenant-list | awk  '{print $4}'`
EXCEPTION_LIST="name admin demo service alt_demo invisible_to_admin"

for tenant in $TENANT_LIST
do
    match=`echo $EXCEPTION_LIST | grep $tenant`
    if [[ "$match" == "" ]]; then
        echo $tenant
        keystone tenant-delete $tenant
        sleep 0.3
    fi
done
