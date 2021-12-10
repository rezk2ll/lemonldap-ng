OpenID Connect Provider
=======================

Presentation
------------


.. note::

    OpenID Connect is a protocol based on REST, OAuth 2.0 and JOSE
    stacks. It is described here: http://openid.net/connect/.

LL::NG can act as an OpenID Connect Provider (OP). It will answer to
OpenID Connect requests to give user identity (through ID Token) and
information (through User Info end point).

As an OP, LL::NG supports a lot of OpenID Connect features:

-  Authorization Code, Implicit and Hybrid flows
-  Publication of JSON metadata and JWKS data (Discovery)
-  ``prompt``, ``display``, ``ui_locales``, ``max_age`` parameters
-  Extra claims definition
-  Authentication context Class References (ACR)
-  Nonce
-  Dynamic registration
-  Access Token Hash generation
-  ID Token signature (HS256/HS384/HS512/RS256/RS384/RS512)
-  UserInfo endpoint, as JSON or as JWT
-  Request and Request URI
-  Session management
-  FrontChannel Logout
-  BackChannel Logout
-  PKCE (Since ``2.0.4``) - See :rfc:`7636`
-  Introspection endpoint (Since ``2.0.6``) - See :rfc:`7662`
-  Offline access (Since ``2.0.7``)
-  Refresh Tokens (Since ``2.0.7``)
-  Optional JWT Access Tokens (Since ``2.0.12``) - See :rfc:`9068`

Configuration
-------------

OpenID Connect Service
~~~~~~~~~~~~~~~~~~~~~~

See :doc:`OpenID Connect service<openidconnectservice>` configuration
chapter.

IssuerDB
~~~~~~~~

Go in ``General Parameters`` » ``Issuer modules`` » ``OpenID Connect``
and configure:

-  **Activation**: set to ``On``.
-  **Path**: keep ``^/oauth2/`` unless you need to use another path
-  **Use rule**: a rule to allow user to use this module, set to ``1``
   to always allow.


.. tip::

    For example, to allow only users with a strong authentication
    level:

    ::

       $authenticationLevel > 2



Configuration of LL::NG in Relying Party
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each Relying Party has its own configuration way. LL::NG publish its
OpenID Connect metadata to ease the configuration of client.

The metadata can be found at the standard "Well Known" URL:
http://auth.example.com/.well-known/openid-configuration

An example of its content:

.. code-block:: javascript

   {
      "end_session_endpoint" : "http://auth.example.com/oauth2/logout",
      "jwks_uri" : "http://auth.example.com/oauth2/jwks",
      "token_endpoint_auth_methods_supported" : [
         "client_secret_post",
         "client_secret_basic"
      ],
      "token_endpoint" : "http://auth.example.com/oauth2/token",
      "response_types_supported" : [
         "code",
         "id_token",
         "id_token token",
         "code id_token",
         "code token",
         "code id_token token"
      ],
      "userinfo_signing_alg_values_supported" : [
         "none",
         "HS256",
         "HS384",
         "HS512",
         "RS256",
         "RS384",
         "RS512"
      ],
      "id_token_signing_alg_values_supported" : [
         "none",
         "HS256",
         "HS384",
         "HS512",
         "RS256",
         "RS384",
         "RS512"
      ],
      "userinfo_endpoint" : "http://auth.example.com/oauth2/userinfo",
      "request_uri_parameter_supported" : "true",
      "acr_values_supported" : [
         "loa-4",
         "loa-1",
         "loa-3",
         "loa-5",
         "loa-2"
      ],
      "request_parameter_supported" : "true",
      "subject_types_supported" : [
         "public"
      ],
      "issuer" : "http://auth.example.com/",
      "grant_types_supported" : [
         "authorization_code",
         "implicit",
         "hybrid"
      ],
      "authorization_endpoint" : "http://auth.example.com/oauth2/authorize",
      "scopes_supported" : [
         "openid",
         "profile",
         "email",
         "address",
         "phone"
      ],
      "require_request_uri_registration" : "false",
      "registration_endpoint" : "http://auth.example.com/oauth2/register"
   }

Configuration of Relying Party in LL::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go in Manager and click on ``OpenID Connect Relying Parties``, then
click on ``Add OpenID Relying Party``. Give a technical label (no
spaces, no special characters), like “sample-rp”;

You can then access to the configuration of this RP.

Exported attributes
^^^^^^^^^^^^^^^^^^^

You can map here the attribute names from the LL::NG session to an
`OpenID Connect
claim <http://openid.net/specs/openid-connect-core-1_0.html#StandardClaims>`__.

