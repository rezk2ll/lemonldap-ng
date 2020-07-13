How to change configuration backend
===================================

LemonLDAP::NG provides a script to change configuration backend easily
keeping history. It is set in LemonLDAP::NG utilities directory
(``convertConfig``).

How it works
------------

The ``convertConfig`` utility reads 2 LL::NG configuration files
(``lemonldap-ng.ini``):

-  **Current**: to extract all configuration history
-  **New**: to write all configuration history

Let's go
--------

-  Prepare your new lemonldap-ng.ini file
-  Configure your new backend (create SQL database,...)
-  Launch the following command:

.. code-block:: shell

   convertConfig --current=/etc/lemonldap-ng/lemonldap-ng.ini --new=/new/lemonldap-ng.ini

-  Install the new lemonldap-ng.ini file at the place of the old file in
   all LL::NG servers
-  Restart all your Apache servers

.. note::

   Since LemonLDAP 2.0.9, you don't need the ``--current`` and ``--new`` options
   when migrating from the default file-based backend. Simply run
   `convertConfig` to migrate from the default configuration backend to the
   currently configured backend.


See also
--------

Documentation is available for configuration backends :

-  :doc:`SQL<sqlconfbackend>`
-  :doc:`File<fileconfbackend>`
-  :doc:`LDAP<ldapconfbackend>`
-  :doc:`SOAP proxy mechanism<soapconfbackend>`
