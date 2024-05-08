OpenID Connect Token Exchange
=============================

Presentation
~~~~~~~~~~~~

Token exchange is the process of using a set of credentials or token to obtain
an entirely different token, for example to get access to an application not
included in current ``access_token``.

Available Token Exchange systems
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. tip::

   The ``Lemonldap::NG::Portal::Lib::OIDCTokenExchange`` base class allow
   developers to easily write some other token exchange systems. See
   its manpage.


Internal Token Exchange
-----------------------

LLNG provide an internal OIDC token exchange system that allows an OIDC relying
party to ask for an access_token available for another.

Configuration
^^^^^^^^^^^^^

The only thing to configure is to add a list of Relying Party authorized to ask
for an access_token into the destination Relying Party. This list contains a
space separated of Relying Party names *(use the internal LLNG name, not the
client ID)*: "OpenID Connect Relying Party » dest » Options » Advanced » Other RP allowed to exchange access_token".

How to use it
^^^^^^^^^^^^^

Request parameters:

* **Authentication** *(RP source)*:

  * ``client_id``: the client identifier
  * ``client_secret`` if client isn't public
  * ``subject_token``: the current ``access_token``

* **Oauth2 parameters**:

  * ``grant_type`` must be ``urn:ietf:params:oauth:grant-type:token-exchange``
  * ``subject_token_type`` *(optional)*, only ``urn:ietf:params:oauth:token-type:access_token`` is supported here
  * ``requested_token_type`` *(optional)*, only ``urn:ietf:params:oauth:token-type:access_token`` is supported here

* **Target**:

  * ``audience``: the client identifier of the target *(not the internal LLNG name)*

Exemple:

::

   curl -X POST \
    -d "client_id=clientIdSrc" \
    --data-urlencode "client_secret=ClientSecretSrc" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "subject_token=accessTokenString" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    -d "audience=target-client" \
    http://auth.example.com/oauth2/token
