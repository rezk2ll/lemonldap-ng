File configuration backend
==========================

This is the default configuration backend. Configuration is stored as
JSON.


.. tip::

    This configuration storage can be shared between different
    hosts using:

    -  :doc:`SOAP configuration backend proxy<soapconfbackend>`
    -  any files sharing system (NFS, NAS, SAN,...)



Configuration
-------------

You just have to configure a directory writable by Apache user and set
it in [configuration] section in your lemonldap-ng.ini file:

.. code-block:: ini

   [configuration]
   type  = File
   dirName = /var/lib/lemonldap-ng/conf
   prettyPrint = 1


Parameters
----------

* `dirName`: directory under which the configuration files will be stored. It must be writable by your webserver account
* `prettyPrint`: store files in a readable. Set it to 0 to get a small performance increase when loading/saving configuration
