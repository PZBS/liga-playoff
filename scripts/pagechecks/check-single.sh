#!/bin/bash

cd $(dirname $0)

GROUP=$1
shift

echo 'Checking external play-off data for' $GROUP
python check-playoff.py ../../$GROUP.jtpo $@

cd - >>/dev/null
