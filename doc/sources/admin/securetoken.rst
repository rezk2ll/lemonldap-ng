Secure Token Handler
====================

Presentation
------------

The Secure Token Handler is a special Handler that creates a token for
each request and send it to the protected application. The real user
identifier is stored in a Memcached server and the protected application
can request the Memcached server to get user identifier.

This mechanism allows one to protect an application with an unsafe link
between Handler and the application, but with a safe link between the
Memcached server and the application.

Configuration
-------------

Install Cache::Memcached dependency.

Virtual host
~~~~~~~~~~~~

You just have to set "Type: SecureToken" in the VirtualHost options in
the manager.

If you want to protect only a virtualHost part, keep type on "Main" and
set type in your configuration file:

-  Apache: use simply a ``PerlSetVar VHOSTTYPE AuthBasic``
-  Nginx: create another FastCGI with a
   ``fastcgi_param VHOSTTYPE SecureToken;``


.. note::

    This handler uses Apache2Filter Module to hide token, prefer
    :doc:`Handling server webservice calls<servertoserver>` for other
    servers.

Handler parameters
~~~~~~~~~~~~~~~~~~

SecureToken parameters are the following:

-  **Memcached servers**: addresses of Memcached servers, separated with
   spaces
-  **Token expiration**: time in seconds for token expiration (remove
   from Memcached server)
-  **Attribute to store**: session key that will be stored in
   Memcached
-  **Protected URLs**: Regexp of URLs for which the secure token will be
   sent, separated by spaces
-  **Header name**: name of the HTTP header carrying by the secure
   token
-  **Allow requests in error**: allow a request that has generated an
   error in token generation to be forwarded to the protected
   application without secure token (default: yes)


.. attention::

    Due to Handler API change in 1.9, you need to set these
    attributes in ``lemonldap-ng.ini`` and not in Manager, for example:

    .. code:: ini

       [handler]
       secureTokenMemcachedServers = 127.0.0.1:11211
       secureTokenExpiration = 60
       secureTokenAttribute = uid
       secureTokenUrls = .*
       secureTokenHeader = Auth-Token
       secureTokenAllowOnError = 1


