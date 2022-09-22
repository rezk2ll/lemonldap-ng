Wekan
=====

|image0|

Presentation
------------

Wekan is an open-source Kanban, similar to trello.

See `the official Wekan website <https://wekan.github.io/>`__ for a
complete presentation.

It feature an oauth2 login feature that work with LemonLDAP::NG

Configuring Wekan
-----------------

Wekan is mostly configured with environement variables, you need to set
theses :

* **OAUTH2_ENABLED**: ``TRUE``
* **OAUTH2_CLIENT_ID**: ``ClientID``
* **OAUTH2_SECRET**: ``Secret``
* **OAUTH2_SERVER_URL**: ``https://auth.example.com/``
* **OAUTH2_AUTH_ENDPOINT**: ``oauth2/authorize``
* **OAUTH2_USERINFO_ENDPOINT**: ``oauth2/userinfo``
* **OAUTH2_TOKEN_ENDPOINT**: ``oauth2/token``
* **OAUTH2_ID_MAP**: ``sub``
* **OAUTH2_USERNAME_MAP**: ``sub``
* **OAUTH2_FULLNAME_MAP**: ``name``
* **OAUTH2_EMAIL_MAP**: ``email``
* **OAUTH2_REQUEST_PERMISSIONS**: ``openid profile email``


.. danger::

    Be careful to the / in server_url and endpoints, the
    complete URL need to be valid, ie auth.example.com/ for url & oauth2/xxx
    for endpoints, OR, auth.example.com & /oauth2/xxx for endpoints.

Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

We now have to configure LemonLDAP::NG to recognize Wekan as a valid
OAuth2 relaying party and send it the information it needs to recognize
a user.

Add a :doc:`new OpenID Connect relaying party<..//idpopenidconnect>`
with the following parameters:

* **Client ID**: the same you set in Wekan configuration (same as OAUTH2_CLIENT_ID)
* **Client Secret**: the same you set in Wekan configuration (same as OAUTH2_SECRET)
* Add the following exported attributes
   * ``name``: session attribute containing the user's full name
   * ``email``: session attribute containing the user's email or _singleMail

\_singleMail Macro
^^^^^^^^^^^^^^^^^^


.. danger::

    OIDC login fails when an user as a multi-valued email
    attribute, this need to be fixed on wekan's side, we can bypass that by
    telling lemonldap to only send one email

Create a new macro, name it (_singleMail is an example), the macro
should contain ``(split(/; /,$mail))[1]``

.. |image0| image:: /applications/wekan-logo.png
   :class: align-center

