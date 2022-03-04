#!/usr/bin/env bash
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    exit 0;
elif [ "$1" = "--name" -o "$1" = "-n" ]; then
    name=$2
    shift 2
else
    break
fi
done

for prefix in $@
do 
echo $prefix
echo `grep -e '!' ${prefix}.out`
done