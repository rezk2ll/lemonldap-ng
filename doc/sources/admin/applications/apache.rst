Apache HTTP Server
==================

|image0|


Presentation
------------

The `Apache HTTP Server <http://httpd.apache.org/>`__ is a free and open-source
cross-platform web server software, released under the terms of Apache License
2.0.

It can be used to protect applications and transmit user identity information
to them through HTTP headers.

Apache is highly customizable and can protect applications in many different ways.


Handler
-------

LemonLDAP::NG can be directly integrated into Apache to protect applications using Perl rules.

The LemonLDAP::NG Handler uses `mod_perl`.

See the :doc:`Virtual Hosts documentation <../configvhost>` for details.

mod_auth_mellon
---------------

You can use `mod_auth_mellon <https://github.com/latchset/mod_auth_mellon>`__ as an alternative to the LemonLDAP::NG handler if you do not want to use `mod_perl`.

You first need to enable the :doc:`SAML Issuer <../idpsaml>`.

First, download the metadata file from LemonLDAP::NG ::

    wget -O /etc/apache2/idp-metadata.xml https://auth.example.com/saml/metadata/idp

Location parameters ::

    <Location /secured>
        Require valid-user
        AuthType "Mellon"

        MellonEnable "auth"
        MellonEndpointPath "/secured/saml"
        MellonIDPMetadataFile /etc/apache2/idp-metadata.xml

        # Certificate for signing SAML requests
        MellonSPPrivateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
        MellonSPCertFile /etc/ssl/certs/ssl-cert-snakeoil.pem
	</Location>

You can then obtain the SAML SP metadata at ``https://apache.example.com/secured/saml/metadata``, you need to input it in LemonLDAP::NG when creating the SAML service provider configuration.

mod_auth_openidc
----------------

You can use `mod_auth_openidc <https://www.mod-auth-openidc.org/>`__ as an alternative to the LemonLDAP::NG handler if you do not want to use `mod_perl`.

You first need to enable the :doc:`OpenID Connect Issuer <../idpopenidconnect>`.

VirtualHosts parameters ::

      # Apache-specific configuration
      OIDCCryptoPassphrase changeme
      OIDCRedirectURI https://apache.example.com/secret/oauth2callback

      # URL of LemonLDAP::NG OIDC metadata
      OIDCProviderMetadataURL https://auth.example.com/.well-known/openid-configuration
      # Client ID and client secret from LemonLDAP::NG configuration
      OIDCClientID testrp
      OIDCClientSecret testrp

Location parameters ::

    <Location /secured>
          AuthType openid-connect
          Require valid-user
    </Location>

mod_auth_cas
------------

You can use `mod_auth_cas <https://github.com/apereo/mod_auth_cas>`__ as an alternative to the LemonLDAP::NG handler if you do not want to use `mod_perl`.

You first need to enable the :doc:`CAS Issuer <../idpcas>`.

Global parameters ::

	CASCookiePath /var/cache/apache2/mod_auth_cas/
	CASLoginURL https://auth.example.com/cas/login
	CASValidateURL https://auth.example.com/cas/serviceValidate

VirtualHosts parameters ::

    <Location /secured>
		Authtype CAS
		Require valid-user
    </Location>


.. |image0| image:: /applications/apache.png
   :class: align-center

