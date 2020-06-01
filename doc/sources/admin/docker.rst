LemonLDAP::NG in Docker
=======================

|image0|

Presentation
------------

`Docker <https://www.docker.com/>`__ allows do run application into
containers.

You can find a Docker image for LemonLDAP::NG in this repository:
https://hub.docker.com/r/coudot/lemonldap-ng/

See also this github project:
https://github.com/LemonLDAPNG/lemonldap-ng-docker

Usage
-----

Prerequisites:

-  Add
   auth.example.com/manager.example.com/test1.example.com/test2.example.com
   to /etc/hosts on the host

::

   echo "127.0.0.1 auth.example.com manager.example.com test1.example.com test2.example.com" | sudo tee -a /etc/hosts

-  Map the container port 80 to host port 80 (option -p)

::

   docker run -d -p 80:80 coudot/lemonldap-ng

Then connect to http://auth.example.com with your browser and log in
with dwho/dwho.

.. |image0| image:: /documentation/lemonldap-ng-docker.png
   :class: align-center

