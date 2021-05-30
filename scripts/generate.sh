#!/bin/bash
cd $(dirname $0)
cd ..
cat scripts/.groups | while read GROUP
do
    python2 scripts/jfrteamy-playoff/playoff.py $GROUP.jtpo -v
done
