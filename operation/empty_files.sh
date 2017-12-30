#!/bin/bash


#This will clear every file in every subdirectory.
find . -type f -exec sh -c 'echo -n "" > $1' sh {} \;

#To just clear the files in the current directory:
for i in *; do cat /dev/null > $i; done

