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

You can associate here an authentication context to an authentication
level.

Security
~~~~~~~~

-  **Keys** : define public/private key pair to do asymmetric signature
-  **Signing Key ID**: ID of signing key
-  **Dynamic Registration**: Set to 1 to allow clients to register
   themselves. This may be a security risk as this will create a new
   configuration in the backend per registration request. You can limit
   this by protecting in the WebServer the registration end point with
   an authentication module, and give the credentials to clients.
-  **Authorization Code flow**: Set to 1 to allow Authorization Code
   flow
-  **Implicit flow**: Set to 1 to allow Implicit flow
-  **Hybrid flow**: Set to 1 to allow Hybrid flow

Sessions
~~~~~~~~

It is recommended to use a separate sessions storage for OpenID Connect
sessions, else they will stored in the main sessions storage.

Dynamic Registration
~~~~~~~~~~~~~~~~~~~~

If dynamic registration is enabled, you can configure the following
options to define attributes and extra claims when a new relying party
is registered trough the ``/oauth2/register`` endpoint:

-  Exported vars for dynamic registration
-  Extra claims for dynamic registration

Key rotation script
-------------------

OpenID Connect specification let the possibility to rotate keys to
improve security. LL::NG provide a script to do this, that should be put
in a cronjob.

The script is ``/usr/share/lemonldap-ng/bin/rotateOidcKeys``. It can be
run for example each week:

::

   5 5 * * 6 www-data /usr/share/lemonldap-ng/bin/rotateOidcKeys


.. tip::

    Set the correct Apache user, else generated configuration will
    not be readable by LL::NG.

Session management
------------------

LL::NG implements the change notification as defined here:
http://openid.net/specs/openid-connect-session-1_0.html#ChangeNotification

A ``changed`` state will be sent if the user is disconnected from LL::NG
portal (or has destroyed its SSO cookie). Else the ``unchanged`` state
will be returned.


.. tip::

    To work, the LL::NG cookie must not be protected against
    javascript (``httpOnly`` option should be set to ``0``).
