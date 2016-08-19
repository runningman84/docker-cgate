CommuniGate
============

[![](https://images.microbadger.com/badges/version/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://images.microbadger.com/badges/image/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://img.shields.io/docker/stars/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")
[![](https://img.shields.io/docker/pulls/runningman84/cgate.svg)](https://hub.docker.com/r/runningman84/cgate "Click to view the image on Docker Hub")

Introduction
----
This docker image installs CommuniGate Pro using Alpine Linux.

A documentation can be found here:
https://www.communigate.com/communigatepro/


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

Finally
----
You can integrate cgate with my spamd docker image in order to filter spam. A tutorial will be published soon.
