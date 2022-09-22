Pro Santé Connect
=================

|logo|

Presentation
------------

`Pro Santé Connect <https://tech.esante.gouv.fr/outils-services/pro-sante-connect-e-cps/presentation-generale>`__ is
a French identity provider for healthcare professionals. It relies on OpenID Connect protocol.

Register on Pro Santé Connect
-----------------------------

Once :doc:`OpenID Connect service<openidconnectservice>` is configured,
you need to register to Pro Santé Connect.

Go on https://integrateurs-cps.asipsante.fr.

You need to provide the callback URLs, for example
https://auth.domain.com/?openidconnectcallback=1.

And also a logout URL, for example
https://auth.domain.com/?logout=1.

You will then get a ``client_id`` and a ``client_secret``.

Declare Pro Santé Connect in your LL::NG server
-----------------------------------------------

Go in Manager and create a new OpenID Connect provider. You can call it
``psc-connect`` for example.

Click on ``Metadata`` and set manually the metadata of the service.

For the sandbox server:

.. code-block:: javascript

   {
     "issuer": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet",
     "authorization_endpoint": "https://wallet.bas.esw.esante.gouv.fr/auth",
     "token_endpoint": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/token",
     "introspection_endpoint": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/token/introspect",
     "userinfo_endpoint": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/userinfo",
     "end_session_endpoint": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/logout",
     "jwks_uri": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/certs",
     "check_session_iframe": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/login-status-iframe.html",
     "grant_types_supported": [
       "authorization_code",
       "implicit",
       "refresh_token",
       "password",
       "client_credentials"
     ],
     "response_types_supported": [
       "code",
       "none",
       "id_token",
       "token",
       "id_token token",
       "code id_token",
       "code token",
       "code id_token token"
     ],
     "subject_types_supported": [
       "public",
       "pairwise"
     ],
     "id_token_signing_alg_values_supported": [
       "PS384",
       "ES384",
       "RS384",
       "HS256",
       "HS512",
       "ES256",
       "RS256",
       "HS384",
       "ES512",
       "PS256",
       "PS512",
       "RS512"
     ],
     "id_token_encryption_alg_values_supported": [
       "RSA-OAEP",
       "RSA1_5"
     ],
     "id_token_encryption_enc_values_supported": [
       "A256GCM",
       "A192GCM",
       "A128GCM",
       "A128CBC-HS256",
       "A192CBC-HS384",
       "A256CBC-HS512"
     ],
     "userinfo_signing_alg_values_supported": [
       "PS384",
       "ES384",
       "RS384",
       "HS256",
       "HS512",
       "ES256",
       "RS256",
       "HS384",
       "ES512",
       "PS256",
       "PS512",
       "RS512",
       "none"
     ],
     "request_object_signing_alg_values_supported": [
       "PS384",
       "ES384",
       "RS384",
       "HS256",
       "HS512",
       "ES256",
       "RS256",
       "HS384",
       "ES512",
       "PS256",
       "PS512",
       "RS512",
       "none"
     ],
     "response_modes_supported": [
       "query",
       "fragment",
       "form_post"
     ],
     "registration_endpoint": "https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/clients-registrations/openid-connect",
     "token_endpoint_auth_methods_supported": [
       "private_key_jwt",
       "client_secret_basic",
       "client_secret_post",
       "tls_client_auth",
       "client_secret_jwt"
     ],
     "token_endpoint_auth_signing_alg_values_supported": [
       "PS384",
       "ES384",
       "RS384",
       "HS256",
       "HS512",
       "ES256",
       "RS256",
       "HS384",
       "ES512",
       "PS256",
       "PS512",
       "RS512"
     ],
     "claims_supported": [
       "aud",
       "sub",
       "iss",
       "auth_time",
       "name",
       "given_name",
       "family_name",
       "preferred_username",
       "email",
       "acr"
     ],
     "claim_types_supported": [
       "normal"
     ],
     "claims_parameter_supported": false,
     "scopes_supported": [
       "openid",
       "address",
       "email",
       "identity",
       "microprofile-jwt",
       "offline_access",
       "phone",
       "profile",
       "roles",
       "scope_1",
       "scope_2",
       "scope_all",
       "web-origins",
       "eidas2"
     ],
     "request_parameter_supported": true,
     "request_uri_parameter_supported": true,
     "code_challenge_methods_supported": [
       "plain",
       "S256"
     ],
     "tls_client_certificate_bound_access_tokens": true
   }

You should alos import JWKS data from https://auth.bas.esw.esante.gouv.fr/auth/realms/esante-wallet/protocol/openid-connect/certs
directly in configuration to avoid requests to reload them.

Go in ``Exported attributes`` to choose which attributes you want to collect.
Read the technical documentation to know available attributes:
https://tech.esante.gouv.fr/outils-services/pro-sante-connect-e-cps/documentation-technique

Now go in ``Options``:

- Register the ``client_id`` and ``client_secret`` given by Pro Santé Connect
- In ``Scopes`` set ``openid scope_all``
- In ``ACR values`` set ``eidas2``
- You can also set the name and the logo

.. |logo| image:: /applications/prosanteconnect_logo.png
   :class: align-center
