FROM frolvlad/alpine-glibc
MAINTAINER Philipp Hellmich <phil@hellmi.de>

# install wget
RUN apk add --update wget tar ca-certificates openssl binutils

# install dumb init
RUN wget -q https://github.com/Yelp/dumb-init/releases/download/v1.1.0/dumb-init_1.1.0_amd64 \
-O /usr/local/bin/dumb-init \
&& chmod +x /usr/local/bin/dumb-init

# add our user to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN adduser -S cgatepro -h /var/CommuniGate -G mail \
&& mkdir -p /var/CommuniGate \
&& mkdir -p /opt/CommuniGate \
&& chown -R cgatepro.mail /var/CommuniGate

# install communigate 32bit static
#RUN cd /tmp \
#&& wget -q ftp://ftp.stalker.com/pub/CommuniGatePro/CGatePro-Linux-Intel.tgz \
#-O /tmp/CGatePro-Linux-Intel.tgz \
#&& tar -xzf /tmp/CGatePro-Linux-Intel.tgz \
#&& mv /tmp/CGateProSoftware/CommuniGate /opt/ \
#&& rm -fr /tmp/CGateProSoftware/ \
#&& rm /tmp/CGatePro-Linux-Intel.tgz \
#&& rm /opt/CommuniGate/CGServer \
#&& rm /opt/CommuniGate/mail \
#&& rm /opt/CommuniGate/sendmail

RUN cd /tmp \
&& wget -q ftp://ftp.stalker.com/pub/CommuniGatePro/CGatePro-Linux_amd64.deb \
-O /tmp/CGatePro-Linux_amd64.deb \
&& ar x /tmp/CGatePro-Linux_amd64.deb \
&& tar -xzf /tmp/data.tar.gz \
&& mv /tmp/opt/CommuniGate/* /opt/CommuniGate \
&& rm -fr /tmp/*

# install dkim helper
RUN apk add --update perl-mail-dkim \
&& wget -q https://www.communigate.com/ScriptRepository/helper_DKIM_verify.pl \
-O /opt/CommuniGate/helper_DKIM_verify.pl \
&& wget -q https://www.communigate.com/ScriptRepository/helper_DKIM_sign.pl \
-O /opt/CommuniGate/helper_DKIM_sign.pl \
&& chmod 755 /opt/CommuniGate/helper_DKIM_verify.pl \
&& chmod 755 /opt/CommuniGate/helper_DKIM_sign.pl

# install cgpav
# http://program.farit.ru/antivir/cgpav-1.5.tar.gz
ADD cgpav-64 /opt/CommuniGate/cgpav
RUN chmod 755 /opt/CommuniGate/cgpav

ADD Main.settings /opt/CommuniGate/SAMPLE/Main.settings
ADD Rules.settings /opt/CommuniGate/SAMPLE/Rules.settings
ADD Queue.settings /opt/CommuniGate/SAMPLE/Queue.settings

ADD cgpav.conf /etc/cgpav.conf

ADD run.sh /run.sh
RUN chmod +x /*.sh

# Define mountable directories.
VOLUME ["/var/CommuniGate"]

# Server CMD
CMD ["dumb-init", "/run.sh"]

# Expose ports.
# Webadmin http/https
EXPOSE 8010
EXPOSE 9010
# Webmail http/https
EXPOSE 8100
EXPOSE 9100
# Server SMTP
EXPOSE 25
# Server PWD
EXPOSE 106
# User SMTP/IMAP/POP
EXPOSE 110
EXPOSE 143
EXPOSE 587
EXPOSE 993
EXPOSE 995
# User SIP
EXPOSE 5060
