FROM centos:centos6
MAINTAINER Philipp Hellmich <phil@hellmi.de>

# Set the debconf frontend to Noninteractive
#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install wget
RUN yum install -y wget

# install dumb init
RUN wget -q https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64 \
-O /usr/local/bin/dumb-init \
&& chmod +x /usr/local/bin/dumb-init

# add our user to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd cgatepro -d /var/CommuniGate -r -g mail \
&& mkdir -p /var/CommuniGate \
&& chown -R cgatepro.mail /var/CommuniGate

# install communigate
RUN wget -q ftp://ftp.stalker.com/pub/CommuniGatePro/CGatePro-Linux.x86_64.rpm \
-O /tmp/CGatePro-Linux.x86_64.rpm \
&& rpm -i /tmp/CGatePro-Linux.x86_64.rpm \
&& rm /tmp/CGatePro-Linux.x86_64.rpm

# Define mountable directories.
VOLUME ["/var/CommuniGate"]

# Server CMD
CMD ["dumb-init", "/opt/CommuniGate/CGServer", "--Base /var/CommuniGate", "--dropRoot", "--logToConsole"]

# Expose ports.
# Webadmin http/https
EXPOSE 8010
EXPOSE 9010
# Webmail http/https
EXPOSE 8100
EXPOSE 9100
# Server SMTP
EXPOSE 25
# User SMTP/IMAP/POP
EXPOSE 110
EXPOSE 143
EXPOSE 587
EXPOSE 993
EXPOSE 995
EXPOSE 5060
