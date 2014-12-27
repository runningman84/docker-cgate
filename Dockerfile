FROM ubuntu:trusty
MAINTAINER Philipp Hellmich <phil@hellmi.de>

# system update
RUN apt-get update -y
RUN apt-get upgrade -y
# tools
RUN apt-get install alien wget -y
# communigate
RUN wget ftp://ftp.stalker.com/pub/CommuniGatePro/6.0/CGatePro-Linux-6.0-10.x86_64.rpm -O /tmp/CGatePro-Linux-6.0-10.x86_64.rpm
RUN alien -i /tmp/CGatePro-Linux-6.0-10.x86_64.rpm
RUN rm /tmp/CGatePro-Linux-6.0-10.x86_64.rpm

# Clean up APT when done.
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN useradd cgatepro -d /var/CommuniGate -s /usr/sbin/nologin -g mail -r 

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
