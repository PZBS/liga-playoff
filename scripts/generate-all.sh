#!/bin/bash
set -e

cd "$(dirname "$0")"/jfrteamy-playoff
python=venv/bin/python

generate_playoff () {
    rm -f playoff.html
    filename=$1
    ftp_path=$2
    echo "Generating $filename to $ftp_path..."
    $python playoff.py ../../$filename.json
    echo "Uploading to $ftp_path..."
    scp playoff.html pzbs:~/liga/$ftp_path
    rm -f playoff.html
    echo "Done"
}

generate_playoff eklasa ekstraklasa/playoff.html
generate_playoff 1n 1liga/n/playoff.html
generate_playoff 1s 1liga/s/playoff.html
generate_playoff 2nw 2liga/nw/playoff.html
generate_playoff 2ne 2liga/ne/playoff.html
generate_playoff 2se 2liga/se/playoff.html
generate_playoff 2sw 2liga/sw/playoff.html

