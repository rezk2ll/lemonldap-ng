OpenID Connect service configuration
====================================

Service configuration
---------------------

Go in Manager and click on ``OpenID Connect Service`` node.

Issuer identifier
~~~~~~~~~~~~~~~~~

Set the issuer identifier, which should be the portal URL.

For example: http://auth.example.com

Endpoints
~~~~~~~~~~

Name of different OpenID Connect endpoints. You can keep the default
values unless you have a specific need to change them.

-  **Authorization**
-  **Tokens**
-  **User Info**
-  **JWKS**
-  **Registration**
-  **End of session**
-  **Check Session**


.. tip::

    The end points are published inside JSON metadata.

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

Timeouts
~~~~~~~~

-  **Authorization Codes**: Expiration time of
   authorization code. Default value is one minute.
-  **ID Tokens**: Expiration time of ID Tokens.
   Default value is one hour.
-  **Access Tokens**: Expiration time of Access Tokens.
   Default value is one hour.
-  **Offline sessions**: This option sets Refresh Tokens lifetime
   retrieved with ``offline_access`` scope. Default value is one month.


Sessions
~~~~~~~~

Best pratice is to use a separate sessions storage for OpenID Connect
sessions, else they will be stored in main sessions storage.

Dynamic Registration
~~~~~~~~~~~~~~~~~~~~

-  **Dynamic Registration**: Set to 1 to allow clients to register
   themselves. This may be a security risk as this will create a new
   configuration in the backend per registration request. You can restrict
   this by protecting the WebServer registration endpoint with
   an authentication module, and give the credentials to clients.

If dynamic registration is enabled, you can configure the following
options to define attributes and extra claims released when a new relying
party is registered through ``/oauth2/register`` endpoint:

-  **Exported vars**
-  **Extra claims**

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
