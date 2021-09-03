Test OpenID Connect with command line tools
===========================================

We present here how to test the OpenID Connect protocol (authorization code flow) with commande line tools, like `curl`.

We use in this example a public OIDC provider based on LL::NG: `<https://oidctest.wsweet.org>`_

Authentication
--------------

The first step is to obtain a valid SSO session on the portal. The standard solution  is to use a web browser and log into the portal, then get the value of the SSO cookie.

In our case, to be able to use only command lines, we will use portal REST API (which requires to adapt the `requireToken` configuration to get cookie value in JSON response (see :doc:`REST services<restservices>`). This should not be what you will on a production service.

Example of REST service usage, with credentials `dwho`/`dwho`:

.. code-block:: shell

   curl -X POST -d user=dwho -d password=dwho -H 'Accept: application/json' 'https://oidctest.wsweet.org/oauth2/'

The session id is displayed in JSON response:

.. code-block:: javascript

   {
    "error" : "0",
    "id" : "0640f95827111f00ba7ad5863ba819fe46cfbcecdb18ce525836369fb4c8350b",
    "result" : 1
   }

Authorization code
------------------

In the first step of authorization code flow, we request a temporary code, ont the `authorize` end point.

Parameters needed:
 * SSO session id (will be passed in `lemonldap` cookie, adapt the name if needed)
 * Client ID: given by your OIDC provider, we use here `private`
 * Scope: depends on which information you need, we will use here `openid profile email`
 * Redirect URI: shoud match the value registered in your OIDC provider, we will use here `http://localhost`

The OIDC provide will return the code in the location header, so we just output this reponse header:

.. code-block:: shell

   curl -s -D - -o /dev/null -b lemonldap=0640f95827111f00ba7ad5863ba819fe46cfbcecdb18ce525836369fb4c8350b 'https://oidctest.wsweet.org/oauth2/authorize?response_type=code&client_id=private&scope=openid+profile+email&redirect_uri=http://localhost' | grep '^location'

The value of the location header is:

.. code-block:: shell

   location: http://localhost?code=294b0facd91a0fa92762edc48d18369e99c330ba2b8fb05ab2c45999fcef6e17&session_state=BpB8KRMBEDUs%2B7lAjsz4DRk3E0RJImxgUbMsCFFAUa8%3D.N3dVOFg3a2RpNXVJK3ltSldrYXZjUjhtU0tvd29sWkpuWWJJbll5ZGs5NzhZMnh5bmQwd0IxRmJVWUxJSTlkWDBnSWZ2SWFVZmU0UnRaMkVJVjNUY3c9PQ


So we get the code value: `94b0facd91a0fa92762edc48d18369e99c330ba2b8fb05ab2c45999fcef6e17`

This code has a short lifetime, we will use it to get access token and ID token in the next step

Tokens
------

In this step, we exchange the authorization code against tokens:
 * Access token
 * ID token
 * Refresh token (optional)

Parameters needed:
 * Authorization code: see previous step
 * Grant type: we use here `authorization_code`
 * Redirect URI: same value as the one used in the previous step
 * Client ID and Client Secret: given by your OIDC provider, we use here `private`/`tardis`

.. code-block:: shell

   curl -X POST -d grant_type=authorization_code -d 'redirect_uri=http://localhost' -d code=94b0facd91a0fa92762edc48d18369e99c330ba2b8fb05ab2c45999fcef6e17 -u 'private:tardis' 'https://oidctest.wsweet.org/oauth2/token' | json_pp

The JSON response looks like this:

.. code-block:: javascript

   {
    "access_token" : "a88b8dde538719e55c3cb8fbd14d06ed77853c685a62abf6ecb88d86228a9c64",
    "expires_in" : 3600,
    "id_token" : "eyJhbGciOiJSUzI1NiIsImtpZCI6Im9pZGN0ZXN0IiwidHlwIjoiSldUIn0.eyJhdXRoX3RpbWUiOjE2MTQxNjAwMDYsImlhdCI6MTYxNDE2MzIxOCwiaXNzIjoiaHR0cHM6Ly9vaWRjdGVzdC53c3dlZXQub3JnLyIsImF0X2hhc2giOiJIVGswOVNjSjRObEFua3k5SGFFX2VRIiwiYWNyIjoibG9hLTIiLCJleHAiOjE2MTQxNjY4MTgsInN1YiI6ImR3aG8iLCJhenAiOiJwcml2YXRlIiwiYXVkIjpbInByaXZhdGUiXX0.N3TNufjKLzKM3qiIitA7JHUei4L572XjF6AcVl7UAFB6efdGUCiAL7amlUl0FgjZfzW9bzvulBVDidoYSicIaysIdI4KkjmjpVN0Z3gOSu0ecuk5p8fD1KbX6-tmA3txeR18nzfhdckq-S-6Lx7wrWpPNyrzGx-FImbOaUPN2yeVhKPXhdyHJbzI0RqJETxnBkyW-CLEzAJyq3rCUVX-D8kHADvg6a42QQyPdxvBuGrdBfyDDDb_Py13H1qhn40NnuFknR1wSahsY6U97uUooyk-0_U4J3XJAHySjCtivtSeP0fM_5eblMuh6WdVjrfnUF0xnCTbCa2gYRlTS38BkqcsWY26PXoRAOo31a1cmB5sMSZyPtRF9UZcmGiNBIymMMdFgVAJONb6uliiTS5j9-nkmHOqVC-XJ6tuiU3ZSBQ8nCRyNW2LaCzpJ5c3ytP9yYQtyT8HmhN0VnXob3K1uJEA_Xcu4sADjtrm-LbrGiwaVMkfu-C6YIrbuC9riOW6TneV2gAzAjXPOW_UZeXrCrx66GHIJPsJIq29UfbTN5Pxo9SH2yKw6PSfxevkZhBIhEXCOMaIUHrlWz2jDBBzPIWeiSRbK_MRtejQmdRUs8nqdq-McVwnFiUMDt1KZXxqScTtMDF_Lo9oK2RaCijEJ7MSPEscr_YOyp3KIq2FLVg",
    "refresh_token" : "19434440ed4da2803e8ba9d91cb2eabd5b8bd12af2609429bda03ed487e6ef57",
    "token_type" : "Bearer"
   }

The access token will be used for the last step, to get information about the user.

The ID Token is a JWT (JSON Web Token) and can be parsed easily, as this is the concatenation of 3 JSON strings encoded in base 64: `base64(header).base64(payload).base64(signature)`.

Decoding the payload gives:

.. code-block:: javascript

   {
    "acr" : "loa-2",
    "at_hash" : "HTk09ScJ4NlAnky9HaE_eQ",
    "aud" : [
      "private"
    ],
    "auth_time" : 1614160006,
    "azp" : "private",
    "exp" : 1614166818,
    "iat" : 1614163218,
    "iss" : "https://oidctest.wsweet.org/",
    "sub" : "dwho"
   }

User info
---------

This step is optional and allows to fetch user information linked to scopes requested in the first step.

Parameters needed:
 * Access token, used as bearer authorization

.. code-block:: shell

   curl -H 'Authorization: Bearer a88b8dde538719e55c3cb8fbd14d06ed77853c685a62abf6ecb88d86228a9c64' 'https://oidctest.wsweet.org/oauth2/userinfo' | json_pp

JSON response:

.. code-block:: javascript

   {
    "email" : "dwho@badwolf.org",
    "name" : "Doctor Who",
    "preferred_username" : "dwho",
    "sub" : "dwho"
   }

Introspection
-------------

You can the validity of the access token with the introspection endpoint.

Parameters needed:
 * Client ID and Client Secret, used as basic authorization
 * Access token

.. code-block:: shell

   curl -u private:tardis -X POST -d  'token=a88b8dde538719e55c3cb8fbd14d06ed77853c685a62abf6ecb88d86228a9c64' 'https://oidctest.wsweet.org/oauth2/introspect' | json_pp

JSON response:

.. code-block:: javascript

   {
    "active" : true,
    "client_id" : "private",
    "exp" : 1630684115,
    "iss" : "https://oidctest.wsweet.org/",
    "scope" : "openid profile email",
    "sub" : "dwho"
   }
