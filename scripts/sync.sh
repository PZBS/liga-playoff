#!/bin/bash
cd $(dirname $0)
cd ../output
lftp  << EOF
      open -u ${LIGA_FTP_USER},${LIGA_FTP_PASS} ${LIGA_FTP_HOST}
      mirror -R . ${LIGA_PLAYOFF_FTP_PATH}
EOF
