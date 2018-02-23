#!/bin/bash
set -e

cd "$(dirname "$0")"/jfrteamy-playoff
python=venv/bin/python

# level = 1 or 2
# group = "n" or "nw" or "se" or ...
generate_playoff () {
    rm -f playoff.html
    level=$1
    group=$2
    echo "Generating $level$group..."
    $python playoff.py ../../$level$group.json
    echo "Uploading $level$group..."
    scp playoff.html pzbs:~/liga/${level}liga/$group/playoff.html
    rm -f playoff.html
    echo "Done"
}

generate_playoff 1 n
generate_playoff 1 s
generate_playoff 2 nw
generate_playoff 2 ne
generate_playoff 2 se
generate_playoff 2 sw

