OpenID Connect Provider
=======================

Presentation
------------


.. note::

    OpenID Connect is a protocol based on REST, OAuth 2.0 and JOSE
    stacks. It is described here: http://openid.net/connect/.

LL::NG can act as an OpenID Connect Provider (OP). It will reply to
OpenID Connect requests to give user identity (through ID Token) and
information (through UserInfo endpoint).

As an OP, LL::NG supports many OpenID Connect features:

-  Authorization Code, Implicit and Hybrid flows
-  `Publication of JSON metadata and JWKS data (Discovery) <https://openid.net/specs/openid-connect-discovery-1_0.html>`__
-  ``prompt``, ``display``, ``ui_locales``, ``max_age`` parameters
-  :ref:`Mapping custom scope values to non-standard claims <oidcextraclaims>`
-  Authentication context Class References (ACR)
-  Nonce
-  `Dynamic registration <https://openid.net/specs/openid-connect-registration-1_0.html>`__
-  Access Token Hash generation
-  ID Token signature (HS256/HS384/HS512/RS256/RS384/RS512)
-  UserInfo endpoint, as JSON or as JWT
-  Request and Request URI
-  `FrontChannel Logout <https://openid.net/specs/openid-connect-frontchannel-1_0.html>`__
-  `RP-Initiated Logout <https://openid.net/specs/openid-connect-rpinitiated-1_0.html>`__
-  PKCE (Since ``2.0.4``) - See :rfc:`7636`
-  Introspection endpoint (Since ``2.0.6``) - See :rfc:`7662`
-  Offline access (Since ``2.0.7``)
-  Refresh Tokens (Since ``2.0.7``)
-  Optional JWT Access Tokens (Since ``2.0.12``) - See :rfc:`9068`
-  `Form Post Response Mode <https://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html>`__ (Since ``2.0.16``)

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

-  **Activation**: Set to ``On``
-  **Path**: Keep ``^/oauth2/`` unless you need to use another path
-  **Use rule**: Rule to allow user to use this module, set to ``1``
   to always allow


.. tip::

    For example, to allow only users with a strong authentication
    level:

    ::

       $authenticationLevel > 2



Configuration of LL::NG in Relying Party
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each Relying Party has its own configuration way. LL::NG exposes
its OpenID Connect metadata to help clients configuration.

Metadata can be downloaded at the standard "Well Known" URL:
http://auth.example.com/.well-known/openid-configuration

OIDC metadata example:

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
click on ``Add OpenID Relying Party``. Set a technical name
(without space or special character), like “sample-rp”;

You can then set this RP configuration.

.. _oidcexportedattr:

Exported attributes
^^^^^^^^^^^^^^^^^^^

.. warning::

   By default, only `standard OpenID Connect claims <http://openid.net/specs/openid-connect-core-1_0.html#StandardClaims>`__
   are exposed to applications. If you want to add non-standard attributes, you have to create a new scope in the *Scope values content* section and your application must request it.

For each OpenID Connect attribute you want to expose to applications, you can define:

* **Claim name**: Name of the attribute as it will appear in Userinfo responses
* **Variable name**: Name of the LemonLDAP::NG session variable containing the attribute value
* **Type**: Attribute data type. By default, it is a string. Choosing integer or boolean will make the attribute appear as the corresponding JSON type.
* **Array**: Select how multi-valued attributes are processed

  * **Auto**: If the session key contains a single value, it will be released as a JSON number, string or boolean, depending on the previously specified type. If the session key contains multiple values, it will be released as an array of numbers, strings or booleans.
  * **Always**: Return an array even if the attribute only contains one value
  * **Never**: If the session key contains a single value, it will be released as a JSON number, string or boolean. If the session key contains multiple values, it will be released as a single string with a separator character.


.. attention::

    The specific ``sub`` attribute is not defined here, but in ``User attribute`` parameter (see below).


.. _oidcextraclaims:

