Browseable LDAP session backend
===============================

LemonLDAP::NG configuration
---------------------------

Go in the Manager and set the session module to ``Apache::Session::Browseable::LDAP`` for each session type you intend to use:

* ``General parameters`` » ``Sessions`` » ``Session storage`` » ``Apache::Session module``
* ``General parameters`` » ``Sessions`` » ``Persistent sessions`` » ``Apache::Session module``
* ``CAS Service`` » ``CAS sessions module name``
* ``OpenID Connect Service`` » ``Sessions`` » ``Sessions module name``
* ``SAML2 Service`` » ``Advanced`` » ``SAML sessions module name``

The fill out the corresponding module parameters:

======================== ================================= ===============================
Required parameters
======================== ================================= ===============================
Name                     Comment                           Example
**ldapServer**           URI of the server                 ldap://localhost
**ldapConfBase**         DN of sessions branch             ou=sessions,dc=example,dc=com
**ldapBindDN**           Connection login                  cn=admin,dc=example,dc=com
**ldapBindPassword**     Connection password               secret
**ldapRaw**              Binary attributes                 (?i:^jpegPhoto|;binary)
**Index**                Fields to index                   refer to :ref:`fieldstoindex`
Optional parameters
Name                     Comment                           Default value
**ldapObjectClass**      Objectclass of the entry          applicationProcess
**ldapAttributeId**      Attribute storing session ID      cn
**ldapAttributeContent** Attribute storing session content description
**ldapAttributeIndex**   Attribute storing index           ou
**ldapVerify**           Perform certificate validation    require (use none to disable)
**ldapCAFile**           Path of CA file bundle            (system CA bundle)
**ldapCAPath**           Perform CA directory              (system CA bundle)
======================== ================================= ===============================

.. note::

   In order to properly handle UTF-8 encoded values, you may need to set the
   ldapRaw parameter to a non-null value. This requires
   Apache::Session::Browseable >= 1.3.3
