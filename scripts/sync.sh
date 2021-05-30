#!/bin/bash
cd $(dirname $0)
cd ../output
lftp  << EOF
      open -u ${LIGA_PLAYOFF_FTP_USER},${LIGA_PLAYOFF_FTP_PASS} ${LIGA_PLAYOFF_FTP_HOST}
      mirror -R . ${LIGA_PLAYOFF_FTP_PATH}
EOF
