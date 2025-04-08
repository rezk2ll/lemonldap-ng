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

Official documentation is available on `partner website <https://partenaires.proconnect.gouv.fr/docs>`__.

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


LL::NG as Relying Party
-----------------------

Registration on ProConnect
^^^^^^^^^^^^^^^^^^^^^^^^^^

Use the `partner website <https://partenaires.proconnect.gouv.fr/>`__ to declare your application in test.
Production needs a DataPass request.

Fill these informations:

* Application name
* Login URL: your portal URL with the OIDC callback parameter, for example: ``https://auth.example.com/?openidconnectcallback=1``
* Logout URL: your portal URL with logout parameter, for example: ``https://auth.example.com/?logout=1``
* Signature algorithm: use recommanded values, for example RS256

Copy client ID and client secret, they are required to configure ProConnect OpenID Provider on LL::NG.

Configuration on LemonLDAP::NG
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add ProConnect as OpenID Provider, with these options:

* Metadata: get metadata from `test <https://fca.integ01.dev-agentconnect.fr/api/v2/.well-known/openid-configuration>`__ or `production <https://auth.agentconnect.gouv.fr/api/v2/.well-known/openid-configuration>`__
* Exported attributes:

  * givenName: given_name
  * idp_id: idp_id
  * mail: email
  * siret: siret
  * sn: usual_name
  * telephoneNumber: phone_number
  * uid: uid

* Options:

  * Configuration:

    * Store ID Token: On (required for logout)
    * Configuration endpoint: set metadata URL
    * Client ID/Client Secret: put values given by ProConnect

  * Protocol:

    * Scope: openid given_name usual_name email uid siret idp_id phone

Configuration with CLI
^^^^^^^^^^^^^^^^^^^^^^

If you want to configure it through CLI, you can adapt the following commands.

* Metadata (adapt URL to test or production)

::

    curl https://auth.agentconnect.gouv.fr/api/v2/.well-known/openid-configuration > /tmp/metadata-proconnect.json

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcOPMetaDataJSON op-proconnect `cat /tmp/metadata-proconnect.json`

* Attributes

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcOPMetaDataExportedVars/op-proconnect givenName given_name \
            oidcOPMetaDataExportedVars/op-proconnect idp_id idp_id \
            oidcOPMetaDataExportedVars/op-proconnect mail email \
            oidcOPMetaDataExportedVars/op-proconnect siret siret \
            oidcOPMetaDataExportedVars/op-proconnect sn usual_name \
            oidcOPMetaDataExportedVars/op-proconnect telephoneNumber phone_number \
            oidcOPMetaDataExportedVars/op-proconnect uid uid


* Options (replace client ID, client secret and metadata URL)

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsAuthnEndpointAuthSigAlg RS256 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsCheckJWTSignature 1 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsClientID <client ID> \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsClientSecret <cliebt secret> \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsConfigurationURI <metadata URL> \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsIDTokenMaxAge 30 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsJWKSTimeout 0 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsMaxAge 0 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsNoJwtHeader 0 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsRequirePkce 0 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsScope openid given_name usual_name email uid siret idp_id phone custom \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsStoreIDToken 1 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsTokenEndpointAuthMethod client_secret_post \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsUseNonce 1 \
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsUserinfoSource userinfo

.. |image0| image:: /applications/proconnect.svg
   :class: align-center
   :width: 300px
