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
OpenID Connect Providers (OP). It will get the user identity through an
ID Token, and grab user attributes through UserInfo endpoint.

As an RP, LL::NG supports many OpenID Connect features:

-  Authorization Code, Implicit and Hybrid flows
-  Automatic download of JWKS
-  JWT signature verification
-  Access Token Hash verification
-  ID Token validation
-  Get UserInfo as JSON or as JWT
-  Logout on EndSession endpoint

You can use this authentication module to link your LL::NG server to any
OpenID Connect Provider. Here are some examples, with their specific
documentation:


.. toctree::
   :hidden:

   authopenidconnect_google
   authopenidconnect_franceconnect
   authopenidconnect_prosanteconnect


=============== ================== ==================
Google          France Connect     Pro Santé Connect
=============== ================== ==================
|google|        |franceconnect|    |prosanteconnect|
=============== ================== ==================

.. |google| image:: applications/google_logo.png
   :target: authopenidconnect_google.html

.. |franceconnect| image:: applications/franceconnect_logo.png
   :target: authopenidconnect_franceconnect.html

.. |prosanteconnect| image:: applications/prosanteconnect_logo.png
   :target: authopenidconnect_prosanteconnect.html

.. attention::

    OpenID Connect specification is not achieved for logout propagation.
    So logout initiated by relaying-party will be forwarded to
    OpenID Connect provider but logout initiated by the provider (or another
    RP) will not be propagated. LL::NG will implement this when specification
    is published.

Configuration
-------------

OpenID Connect Service
~~~~~~~~~~~~~~~~~~~~~~

See :doc:`OpenID Connect service<openidconnectservice>` configuration
chapter.

Authentication and UserDB
~~~~~~~~~~~~~~~~~~~~~~~~~

In ``General Parameters`` > ``Authentication modules``, set:

-  **Authentication module**: OpenID Connect
-  **Users module**: OpenID Connect


.. tip::

    As passwords will not be managed by LL::NG, you can disable
    :ref:`menu password module<portalmenu-menu-modules>`.


.. attention::

    Browser implementations of formAction directive are
    inconsistent (e.g. Firefox does not block the redirects whereas Chrome
    does). Administrators may have to modify formAction value with wildcard
    likes \*.

    In Manager, go in:

    ``General Parameters`` > ``Advanced Parameters`` > ``Security`` >
    ``Content Security Policy`` > ``Form destination``

Then in ``General Parameters`` > ``Authentication modules`` >
``OpenID Connect parameters``, you can set:

-  **Authentication level**: authentication level associated to this module
-  **Callback GET parameter**: name of the GET parameter used for intercepting
   callback (default: openidconnectcallback)
-  **State session timeout**: duration of a state session (used for keeping
   state information between authentication request and authentication
   response) in seconds (default: 600)

Register LL::NG to an OpenID Connect Provider
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To register LL::NG, you will need to give some information like
application name or logo.

You will be prompted to provide a *Redirect URI* for LL::NG, which is built 
by appending the ``openidconnectcallback=1`` parameter to the Portal URL.

For example:

-  https://auth.example.com/?openidconnectcallback=1


.. attention::

    If you use the :doc:`choice backend<authchoice>`,
    you need to set SameSite cookie value to "Lax" or "None".
    See :doc:`SSO cookie parameters<ssocookie>`

After registration, the OP must give you a *Client ID* and a *Client
secret* required to configure the OP in LL::NG.

Declare the OpenID Connect Provider in LL::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Manager, select node ``OpenID Connect Providers`` and click on
``Add OpenID Connect Provider``. Set a technical name (without space or
special character) like "sample-op".

You can then access to the configuration of this OP.

Metadata
^^^^^^^^

The OP should publish its metadata in a JSON file (see for example
`Google
metadata <https://accounts.google.com/.well-known/openid-configuration>`__).
Copy the content of this file in the textarea.
Portal discovery document can be found here: \https://#portal#/.well-known/openid-configuration

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

.. code-block:: javascript

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
automatically if jwks_uri is defined in metadata. Else you can paste
the JSON file content in the textarea.


.. tip::

    If the OpenID Connect provider only uses symmetric encryption,
    JWKS data are useless.

Exported attributes
^^^^^^^^^^^^^^^^^^^

Define here mapping between LL::NG session content and fields
provided in UserInfo endpoint response. These fields are defined in
`OpenID Connect standard <http://openid.net/specs/openid-connect-core-1_0.html#StandardClaims>`__,
and depends on the scope requested by LL::NG (see options below).

So you can define by example:

-  cn => name
-  sn => family_name
-  mail => email
-  uid => sub

Options
^^^^^^^

Configuration
"""""""""""""
-  **Configuration endpoint**: URL of OP configuration endpoint
-  **JWKS data timeout**: After this time, LL::NG will do a request
   to get a fresh version of JWKS data. Set to 0 to disable it
-  **Client ID**: client ID given by OP
-  **Client secret**: client secret given by OP
-  **Store ID token**: Allows one to store the ID Token (JWT) inside
   user session. Do not enable it unless you need to replay this token
   on an application, or if you need the id_token_hint parameter when
   using logout.

Protocol
""""""""
-  **Scope**: Value of scope parameter (example: openid profile). The
   ``openid`` scope is mandatory.
-  **Display**: Value of display parameter (example: page)
-  **Prompt**: Value of prompt parameter (example: consent)
-  **Max age**: Value of max_age parameter (example: 3600)
-  **UI locales**: Value of ui_locales parameter (example: en-GB en
   fr-FR fr)
-  **ACR values**: Value acr_values parameters (example: loa-1)
-  **Token endpoint authentication method**: choice between
   ``client_secret_post`` and ``client_secret_basic``
-  **Check JWT signature**: Set to 0 to disable JWT signature
   checking
-  **ID Token max age**: If defined, LL::NG will check the ID Token
   date and reject it if too old
-  **Use nonce**: If enabled, a nonce will be sent, and verified from
   the ID Token

Comment: Set a comment
"""""""""""""""""""""""

Display
^^^^^^^

Used only if at least 2 OIDC Providers are declared

-  **Name**: Name of the OP
-  **Logo**: Logo of the OP
-  **Tooltip**: Information displayed on mouse over the button
-  **Resolution rule**: Rule that will be applied to preselect an OP
   for a user. You have access to all environment variable *(like user
   IP address)* and all session keys.

For example, to preselect this OP for users coming from 129.168.0.0/16
network

::

   $ENV{REMOTE_ADDR} =~ /^192\.168/

To preselect this OP when the ``MY_OP`` :doc:`choice <authchoice>` is selected ::

    $_choice eq "MY_OP"

-  **Order**: Used for sorting OP

.. attention::

    With HTTPS authorization endpoint, you may have to set **LWP::UserAgent object**
    with ``verify_hostname => 0`` and ``SSL_verify_mode => 0``.


    Go to: ``General Parameters > Advanced Parameters > Security > SSL options for server requests``