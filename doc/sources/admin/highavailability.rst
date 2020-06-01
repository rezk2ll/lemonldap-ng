High availability
=================

LemonLDAP::NG is highly scalable, so easy to insert behind a
load-balancer:

-  Portal does not store any data outside the session database, so you
   can have many portal servers using the same HTTP host name
-  All handlers download the whole configuration, so many servers can
   serve the same virtual hosts

You can for example set up a fail-over cluster with
`Heartbeat <http://www.linux-ha.org/wiki/Heartbeat>`__ and
`HAproxy <http://haproxy.1wt.eu/>`__, like this:

|image0|

You just have to share configuration and sessions databases between
those servers:

|image1|

.. |image0| image:: /documentation/ha-apache.png
   :class: align-center
.. |image1| image:: /documentation/ha-sessions-configuration.png
   :class: align-center

