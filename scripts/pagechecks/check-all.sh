#!/bin/bash

cd $(dirname $0)

grep -v '^#' ../.groups | while read GROUP
do
    ./check-single.sh $GROUP $@
done

cd - >>/dev/null
