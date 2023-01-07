Redis session backend
=====================

`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Browseable::Redis>`__
is the faster shareable session backend

Setup
-----

Install and launch a `Redis server <https://redis.io/>`__.
Install
`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Browseable::Redis>`__
Perl module.

With Sentinel, make sure you are using at least version 1.3.8 of ``Apache::Session::Browseable``, this might require installing it from Debian Backports or CPAN.

In the manager: set
`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Browseable::Redis>`__
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the connection parameters for your Redis server(s).

This backend uses the perl bindings for Redis database provided by the `Redis perl module <https://metacpan.org/pod/Redis>`__.
A complete list of supported constructor/connection options can be found in the `module documentation <https://metacpan.org/pod/Redis>`__.

E.g., Parameters (case sensitive):

============= =========================== ===============================================
Name          Comment                     Example
============= =========================== ===============================================
**server**    Redis server @ IP:PORT      127.0.0.1:6379
**sock**      Redis server @ unix socket  unix:/path/to/redis.sock
**sentinels** Redis sentinels list        127.0.0.1:26379,127.0.0.2:26379,127.0.0.3:26379
**service**   Sentinel service name       mymaster
**password**  password (== requirepass)   ChangeMe
**database**  Redis DB                    1
**Index**     Fields to index             refer to :ref:`fieldstoindex`
============= =========================== ===============================================

Security
--------

Restrict network access to the redis server. For remote servers, you can
use :doc:`SOAP session backend<soapsessionbackend>` in cunjunction to
increase security for remote server that access through an unsecure
network
