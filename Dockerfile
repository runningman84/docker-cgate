FROM frolvlad/alpine-glibc
MAINTAINER Philipp Hellmich <phil@hellmi.de>

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/runningman84/docker-cgate"

# install wget
RUN apk add --update wget tar ca-certificates openssl binutils curl

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
#cgate_1         | 19:54:55.527 2 HTTPU [0.0.0.0]:8100 listener ready for connections
#cgate_1         | 19:54:55.527 2 HTTPA [0.0.0.0]:8010 listener ready for connections
#cgate_1         | 19:54:55.527 2 HTTPA [0.0.0.0]:9010 listener ready for connections
#cgate_1         | 19:54:55.528 2 HTTPU [0.0.0.0]:9100 listener ready for connections
#cgate_1         | 19:54:55.528 2 PWD [0.0.0.0]:106 listener ready for connections
#cgate_1         | 19:54:55.528 2 STUN [0.0.0.0]:3478 listener ready for connections
#cgate_1         | 19:54:55.528 2 STUN [0.0.0.0]:5349 listener ready for connections
#cgate_1         | 19:54:55.528 2 POP [0.0.0.0]:110 listener ready for connections
#cgate_1         | 19:54:55.528 2 ACAP [0.0.0.0]:674 listener ready for connections
#cgate_1         | 19:54:55.528 2 LDAP [0.0.0.0]:636 listener ready for connections
#cgate_1         | 19:54:55.528 2 LDAP [0.0.0.0]:389 listener ready for connections
#cgate_1         | 19:54:55.528 2 IMAP [0.0.0.0]:143 listener ready for connections
#cgate_1         | 19:54:55.528 2 IMAP [0.0.0.0]:993 listener ready for connections
#cgate_1         | 19:54:55.528 2 FTP [0.0.0.0]:8021 listener ready for connections
#cgate_1         | 19:54:55.528 2 SMTP [0.0.0.0]:25 listener ready for connections
#cgate_1         | 19:54:55.528 2 SIP [0.0.0.0]:5060 listener ready for connections
#cgate_1         | 19:54:55.528 2 SIP [0.0.0.0]:5061 listener ready for connections
#cgate_1         | 19:54:55.528 2 XMPP [0.0.0.0]:5222 listener ready for connections
#cgate_1         | 19:54:55.528 2 XMPP [0.0.0.0]:5269 listener ready for connections
#cgate_1         | 19:54:55.528 2 XIMSS [0.0.0.0]:11024 listener ready for connections
EXPOSE 8100 8010 9010 9100 106 3478 5349 110 674 636 143 993 8021 25 5060/udp 5061/udp 5222 5269 11024

HEALTHCHECK --interval=5m --timeout=3s CMD curl -I -s -f http://localhost:8100/ || exit 1
