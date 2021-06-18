Publik
=======

|image0|

Presentation
------------

Publik is an open-source citizen relationship management tool.

See `the official Publik website <https://publik.entrouvert.com/>`__ for a
complete presentation.

It feature an OpenID Connect login that work with LemonLDAP::NG.

Configuring Publik
-------------------

Connect to your publik instance authentic2 webui with an Admin user, in the admin panel, go to "Authentic2_Auth_Oidc" › "Oidc providers".

Click on "Add Oidc Provider".

* Nom : LemonLDAP SSO
* Identifiant court : lemonldap
* Émetteur : https://auth.example.com/
* client id : clientid
* client secret : secret
* authorization endpoint : https://auth.example.com/oauth2/authorize
* token endpoint : https://auth.example.com/oauth2/token
* userinfo endpoint : https://auth.example.com/oauth2/userinfo
* end session endpont : https://auth.example.com/oauth2/logout
* WebKey JSON : Copy/Paste the content of https://auth.example.com/oauth2/jwks
* Claims Enabled : yes
* Show on connection page : yes

Strategy and Collectivity can be configured based to your needs.

OIDC Claim mappings can be configured based on your needs.

Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

We now have to configure LemonLDAP::NG to recognize publik as a valid OIDC relying party.

Add a :doc:`new OpenID Connect relying party<..//idpopenidconnect>`
with the following parameters (Options -> Basic) :

* **Client ID**: the same you set in Publik configuration.
* **Client Secret**: the same you set in Publik configuration.
* **Allowed redirection addresses for login**: The "Callback URL" for authentic2 : https://authentic2-instance/accounts/oidc/callback/

.. |image0| image:: /applications/logo-publik.png
   :class: align-center
