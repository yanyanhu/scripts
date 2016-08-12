#!/bin/bash

USER_LIST=`keystone user-list | awk  '{print $4}'`
EXCEPTION_LIST="name admin demo senlin senlin-user nova cinder glance neutron heat zaqar ceilometer alt_demo test-user"

for user in $USER_LIST
do
    match=`echo $EXCEPTION_LIST | grep $user`
    if [[ "$match" == "" ]]; then
        echo $user
        keystone user-delete $user
        sleep 0.3
    fi
done
