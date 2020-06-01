Configure LemonLDAP::NG to use REST proxy mechanism
===================================================

LL::NG use 2 internal databases to store its configuration and sessions.
It can be configured to use REST instead of direct access to those
databases (for remote servers).

.. tip::

    This mechanism can be used to
    secure access for remote servers that cross an unsecured network to
    access to LL::NG databases.

Use REST for Lemonldap::NG configuration
----------------------------------------

Steps:

-  :ref:`Choose and configure your main configuration storage system<start-configuration-database>`
-  Follow :doc:`REST configuration backend<restconfbackend>` page
-  Restart all your remote Apache servers

Use REST for Lemonldap::NG sessions
-----------------------------------

Steps:

-  :ref:`Choose and configure your main sessions storage system<start-sessions-database>`
-  Follow :doc:`REST sessions backend<restsessionbackend>` page
