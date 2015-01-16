FROM centos:centos6
MAINTAINER Philipp Hellmich <phil@hellmi.de>

# add our user to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd cgatepro -d /var/CommuniGate -r -g mail && mkdir -p /var/CommuniGate && chown -R cgatepro.mail /var/CommuniGate

# install wget
RUN yum install -y wget
 
# install communigate
RUN wget ftp://ftp.stalker.com/pub/CommuniGatePro/6.0/CGatePro-Linux-6.0-11.x86_64.rpm -O /tmp/CGatePro-Linux-6.0-11.x86_64.rpm && rpm -i /tmp/CGatePro-Linux-6.0-11.x86_64.rpm && rm /tmp/CGatePro-Linux-6.0-11.x86_64.rpm

# Define mountable directories.
VOLUME ["/var/CommuniGate"]

# Server CMD
CMD /opt/CommuniGate/CGServer --Base /var/CommuniGate --dropRoot

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
