#!/bin/sh
set -e

APPLICATION="/opt"
BASEFOLDER="/var/CommuniGate"
SUPPLPARAMS="--dropRoot --logToConsole"

if [ -z ${MAILSERVER_DOMAIN+x} ]; then MAILSERVER_DOMAIN=example.org; fi
if [ -z ${MAILSERVER_HOSTNAME+x} ]; then MAILSERVER_HOSTNAME=mail.example.org; fi
if [ -z ${HELPER_THREADS+x} ]; then HELPER_THREADS=3; fi
if [ -z ${SPAMASSASIN_HOST+x} ]; then SPAMASSASIN_HOST=localhost; fi
if [ -z ${SPAMASSASIN_PORT+x} ]; then SPAMASSASIN_PORT=783; fi

echo "=> Using the following CommuniGatePro configuration:"
echo "========================================================================"
echo "      Application folder:  $APPLICATION"
echo "      Data folder:         $BASEFOLDER"
echo "      Startup parameters:  $SUPPLPARAMS"
echo ""
echo " Helpers for cgpav and DKIM are preconfigured"
echo "========================================================================"


[ -f ${APPLICATION}/CommuniGate/CGServer-static ] || exit 1

#ulimit -u 2000
ulimit -c 2097151
umask 0

# Custom startup parameters
if [ -f ${BASEFOLDER}/Startup.sh ]; then
  . ${BASEFOLDER}/Startup.sh
fi

if [ -d ${BASEFOLDER} ] ; then
  echo "Enforcing file system rights in the CommuniGate Base Folder..."
  chown -R cgatepro.mail ${BASEFOLDER}
  chmod -R g+rw ${BASEFOLDER}
else
  echo "Creating the CommuniGate Base Folder..."
  mkdir ${BASEFOLDER}
  chown -R cgatepro.mail ${BASEFOLDER}
  chmod 2770 ${BASEFOLDER}
fi

if [ ! -d ${BASEFOLDER}/Settings ] ; then
  echo "Creating CommuniGate configuration from SAMPLE..."
  mkdir ${BASEFOLDER}/Settings
  cp ${APPLICATION}/CommuniGate/SAMPLE/Main.settings ${BASEFOLDER}/Settings
  cp ${APPLICATION}/CommuniGate/SAMPLE/Rules.settings ${BASEFOLDER}/Settings
  cp ${APPLICATION}/CommuniGate/SAMPLE/Queue.settings ${BASEFOLDER}/Settings
  chown -R cgatepro.mail ${BASEFOLDER}/Settings
  chmod 2770 ${BASEFOLDER}/Settings
fi

if [ -f ${BASEFOLDER}/Settings/Main.settings ]; then
  echo "Applying CommuniGate main configuration from ENVIRONMENT..."
  echo "DomainName: $MAILSERVER_HOSTNAME"
  sed "s/DomainName =.*/DomainName = $MAILSERVER_HOSTNAME;/g" -i ${BASEFOLDER}/Settings/Main.settings
fi

if [ -f ${BASEFOLDER}/Settings/Queue.settings ]; then
  echo "Applying CommuniGate queue configuration from ENVIRONMENT..."
  echo "EnqueuerProcessors: $HELPER_THREADS"
  sed "s/EnqueuerProcessors =.*/EnqueuerProcessors = $HELPER_THREADS;/g" -i ${BASEFOLDER}/Settings/Main.settings
fi

if [ ! -d ${BASEFOLDER}/DKIM ] ; then
  echo "Creating DKIM public and private keys..."
  mkdir ${BASEFOLDER}/DKIM
  openssl genrsa -out ${BASEFOLDER}/DKIM/dkim.key 1024
  openssl rsa -in ${BASEFOLDER}/DKIM/dkim.key -out ${BASEFOLDER}/DKIM/dkim.public -pubout -outform PEM
  chown -R cgatepro.mail ${BASEFOLDER}/DKIM
fi

echo "Found DKIM public key:"
cat ${BASEFOLDER}/DKIM/dkim.public

if [ -f /opt/CommuniGate/helper_DKIM_sign.pl ]; then
  echo "Applying DKIM sign configuration from ENVIRONMENT..."
  echo "MaxThreads: $HELPER_THREADS"
  #echo "DomainName: $MAILSERVER_HOSTNAME"
  #my $nThreads=5;
  sed "s/Threads.*=.*/Threads = $HELPER_THREADS;/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain1.dom/$MAILSERVER_DOMAIN/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain1.key/\/var\/CommuniGate\/DKIM\/dkim.key/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
fi

if [ -f /opt/CommuniGate/helper_DKIM_verify.pl ]; then
  echo "Applying DKIM verify configuration from ENVIRONMENT..."
  echo "MaxThreads: $HELPER_THREADS"
  #echo "DomainName: $MAILSERVER_HOSTNAME"
  #my $nThreads=5;
  sed "s/Threads.*=.*/Threads = $HELPER_THREADS;/g" -i /opt/CommuniGate/helper_DKIM_verify.pl
fi

if [ -f /etc/cgpav.conf ]; then
  echo "Creating CGPAV configuration from ENVIRONMENT..."
  echo "max childs: $HELPER_THREADS"
  echo "spamassassin_host: $SPAMASSASIN_HOST"
  echo "spamassassin_port: $SPAMASSASIN_PORT"
  sed "s/max_childs =.*/max_childs = $HELPER_THREADS/g" -i /etc/cgpav.conf
  sed "s/spamassassin_host =.*/spamassassin_host = $SPAMASSASIN_HOST/g" -i /etc/cgpav.conf
  sed "s/spamassassin_port =.*/spamassassin_port = $SPAMASSASIN_PORT/g" -i /etc/cgpav.conf
fi

echo "Starting CommuniGate Pro"

exec ${APPLICATION}/CommuniGate/CGServer-static --Base ${BASEFOLDER} ${SUPPLPARAMS}
