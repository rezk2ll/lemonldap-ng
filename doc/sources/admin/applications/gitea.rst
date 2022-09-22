Gitea
=====

|logo|

Presentation
------------

`Gitea <https://gitea.io/>`__ is a community managed lightweight
code hosting solution written in Go. It is published under the MIT license.

It can be configured to authenticate users with :doc:`OpenID Connect <../idpopenidconnect>`.

Configuration
--------------

LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server

Make sure you have generated a set of signing keys in
``OpenID Connect Service`` » ``Security`` » ``Keys``

You also need to set a Signing key ID to a non-empty value of your choice.

Then, add a Relaying Party with the following configuration:

- Options » Basic » Client ID : choose a client ID, such as ``gitea``
- Options » Basic » Client Secret : choose a client secret, such as ``xxxx``
- Options » Basic » Allowed redirection address : ``https://git.example.com/user/oauth2/NAME/callback``
- Options » ID Token Signature Algorithm : ``RS256``
- No Exported Attributes needed

.. note::

   The redirection address is built like this: ``<Gitea service URL>`` ``/user/oauth2/`` ``<Name of the OIDC authentication source in Gitea>`` ``/callback``

Gitea
~~~~~

Go in administration panel and create a new authentication source:

|screenshot_admin|

Configure settings:

- Authentication name: set here the value used for the redirection address
- OAuth2 Provider: set OpenID Connect
- Client ID: the Client ID configured on LL::NG side
- Client Secret: the Client Secret configured on LL::NG side
- OpenID Connect Auto Discovery URL: use the default OIDC configuration URL of your LL::NG server
- Enable the authentication source

Usage
-----

In Gitea login screen, a new OpenID logo appears at the bottom. Click on it to authenticate.

At first connection, the user must associate his account to an existing one (local or LDAP). The assocation is then remembered for further connections.

.. |logo| image:: /applications/gitea_logo.png
   :class: align-center
.. |screenshot_admin| image:: /applications/gitea_oidc_config.png
   :class: align-center
