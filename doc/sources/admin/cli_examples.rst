Command Line Interface (lemonldap-ng-cli) examples
==================================================

This page shows some examples of LL::NG Command Line Interface. See
:ref:`how to use the command<configlocation-command-line-interface-cli>`.


.. attention::

    On Debian, the command is located in
    ``/usr/share/lemonldap-ng/bin`` and on CentOS in
    ``/usr/libexec/lemonldap-ng/bin``. Adapt the path for the system you are
    using.

Save/restore configuration
--------------------------

This part requires LLNG 2.0.5 at least.

Save:

.. code-block:: sh

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli save >config.json

Restore:

.. code-block:: shell

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli restore config.json
   # Or
   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli restore - <config.json

Rollback (restore previous configuration, *since 2.0.8*):

.. code-block:: shell

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli rollback

Configure HTTPS
---------------

When setting HTTPS, you first need to modify Apache/Nginx configuration,
then you must configure LL::NG to change portal URL, Handler
redirections, cookie settings, ...

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           portal https://auth.example.com \
           mailUrl https://auth.example.com/resetpwd \
           registerUrl https://auth.example.com/register \
           https 1 \
           securedCookie 1

Configure sessions backend
--------------------------

For production, it is recommended to use
:doc:`Browseable session backend<browseablesessionbackend>`. Once tables
are created with columns corresponding to index, the following commands
can be executed to set all the session backends.

In this example we have:

-  Backend: PostGreSQL
-  DB user: lemonldaplogin
-  DB password: lemonldappw
-  Database: lemonldapdb
-  Host: pg.example.com

-  SSO sessions:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       delKey \
           globalStorageOptions Directory \
           globalStorageOptions LockDirectory

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           globalStorage Apache::Session::Browseable::Postgres

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           globalStorageOptions DataSource 'DBI:Pg:database=lemonldapdb;host=pg.example.com' \
           globalStorageOptions UserName 'lemonldaplogin' \
           globalStorageOptions Password 'lemonldappw' \
           globalStorageOptions Commit 1 \
           globalStorageOptions Index 'ipAddr _whatToTrace user' \
           globalStorageOptions TableName 'sessions'

-  Persistent sessions:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       delKey \
           persistentStorageOptions Directory \
           persistentStorageOptions LockDirectory

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           persistentStorage Apache::Session::Browseable::Postgres

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           persistentStorageOptions DataSource 'DBI:Pg:database=lemonldapdb;host=pg.example.com' \
           persistentStorageOptions UserName 'lemonldaplogin' \
           persistentStorageOptions Password 'lemonldappw' \
           persistentStorageOptions Commit 1 \
           persistentStorageOptions Index '_session_uid' \
           persistentStorageOptions TableName 'psessions'

-  CAS sessions

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           casStorage Apache::Session::Browseable::Postgres

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           casStorageOptions DataSource 'DBI:Pg:database=lemonldapdb;host=pg.example.com' \
           casStorageOptions UserName 'lemonldaplogin' \
           casStorageOptions Password 'lemonldappw' \
           casStorageOptions Commit 1 \
           casStorageOptions Index '_cas_id' \
           casStorageOptions TableName 'cassessions'

-  SAML sessions

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           samlStorage Apache::Session::Browseable::Postgres

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
          samlStorageOptions DataSource 'DBI:Pg:database=lemonldapdb;host=pg.example.com' \
          samlStorageOptions UserName 'lemonldaplogin' \
          samlStorageOptions Password 'lemonldappw' \
          samlStorageOptions Commit 1 \
          samlStorageOptions Index '_saml_id ProxyID _nameID _assert_id _art_id _session_id' \
          samlStorageOptions TableName 'samlsessions'

-  OpenID Connect sessions

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
          oidcStorage Apache::Session::Browseable::Postgres

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
          oidcStorageOptions DataSource 'DBI:Pg:database=lemonldapdb;host=pg.example.com' \
          oidcStorageOptions UserName 'lemonldaplogin' \
          oidcStorageOptions Password 'lemonldappw' \
          oidcStorageOptions Commit 1 \
          oidcStorageOptions TableName 'oidcsessions'

Configure virtual host
----------------------

A virtual host must be defined in Apache/Nginx and access rules and
exported headers must be configured in LL::NG.

In this example we have:

-  host: test.example.com
-  Access rules:

   -  default => accept
   -  Logout: ^/logout\.php => logout_sso

