LDAP configuration backend
==========================

Presentation
------------

You can choose to store LemonLDAP::NG configuration in an LDAP
directory.

|image0|

Advantages:

-  Easy to share between servers with remote LDAP access
-  Easy to duplicate with LDAP synchronization services (like SyncRepl
   in OpenLDAP)
-  Security with SSL/TLS
-  Access control possible by creating one user for Manager (write) and
   another for portal and handlers (read)
-  Easy import/export through LDIF files

The configuration will be store under a specific branch, for example
``ou=conf,ou=applications,dc=example,dc=com``.

Each configuration will be represented as an entry, which structural
objectClass is by default ``applicationProcess``. The configuration name
is the same that files, so lmConf-1, lmConf-2, etc. This name is used in
entry DN, for example
``cn=lmConf-1,ou=conf,ou=applications,dc=example,dc=com``.

Then each parameter is one value of the attribute ``description``,
prefixed by its key. For example ``{ldapPort}389``.

The LDIF view of such entry can be:

::

   dn: cn=lmConf-1,ou=conf,ou=applications,dc=example,dc=com
   objectClass: top
   objectClass: applicationProcess
   cn: lmConf-1
   description: {globalStorage}'Apache::Session::File'
   description: {cookieName}'lemonldap'
   description: {whatToTrace}'$uid'
   ...

Configuration
-------------

LDAP server
~~~~~~~~~~~

Configuration objects use standard object class: ``applicationProcess``.
This objectClass allow attributes ``cn`` and ``description``. If your
LDAP server do not manage this objectClass, configure other objectclass
and attributes (see below).

We advice to create a specific LDAP account with write access on
configuration branch.

Next create the configuration branch where you want. Just remember its
DN for LemonLDAP::NG configuration.

LemonLDAP::NG
~~~~~~~~~~~~~

Configure LDAP configuration backend in ``lemonldap-ng.ini``, section
``[configuration]``:

.. code-block:: ini

   type = LDAP
   ldapServer = ldap://localhost
   ldapConfBase = ou=conf,ou=applications,dc=example,dc=com
   ldapBindDN = cn=manager,dc=example,dc=com
   ldapBindPassword = secret
   ldapObjectClass = applicationProcess
   ldapAttributeId = cn
   ldapAttributeContent = description

Parameters:

-  **ldapServer**: LDAP URI of the server
-  **ldapConfBase**: DN of configuration branch
-  **ldapBindDN**: DN used to bind LDAP
-  **ldapBindPassword**: password used to bind LDAP
-  **ldapObjectClass**: structural objectclass of configuration entry
   (optional)
-  **ldapAttributeId**: RDN attribute of configuration entry (optional)
-  **ldapAttributeContent**: attribute used to store configuration
   values, must be multivalued (optional)
-  **ldapVerify**: When using a LDAPS or TLS server, whether or not to validate the server certificate. Possible values: ``require``, ``optional`` or ``none``.
-  **ldapCAFile**:  This allows you to override the default system-wide
   certificate authorities by giving a single file containing the CA used by the
   LDAP server.
-  **ldapCAPath**: This allows you to override the default system-wide
   certificate authorities by giving the path of a directory containing your
   trusted certificates.


.. |image0| image:: /documentation/configuration-ldap.png
   :class: align-center