.. include:: openidconnectclaims.rst

.. _oidcexportedattr:

For each OpenID Connect claim you want to release to applications, you can define:

* **Claim name**: the name of the claim as it will appear in Userinfo responses
* **Variable name**: the name of the LemonLDAP::NG session variable containing the claim value
* **Type**: the data type of the attribute. By default, a string. Choosing integer or boolean will make the claim appear as the corresponding JSON type.
* **Array**: choose how to process multi-valued attributes

  * **Auto**: If the session key contains a single value, it will be released as a JSON number, string or boolean, depending on the previously specified type. If the session key contains multiple values, it will be released as an array of numbers, strings or booleans.
  * **Always**: Return an array even if the attribute only contains one value
  * **Never**: If the session key contains a single value, it will be released as a JSON number, string or boolean. If the session key contains multiple values, it will be released as a single string with a separator character.


.. attention::

    The specific ``sub`` attribute is not defined here, but
    in User attribute parameter (see below).


.. _oidcextraclaims:

Extra Claims
^^^^^^^^^^^^


.. attention::

    By default, only claims that are part of standard OpenID Connect scopes
    (``profile``, ``email``, ``phone``, ``address``) will be sent to a client.
    If you want to send a claim that is not in the OpenID Connect
    specification, you need to declare it in the Extra Claims section

If you want to make custom claims visible to OpenID Connect clients, you
need to declare them in a scope.

Add your additional scope as the **Key**, and a space-separated list of
claims as the **Value**:

-  timelord => rebirth_count bloodline

In this example, an OpenID Client asking for the ``timelord`` scope will
be able to read the ``rebirth_count`` and ``bloodline`` claims from the
Userinfo endpoint.


.. important::

    Any Claim defined in this section must be mapped to a
    LemonLDAP::NG session attribute in the **Exported Attributes**
    section

.. _oidcscoperules:

Scope Rules
^^^^^^^^^^^

.. versionadded:: 2.0.12

|beta| This feature may change in a future version in a way that breaks
compatibility with existing configuration

By default, LemonLDAP::NG grants all scopes requested by the application, as
long as the user consents to them.

This configuration screen allows you to change that behavior by attaching
:ref:`a rule<rules>` to a particular scope.

* If the rule evaluates to true, the scope is added to the current request,
  even if it was not requested by the application
* If the rule evaluates to false, the scope is removed from the current request
* Scopes which are not declared in the "Scope rules" list are left untouched

When writing scope rules, you can use the special ``$requested`` variable. This
variables evaluates to `true` within a scope rule when the corresponding scope
has been requested by the application. You can use this variable in a dynamic
rule when you only want to add a scope when the application requested it.

Examples:

* ``read``: ``inGroup('readers')``

  * the ``read`` scope will be granted if the user is a member of the ``readers`` group even if the application did not request it.

* ``write``: ``$requested and inGroup('writers')``

  * the ``write`` scope will be granted if the user is a member of the ``writers`` group, but only if the application requested it.


Options
^^^^^^^

-  **Basic**

   -  **Client ID**: Client ID for this RP
   -  **Client secret**: Client secret for this RP (can be use for
      symmetric signature)
   -  **Public client** (since version ``2.0.4``): set this RP as public
      client, so authentication is not needed on token endpoint
   -  **Redirection addresses**: Space separated list of redirect
      addresses allowed for this RP

-  **Advanced**

   -  **Bypass consent**: Enable if you never want to display the scope
      sharing consent screen (consent will be accepted by default).
      Bypassing the consent is **not** compliant with OpenID Connect
      standard.
   -  **User attribute**: session field that will be used as main
      identifier (``sub``)
   -  **Force claims to be returned in ID Token**: This options will
      make user attributes from the requested scope appear as ID Token
      claims.
   -  **Use JWT format for Access Token** (since version ``2.0.12``): When
      using this option, Access Tokens will use the JWT format, which means they
      can be verified by external OAuth2.0 resource servers without using the
      introspection or userinfo endpoint.
   -  **Release claims in Access Token** (since version ``2.0.12``): If Access
      Tokens are in JWT format, this option lets you release the claims defined
      in the *Extra Claims* section inside the Access Token itself.
   -  **Additional audiences** (since version ``2.0.8``): You can
      specify a space-separate list of audiences that will be added the
      audiences of the ID Token
   -  **Use refresh tokens** (since version ``2.0.7``): If this option
      is set, LemonLDAP::NG will issue a Refresh Token that can be used
      to obtain new access tokens as long as the user session is still
      valid.

