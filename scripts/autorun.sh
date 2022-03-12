#!/bin/bash

export GIT_SSH_COMMAND="ssh ${LIGA_SSH_OPTS}"

FORCE=${1:-0}

PREVHEAD=$(git rev-parse HEAD)
git pull --quiet --rebase --autostash --recurse-submodules --no-stat
if [ -n "$(git diff --name-status --no-renames $PREVHEAD HEAD)" -o $FORCE != "0" ]
then
    ( date --rfc-3339=seconds; ./generate.sh; ./sync.sh; date --rfc-3339=seconds; ) > ${LIGA_PLAYOFF_LOGFILE} 2>&1
fi
