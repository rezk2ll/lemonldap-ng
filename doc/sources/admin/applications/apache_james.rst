Apache James
=======

|logo|

Presentation
------------

`James <https://james.apache.org/>`__ is an open-source email server and client application framework developed by the
Apache Software Foundation. James stands for "Java Apache Mail Enterprise Server."
The Apache James project provides various components and libraries for handling email-related tasks.
Its main focus is on building a robust and extensible email server that can be used for sending, receiving,
and managing emails.

It can be configured with pair `Apisix <https://apisix.apache.org/>`__ and LemonLDAP as an OIDC Gateway

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

Define exported attributes:

- ``email``: the user mapping with James

Apisix
~~~~~~~

In order to be compatible between Apisix and James, `Linagora <https://github.com/linagora/tmail-backend/tree/master/demo/apisix/tmail-apisix-plugin-runner>`__
wrote a plugin ``tmail-apisix-plugin-runner`` in Java for:
- Handling revoked token.
- Rewriting the `X-User` header.

The plugin is available for download here: https://github.com/linagora/tmail-backend/raw/master/demo/apisix/apache-apisix-java-plugin-runner-0.4.0-bin.tar.gz
Or you can use the Docker image that already contains `apisix:3.2.0-debian <https://github.com/linagora/tmail-backend/blob/master/demo/apisix/Dockerfile>`__

The Apisix route configuration:

.. code-block:: yaml

    routes:
      -
        id: jmap
        uri: /oidc/jmap
        service_id: jmap_service_oidc
        methods:
          - POST
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /jmap
      -
        id: jmap_websocket
        uri: /oidc/jmap/ws
        service_id: jmap_service_oidc
        enable_websocket: true
        methods:
          - GET
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /jmap/ws
      -
        id: jmap_session_oidc
        uri: /oidc/jmap/session
        service_id: jmap_service_oidc
        methods:
          - GET
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /jmap/session
      -
        id: download
        uri: /oidc/download/*
        service_id: jmap_service_oidc
        methods:
          - GET
          - POST
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            regex_uri:
              - "^/oidc/download/(.*)/(.*)"
              - "/download/$1/$2"
      -
        id: upload
        uri: /oidc/upload/*
        service_id: jmap_service_oidc
        methods:
          - POST
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            regex_uri:
              - "^/oidc/upload/(.*)"
              - "/upload/$1"
      -
        id: upload_draft
        uri: /oidc/upload
        service_id: jmap_service_oidc
        methods:
          - POST
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /upload
      -
        id: web_known_finger
        uris:
          - /oidc/.well-known/webfinger
          - /.well-known/webfinger
        methods:
          - GET
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /.well-known/webfinger
      -
        id: web_known_linagora_ecosystem
        uri: /oidc/.well-known/linagora-ecosystem
        service_id: jmap_service_oidc
        methods:
          - GET
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /.well-known/linagora-ecosystem
      -
        id: web_known_jmap
        uri: /oidc/.well-known/jmap
        service_id: jmap_service_oidc
        methods:
          - GET
          - OPTIONS
        plugin_config_id: jmap-plugin
        plugins:
          proxy-rewrite:
            uri: /.well-known/jmap
          response-rewrite:
            _meta:
              filter:
                - - request_method
                  - "~="
                  - OPTIONS
            headers:
              set:
                Location: "/oidc/jmap/session"

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

    upstreams:
      -
        id: jmap_upstream
        nodes:
          "james:80": 1
        type: roundrobin

    plugin_configs:
      -
        id: jmap-plugin
        plugins:
          ext-plugin-pre-req:
            _meta:
              filter:
                - - request_method
                  - "~="
                  - OPTIONS
            conf:
              - name: TokenRevokedFilter
                value: ''
              - name: RewriteXUserFilter
                value: 'pre'
          ext-plugin-post-req:
            conf:
              - name: RewriteXUserFilter
                value: 'post'

- Service id ``jmap_service_oidc`` based on `openid-connect plugins <https://apisix.apache.org/docs/apisix/plugins/openid-connect/>`__


The Apisix plugin configuration

.. code-block:: yaml

    ext-plugin:
      path_for_test: /tmp/runner.sock
      cmd: ['java', '-jar', '-DAPP_REWRITE_XUSER_USERINFO_FIELD=email', '-Xmx1g', '-Xms1g', '/usr/local/apisix/token_revoker_plugin.jar']


Apache James
~~~~~~~


User repository configuration

.. code-block:: xml

    <usersrepository name="LocalUsers"
                     class="org.apache.james.user.ldap.ReadOnlyUsersLDAPRepository"
                     ldapHost="ldap://ldap:389"
                     principal="cn=admin,dc=localhost"
                     credentials="admin"
                     userBase="ou=people,dc=localhost"
                     userIdAttribute="uid"
                     userObjectClass="email">
        <supportsVirtualHosting>true</supportsVirtualHosting>
    </usersrepository>

- ldapHost: The URL of the LDAP server to connect to.
- principal: (optional) The name (DN) of the user with which to initially bind to the LDAP server.
- credentials: (optional) The password with which to initially bind to the LDAP server.
- userBase: The context within which to search for user entities.
- userIdAttribute: The name of the LDAP attribute which holds user ids.
- userObjectClass: The objectClass value for user nodes below the userBase.

For more details: https://james.apache.org/server/config-users.html


JMAP configuration

.. code-block:: properties

    authentication.strategy.rfc8621=XUserAuthenticationStrategy

For more details: https://james.apache.org/server/config-jmap.html

.. note::

    Another example of more components in the architecture can be found here: `<https://github.com/apache/james-project/blob/master/examples/oidc/README.md>`__

.. |logo| image:: /applications/apache_james_logo.png
   :class: align-center


