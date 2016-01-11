#!/bin/bash

APPLICATION="/opt"
BASEFOLDER="/var/CommuniGate"
SUPPLPARAMS="--dropRoot --logToConsole"

echo "=> Using the following CommuniGatePro configuration:"
echo "========================================================================"
echo "      Application folder:  $APPLICATION"
echo "      Data folder:         $BASEFOLDER"
echo "      Startup parameters:  $SUPPLPARAMS"
echo ""
echo " Content filtering can be done with clamav and spamd"
echo " use this as a content filter: "
echo " /opt/CommuniGate/cgpav -f /etc/cgpav.conf"
echo "========================================================================"


[ -f ${APPLICATION}/CommuniGate/CGServer ] || exit 1

#ulimit -u 2000
ulimit -c 2097151
umask 0

# Custom startup parameters
if [ -f ${BASEFOLDER}/Startup.sh ]; then
  . ${BASEFOLDER}/Startup.sh
fi

if [ -d ${BASEFOLDER} ] ; then
  # ...
  chown -R cgatepro.mail ${BASEFOLDER}
  chmod -R g+rw ${BASEFOLDER}
else
  echo "Creating the CommuniGate Base Folder..."
  mkdir ${BASEFOLDER}
  chgrp mail ${BASEFOLDER}
  chmod 2770 ${BASEFOLDER}
fi

#sed -i /var/CommuniGate/cgpav.conf "s/spamassassin_host =.*/spamassassin_host=xxx/g"

echo "Starting CommuniGate Pro"

exec ${APPLICATION}/CommuniGate/CGServer --Base ${BASEFOLDER} ${SUPPLPARAMS}
