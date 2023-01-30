SecureToken Handler
===================

Presentation
------------

The SecureToken Handler is a particular Handler that generates a token at
each request and send it to protected application. User identifier is
stored in a Memcached server and the protected application
can retrieve the user identifier from the Memcached server.

This mechanism allows one to protect an application with an unsafe link
between Handler and the application, but with a safe link between the
Memcached server and the application.

Configuration
-------------

Install Cache::Memcached dependency.

Virtual host
~~~~~~~~~~~~

You just have to set "Type: SecureToken" in the VirtualHost options in manager.

If you want to protect only a virtualHost location, select "Main" in
the manager and set type in your web server configuration file:

-  Apache: just use ``PerlSetVar VHOSTTYPE SecureToken`` directive
-  Nginx: set ``fastcgi_param VHOSTTYPE SecureToken;`` parameter

.. note::

    This handler uses Apache2Filter Module to hide token, prefer
    :doc:`Handling server webservice calls<servertoserver>` for other
    servers.

Handler parameters
~~~~~~~~~~~~~~~~~~

SecureToken parameters are the following:

-  **Memcached servers**: space-separated list of Memcached server addresses
-  **Token expiration**: time in seconds for token expiration (remove
   from Memcached server)
-  **Attribute to store**: session key that will be stored in Memcached
-  **Protected URLs**: space-separated list of Regexp to match URLs for
   which the secure token will be sent
-  **Header name**: HTTP header name to carry out the secure token
-  **Allow requests in error**: allow a request that has generated an
   error during token generation to be forwarded to the protected
   application without secure token (default: yes)


.. attention::

    SecureToken Handler paremeters must be set in ``lemonldap-ng.ini`` file
    not in Manager, for example:

    .. code:: ini

       [handler]
       secureTokenMemcachedServers = 127.0.0.1:11211
       secureTokenExpiration = 60
       secureTokenAttribute = uid
       secureTokenUrls = .*
       secureTokenHeader = Auth-Token
       secureTokenAllowOnError = 1