Scope values content
^^^^^^^^^^^^^^^^^^^^

By default, the following scope-to-attributes are mapped by LL::NG:

.. csv-table::
   :header: "Scope value", "Attribute list"
   :delim: ;
   :widths: auto

   profile; name family_name given_name middle_name nickname preferred_username profile picture website gender birthdate zoneinfo locale updated_at
   email; email email_verified
   address; street_address locality region postal_code country
   phone; phone_number phone_number_verified

If you want to expose custom attributes to OpenID Connect clients,
you have to declare them in a new scope in this section.

Add your additional scope as **Key**, and a space-separated list of
attributes as **Value**:

-  `employment_info` => `position company`

In this example, an OpenID Connect client (RP) requesting for the ``employment_info`` scope will
be able to read the ``company`` and ``position`` attributes from the UserInfo endpoint.

.. important::

    Any attribute defined in this section must be mapped to a
    LL::NG session variable in **Exported Attributes** section

.. important::

    Your custom attributes will only be visible if the application requests the
    corresponding scope value




.. _oidcscoperules:

Scope rules
^^^^^^^^^^^

.. versionadded:: 2.0.12

|beta| This feature may change in a future version in a way that breaks
compatibility with existing configuration.

By default, LL::NG grants all scopes requested by the application, as
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

Macros
^^^^^^

You can define here macros that will be only evaluated for this service,
and not registered in the user's session.

Options
^^^^^^^

-  **Basic**

   -  **Public client** (since version ``2.0.4``): Set this RP as public
      client, so authentication is not needed on tokens endpoint
   -  **Client ID**: Client ID for this RP
   -  **Client secret**: Client secret for this RP (can be used for
      symmetric signature)
   -  **Allowed redirection addresses for login**: Space-separated list of redirect
      addresses allowed for this RP

-  **Advanced**

   -  **Bypass consent**: Enable if you never want to display the scope
      sharing consent screen (consent will be accepted by default).
      Bypassing the consent is **not** compliant with OpenID Connect
      standard.
   -  **Force claims to be returned in ID Token**: This options will
      make user attributes from the requested scope appear as ID Token claims
   -  **Use JWT format for Access Token** (since version ``2.0.12``): When
      using this option, Access Tokens will use the JWT format, which means they
      can be verified by external OAuth2.0 resource servers without using the
      Introspection or UserInfo endpoint.
   -  **Release claims in Access Token** (since version ``2.0.12``): If Access
      Tokens are in JWT format, this option lets you release the claims defined
      in the *Extra Claims* section inside the Access Token itself
   -  **Use refresh tokens** (since version ``2.0.7``): If this option
      is enabled, LL::NG will issue a Refresh Token that can be used
      to obtain new access tokens as long as the user session is still
      valid
   -  **User attribute**: Session field that will be used as main
      identifier (``sub``). Default value is ``whatToTrace``.
   -  **Additional audiences** (since version ``2.0.8``): You can
      specify a space-separated list of audiences that will be added to the
      ID Token audiences, and possibly the access token audiences if the
      access token format is set to JWT

-  **Security**

   -  **ID Token signature algorithm**: Select one of the available public key
      (RSXXX) or HMAC (HSXXX) based signature algorithms
   -  **Access Token signature algorithm** (since version ``2.0.12``): Select
      one of the available public key signature algorithms
   -  **Userinfo response format** (since version ``2.0.12``): By default,
      UserInfo is returned as a simple JSON object. You can also choose to
      return it as a JWT, using one of the available signature algorithms.
   -  **Require PKCE** (since version ``2.0.4``): A code challenge is
      required at Tokens endpoint (see :rfc:`7636`)
   -  **Allow offline access** (since version ``2.0.7``): After enabling
      this feature, an application may request the **offline_access**
      scope, and will obtain a Refresh Token that persists even after
      the user has logged off. See
      https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess
      for details. These offline sessions can be administered through
      the Session Browser.
   -  **Allow OAuth2.0 Password Grant** (since version ``2.0.8``): Allow the use of
      the :ref:`Resource Owner Password Credentials Grant <resource-owner-password-grant>` by this client.
      This feature only works if you have configured a form-based authentication module.
   -  **Allow OAuth2.0 Client Credentials Grant** (since version ``2.0.11``): Allow the use of the
      :ref:`Client Credentials Grant <client-credentials-grant>` by this client.
   -  **Authentication level**: Required authentication level to access this application
   -  **Access rule**: Lets you specify a :doc:`Perl rule<rules_examples>` to restrict access to this client

