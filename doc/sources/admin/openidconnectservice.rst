OpenID Connect service configuration
====================================

Service configuration
---------------------

Go in Manager and click on ``OpenID Connect Service`` node.

Issuer identifier
~~~~~~~~~~~~~~~~~

Set the issuer identifier, which should be the portal URL.
For example: http://auth.example.com

Set a blank value to use Portal URL.

Endpoints
~~~~~~~~~~

Name of different OpenID Connect endpoints. You can keep the default
values unless you have a specific need to change them.

-  **Authorization**
-  **Tokens**
-  **User Info**
-  **JWKS**
-  **Registration**
-  **Introspection**
-  **End of session**
-  **Check Session**
-  **Front-Channel URI**
-  **Back-Channel URI**

.. tip::

    These endpoints are published in JSON metadata.

Authentication context
~~~~~~~~~~~~~~~~~~~~~~

You can associate here an authentication context to an authentication level.

Security
~~~~~~~~

-  **Keys**: Define public/private key pair for asymmetric signature. A JWKS
   ``kid`` (Key ID) is automatically derived when new keys are generated.
-  **Authorization Code flow**: Set to 1 to allow Authorization Code flow
-  **Implicit flow**: Set to 1 to allow Implicit flow
-  **Hybrid flow**: Set to 1 to allow Hybrid flow
-  **Only allow declared scopes**: By default, LL::NG will grant all requested scopes.
   When this option is enabled, LL::NG will only grant:

   - Standard OIDC scopes (``openid`` ``profile`` ``email`` ``address`` ``phone``)
   - Scopes declared in :ref:`Scope values content <oidcextraclaims>`
   - Scopes declared in :ref:`Scope Rules <oidcscoperules>` (if they match the rule)


.. _x5c:

.. versionchanged:: 2.0.16

    In order to increase compatibility with some applications, LemonLDAP::NG
    encapsulates the OIDC signing key in a certificate.

    If you generated your OIDC keys on an older version of LemonLDAP::NG, and
    some application complains that the JWKS document is missing a `x5c` key,
    you can upgrade your OIDC signing key in the following manner ::

        # Extract the OIDC signing key
        lemonldap-ng-cli  get oidcServicePrivateKeySig | sed 's/^oidcServicePrivateKeySig = //' > oidc.key

        # Generate a certificate
        openssl req -x509 -key oidc.key -out oidc.pem -sha256 -days 7000 -subj="/CN=$(hostname -f)"

        # Import the new certificate
        lemonldap-ng-cli set oidcServicePublicKeySig "$(cat oidc.pem)"

        # Remove temporary files
        rm oidc.key oidc.pem

Timeouts
~~~~~~~~

-  **Authorization Codes**: Expiration time of
   authorization code. Default value is one minute.
-  **ID Tokens**: Expiration time of ID Tokens.
   Default value is one hour.
-  **Access Tokens**: Expiration time of Access Tokens.
   Default value is one hour.
-  **Offline sessions**: This option sets lifetime of Refresh Tokens
   retrieved with ``offline_access`` scope. Default value is one month.


Sessions
~~~~~~~~

Best pratice is to use a separate sessions storage for OpenID Connect
sessions, else they will be stored in main sessions storage.

Dynamic Registration
~~~~~~~~~~~~~~~~~~~~

-  **Activation**: Set to 1 to allow clients to register themselves

If **Dynamic Registration** is enabled, you can configure the following
options to define attributes and extra claims released when a new relying
party is registered through ``/oauth2/register`` endpoint:

-  **Exported vars**
-  **Extra claims**

.. warning::
    Dynamic Registration can be a security risk because a new configuration
    will be created in the backend for each registration request.
    You can restrict this by protecting the WebServer registration endpoint
    with an authentication module, and give credentials to clients.

Keys rotation script
--------------------

OpenID Connect specifications allow to rotate keys to improve security.
LL::NG provides a script to do this, that should be used in a cronjob.

The script is ``/usr/share/lemonldap-ng/bin/rotateOidcKeys``. It can be
run for example each week:

::

   5 5 * * 6 www-data /usr/share/lemonldap-ng/bin/rotateOidcKeys


.. tip::

    Set the correct WebServer user, else generated configuration will
    not be readable by LL::NG.

Session management
------------------

LL::NG implements the `OpenID Connect Change Notification specification <http://openid.net/specs/openid-connect-session-1_0.html#ChangeNotification>`__

A ``changed`` state will be sent if the user is disconnected from LL::NG
portal (or has removed its SSO cookie). Else the ``unchanged`` state
will be returned.


.. tip::

    This feature requires that the LL::NG cookie is exposed to 
    javascript (``httpOnly`` option must be set to ``0``).
