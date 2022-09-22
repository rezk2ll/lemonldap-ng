Mobilizon
=========

|mobilizon_logo.jpg|

Presentation
------------

`Mobilizon <https://joinmobilizon.org>`__ is an online tool to help manage your events, your profiles and your groups.

Mobilizon lets users `authenticate with OpenID Connect <https://docs.joinmobilizon.org/administration/configure/auth/#oauth>`__ through the same plugin used by Keycloak.

First, make sure you have set up LemonLDAP::NG 's
:doc:`OpenID Connect service<..//openidconnectservice>` and added
:doc:`a Relaying Party for your Mobilizon instance<..//idpopenidconnect>`

The only options you need to configure are:

* *Client ID*: choose one
* *Client Secret*: choose one
* *Allowed redirection addresses for login*: ``https://mobilizon.example.com/auth/keycloak/callback``

Mobilizon configuration
-----------------------

Edit ``/etc/mobilizon/config.exs``, and adjust the Client ID, Client Secret and URLs to match your domain ::

   config :ueberauth,
       Ueberauth,
       providers: [
         keycloak: {Ueberauth.Strategy.Keycloak, [default_scope: "openid profile email"]}
       ]

   config :mobilizon, :auth,
     oauth_consumer_strategies: [
       {:keycloak, "LemonLDAP::NG"}
     ]

   config :ueberauth, Ueberauth.Strategy.Keycloak.OAuth,
     client_id: "CHANGEME",
     client_secret: "CHANGEME",
     site: "https://auth.example.com",
     authorize_url: "https://auth.example.com/oauth2/authorize",
     token_url: "https://auth.example.com/oauth2/token",
     userinfo_url: "https://auth.example.com/oauth2/userinfo",
     token_method: :post


.. |mobilizon_logo.jpg| image:: /applications/mobilizon_logo.jpg
   :class: align-center

