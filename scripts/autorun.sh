#!/bin/bash
set -u

export GIT_SSH_COMMAND="ssh ${LIGA_SSH_OPTS}"

FORCE=${1:-0}
RUNNING_INDICATOR=${LIGA_PLAYOFF_LOGFILE}.running

find $(dirname ${LIGA_PLAYOFF_LOGFILE}) -name \*.running -mmin +720 -delete # if the bracket is not running for 12 hours, it's running

PREVHEAD=$(git rev-parse HEAD)
git pull --quiet --rebase --autostash --recurse-submodules --no-stat origin master
if [ -n "$(git diff --name-status --no-renames $PREVHEAD HEAD)" -o $FORCE != "0" -o -f ${RUNNING_INDICATOR} ]
then
    ( date --rfc-3339=seconds; ./generate.sh; ./sync.sh; date --rfc-3339=seconds; ) > ${LIGA_PLAYOFF_LOGFILE} 2>&1
    (grep 'phase object' ${LIGA_PLAYOFF_LOGFILE} | grep -v 'not running' > /dev/null) && touch ${RUNNING_INDICATOR}
fi
