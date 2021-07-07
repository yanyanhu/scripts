#!/bin/bash

# To split a file with strings in the following format and print
# the first element in each line, means 'abc', 'bcd', 'cde'
#
# abc|123|xyz
# bcd|234|yyy
# cde|456|zzz
#

# Replace delimeter with other character if needed
cat $FILENAME | awk '{split($0,a,"|"); print a[1]}'

