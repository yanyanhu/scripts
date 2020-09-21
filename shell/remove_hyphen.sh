#!/bin/bash

STR=$1

# Remove hyphens from STR
NEW_STR=`echo $STR | sed -e 's/-//g'`
echo $NEW_STR
