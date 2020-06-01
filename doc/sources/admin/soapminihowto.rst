Configure LemonLDAP::NG to use SOAP proxy mechanism
===================================================

LL::NG use 2 internal databases to store its configuration and sessions.
It can be configured to use SOAP instead of direct access to those
databases (for remote servers).
.. tip::

    This mechanism can be used to
    secure access for remote servers that cross an unsecured network to
    access to LL::NG databases.

Since version 2.0, same services are available by REST.

Use SOAP for Lemonldap::NG configuration
----------------------------------------

Steps:

-  :ref:`Choose and configure your main configuration storage system<start-configuration-database>`
-  Follow :doc:`SOAP configuration backend<soapconfbackend>` page
-  Restart all your remote Apache servers

Use SOAP for Lemonldap::NG sessions
-----------------------------------

Steps:

-  :ref:`Choose and configure your main sessions storage system<start-sessions-database>`
-  Follow :doc:`SOAP sessions backend<soapsessionbackend>` page