-  **Timeouts**

   -  **Authorization Code expiration**: Expiration time of
      authorization code, when using the Authorization Code flow. The
      default value is one minute.
   -  **ID Token expiration**: Expiration time of ID Tokens. The default
      value is one hour.
   -  **Access token expiration**: Expiration time
      of Access Tokens. The default value is one hour.
   -  **Offline session expiration**: This sets the lifetime of the
      refresh token obtained with the **offline_access** scope. The
      default value is one month. This parameter only applies if offline
      sessions are enabled.

-  **Security**

   -  **ID Token signature algorithm**: Select one of the available public key
      (RSXXX) or HMAC (HSXXX) based signature algorithms
   -  **Access Token signature algorithm** (since version ``2.0.12``): Select
      one of the available public key signature algorithms
   -  **Userinfo response format** (since version ``2.0.12``): By default,
      UserInfo is returned as a simple JSON object. You can also choose to
      return it as a JWT, using one of the available signature algorithms.
   -  **Require PKCE** (since version ``2.0.4``): a code challenge is
      required at token endpoint (see
      :rfc:`7636`)
   -  **Allow offline access** (since version ``2.0.7``): After enabling
      this feature, an application may request the **offline_access**
      scope, and will obtain a Refresh Token that persists even after
      the user has logged off. See
      https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess
      for details. These offline sessions can be administered through
      the Session Browser.
   - **Allow OAuth2.0 Password Grant** (since version ``2.0.8``): Allow the use of the :ref:`Resource Owner Password Credentials Grant <resource-owner-password-grant>` by this client. This feature only works if you have configured a form-based authentication module.
   - **Allow OAuth2.0 Client Credentials Grant** (since version ``2.0.11``): Allow the use of the :ref:`Client Credentials Grant <client-credentials-grant>` by this client.
   - **Authentication Level**: required authentication level to access this application
   - **Access Rule**: lets you specify a :doc:`Perl rule<rules_examples>` to restrict access to this client

- **Logout**

  - **Allowed redirection addresses for logout**: A space separated list of
    URLs that this client can redirect the user to once the logout is done
    (through ``post_logout_redirect_uri``)
  - **URL**: Specify the relying party's logout URL
  - **Type**: Type of Logout to perform (only Front-Channel is implemented for now)
  - **Session required**: Whether to send the Session ID in the logout request

Access Rule extra variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When writing your access rules, you can additionally use the following variables:

* ``$_oidc_grant_type`` (since version ``2.0.14``): the grant type being used to
  access this service. Possible values: ``authorizationcode``,
  ``implicit``, ``hybrid``, ``clientcredentials``, ``password``

.. _resource-owner-password-grant:

Resource Owner Password Credentials Grant
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Resource Owner Password Credentials Grant allows you to exchange a user's login and password for an access token. This must be considered a legacy form of authentication, since the Authorization Code web-based flow is prefered for all applications that support it. It can however be useful in some scenarios involving technical accounts that cannot implement a web-based authentication flow.

.. versionchanged:: 2.0.12

   when using the :doc:`Choice <authchoice>` authentication module, the *Choice used for password authentication* setting can be used to select which authentication choice is used by the Resource Owner Password Credentials Grant. Naturally, the selected choice must be a password-based authentication method (LDAP, DBI, REST, etc.)

.. seealso::

   Specification for the Resource Owner Password Credentials Grant: :rfc:`6749#section-4.3`

.. _client-credentials-grant:

Client Credentials Grant
^^^^^^^^^^^^^^^^^^^^^^^^

The Client Credentials Grant allows you to obtain an Access Token using only a Relying Party's Client ID and Client Secret.

The following attributes are made available in the created session:

* The ``_whatToTrace`` attribute (main session identifier), is set to the
  relying party's configuration key
* The ``_scope`` attribute is set to the requested scopes
* The ``_clientId`` attribute is set to the Client ID that obtained the access
  token.
* The ``_clientConfKey`` attribute is set to the LemonLDAP::NG configuration
  key for the client that obtained the access token.

The Access Rule, if defined, will have access to those variables, as well as
the `@ENV` array. You can use it to restrict the use of this grant to
pre-determined scopes, a particular IP address, etc.

These session attribute will be released on the UserInfo endpoint if they are
mapped to Exported Attributes and Extra Claims

.. seealso::

   Specification for the Client Credentials Grant: :rfc:`6749#section-4.4`

Macros
^^^^^^

You can define here macros that will be only evaluated for this service,
and not registered in the session of the user.

Display
^^^^^^^

-  **Display name**: Name of the RP application
-  **Logo**: Logo of the RP application

.. |beta| image:: /documentation/beta.png
