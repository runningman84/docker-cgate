CommuniGate
============

[![](https://images.microbadger.com/badges/version/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://images.microbadger.com/badges/image/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://img.shields.io/docker/stars/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://img.shields.io/docker/pulls/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![Anchore Image Overview](https://anchore.io/service/badges/image/33d1c1f2abf0d2f7d6e56decfe4025064c78cbbe5ba634b3f6df9544071f1c5c)](https://anchore.io/image/dockerhub/runningman84%2Fcgate%3Alatest)

Introduction
----
This docker image installs CommuniGate Pro using Ubuntu 18.04 base image.

A documentation can be found here:
[https://www.communigate.com/communigatepro/](https://www.communigate.com/communigatepro/)


Install
----

```sh
docker pull runningman84/cgate
```

Running
----

```sh
docker run -d -P -p 8010:8010 -p 8100:8100 -p 25:25 -p 110:110 -p 143:143 runningman84/cgate
```
CommuniGate provides a lot of servies the corresponding ports can be seen in this output:
```
cgate_1         | 19:54:55.527 2 HTTPU [0.0.0.0]:8100 listener ready for connections
cgate_1         | 19:54:55.527 2 HTTPA [0.0.0.0]:8010 listener ready for connections
cgate_1         | 19:54:55.527 2 HTTPA [0.0.0.0]:9010 listener ready for connections
cgate_1         | 19:54:55.528 2 HTTPU [0.0.0.0]:9100 listener ready for connections
cgate_1         | 19:54:55.528 2 PWD [0.0.0.0]:106 listener ready for connections
cgate_1         | 19:54:55.528 2 STUN [0.0.0.0]:3478 listener ready for connections
cgate_1         | 19:54:55.528 2 STUN [0.0.0.0]:5349 listener ready for connections
cgate_1         | 19:54:55.528 2 POP [0.0.0.0]:110 listener ready for connections
cgate_1         | 19:54:55.528 2 ACAP [0.0.0.0]:674 listener ready for connections
cgate_1         | 19:54:55.528 2 LDAP [0.0.0.0]:636 listener ready for connections
cgate_1         | 19:54:55.528 2 LDAP [0.0.0.0]:389 listener ready for connections
cgate_1         | 19:54:55.528 2 IMAP [0.0.0.0]:143 listener ready for connections
cgate_1         | 19:54:55.528 2 IMAP [0.0.0.0]:993 listener ready for connections
cgate_1         | 19:54:55.528 2 FTP [0.0.0.0]:8021 listener ready for connections
cgate_1         | 19:54:55.528 2 SMTP [0.0.0.0]:25 listener ready for connections
cgate_1         | 19:54:55.528 2 SIP [0.0.0.0]:5060 listener ready for connections
cgate_1         | 19:54:55.528 2 SIP [0.0.0.0]:5061 listener ready for connections
cgate_1         | 19:54:55.528 2 XMPP [0.0.0.0]:5222 listener ready for connections
cgate_1         | 19:54:55.528 2 XMPP [0.0.0.0]:5269 listener ready for connections
cgate_1         | 19:54:55.528 2 XIMSS [0.0.0.0]:11024 listener ready for connections
```

The container can be configured using these ENVIRONMENT variables:

Key | Description | Default
------------ | ------------- | -------------
MAILSERVER_DOMAIN | The primary domain of the mailserver | example.org
MAILSERVER_HOSTNAME | The hostname of the mailserver | mail.example.org
HELPER_THREADS | The number of helper threads for cgpav | 1
CGPAV_SPAMASSASIN_HOST | The hostname of the spamd service | localhost
CGPAV_SPAMASSASIN_PORT | The port of the spamd service | 783
CGPAV_VIRUS_ACTION | How to handle infected mails | none (virus scanning disabled)
CGPAV_SPAM_ACTION | How to handle spam mails | addheaderjunk

CGPAV filter is preconfigured. The CGPAV filter scans using spamassassin.

Finally
----
You should use an extra volume for /var/CommuniGate to store the user data outside this container.

An intergration with my spamd container can look like this:

```
cgate:
  image: runningman84/cgate
  links:
    - spamd:spamd
  ports:
    - 25:25
    - 143:143
    - 8100:8100
    - 9100:9100
    - 8010:8010
    - 9010:9010
  environment:
    - CGPAV_SPAMASSASIN_HOST=spamd
    - MAILSERVER_DOMAIN=example.com
    - MAILSERVER_HOSTNAME=mail.example.com
    - HELPER_THREADS=1
spamd:
  image: runningman84/spamd
```
