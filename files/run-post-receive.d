#!/bin/sh

input=$(cat)
scripts_directory="`dirname $0`/post-receive.d"

for script in `ls $scripts_directory/*`; do
    echo $input | $script
done
