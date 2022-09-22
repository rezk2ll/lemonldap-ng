Gerrit
======

|image0|

Presentation
------------

`Gerrit <https://www.gerritcodereview.com/>`__ allows to review commits before they are integrated into a target branch.

With the `OAuth2 provider plugin <https://gerrit.googlesource.com/plugins/oauth/>`__ Gerrit can use OAuth2 protocol for authentication.

Configuration
-------------

Gerrit
------

`Install <https://gerrit-review.googlesource.com/Documentation/config-plugins.html#installation>`__ the OAuth Provider plugin. A prebuilt package of the plugin can be found on the `Gerrit CI <https://gerrit-ci.gerritforge.com/job/plugin-oauth-bazel-master-master/lastSuccessfulBuild/artifact/bazel-bin/plugins/oauth/oauth.jar>`__.

Then, configure Gerrit:

In ``/var/gerrit/etc/gerrit.config``

::

   ...
   [auth]
     type = OAUTH
     gitBasicAuthPolicy = HTTP
   ...
   [plugin "gerrit-oauth-provider-lemonldap-oauth"]
     root-url = https://auth.<LLNG_SERVER>
     client-id = <GERRIT_CLIENT_ID>

In ``/var/gerrit/etc/secret.config``

::

   ...
   [plugin "gerrit-oauth-provider-lemonldap-oauth"]
     client-secret = <GERRIT_CLIENT_SECRET>

LL::NG
------

Add an Open ID Connect Relying Party for Gerrit

.. code-block:: bash

   # Exported attributes (the values must fit your LDAP schema)
   lemonldap-ng-cli -yes 1 \
      addKey \
        oidcRPMetaDataExportedVars/gerrit preferred_username uid \
        oidcRPMetaDataExportedVars/gerrit name cn \
        oidcRPMetaDataExportedVars/gerrit email mail \
        oidcRPMetaDataExportedVars/gerrit sub email

   # Options > Basic > Allowed redirection addresses for login
   #         > Logout > Allowed redirection addresses for logout
   lemonldap-ng-cli -yes 1 \
      addKey \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsRedirectUris 'http://<GERRIT_SERVER>/oauth' \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsPostLogoutRedirectUris 'https://<GERRIT_SERVER>/'

   # Options > Basic > Client ID
   #         > Basic > Client Secret
   lemonldap-ng-cli -yes 1 \
      addKey \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsClientID '<GERRIT_OAUTH_ID>' \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsClientSecret '<GERRIT_OAUTH_SECRET>'

   # Timeout > ID Token expiration
   #         > Access Token expiration
   # Security > ID Token signature algorithm
   lemonldap-ng-cli -yes 1 \
      addKey \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsIDTokenExpiration 3600 \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsAccessTokenExpiration 3600 \
        oidcRPMetaDataOptions/gerrit oidcRPMetaDataOptionsIDTokenSignAlg RS512


.. |image0| image:: /applications/gerrit_logo.png
   :class: align-center