-  **Timeouts**

   -  **Authorization Codes** *(default: one minute)*: Expiration time of
      Authorization Codes, when using the Authorization Code flow.
   -  **ID Tokens** *(default: one hour)*: Expiration time of ID Tokens.
   -  **Access Tokens** *(default: one hour)*: Expiration time
      of Access Tokens.
   -  **Offline sessions** *(default: one month)*: Lifetime of the
      refresh token obtained with the **offline_access** scope.
      This parameter only applies if offline sessions are enabled.

-  **Logout**

   -  **Bypass confirm**: Bypass logout confirmation when logout is initiated
      by relaying party
   -  **Session required**: Whether to send the Session ID in the logout request
   -  **Type**: Type of logout to perform (only Front-Channel is implemented for now)
   -  **URL**: Specify the relying party's logout URL
   -  **Allowed redirection addresses for logout**: A space-separated list of
      URLs that this client can redirect the user to once the logout is done
      (through ``post_logout_redirect_uri``)

-  **Comment**: set a comment

Display
^^^^^^^

-  **Display name**: Name of the RP application
-  **Logo**: Logo of the RP application

.. |beta| image:: /documentation/beta.png


Access rule extra variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When writing your access rules, you can additionally use the following variables:

* ``$_oidc_grant_type`` (since version ``2.0.14``): the grant type being used to
  access this service. Possible values: ``authorizationcode``,
  ``implicit``, ``hybrid``, ``clientcredentials``, ``password``

The following attributes are made available in the created session:

* The ``_whatToTrace`` attribute (main session identifier), is set to the
  relying party's Client ID
* The ``_scope`` attribute is set to the requested scopes
* The ``_clientId`` attribute is set to the Client ID that obtained the access
  token.
* The ``_clientConfKey`` attribute is set to the LemonLDAP::NG configuration
  key for the client that obtained the access token.

The **Access Rule**, if defined, will have access to those variables, as well as
the `@ENV` array. You can use it to restrict the use of this grant to
pre-determined scopes, a particular IP address, etc.

These session attributes will be released on the UserInfo endpoint if they are
mapped to **Exported Attributes** and **Extra Claims**.

.. _resource-owner-password-grant:

Resource Owner Password Credentials Grant
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Resource Owner Password Credentials Grant allows you to exchange a user's login and password for an access token. This must be considered a legacy form of authentication, since the Authorization Code web-based flow is prefered for all applications that support it. It can however be useful in some scenarios involving technical accounts that cannot implement a web-based authentication flow.

.. versionchanged:: 2.0.12

   When using the :doc:`Choice <authchoice>` authentication module, the *Choice used for password authentication* setting can be used for selecting which authentication choice is used by the Resource Owner Password Credentials Grant. Naturally, the selected choice must be a password-based authentication method (LDAP, DBI, REST, etc.).

.. seealso::

   Specification for the Resource Owner Password Credentials Grant: :rfc:`6749#section-4.3`

.. _client-credentials-grant:

Client Credentials Grant
^^^^^^^^^^^^^^^^^^^^^^^^

The Client Credentials Grant allows you to obtain an Access Token using only a Relying Party's Client ID and Client Secret.

.. seealso::

   Specification for the Client Credentials Grant: :rfc:`6749#section-4.4`
