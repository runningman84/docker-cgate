CommuniGate
============

Introduction
----
This docker image installs CommuniGate Pro using Ubuntu LTS 14.04

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
