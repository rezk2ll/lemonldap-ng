Grafana
=======

|image0|

Presentation
------------

`Grafana <https://grafana.com/>`__ is an Open Source dashboard for
monitoring databases such as Prometheus, Graphite or Elasticsearch

Grafana offers social login through a generic OAuth 2 connector.
Thankfully, it is close enough to OpenID Connect to work well with
LemonLDAP::NG

Pre-requisites
--------------

Grafana configuration
~~~~~~~~~~~~~~~~~~~~~

You should start by following the generic OAuth2 documentation provided
by Grafana: https://grafana.com/docs/grafana/latest/auth/generic-oauth/

Your configuration file will have to look something like this:

::

   [auth.generic_oauth]
   enabled = true
   client_id = CHOOSE_A_CLIENT_ID
   client_secret = CHOOSE_A_CLIENT_SECRET
   scopes = openid email profile
   auth_url = https://auth.example.com/oauth2/authorize
   token_url = https://auth.example.com/oauth2/token
   api_url = https://auth.example.com/oauth2/userinfo
   allow_sign_up = true
   name = LemonLDAP::NG
   send_client_credentials_via_post = false
   email_attribute_name = email

LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server

Then, add a Relaying Party with the following configuration:

-  Options » Authentification » Client ID : same as ``client_id`` above
-  Options » Authentification » Client Secret : same as ``client_secret`` above
-  Options » Allowed redirection address : ``https://<grafana domain>/login/generic_oauth``

If you want to transmit extra user attributes to Grafana, you also need to configure:

-  Scope values content »

   -  add a key named ``profile`` to override the default claim list
   -  set a value of ``name username display_name upn``

-  Exported Attributes (not all of them are mandatory)

   -  replace the existing keys with the following 5 new keys:

      -  ``name``
      -  ``username``
      -  ``display_name``
      -  ``upn``
      -  ``email``

   -  map them to your corresponding LemonLDAP::NG session attribute

.. tip::

    To trigger OIDC authentication directly, you can register grafana in application menu and
    set as URL: ``https://<grafana domain>/login/generic_oauth``

.. |image0| image:: /applications/grafana_logo.png
   :class: align-center