-  Headers:

   -  Auth-User: $uid
   -  Auth-Mail: $mail

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           'locationRules/test.example.com' 'default' 'accept' \
           'locationRules/test.example.com' '(?#Logout)^/logout\.php' 'logout_sso' \
           'exportedHeaders/test.example.com' 'Auth-User' '$uid' \
           'exportedHeaders/test.example.com' 'Auth-Mail' '$mail'

Configure form replay
---------------------

To add form replay on a host, you need to set the catched URI and
the variables to post.

In this example we have:

- Host: test.example.com
- Catched URI: /login.php
- jQuery URL: default

- Variables:
   - login: $uid
   - password: $_password

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 -sep , \
       addKey \
           post,test.example.com,'/login.php' jqueryUrl default

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 -sep , \
       addPostVars \
           post,test.example.com,'/login.php' login '$uid' \
           post,test.example.com,'/login.php' password '$_password'

Configure LDAP authentication backend
-------------------------------------

In this example we use:

-  LDAP server: ldap://ldap.example.com
-  LDAP Bind DN : cn=lemonldapng,ou=dsa,dc=example,dc=com
-  LDAP Bind PW: changeit
-  LDAP search base: ou=users,dc=example,dc=com
-  LDAP attributes:

   -  uid => uid
   -  cn => cn
   -  mail => mail
   -  sn => sn
   -  givenName => givenName
   -  mobile => mobile

-  LDAP group base: ou=groups,dc=example,dc=com
-  Use recursive search for groups

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           authentication LDAP \
           userDB LDAP \
           passwordDB LDAP \
           ldapServer 'ldap://ldap.example.com' \
           managerDn 'cn=lemonldapng,ou=dsa,dc=example,dc=com' \
           managerPassword 'changeit' \
           ldapBase 'ou=users,dc=example,dc=com'

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           ldapExportedVars uid uid \
           ldapExportedVars cn cn \
           ldapExportedVars sn sn \
           ldapExportedVars mobile mobile \
           ldapExportedVars mail mail \
           ldapExportedVars givenName givenName

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           ldapGroupBase 'ou=groups,dc=example,dc=com' \
           ldapGroupObjectClass groupOfNames \
           ldapGroupAttributeName member \
           ldapGroupAttributeNameGroup dn \
           ldapGroupAttributeNameSearch cn \
           ldapGroupAttributeNameUser dn \
           ldapGroupRecursive 1

Configure CAS Identity Provider
-------------------------------

You just have to enable the CAS server feature, and you can set the
access control policy (see
:ref:`CAS service options<idpcas-configuring-the-cas-service>`):

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           issuerDBCASActivation 1 \
           casAccessControlPolicy error

Register a CAS application
--------------------------

This is only required if your access control policy is not ``none``.

In this example we have:

-  App configuration key: testapp
-  App service URL: https://testapp.example.com/
-  App exported attribute: mail and cn

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           casAppMetaDataExportedVars/testapp mail mail \
           casAppMetaDataExportedVars/testapp cn cn
           casAppMetaDataOptions/testapp casAppMetaDataOptionsService 'https://testapp.example.com/'

Configure SAML Identity Provider
--------------------------------

You can then generate a private key and a self-signed certificate with
these commands;

::

   openssl req -new -newkey rsa:4096 -keyout saml.key -nodes  -out saml.pem -x509 -days 3650

Fix the certificate key format (you can skip this step if you are
running >= 2.0.6)

::

   sed -e "s/END PRIVATE/END RSA PRIVATE/" \
       -e "s/BEGIN PRIVATE/BEGIN RSA PRIVATE/" \
       -i saml.key

Import them in configuration and activate the SAML issuer

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           samlServicePrivateKeySig "`cat saml.key`" \
           samlServicePublicKeySig "`cat saml.pem`" \
           issuerDBSAMLActivation 1

You can also define organization name and URL for SAML metadata:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           samlOrganizationName 'ACME' \
           samlOrganizationDisplayName 'ACME Corporation' \
           samlOrganizationURL 'http://www.acme.com'

Register an SAML Service Provider
---------------------------------

In this example we have:

-  SP configuration key: testsp
-  SP metadata file: metadata-testsp.xml
-  SP exported attribute: EmailAdress (filled with mail session key)

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           samlSPMetaDataXML/testsp samlSPMetaDataXML "`cat metadata-testsp.xml`" \
           samlSPMetaDataExportedAttributes/testsp mail '1;EmailAddress'

