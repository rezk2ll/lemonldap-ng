Agent Connect
==============

|image0|

Presentation
------------

`Agent Connect <https://agentconnect.gouv.fr/>`__ is an
authentication platform made by French government for people
working for the state. It relies on OpenID Connect protocol.

To select on which Identity Provider the user will be redirected,
Agent Connect relies on the email domain :

|agentconnect_login_form|

.. tip::

    All users of an email domain will use the same Identity Provider.


LemonLDAP::NG can be used as Relying Party or OpenID Provider for Agent Connect.

Official documentation is available on `Github <https://github.com/france-connect/Documentation-AgentConnect/blob/main/README.md#-agentconnect---documentation>`__.

LL::NG as OpenID Provider
-------------------------

Registration on Agent Connect
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As noticed in the `official documentation <https://github.com/numerique-gouv/agentconnect-documentation/blob/main/doc_fi.md>`__, you need to 
`fill a form <https://www.demarches-simplifiees.fr/commencer/demande-creation-fi-fca>`__ to request the authorization of using Agent Connect.

You will provide one or more mail domains that will be associated with your Identity Provider.

Once the configuration is done on LL::NG, you will send them the client ID, client secret and OIDC metadata URL.

Configuration on LemonLDAP::NG
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add Agent Connect as Relying Party, with these options:

* Client ID / Client Secret: generate random values
* Redirect URIs: https://auth.agentconnect.gouv.fr/api/v2/oidc-callback
* Redirect Logout URIs: https://auth.agentconnect.gouv.fr/api/v2/client/logout-callback
* Exported attributes:

  * email (mandatory)
  * given_name (mandatory)
  * name (mandatory)
  * organizational_unit (must not contain some special characters, listed in this regex `/^[^.*?{}()|[\]\t\r\n\\]*$/`)
  * phone
  * preferred_username
  * siret
  * uid (mandatory, must contain only ASCII characters)
  * usual_name (mandatory)

* User attribute: be sure to choose a unique and persistent attribute
* ID Token signature algorithm: RS256
* UserInfo response format: JWT/RS256
* Scope / Scope value contents:

  * given_name: given_name
  * organizational_unit: organizational_unit
  * phone: phone
  * siret: siret
  * uid: uid
  * usual_name: usual_name

To match authencation levels required by Agent Connect, you must adapt the corresponding levels in `OpenID Connect Service` > `Authentication context`. You need at least the `eidas1` level.

.. tip::
   For test platform, you need to use the URLs listed on `this page <https://github.com/numerique-gouv/agentconnect-documentation/blob/main/doc_fi/test_fca_fi/test_fca_demonstrateur_fi.md>`__.


Configuration with CLI
^^^^^^^^^^^^^^^^^^^^^^

If you want to configure it through CLI, you can adapt the following commands.

* Main paarameters

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsAccessTokenExpiration 120 \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsClientID client-id-for-agent-connect \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsClientSecret client-secret-for-agent-connect \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsIDTokenExpiration 3600 \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsIDTokenSignAlg RS256 \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsPostLogoutRedirectUris https://auth.agentconnect.gouv.fr/api/v2/oidc-callback \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsRedirectUris https://auth.agentconnect.gouv.fr/api/v2/client/logout-callback \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsUserIDAttr uid \
            oidcRPMetaDataOptions/rp-agent-connect oidcRPMetaDataOptionsUserInfoSignAlg RS256


* Attributes

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataExportedVars/rp-agent-connect email mail \
            oidcRPMetaDataExportedVars/rp-agent-connect given_name givenName \
            oidcRPMetaDataExportedVars/rp-agent-connect name cn \
            oidcRPMetaDataExportedVars/rp-agent-connect organizational_unit ou \
            oidcRPMetaDataExportedVars/rp-agent-connect phone telephoneNumber \
            oidcRPMetaDataExportedVars/rp-agent-connect preferred_username displayName \
            oidcRPMetaDataExportedVars/rp-agent-connect siret deparmentNumber \
            oidcRPMetaDataExportedVars/rp-agent-connect uid uid \
            oidcRPMetaDataExportedVars/rp-agent-connect usual_name sn

* Extra scopes (only needed if you did not configure LL::NG to automatically send all exported attributes by default)

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect given_name given_name \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect organizational_unit organizational_unit \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect phone phone \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect siret siret \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect uid uid \
            oidcRPMetaDataOptionsExtraClaims/rp-agent-connect usual_name usual_name


.. |image0| image:: /applications/logo-agentconnect.svg
   :class: align-center
   :width: 300px
.. |agentconnect_login_form| image:: /applications/agentconnect-login-form.png
   :class: align-center
   :width: 1200px
