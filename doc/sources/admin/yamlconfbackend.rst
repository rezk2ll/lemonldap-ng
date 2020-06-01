YAMLFile configuration backend
==============================

Same as :doc:`File configuration backend<fileconfbackend>` except that
configuration is stored in YAML format.

Configuration
-------------

You just have to configure a directory writable by Apache user and set
it in [configuration] section in your lemonldap-ng.ini file:

.. code-block:: ini

   [configuration]
   type  = YAMLFile
   dirName = /var/lib/lemonldap-ng/conf