Configure OpenID Connect Identity Provider
------------------------------------------

Activate the OpenID Connect Issuer and set issuer name (equal to portal
URL):

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           issuerDBOpenIDConnectActivation 1 \
           oidcServiceMetaDataIssuer http://auth.example.com

Generate keys:

::

   openssl genrsa -out oidc.key 4096
   openssl rsa -pubout -in oidc.key -out oidc_pub.key

Import them:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           oidcServicePrivateKeySig "`cat oidc.key`" \
           oidcServicePublicKeySig "`cat oidc_pub.key`" \
           oidcServiceKeyIdSig "`genpasswd`"

If needed you can allow implicit and hybrid flows:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           oidcServiceAllowImplicitFlow 1 \
           oidcServiceAllowHybridFlow 1

Register an OpenID Connect Relying Party
----------------------------------------

In this example we have:

-  RP configuration key: testrp
-  Client ID : testclientid
-  Client secret : testclientsecret
-  Allowed redirection URL:

   -  For login: https://testrp.example.com/?callback=1
   -  For logout: https://testrp.example.com/

-  Exported attributes:

   -  email => mail
   -  familiy_name => sn
   -  name => cn

-  Exported attributes:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           oidcRPMetaDataExportedVars/testrp email mail \
           oidcRPMetaDataExportedVars/testrp family_name sn \
           oidcRPMetaDataExportedVars/testrp name cn

-  Credentials:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           oidcRPMetaDataOptions/testrp oidcRPMetaDataOptionsClientID testclientid \
           oidcRPMetaDataOptions/testrp oidcRPMetaDataOptionsClientSecret testclientsecret

-  Redirection:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           oidcRPMetaDataOptions/testrp oidcRPMetaDataOptionsRedirectUris 'https://testrp.example.com/?callback=1' \
           oidcRPMetaDataOptions/testrp oidcRPMetaDataOptionsPostLogoutRedirectUris 'https://testrp.example.com/'

-  Signature and token expiration:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           oidcRPMetaDataOptions/testrp  oidcRPMetaDataOptionsIDTokenSignAlg RS512 \
           oidcRPMetaDataOptions/testrp  oidcRPMetaDataOptionsIDTokenExpiration 3600 \
           oidcRPMetaDataOptions/testrp oidcRPMetaDataOptionsAccessTokenExpiration 3600

Categories and applications in menu
-----------------------------------

Create the category "applications":

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           applicationList/applications type category \
           applicationList/applications catname Applications

Create the application "sample" inside category "applications":

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       addKey \
           applicationList/applications/sample type application \
           applicationList/applications/sample/options description "A sample application" \
           applicationList/applications/sample/options display "auto" \
           applicationList/applications/sample/options logo "tux.png" \
           applicationList/applications/sample/options name "Sample application" \
           applicationList/applications/sample/options uri "https://sample.example.com/"


.. _cli-examples-encryption-key:

Encryption key
--------------

To update the master encryption key:

::

   /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
       set \
           key 'xxxxxxxxxxxxxxx'


.. _cli-sessions:

Sessions Management
-------------------
.. versionadded:: 2.0.9


Get the content of a session ::

   lemonldap-ng-sessions get 9684dd2a6489bf2be2fbdd799a8028e3

Get the content of a persistent session ::

   lemonldap-ng-sessions get --persistent dwho

Search all sessions by username ::

   lemonldap-ng-sessions search --where uid=dwho

Modify session ::

   lemonldap-ng-sessions setKey 9684dd2a6489bf2be2fbdd799a8028e3 \
      authenticationLevel 1


.. versionadded:: 2.0.10
   Delete all sessions by username

::

   lemonldap-ng-sessions delete --where uid=dwho


Second Factors management
-------------------------

.. versionadded:: 2.0.9

List second factors of a user ::

   lemonldap-ng-sessions secondfactors get dwho

Deregister Yubikey of a user ::

   lemonldap-ng-sessions secondfactors delType dwho UBK

OIDC Consents management
------------------------

.. versionadded:: 2.0.9

List consents of a user ::
   
   lemonldap-ng-sessions consents get dwho

Revoke consents on OIDC provider 'test' for a user::

   lemonldap-ng-sessions consents delete dwho test
