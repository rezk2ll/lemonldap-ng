ITSM NG
=======

|image0|

Presentation
------------

`ITSM-NG <https://www.itsm-ng.org/>`__ is a fork of GLPI. The software's main features are: assets management, IT inventory, service desk, dashboards, KB...

ITSM-NG is compatible with OpenID Connect protocol.

OpenID Connect
--------------

Configuring ITSM-NG
^^^^^^^^^^^^^^^^^^^

The configuration steps are described on `ITSM-NG wiki <https://wiki.itsm-ng.org/oidc/>`__.

Just set LemonLDAP::NG main portail URL in ``Provider`` field, and define ``Client ID`` and ``Client Secret``.

Configuring LemonLDAP::NG
^^^^^^^^^^^^^^^^^^^^^^^^^

If not done yet, configure LemonLDAP::NG as an
:doc:`OpenID Connect service<..//openidconnectservice>`.

Then add ITSM-NG as a :doc:`new OpenID Connect Relying Party<..//idpopenidconnect>`
using the following parameters:

* **Client ID**: the same you set in ITSM-NG configuration
* **Client Secret**: the same you set in ITSM-NG configuration
* Add the following **exported attributes**:
   * **given_name**: user's givenName attribute
   * **family_name**: user's sn attribute
   * **email**: user's mail attribute
* **Login and Logout Redirect URIs**: The main URL of ITSM-NG instance

Configuration sample using CLI:

::

     $ /usr/libexec/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
         addKey \
           oidcRPMetaDataExportedVars/itsmng given_name givenName \
           oidcRPMetaDataExportedVars/itsmng family_name sn \
           oidcRPMetaDataExportedVars/itsmng email mail \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsClientID myClientId \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsClientSecret myClientSecret \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsRedirectUris 'https://itsmng.example.com'  \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsPostLogoutRedirectUris 'https://itsmng.example.com' \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsIDTokenSignAlg RS512 \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsIDTokenExpiration 3600 \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsAccessTokenExpiration 3600 \
           oidcRPMetaDataOptions/itsmng oidcRPMetaDataOptionsBypassConsent 1

.. tip::

   Declare all attributes that you need to map in ITSM-NG configuration. These attributes must be returned by the scopes requested by ITSM-NG.

.. |image0| image:: /applications/itsm-ng.png
   :class: align-center

