Mattermost Team Edition
=======================

|image0|

Presentation
------------

Mattermost is a team-based instant messaging application.

See `the official Mattermost website <https://mattermost.com/>`__ for a
complete presentation.

Mattermost follows an Open Core development model. The freely available
`Team edition <https://docs.mattermost.com/developer/manifesto.html>`__
contains all the basic chat features, but lack the integration
capabilities found in the `Enterprise
edition <https://mattermost.com/pricing/>`__.

The Enterprise edition provides `SAML
integration <https://docs.mattermost.com/deployment/sso-saml.html>`__
out of the box, and you can configure it just like
:doc:`any other SAML service in LemonLDAP::NG<..//idpsaml>`

The Team edition, however, only provides SSO integration with Gitlab.

However, it is possible to configure LemonLDAP::NG to behave exactly
like a Gitlab Oauth2 server, allowing Mattermost Team Edition to be
integrated with LemonLDAP::NG without having to use a
:doc:`Gitlab<gitlab>` server.


.. danger::

    The following configuration requires your user database
    to expose a unique numeric identifier for every user.

Configuring Mattermost Team Edition
-----------------------------------

Configuring Mattermost through the *System Console* will not allow you
to set the correct URLs. You need to edit the Mattermost configuration
file, and avoid changing Gitlab integration settings in the *System
Console*

Set the following settings in ``/opt/mattermost/config/config.json``

::

       "GitLabSettings": {
           "Enable": true,
           "Secret": "CHOOSE_A_CLIENT_SECRET",
           "Id": "CHOOSE_A_CLIENT_ID",
           "Scope": "",
           "AuthEndpoint": "https://auth.example.com/oauth2/gitlab_authorize",
           "TokenEndpoint": "https://auth.example.com/oauth2/token",
           "UserApiEndpoint": "https://auth.example.com/oauth2/userinfo"
       },

Configuring your web server
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mattermost does not use OpenID Connect to communicate with Gitlab, but
uses plain OAuth2 instead. Because of that, LemonLDAP::NG will not
receive the ``scope=`` parameter and will display an error on the portal
when trying to authenticate.

In order to fix this, we can add a fake OAuth2 authorize URL on the
LemonLDAP::NG server that will automatically add this ``scope=``
parametrer, before sending the request to the correct OIDC URL

Here is an example configuration for Nginx, add it in your Portal
virtualhost before any other rewrite rule:

::

       rewrite ^/oauth2/gitlab_(authorize.*)$ https://auth.example.com/oauth2/$1?scope=openid%20gitlab ;

And if you are using Apache

::

   RewriteRule "^/oauth2/gitlab_authorize(.*)$" "https://auth.example.com/oauth2/authorize?$1scope=openid gitlab" [QSA,NE]

Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

We now have to configure LemonLDAP::NG to recognize Mattermost as a
valid OAuth2 relaying party and send it the information it needs to
recognize a user.

Add a :doc:`new OpenID Connect relaying party<..//idpopenidconnect>`
with the following parameters:

* **Client ID**: the same you set in Mattermost configuration
* **Client Secret**: the same you set in Mattermost configuration
* Add a new scope in "Extra claims"
   * **Key**: ``gitlab``
   * **Value**: ``id username name email``
* Add the following exported attributes
   * ``username``: set it to the session attribute containing the user login
   * ``name``: session attribute containing the user's full name
   * ``email``: session attribute containing the user's email
   * ``id``: session attribute containing the user's numeric ID. You must set
     this claim type to *Integer*

.. danger::

    Mattermost absolutely needs to receive a numerical value in the ``id``
    claim. If you are using a LDAP server, you could use the ``uidNumber`` LDAP
    attribute. If you use something else, you will have to find a way to
    assign a unique numeric ID to each Mattermost user.

    The ``id`` attribute has to be different for each user, since this is
    the field Mattermost will use internally to map Gitlab identities to
    Mattermost accouts.

Troubleshooting
~~~~~~~~~~~~~~~

If you see a HTTP code 500 when going back to mattermost, with a panic()
in ``(*GitLabUser).IsValid(...)`` , it probably means that you are not
exporting the correct attributes, but it can also mean that ``id`` is
exported as a JSON string.

.. note::
   An issue in version 2.0.9 prevented the ``id`` field from being sent correctly.
   Upgrade your LemonLDAP-NG installation to at least 2.0.10 and :ref:`set the claim
   type <oidcexportedattr>` to *Integer*

.. |image0| image:: /applications/mattermost_logo.png
   :class: align-center

