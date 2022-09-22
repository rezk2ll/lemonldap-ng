REST configuration backend
==========================

You can share your configuration over the network using REST proxy
system:

-  GET /config/latest: get the last config metadata
-  GET /config/<cfgNum>: get the metadata for config n° <cfgNum>
-  GET /config/<latest|cfgNum>/<key>: get conf key value
-  GET /config/<latest|cfgNum>?full=1: get the full configuration

You can retrieve "human readable" error messages:

-  GET /error/<lang>/<errNum>: get <errNum> error reference and <lang>
   errors file.

If no <lang> provided, 'en' errors file is returned.


.. tip::

    Note that REST is not a real configuration backend, but just a
    proxy system to access to your configuration over the network

Configuration
-------------

First, configure your real backend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  On your main server, configure a
   :doc:`File<fileconfbackend>`,
   :doc:`SQL<sqlconfbackend>` or
   :doc:`LDAP<ldapconfbackend>` backend
-  Enable REST server in the configuration using the manager (in portal
   plugins)
-  Configure your web server to allow remote access. Remote REST access
   is disabled by default. Change it as follow:

\* In ``portal-apache2.conf``:

.. code-block:: apache

   # REST functions for configuration access (disabled by default)
   <Location /index.fcgi/config>
       Require ip 192.168.2.0/24
   </Location>

\* In ``portal-nginx.conf``:

.. code-block:: nginx

   # REST functions for configuration access (disabled by default)
   location /index.psgi/config {
     allow 192.168.2.0/24;
   }

Next, configure REST for your remote servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Change configuration in lemonldap-ng.ini :

.. code-block:: ini

   type         = REST
   ; Apache
   baseUrl      = https://auth.example.com/index.fcgi/config
   ; Nginx
   baseUrl      = https://auth.example.com/index.psgi/config

You can also add some other parameters

.. code-block:: ini

   User         = lemonldap
   Password     = mypassword
   # LWP::UserAgent parameters
   proxyOptions = { timeout => 5 }

`User` and `Password` parameters are only used if the entry point `index.fcgi/config`
is protected by a basic authentication. Thus, handlers will make requests to the portal
using these parameters.

