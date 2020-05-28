Redis session backend
=====================

`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Browseable::Redis>`__
is the faster shareable session backend

Setup
-----

Install and launch a `Redis server <http://code.google.com/p/redis/>`__.
Install
`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Redis>`__
Perl module.

In the manager: set
`Apache::Session::Browseable::Redis <https://metacpan.org/pod/Apache::Session::Browseable::Redis>`__
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

Parameters:

============= ==================== ===============================================
Name          Comment              Example
============= ==================== ===============================================
**server**    Redis server         127.0.0.1:6379
**sentinels** Redis sentinels list 127.0.0.1:26379,127.0.0.2:26379,127.0.0.3:26379
============= ==================== ===============================================

You can specify either a single Redis server or a list of Sentinel hosts
using the \*sentinels\* module parameter

You can find the complete list of supported options on the `Redis perl module
documentation <https://metacpan.org/pod/Redis#new>`__.

Security
--------

Restrict network access to the redis server. For remote servers, you can
use :doc:`SOAP session backend<soapsessionbackend>` in cunjunction to
increase security for remote server that access through an unsecure
network
