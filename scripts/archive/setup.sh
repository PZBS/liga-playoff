#!/bin/bash
set -e
cd "$(dirname "$0")"/jfrteamy-playoff

if [ ! -d venv ]; then
    virtualenv venv
fi
venv/bin/pip install -r requirements.txt

