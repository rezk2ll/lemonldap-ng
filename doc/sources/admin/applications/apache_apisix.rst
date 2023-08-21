Apache Apisix
=======

|logo|

Presentation
------------
`Apache Apisix <https://apisix.apache.org/>`__ is a modern, high-performance, and cloud-native API gateway
that enables you to manage and secure your API traffic effectively.
It acts as an intermediary between clients and backend services, providing features such as load balancing,
authentication, rate limiting, traffic control, and more

Configuration
--------------

LemonLDAP::NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server.

Then, add a Relaying Party with the following configuration:

- Client ID : choose a client ID, such as ``james_client_id``
- Client Secret : choose a client secret, such as ``james_client_secret``
- Logout URL: endpoint to Apisix revoked token plugin, such as ``http://apisix.example.com:8081/add-revoked-token``
- Login redirect URI: such as ``http://apisix.example.com:8081/login-callback.html``

Define exported attributes:

- ``email``: the user identifier

Apisix
~~~~~~~

The Apisix route configuration for OIDC is as follows: (based on `openid-connect plugins <https://apisix.apache.org/docs/apisix/plugins/openid-connect/>`__)

.. code-block:: yaml
    services:
      -
        id: jmap_service_oidc
        upstream_id: jmap_upstream
        plugins:
          openid-connect:
            _meta:
              filter:
                - - request_method
                  - "~="
                  - OPTIONS
            client_id: "james_client_id"
            client_secret: "james_client_secret"
            discovery: "http://lemonldap.domain/auth/realms/oidc/.well-known/openid-configuration"
            scope: "openid profile email"
            bearer_only: true
            use_jwks: true

.. note::

    The example with Apisix and Apache James can be found here: `<https://github.com/apache/james-project/blob/master/examples/oidc/README.md>`__

.. |logo| image:: /applications/apache_apisix_logo.png
   :class: align-center


