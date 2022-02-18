OpenID Connect service configuration
====================================

Service configuration
---------------------

Go in Manager and click on ``OpenID Connect Service`` node.

Issuer identifier
~~~~~~~~~~~~~~~~~

Set the issuer identifier, which should be the portal URL.

For example: http://auth.example.com

End points
~~~~~~~~~~

Name of different OpenID Connect endpoints. You can keep the default
values unless you have a specific need to change them.

-  **Authorization**
-  **Token**
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
-  **Dynamic Registration**: Set to 1 to allow clients to register
   themselves. This may be a security risk as this will create a new
   configuration in the backend per registration request. You can limit
   this by protecting in the WebServer the registration endpoint with
   an authentication module, and give the credentials to clients.
-  **Only allow declared scopes**: By default, LL::NG will grant all requested scopes.
   When this option is enabled, LL::NG will only grant:

   - Standard OIDC scopes (``openid`` ``profile`` ``email`` ``address`` ``phone``)
   - Scopes declared in :ref:`Scope values content <oidcextraclaims>`
   - Scopes declared in :ref:`Scope Rules <oidcscoperules>` (if they match the rule)

-  **Authorization Code flow**: Set to 1 to allow Authorization Code flow
-  **Implicit flow**: Set to 1 to allow Implicit flow
-  **Hybrid flow**: Set to 1 to allow Hybrid flow


Timeout
~~~~~~~

-  **Authorization Code expiration**: Expiration time of
   authorization code. The default value is one minute.
-  **ID Token expiration**: Expiration time of ID Tokens. The default
   value is one hour.
-  **Access Token expiration**: Expiration time of Access Tokens.
   The default value is one hour.
-  **Offline session expiration**: This sets the lifetime of the
   refresh token obtained with the ``offline_access`` scope. The
   default value is one month.


Sessions
~~~~~~~~

Best pratice is to use a separate sessions storage for OpenID Connect
sessions, else they will stored in the main sessions storage.

Dynamic Registration
~~~~~~~~~~~~~~~~~~~~

If dynamic registration is enabled, you can configure the following
options to define attributes and extra claims when a new relying party
is registered through the ``/oauth2/register`` endpoint:

-  Exported vars for dynamic registration
-  Extra claims for dynamic registration

Key rotation script
-------------------

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
