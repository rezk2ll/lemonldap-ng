Foreman
=======

|image0|


Presentation
------------

`Foreman <https://theforeman.org/>`__ is a complete lifecycle management tool
for physical and virtual servers.


LemonLDAP::NG
-------------

Enable the :doc:`OpenID Connect Issuer <../idpopenidconnect>`.

Create an OpenID Connect Relying Party with the following paramaters ::

    "oidcRPMetaDataOptionsAccessTokenClaims" : 1,
    "oidcRPMetaDataOptionsAccessTokenJWT" : 1,
    "oidcRPMetaDataOptionsAccessTokenSignAlg" : "RS256",
    "oidcRPMetaDataOptionsClientID" : "rp-foreman",
    "oidcRPMetaDataOptionsClientSecret" : "Cl13nt_S3cr3t",
    "oidcRPMetaDataOptionsIDTokenSignAlg" : "RS256",
    "oidcRPMetaDataOptionsPostLogoutRedirectUris" : "https://foreman.example.com/users/extlogin/redirect_uri",
    "oidcRPMetaDataOptionsRedirectUris" : "https://foreman.example.com/users/extlogin/redirect_uri",


Foreman
-------

Install `mod_auth_openidc <https://www.mod-auth-openidc.org/>`.


httpd mod_auth_openidc parameters ::

      OIDCCryptoPassphrase changeme
      OIDCRedirectURI https://theforeman.example.com/users/extogin/redirect_uri
      OIDCProviderMetadataURL https://auth.example.com/.well-known/openid-configuration
      # Client ID and client secret from LemonLDAP::NG configuration
      OIDCClientID rp-foreman
      OIDCClientSecret Cl13nt_S3cr3t

Add a new location for Foreman ::

    <Location /users/extlogin>
          AuthType openid-connect
          Require valid-user
    </Location>

Tweak The Foreman settings in Auth tab ::

    OIDC Issuer: https://auth.example.com
    OIDC JWKS URL: https://auth.example.com/oauth2/jwks
    OIDC Algorithm: RS256
    OIDC Audience : rp-foreman


.. |image0| image:: /applications/foremanhelmet.svg
   :class: align-center

