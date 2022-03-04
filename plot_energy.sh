#!/usr/bin/env bash

prefix=""
suffix=""
outsuffix=_cpu90
y=!
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    exit 0;
elif [ "$1" = "--prefix" -o "$1" = "-p" ]; then
    prefix=$2
    shift 2
elif [ "$1" = "--suffix" -o "$1" = "-s" ]; then
    suffix=$2
    shift 2
elif [ "$1" = "-x" ]; then
    x=$2
    shift 2
elif [ "$1" = "-y" ]; then
    y=$2
    shift 2
elif [ "$1" = "--outsuffix" -o "$1" = "-c" ]; then
    outsuffix=$2
    shift 2
else
    break
fi
done

for name in $@
do 
echo "${prefix}${name}${suffix}"
echo `grep -e ${x} ${prefix}${name}${suffix}.in`
echo `grep -e ${y} ${prefix}${name}${suffix}${outsuffix}.out`
done