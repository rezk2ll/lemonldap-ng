Wiki.js
=======

|image0|

Presentation
------------

Wiki.js is an open-source wiki.

See `the official Wiki.js website <https://js.wiki/>`__ for a
complete presentation.

It feature an OpenID Connect login that work with LemonLDAP::NG.

Configuring Wiki.js
-------------------

Connect to your wiki.js instance with an Admin user, in the admin panel, go to "Authentication".

Click on "Add Strategy" and Choose "Generic OpenID Connect / OAuth2".

Choose a Display Name.

Define a Client ID and a Client Secret.

* Authorization Endpoint URL : https://auth.example.com/oauth2/authorize
* Token Endpoint URL : https://auth.example.com/oauth2/token
* User info Endpoint URL : https://auth.example.com/oauth2/userinfo
* Issuer : https://auth.example.com
* Logout URL : https://auth.example.com/oauth2/logout

Make a note of the "Callback URL" and the bottom of the screen and save the configuration.

Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

We now have to configure LemonLDAP::NG to recognize wiki.js as a valid OIDC relying party.

Add a :doc:`new OpenID Connect relying party<..//idpopenidconnect>`
with the following parameters (Options -> Basic) :

* **Client ID**: the same you set in Wiki.js configuration.
* **Client Secret**: the same you set in Wiki.js configuration.
* **Allowed redirection addresses for login**: The "Callback URL" defined in wiki.js.

Portal with internal CA
^^^^^^^^^^^^^^^^^^^^^^^

.. danger::

    OIDC login fails when your LemonLDAP portal doesn't use a publicaly recognized certificate (Internal Corporate CA), this is because nodejs use it's own keystore.
    You'll need to pass "NODE_EXTRA_CA_CERTS=" to your wiki installation. If done in docker you will have to create a new image from the official one, add your CA certificates into it, and use the env variable to use it in your wiki.js container.

.. |image0| image:: /applications/wiki.js.svg
   :class: align-center
