LDAP session backend
====================

An Apache session module was created by LL::NG team to store sessions in
an LDAP directory.


.. attention::

    This module is not part of LL::NG distribution, and can
    be found on CPAN:
    `Apache::Session::LDAP <http://search.cpan.org/dist/Apache-Session-LDAP/>`__.


.. tip::

    This module is also available on
    `GitHub <https://github.com/coudot/apache-session-ldap>`__.

Sessions will be stored as LDAP entries, like this:

::

   dn: cn=6fb7c4a170a04668771f03b0a4747f46,ou=sessions,dc=example,dc=com
   objectClass: applicationProcess
   cn: 6fb7c4a170a04668771f03b0a4747f46
   description: [Base64 serialized data]

Setup
-----

Go in the Manager and set the LDAP session module
(`Apache::Session::LDAP <http://search.cpan.org/dist/Apache-Session-LDAP/>`__)
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

======================== ================================= ===============================
Required parameters
------------------------------------------------------------------------------------------
Name                     Comment                           Example
======================== ================================= ===============================
**ldapServer**           URI of the server                 ldap://localhost
**ldapConfBase**         DN of sessions branch             ou=sessions,dc=example,dc=com
**ldapBindDN**           Connection login                  cn=admin,dc=example,dc=dom
**ldapBindPassword**     Connection password               secret
======================== ================================= ===============================

======================== ================================= ===============================
Optional parameters
------------------------------------------------------------------------------------------
Name                     Comment                           Default value
======================== ================================= ===============================
**ldapObjectClass**      Objectclass of the entry          applicationProcess
**ldapAttributeId**      Attribute storing session ID      cn
**ldapAttributeContent** Attribute storing session content description
**ldapVerify**           Perform certificate validation    require (use none to disable)
**ldapCAFile**           Path of CA file bundle            (system CA bundle)
**ldapCAPath**           Perform CA directory              (system CA bundle)
======================== ================================= ===============================

Security
--------

Restrict network access to the LDAP directory, and add specific ACL to
session branch.

You can also use different user/password for your servers by overriding
parameters ``globalStorage`` and ``globalStorageOptions`` in
lemonldap-ng.ini file.
