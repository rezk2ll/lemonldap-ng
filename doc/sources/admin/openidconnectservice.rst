OpenID Connect service configuration
====================================

Service configuration
---------------------

Go in Manager and click on ``OpenID Connect Service`` node.

Issuer identifier
~~~~~~~~~~~~~~~~~

Set the issuer identifier, this URL will also be used as the base URL for all OIDC endpoints.
If this value is left empty, the portal URL is used. Don't change this unless you have a very good reason to.

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
-  **Token revocation**
-  **End of session**
-  **Check Session**
-  **Front-Channel URI**
-  **Back-Channel URI**

.. tip::

    These endpoints are published in JSON metadata.


Authentication context
~~~~~~~~~~~~~~~~~~~~~~

You can associate here an authentication context to an authentication level.

.. _amrrules:

Authentication Method Reference rules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When issuing an ID Token, Lemonldap will fill the ``amr`` field according to
the rules specified in this section. A minimal set of rules is provided. If
you need particular ``amr`` values to be sent to your applications depending on
authentication conditions, you can add your own custom rules here.

The key of each entry is the ``amr`` value to be added to the ID token. The
value is a rule that decides whether or not that value is set.

Any session variable or environment variable can be used, but the most
relevant variables to use here are probably:

* ``$_auth``: name of the authentication module
* ``$_choice``: name of the authentication choice, if used
* ``$_2f``: name of the 2FA type used
* ``$authenticationLevel``: current authentication level
* ``$_clientId``: client ID of the target service, in case a service requires special processing
* ``$_clientConfKey``: configuration key of the target service, in case a service requires special processing

For more information on standard AMR values, refer to :rfc:`8176`

Dynamic registration
~~~~~~~~~~~~~~~~~~~~

If **Dynamic registration** is enabled, you can configure **Exported vars** and **Extra claims** options
to define attributes and extra claims released when a new relying party is registered through ``/oauth2/register`` endpoint.

-  **Activation**: Set to 1 to allow clients to register themselves
-  **Exported vars**
-  **Extra claims**

.. warning::
    Dynamic Registration can be a security risk because a new configuration
    will be created in the backend for each registration request.
    You can restrict this by protecting the WebServer registration endpoint
    with an authentication module, and give credentials to clients.

.. _openidconnectservice-security-parameters:

Security
~~~~~~~~

-  **Keys**: Define public/private key pair for asymmetric signature. A JWKS
   ``kid`` (Key ID) is automatically derived when new keys are generated.
   You have to choose the key type: ``RSA`` or ``EC``. The list of
   supported algorithms in OIDC metadata will be automatically updated.

   - Set signing key if LLNG is an OpenID-Connect server
   - Set Encryption key if LLNG is an OpenID-Connect Relying-Party and if you
     want that the OpenID-Connect server encrypt the JWT tokens

-  **Authorization Code Flow**: Set to 'On' to allow Authorization Code flow
-  **Implicit Flow**: Set to 'On' to allow Implicit flow
-  **Hybrid Flow**: Set to 'On' to allow Hybrid flow
-  **Always send exported attributes**: By default, LL::NG will release all
   exported attributes to RPs. When this option is disabled, only attributes
   allowed by a scope can be transmitted
-  **Only allow declared scopes**: By default, LL::NG will grant all requested scopes.
   When this option is enabled, LL::NG will only grant:

   - Standard OIDC scopes (``openid`` ``profile`` ``email`` ``address`` ``phone``)
   - Scopes declared in :ref:`Scope values content <oidcextraclaims>`
   - Scopes declared in :ref:`Scope Rules <oidcscoperules>` (if they match the rule)
-  **Drop CSP headers from OIDC responses**: Set to 'On' to drop all Content Security Policy headers (:ref:`CSP<security-configure-security-settings>`) from OIDC responses
-  **Default "alg" algorithm for JWE encryption**: when LL::NG is an OpenID-Connect
   Server, you can set here the default "alg" algorithm to use for JWE encryption
-  **Default "enc" algorithm for JWE encryption**: when LL::NG is an OpenID-Connect
   Server, you can set here the default "enc" algorithm to use for JWE encryption
-  **Do not display metadata**: Set to 'On' to hide OIDC metadata


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
-  **OIDC Metadata TTL**: When a non 0 value is set here, the OIDC metadata
   are generated with a ``Cache-Control: public`` header and the corresponding
   "time-to-live" value.


Sessions
~~~~~~~~

Best pratice is to use a separate sessions storage for OpenID Connect
sessions, else they will be stored in main sessions storage.

Keys rotation script
--------------------

OpenID Connect specifications allow to rotate keys to improve security.
LL::NG provides a script to do this, that should be used in a cronjob.

The script is ``/usr/share/lemonldap-ng/bin/rotateOidcKeys``. It can be
run for example each week:

::

   5 5 * * 6 www-data /usr/share/lemonldap-ng/bin/rotateOidcKeys

Both a systemd timer and a cronjob are provided in LL::NG tarball and packages.

This is _not_ enabled by default, one needs to enable it:

- For cron, un-comment the line in the `/etc/cron.d/lemonldap-ng-rotateOidcKeys` cronjob.
- For systemd, run `systemctl enable lemonldap-ng-rotateOidcKeys.timer --now`.

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
