SOAP configuration backend (deprecated)
=======================================

You can share your configuration over the network using SOAP proxy
system.


.. tip::

    Note that SOAP is not a real configuration backend, but just a
    proxy system to access to your configuration over the network


.. attention::

    SOAP has been deprecated. Prefer to use
    :doc:`REST configuration backend<restconfbackend>`\

Configuration
-------------

First, configure your real backend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  On your main server, configure a
   :doc:`File<fileconfbackend>`,
   :doc:`SQL<sqlconfbackend>` or
   :doc:`LDAP<ldapconfbackend>` backend
-  Set SOAP parameter to true in the configuration using the manager:
   the portal will become a SOAP server
-  Configure your web server to allow remote access. Remote SOAP access
   is disabled by default. You must change it as follow :

- in ``portal-apache2.conf`` :

.. code-block:: apache

   # SOAP functions for configuration access (disabled by default)
   <Location /index.fcgi/config>
       Require ip 192.168.2.0/24
   </Location>

- in ``portal-nginx.conf`` :

.. code-block:: nginx

   # SOAP functions for configuration access (disabled by default)
   location /index.psgi/config {
     allow 192.168.2.0/24;
   }

.. _soapconfbackend-next-configure-soap-for-your-remote-servers:

Next, configure SOAP for your remote servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Change configuration in lemonldap-ng.ini :

.. code-block:: ini

   type         = SOAP
   ; Apache
   proxy        = https://auth.example.com/index.fcgi/config
   ; Nginx
   proxy        = https://auth.example.com/index.pcgi/config

You can also add some other parameters

.. code-block:: ini

   User         = lemonldap
   Password     = mypassword
   # LWP::UserAgent parameters
   proxyOptions = { timeout => 5 }

