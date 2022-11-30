Sharepoint
==========

|logo|

Presentation
------------

SharePoint is a web-based collaborative platform that integrates natively with Microsoft Office.

It can be configured to authenticate users with :doc:`OpenID Connect <../idpopenidconnect>`.

.. versionadded:: 2.0.16

   Because Sharepoint requires support for the *OAuth 2.0 Form Post Response Mode*
   feature, it only works starting with LemonLDAP::NG 2.0.16 and above


.. warning::
   Configuring Sharepoint for OpenID Connect is a complex operation which
   requires some familiarity with Microsoft products, and a good knowledge of
   OpenID Connect. This documentation is only meant to help you configure
   LemonLDAP::NG to work with Sharepoint, but is not a complete, up-to-date
   walkthrough.

Configuration
--------------

LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server.

Make sure you have generated a set of signing keys in
``OpenID Connect Service`` » ``Security`` » ``Keys``

The signing public key must be in `BEGIN CERTIFICATE` format, check :ref:`the OIDC certificate conversion instructions <x5c>` for details if you are currently using a public key in `BEGIN PUBLIC KEY` format.

Add a Relaying Party with the following configuration:

- Options » Basic » Client ID : choose a client ID, such as ``my_client_id``
- Options » Basic » Public client : set to ``Enabled``
- Options » Basic » Client Secret : leave empty
- Options » Basic » Allowed redirection address : ``https://spsites.contoso.local/`` (adjust to your own URL)
- Options » Advanced » Force claims to be returned in ID Token : ``On``
- Options » Security » ID Token Signature Algorithm : ``RS256``

Define *Scope values content*:

- ``email`` => ``http://schemas.xmlsoap.org/claims/CommonName http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress``

Define exported attributes:

- ``http://schemas.xmlsoap.org/claims/CommonName`` => ``cn`` (or LemonLDAP variable containing the common name)
- ``http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`` => ``givenName`` (or LemonLDAP variable containing the given name)
- ``http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname`` => ``sn`` (or LemonLDAP variable containing the surname)
- ``http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress`` => ``mail`` (or LemonLDAP variable containing the email)


Sharepoint
~~~~~~~~~~

Refer to the `Microsoft Sharepoint OpenID Connect documentation <https://learn.microsoft.com/en-us/sharepoint/security-for-sharepoint-server/oidc-1-0-authentication>`__ for instructions.

You do not need an Azure AD or Azure ADFS, so you can skip the steps regarding Azure AD/ADFS. You should not need to configure the identity provider manually. If you use LemonLDAP 2.0.16 and above, with a certificate as your OIDC signing key, the OpenID Connect JWKS document should contain the `x5c` field expected by sharepoint.

You can use the following values in the Powershell scripts:

* ``$metadataendpointurl = "https://auth.example.com/.well-known/openid-configuration"`` (adjust to your LemonLDAP::NG domain)
* ``$clientIdentifier = "my_client_id"`` (chosen above)

.. |logo| image:: /applications/sharepoint.png
   :class: align-center


