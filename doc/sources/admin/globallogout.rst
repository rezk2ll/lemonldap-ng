Global logout plugin
====================

This plugin allows a user to log out of all his active sessions.

Configuration
-------------

Just enable it in the Manager (section “plugins”).

-  **Parameters**:

   -  **Activation**: Enable/Disable or set a rule to select which users
      are allowed to close there sessions.
   -  **Auto accept time**: Enable/Disable timer. If timer is disabled,
      all opened sessions will be immediately closed.
   -  **Custom parameter**: Session attribut to display at global logout


.. note::

    To display more than one session attribute, you can create a
    macro like this :

    ``user_USER => "$uid_" . uc $uid``


Back-Channel Logout
-------------------

When GlobalLogout removes other active sessions, it triggers back-channel
logout notifications to federated applications:

- **OIDC Relying Parties**: Back-channel logout tokens are sent to RPs
  configured with ``oidcRPMetaDataOptionsLogoutType = back``

- **SAML Service Providers**: SOAP Single Logout requests are sent to SPs
  that support the SOAP binding

- **CAS Services**: LogoutRequest messages are sent to services that have
  ``casBackChannelSingleLogout`` enabled

.. warning::

    Front-channel logout (OIDC front-channel, SAML HTTP-Redirect/POST)
    **cannot work** for remotely-deleted sessions because the user's browser
    is not present. Only back-channel mechanisms are effective.

The same mechanism applies to the SingleSession plugin when it removes
concurrent sessions.

.. note::

    GlobalLogout only removes **SSO sessions**. OIDC offline sessions
    (refresh tokens obtained with ``offline_access`` scope) are **not**
    affected and will continue to work after GlobalLogout.

    This is by design: offline access tokens are meant to survive SSO
    session termination. Users can manage their offline tokens through
    the OIDC offline tokens plugin (``oidcOfflineTokens``) if enabled.
