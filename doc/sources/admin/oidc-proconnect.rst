ProConnect
==========

|image0|

Presentation
------------

`ProConnect <https://www.proconnect.gouv.fr/>`__ is an
authentication platform made by French government.
It was formerly known as ``AgentConnect``, a name still used in its
domain names.
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

.. tip::
   For test platform, you need to use the URLs listed on `this page <https://partenaires.proconnect.gouv.fr/docs/ressources/valeur_ac_domain>`__.

Authentication levels
^^^^^^^^^^^^^^^^^^^^^

ProConnect requires an eIDAS authentication level, which it requests through
the ``acr_values`` parameter. To match these levels, you must declare them in
`OpenID Connect Service` > `Authentication context`, which maps each
Authentication Context Class Reference (ACR) to an internal LL::NG
authentication level. You need at least the ``eidas1`` level.

You must then give your authentication modules the levels you mapped, so that
a user authenticated by a given module reaches the expected eIDAS level.

.. attention::

   Give each authentication context a **distinct** level, and remove the
   default ``loa-*`` entries you do not use.

   LL::NG does not echo back the ACR requested by the Relying Party: it
   recomputes it from the authentication level reached by the user. When
   several contexts share the same level, the one sent back in the ``acr``
   claim of the ID token is picked arbitrarily, so ProConnect may receive
   ``loa-1`` where it expects ``eidas1``. Since ``2.24.0``, the Manager
   raises a warning when this happens.

   For the same reason, every level a user can actually reach should be
   mapped to an ACR value. When it is not, LL::NG falls back to
   ``loa-<level>``, which ProConnect does not know either.


Configuration with CLI
^^^^^^^^^^^^^^^^^^^^^^

If you want to configure it through CLI, you can adapt the following commands.

* Main parameters

::

    /usr/share/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
        addKey \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsAccessTokenExpiration 120 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsClientID client-id-for-proconnect \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsClientSecret client-secret-for-proconnect \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsIDTokenExpiration 3600 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsIDTokenSignAlg RS256 \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsPostLogoutRedirectUris https://auth.agentconnect.gouv.fr/api/v2/client/logout-callback \
            oidcRPMetaDataOptions/rp-proconnect oidcRPMetaDataOptionsRedirectUris https://auth.agentconnect.gouv.fr/api/v2/oidc-callback \
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
            oidcRPMetaDataExportedVars/rp-proconnect siret departmentNumber \
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
* Signature algorithm: use recommended values, for example RS256

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
            oidcOPMetaDataOptions/op-proconnect oidcOPMetaDataOptionsClientSecret <client secret> \
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
