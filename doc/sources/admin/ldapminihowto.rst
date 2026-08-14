Configure LemonLDAP::NG to use LDAP as main database
====================================================

LemonLDAP::NG use 2 internal databases to store its configuration and sessions.

Use LDAP for configuration
--------------------------

Steps:

-  :doc:`Prepare the LDAP server and the LemonLDAP::NG configuration file<ldapconfbackend>`
-  :doc:`Convert existing configuration<changeconfbackend>`
-  Restart all your Apache servers

Use LDAP for sessions
---------------------

Steps:

-  Follow :doc:`LDAP session backend<ldapsessionbackend>` doc
