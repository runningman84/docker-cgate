#!/bin/sh
set -e

APPLICATION="/opt/CommuniGate"
BASEFOLDER="/var/CommuniGate"
SUPPLPARAMS="--dropRoot --logToConsole"

if [ -z ${MAILSERVER_DOMAIN+x} ]; then MAILSERVER_DOMAIN=example.org; fi
if [ -z ${MAILSERVER_HOSTNAME+x} ]; then MAILSERVER_HOSTNAME=mail.example.org; fi
if [ -z ${HELPER_THREADS+x} ]; then HELPER_THREADS=3; fi
if [ -z ${CGPAV_SPAMASSASIN_HOST+x} ]; then CGPAV_SPAMASSASIN_HOST=localhost; fi
if [ -z ${CGPAV_SPAMASSASIN_PORT+x} ]; then CGPAV_SPAMASSASIN_PORT=783; fi
if [ -z ${CGPAV_SPAM_ACTION+x} ]; then CGPAV_SPAM_ACTION=addheaderjunk; fi
if [ -z ${CGPAV_EXTRA_SPAM_ACTION+x} ]; then CGPAV_EXTRA_SPAM_ACTION=reject; fi
if [ -z ${CGPAV_EXTRA_SPAM_SCORE+x} ]; then CGPAV_EXTRA_SPAM_SCORE=10; fi
if [ -z ${CGPAV_VIRUS_ACTION+x} ]; then CGPAV_VIRUS_ACTION=none; fi

echo "=> Using the following CommuniGatePro configuration:"
echo "========================================================================"
echo "      Application folder:  $APPLICATION"
echo "      Data folder:         $BASEFOLDER"
echo "      Startup parameters:  $SUPPLPARAMS"
echo "      Mailserver Hostname: $MAILSERVER_HOSTNAME"
echo "      Mailserver Domain:   $MAILSERVER_DOMAIN"
echo "      CGPAV spamd Host:    $CGPAV_SPAMASSASIN_HOST"
echo "      CGPAV spamd Port:    $CGPAV_SPAMASSASIN_PORT"
echo "      CGPAV spam action:   $CGPAV_SPAM_ACTION ($CGPAV_EXTRA_SPAM_ACTION)"
echo "      CGPAV virus action:  $CGPAV_VIRUS_ACTION"
echo "      Helper Threads:      $HELPER_THREADS"
echo "      DKIM keys folders:   $BASEFOLDER/DKIM"
echo ""
echo " Helpers and rules for cgpav and DKIM are preconfigured"
echo "========================================================================"


[ -f ${APPLICATION}/CGServer ] || exit 1

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
  cp ${APPLICATION}/SAMPLE/Main.settings ${BASEFOLDER}/Settings
  cp ${APPLICATION}/SAMPLE/Rules.settings ${BASEFOLDER}/Settings
  cp ${APPLICATION}/SAMPLE/Queue.settings ${BASEFOLDER}/Settings
  chown -R cgatepro.mail ${BASEFOLDER}/Settings
  chmod 2770 ${BASEFOLDER}/Settings
fi

if [ -f ${BASEFOLDER}/Settings/Main.settings ]; then
  echo "Applying CommuniGate main configuration from ENVIRONMENT..."
  sed "s/DomainName =.*/DomainName = $MAILSERVER_HOSTNAME;/g" -i ${BASEFOLDER}/Settings/Main.settings
fi

if [ -f ${BASEFOLDER}/Settings/Queue.settings ]; then
  echo "Applying CommuniGate queue configuration from ENVIRONMENT..."
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

echo "Please create a DNS record in the following format with your key in p="
echo "mail._domainkey.$MAILSERVER_DOMAIN. IN TXT \"v=DKIM1; g=*; k=rsa; p=...\""

if [ -f ${APPLICATION}/helper_DKIM_sign.pl ]; then
  echo "Applying DKIM sign configuration from ENVIRONMENT..."
  sed "s/Threads.*=.*/Threads = $HELPER_THREADS;/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain1.dom/$MAILSERVER_DOMAIN/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain2.dom/$MAILSERVER_HOSTNAME/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain1.key/\/var\/CommuniGate\/DKIM\/dkim.key/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
  sed "s/domain2.key/\/var\/CommuniGate\/DKIM\/dkim.key/g" -i /opt/CommuniGate/helper_DKIM_sign.pl
fi

if [ -f ${APPLICATION}/helper_DKIM_verify.pl ]; then
  echo "Applying DKIM verify configuration from ENVIRONMENT..."
  sed "s/Threads.*=.*/Threads = $HELPER_THREADS;/g" -i /opt/CommuniGate/helper_DKIM_verify.pl
fi

if [ -f /etc/cgpav.conf ]; then
  echo "Creating CGPAV configuration from ENVIRONMENT..."
  sed "s/max_childs =.*/max_childs = $HELPER_THREADS/g" -i /etc/cgpav.conf
  sed "s/spamassassin_host =.*/spamassassin_host = $CGPAV_SPAMASSASIN_HOST/g" -i /etc/cgpav.conf
  sed "s/spamassassin_port =.*/spamassassin_port = $CGPAV_SPAMASSASIN_PORT/g" -i /etc/cgpav.conf
  sed "s/infected_action =.*/infected_action = $CGPAV_VIRUS_ACTION/g" -i /etc/cgpav.conf
  sed "s/spam_action =.*/spam_action = $CGPAV_SPAM_ACTION/g" -i /etc/cgpav.conf
  sed "s/extra_spam_score =.*/extra_spam_score = $CGPAV_EXTRA_SPAM_SCORE/g" -i /etc/cgpav.conf
  sed "s/extra_spam_action =.*/extra_spam_action = $CGPAV_EXTRA_SPAM_ACTION/g" -i /etc/cgpav.conf
fi

echo ""

echo "Starting CommuniGate Pro"

exec ${APPLICATION}/CGServer --Base ${BASEFOLDER} ${SUPPLPARAMS}
