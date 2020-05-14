Discourse
=========

|discourse.jpg|

Presentation
------------

`Discourse <https://www.discourse.org/>`__ is a conversation-oriented
forum engine

Discourse supports `its own Single-Sign-On
scheme <https://meta.discourse.org/t/official-single-sign-on-for-discourse-sso/13045>`__
but is also compatible with standard protocols such as SAML and OpenID
Connect, through plugins.

This documentation illustrates the OpenID Connect plugin.

First, make sure you have set up LemonLDAP::NG 's
:doc:`OpenID Connect service<..//openidconnectservice>` and added
:doc:`a Relaying Party for your Discourse instance<..//idpopenidconnect>`

Discourse can use the following OpenID Connect attributes to fill the
user's profile:

::

    * name
    * email
    * given_name
    * family_name
    * preferred_username
    * picture

Make sure you create a username and password for the Relying Party, and
that the discourse callback URL is allowed :
https://discourse.example.com/auth/oidc/callback

Discourse configuration
-----------------------

Plugin installation
~~~~~~~~~~~~~~~~~~~

Install the `Discourse OpenID Connect
Plugin <https://meta.discourse.org/t/openid-connect-authentication-plugin/103632>`__
according to these instructions

Plugin configuration
~~~~~~~~~~~~~~~~~~~~

Browse to your Discourse admin interface, and to the plugin settings

-  openid_connect_enabled: *Yes*
-  openid_connect_discovery_document:
   https://auth.example.com/.well-known/openid-configuration
-  openid_connect_client_id: *Client ID you chose when configuring the
   Relying Party*
-  openid_connect_client_secret: *Client Secret you chose when
   configuring the Relying Party*
-  openid_connect_authorize_scope: *openid email profile*

.. |discourse.jpg| image:: /applications/discourse.jpg
   :class: align-center

