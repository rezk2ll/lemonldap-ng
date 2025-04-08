ProConnect
==========

|image0|

Presentation
------------

`ProConnect <https://agentconnect.gouv.fr/>`__ is an
authentication platform made by French government.
It relies on OpenID Connect protocol.

To select on which Identity Provider the user will be redirected,
ProConnect relies on the email domain.

.. tip::

    All users of an email domain will use the same Identity Provider.


LemonLDAP::NG can be used as Relying Party or OpenID Provider for ProConnect.

Official documentation is available on `Partner website <https://partenaires.proconnect.gouv.fr/docs>`__.

LL::NG as OpenID Provider
-------------------------

Registration on ProConnect
^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to `fill a form <https://www.demarches-simplifiees.fr/commencer/demande-creation-fi-fca>`__ to request the authorization of using ProConnect.

You will provide one or more mail domains that will be associated with your Identity Provider.

Once the configuration is done on LL::NG, you will send them the client ID, client secret and OIDC metadata URL.

Configuration on LemonLDAP::NG
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add ProConnect as Relying Party, with these options:

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

To match authencation levels required by ProConnect, you must adapt the corresponding levels in `OpenID Connect Service` > `Authentication context`. You need at least the `eidas1` level.

.. tip::
   For test platform, you need to use the URLs listed on `this page <https://partenaires.proconnect.gouv.fr/docs/ressources/valeur_ac_domain>`__.


Configuration with CLI
^^^^^^^^^^^^^^^^^^^^^^

If you want to configure it through CLI, you can adapt the following commands.

* Main paarameters

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsAccessTokenExpiration 120 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsClientID client-id-for-proconnect \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsClientSecret client-secret-for-proconnect \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsIDTokenExpiration 3600 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsIDTokenSignAlg RS256 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsPostLogoutRedirectUris https://auth.agentconnect.gouv.fr/api/v2/oidc-callback \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsRedirectUris https://auth.agentconnect.gouv.fr/api/v2/client/logout-callback \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsUserIDAttr uid \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsUserInfoSignAlg RS256


* Attributes

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataExportedVars/rp-proconnect email mail \
            oidcRPMetaDataExportedVars/rp-proconnect given_name givenName \
            oidcRPMetaDataExportedVars/rp-proconnect name cn \
            oidcRPMetaDataExportedVars/rp-proconnect organizational_unit ou \
            oidcRPMetaDataExportedVars/rp-proconnect phone telephoneNumber \
            oidcRPMetaDataExportedVars/rp-proconnect preferred_username displayName \
            oidcRPMetaDataExportedVars/rp-proconnect siret deparmentNumber \
            oidcRPMetaDataExportedVars/rp-proconnect uid uid \
            oidcRPMetaDataExportedVars/rp-proconnect usual_name sn

* Extra scopes (only needed if you did not configure LL::NG to automatically send all exported attributes by default)

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect given_name given_name \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect organizational_unit organizational_unit \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect phone phone \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect siret siret \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect uid uid \
            oidcRPMetaDataOptionsExtraClaims/rp-proconnect usual_name usual_name


.. |image0| image:: /applications/proconnect.svg
   :class: align-center
   :width: 300px
