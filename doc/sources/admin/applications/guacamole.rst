Guacamole
=========

|image0|

Presentation
------------

`Apache Guacamole <https://guacamole.apache.org/>`__ is a web-based
remote desktop gateway. It supports standard protocols like VNC, RDP,
and SSH.

As of version 0.9.14, Guacamole can use
:doc:`OpenID Connect<../idpopenidconnect>` , :doc:`CAS<../idpcas>` or
:doc:`HTTP Headers<../writingrulesand_headers>` as authentication
sources through plug-ins.

This document explains how to implement OpenID Connect

Pre-requisites
--------------

.. _guacamole-1:

Guacamole
~~~~~~~~~

Refer to `the official Guacamole
documentation <http://guacamole.apache.org/doc/gug/>`__ to install
Guacamole, either manually or through Docker images

You need to be able to enable extensions. If you are using docker, you
need to `follow these instructions in order to provide your own
extensions directory and Guacamole configuration
file <http://guacamole.apache.org/doc/gug/guacamole-docker.html#guacamole-docker-guacamole-home>`__

Your Guacamole configuration directory will look something like this.

::

   ├── extensions
   │   └── 00-guacamole-auth-openid-1.0.0.jar
   └── guacamole.properties


.. danger::

    Make sure to rename the JAR in a way that `ensures that it
    will be loaded
    first <https://lists.apache.org/thread.html/b781a5c4e4d14f7ce297200ba6886d888df4333f83836220ac8b69f1@%3Cuser.guacamole.apache.org%3E>`__\

And ``guacamole.properties`` should contain at least

::

   openid-authorization-endpoint: http://auth.example.com/oauth2/authorize
   openid-jwks-endpoint: http://auth.example.com/oauth2/jwks
   openid-issuer: http://auth.example.com
   openid-client-id: guacamole
   openid-redirect-uri: http://guacamole.example.com/guacamole/
   openid-username-claim-type: sub


.. tip::

    Remplace the ``redirect uri`` with your Guacamole server's URL


LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server

You also need to allow the ``Implicit Flow`` under
``OpenID Connect Service`` » ``Security``

Then, add a Relaying Party with the following configuration

-  Options » Authentification » Client ID : same as ``openid-client-id``
   in ``guacamole.properties``
-  Options » Allowed redirection address : same as
   ``openid-redirect-uri`` in ``guacamole.properties``
-  Options » ID Token Signature Algorithm : ``RS512``

.. |image0| image:: /applications/guacamole.png
   :class: align-center

