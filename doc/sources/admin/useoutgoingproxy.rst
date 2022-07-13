Use an outgoing proxy
=====================

For some protocols, LemonLDAP::NG has to directly contact the external server.
This is the case for example with CAS authentication (validation of
service ticket) or OpenID Connect authentication (access to token
endpoint and userinfo endpoint).

If the LL::NG server needs a proxy for outgoing connections, then you
need to configure some environment variables. By default, only connections
to external systems (CAS, OIDC, etc.) are done through the proxy, while HTTP
connections in between LemonLDAP::NG components are not.

Apache
------

In Apache configuration, set:

.. code-block:: apache

   FcgidInitialEnv http_proxy http://X.X.X.X:X
   FcgidInitialEnv https_proxy http://X.X.X.X:X
   # on Centos7, you need LWP::Protocol::connect
   # FcgidInitialEnv https_proxy connect://X.X.X.X:X

   # Optional: use this to force ALL http connections to go
   # through the proxy. This is only useful in some scenarios
   # FcgidInitialEnv PERL_LWP_ENV_PROXY 1
   # FcgidInitialEnv no_proxy <urls-without-proxy>

Nginx/FastCGI
-------------

add in ``/etc/default/lemonldap-ng-fastcgi-server`` :

::

   http_proxy=http://X.X.X.X:X
   https_proxy=http://X.X.X.X:X
   # on Centos7, you need LWP::Protocol::connect
   # https_proxy=connect://X.X.X.X:X

   # Optional: use this to force ALL http connections to go
   # through the proxy. This is only useful in some scenarios
   # PERL_LWP_ENV_PROXY=1
   # no_proxy=<urls-without-proxy>

