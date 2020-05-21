Use an outgoing proxy
=====================

For some protocols, LL::NG has to directly contact the external server.
This is the case for example with CAS authentication (validation of
service ticket) or OpenID Connect authentication (access to token
endpoint and userinfo endpoint).

If the LL::NG server needs a proxy for outgoing connections, then you
need to configure some environment variables.

Apache
------

In Apache configuration, set:

.. code-block:: apache

   FcgidInitialEnv http_proxy http://X.X.X.X:X
   FcgidInitialEnv https_proxy http://X.X.X.X:X
   # on Centos7, you need LWP::Protocol::connect
   # FcgidInitialEnv https_proxy connect://X.X.X.X:X

Nginx/FastCGI
-------------

add in ``/etc/default/lemonldap-ng-fastcgi-server`` :

::

   http_proxy=http://X.X.X.X:X
   https_proxy=http://X.X.X.X:X
   # on Centos7, you need LWP::Protocol::connect
   # https_proxy=connect://X.X.X.X:X

