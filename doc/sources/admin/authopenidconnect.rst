OpenID Connect
==============

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------


.. note::

    OpenID Connect is a protocol based on REST, OAuth 2.0 and JOSE
    stacks. It is described here: http://openid.net/connect/.

LL::NG can act as an OpenID Connect Relying Party (RP) towards multiple
OpenID Connect Providers (OP). It will get the user identity trough an
ID Token, and grab user attributes trough UserInfo endpoint.

As an RP, LL::NG supports a lot of OpenID Connect features:

-  Authorization Code flow
-  Automatic download of JWKS
-  JWT signature verification
-  Access Token Hash verification
-  ID Token validation
-  Get UserInfo as JSON or as JWT
-  Logout on EndSession end point

You can use this authentication module to link your LL::NG server to any
OpenID Connect Provider. Here are some examples, witch their specific
documentation:

=============== ==================
Google          France Connect
=============== ==================
|google|        |franceconnect|
=============== ==================

.. |google| image:: applications/google_logo.png
   :target: authopenidconnect_google.html

.. |franceconnect| image:: applications/franceconnect_logo.png
   :target: authopenidconnect_franceconnect.html

.. important::

    OpenID-Connect specification isn't finished for logout
    propagation. So logout initiated by relaying-party will be forward to
    OpenID-Connect provider but logout initiated by the provider (or another
    RP) will not be propagated. LLNG will implement this when spec will be
    published.

Configuration
-------------

OpenID Connect Service
~~~~~~~~~~~~~~~~~~~~~~

See :doc:`OpenIDConnect service<openidconnectservice>` configuration
chapter.

Authentication and UserDB
~~~~~~~~~~~~~~~~~~~~~~~~~

In ``General Parameters`` > ``Authentication modules``, set:

-  **Authentication module**: OpenID Connect
-  **Users module**: OpenID Connect


.. tip::

    As passwords will not be managed by LL::NG, you can disable
    :ref:`menu password module<portalmenu-menu-modules>`.


.. important::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox doesn't block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in :

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``

Then in ``General Parameters`` > ``Authentication modules`` >
``OpenID Connect parameters``, you can set:

-  **Authentication level**: level of authentication to associate to
   this module
-  **Callback GET parameter**: name of GET parameter used to intercept
   callback (default: openidconnectcallback)
-  **State session timeout**: duration of a state session (used to keep
   state information between authentication request and authentication
   response) in seconds (default: 600)

Register LL::NG to an OpenID Connect Provider
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To register LL::NG, you will need to give some information like
application name or logo. One of mandatory information is the redirect
URL (one or many).

To know this information, just take the portal URL and the Callback GET
parameter, for example:

-  http://auth.example.com/?openidcallback=1
-  http://auth.example.com/index.pl?openidcallback=1
-  http://auth.example.com/?lmAuth=oidc&openidcallback=1


.. important::

    If you use the :doc:`choice backend<authchoice>`, you
    need to add the choice parameter in redirect URL

After registration, the OP must give you a client ID and a client
secret, that will be used to configure the OP in LL::NG.

Declare the OpenID Connect Provider in LL::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the Manager, select node ``OpenID Connect Providers`` and click on
``Add OpenID Connect Provider``. Give a technical name (no spaces, no
special characters), like "sample-op";

You can then access to the configuration of this OP.

Metadata
^^^^^^^^

The OP should publish its metadata in a JSON file (see for example
`Google
metadata <https://accounts.google.com/.well-known/openid-configuration>`__).
Copy the content of this file in the textarea.

If no metadata is available, you need to write them in the textarea.
Mandatory fields are:

-  issuer
-  authorization_endpoint
-  token_endpoint
-  userinfo_endpoint

You can also define:

-  jwks_uri
-  endsession_endpoint

Example template:

.. code:: javascript

   {
     "issuer": "https://auth.example.com/",
     "authorization_endpoint": "https://auth.example.com/oauth2/authorize",
     "token_endpoint": "https://auth.example.com/oauth2/token",
     "userinfo_endpoint": "https://auth.example.com/oauth2/userinfo",
     "end_session_endpoint":"https://auth.example.com/oauth2/logout"
   }

JWKS data
^^^^^^^^^

JWKS is a JSON file containing public keys. LL::NG can grab them
automatically if jwks_uri is defined in metadata. Else you can paste the
content of the JSON file in the textarea.


.. tip::

    If the OpenID Connect provider only uses symmetric encryption,
    JWKS data is not useful.

Exported attributes
^^^^^^^^^^^^^^^^^^^

Define here the mapping between the LL::NG session content and the
fields provided in UserInfo response. The fields are defined in `OpenID
Connect
standard <http://openid.net/specs/openid-connect-core-1_0.html#StandardClaims>`__,
and depends on the scope requested by LL::NG (see options in next
chapter).

.. include:: openidconnectclaims.rst

So you can define for example:

-  cn => name
-  sn => family_name
-  mail => email
-  uid => sub

Options
^^^^^^^

-  **Configuration**:

   -  **Configuration endpoint**: URL of OP configuration endpoint
   -  **JWKS data timeout**: After this time, LL::NG will do a request
      to get a fresh version of JWKS data. Set to 0 to disable it.
   -  **Client ID**: Client ID given by OP
   -  **Client secret**: Client secret given by OP
   -  **Store ID token**: Allows one to store the ID token (JWT) inside
      user session. Don't enable it unless you need to replay this token
      on an application, or if you need the id_token_hint parameter when
      using logout.

-  **Protocol**:

   -  **Scope**: Value of scope parameter (example: openid profile). The
      ``openid`` scope is mandatory.
   -  **Display**: Value of display parameter (example: page)
   -  **Prompt**: Value of prompt parameter (example: consent)
   -  **Max age**: Value of max_age parameter (example: 3600)
   -  **UI locales**: Value of ui_locales parameter (example: en-GB en
      fr-FR fr)
   -  **ACR values**: Value acr_values parameters (example: loa-1)
   -  **Token endpoint authentication method**: Choice between
      ``client_secret_post`` and ``client_secret_basic``
   -  **Check JWT signature**: Set to 0 to disable JWT signature
      checking
   -  **ID Token max age**: If defined, LL::NG will check the date of ID
      token and refuse it if it is too old
   -  **Use Nonce**: If enabled, a nonce will be sent, and verified from
      the ID Token

-  **Display**:

   -  **Display name**: Name of the application
   -  **Logo**: Logo of the application
   -  **Order**: Number to sort buttons

.. |section>openidconnectclaims&noheader| image:: section>openidconnectclaims&noheader

