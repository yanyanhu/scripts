#!/bin/bash


cd $1
SUBDIR=$2
SINCE=10/17/2019

#echo "======commit history======"
git log --oneline --since=$SINCE

echo "=====total lines of code====="

git ls-files | xargs cat | wc -l

echo "=====lines of code change====="

git log --since=$SINCE --numstat --pretty="%H" $SUBDIR | awk '
    NF==3 {plus+=$1; minus+=$2;}
    END   {printf("+%d, -%d\n", plus, minus)}'

echo "=====total commits amount====="
git rev-list --count HEAD --since=$SINCE
