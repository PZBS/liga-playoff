#!/bin/bash
cd $(dirname $0)
cd ..
export PYTHONIOENCODING=utf-8
cat scripts/.groups | while read GROUP
do
    python2 scripts/jfrteamy-playoff/playoff.py $GROUP.jtpo -v
done
