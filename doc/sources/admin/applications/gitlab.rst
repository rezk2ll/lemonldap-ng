Gitlab
======

|image0|

Presentation
------------

See `Gitlab <https://about.gitlab.com/>`__ page for product
presentation.

Gitlab allows one to use SAML to authenticate users, see `official
documentation <https://docs.gitlab.com/ee/integration/saml.html>`__

SAML
----

For this example, we use these sample values:

-  Gitlab URL : https://gitlab.example.com
-  LL::NG portal URL : https://auth.example.com

Gitlab configuration
~~~~~~~~~~~~~~~~~~~~

Find the gitlab.rb file and add these settings:

::

   vi /etc/gitlab/gitlab.rb

.. code-block:: ruby

   gitlab_rails['omniauth_enabled'] = true
   gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
   gitlab_rails['omniauth_auto_link_saml_user'] = true
   gitlab_rails['omniauth_block_auto_created_users'] = false

   gitlab_rails['omniauth_providers'] = [
     {
       name: 'saml',
       args: {
         assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
         idp_cert_fingerprint: '99:BE:7B:68:3F:XX:7D:EF:6B:C3:XX:C0:0E:XX:D4:EA:02:XX:83:2A',
         idp_sso_target_url: 'https://auth.example.com/saml/singleSignOn',
         issuer: 'https://gitlab.example.com',
         name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
       },
       label: 'Login with LL::NG' # optional label for SAML login button
     }
   ]


.. tip::

    To get the fingerprint of IDP certificate, copy SAML
    certificate from LL::NG configuration in a file and use openssl:

    ::

       openssl x509 -in CERT.pem -noout -fingerprint



You can force SAML by default with this option:

.. code-block:: ruby

   gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'saml'

In this case, users won't be able to log directly on gitlab. Set it once
you are sure the SAML configuration is valid.

To apply changes:

::

   gitlab-ctl reconfigure

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

We suppose LL::NG is configured as SAML IDP, and that you converted the
public key into a certificate for SAML signature. You must enable the
option to send certificates in response. If you don't want to, you need
to copy the certificate value into Gitlab configuration, in \`idp_cert\`
parameter.

You can get Gitlab SAML metadata on
https://gitlab.example.com/users/auth/saml/metadata

Register them in LL::NG and send these SAML attributes:

-  mail => email
-  uid => uid
-  cn => name


.. attention::

    The value from LL::NG mail session attribute must be the
    email of the user in Gitlab database, in order to associate
    accounts.

Manage groups
~~~~~~~~~~~~~

You can pass groups to Gitlab. For this, declare groups attribute in
gitlab.rb:

.. code-block:: ruby

   ...
   gitlab_rails['omniauth_providers'] = [
     {
       name: 'saml',
       groups_attribute: 'groups',
   ...

And in LL::NG, export the groups attribute:

-  groups => groups

OpenID Connect
--------------

**Alternatively** to SAML, you can choose to configure Gitlab to use
OpenID Connect.

.. _gitlab-configuration-1:

Gitlab configuration
~~~~~~~~~~~~~~~~~~~~

In ``/etc/gitlab/gitlab.rb``

.. code-block:: ruby

   ...
   gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
   gitlab_rails['omniauth_block_auto_created_users'] = false

   gitlab_rails['omniauth_providers'] = [
     { 'name' => 'openid_connect',
       'label' => 'LemonLDAP::NG',
       'args' => {
         'name' => 'openid_connect',
         'issuer' => 'https://auth.example.com',
         'scope' => ['openid', 'profile', 'email'],
         'response_type' => 'code',
         'client_auth_method' => 'client_secret_post',
         'discovery' => true,
         'uid_field' => 'sub',
         'client_options' => {
           'redirect_uri' => 'http://gitlab.example.com/users/auth/openid_connect/callback',
           'identifier' => 'LEMONLDAP_CLIENT_ID',
           'secret' => 'LEMONLDAP_CLIENT_SECRET',
         }
       }
     }
   ];

   ...

.. _llng-configuration-1:

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

Add an OpenID Connect RP to LemonLDAP::NG

-  Chose a client ID and a client secret, and write the same values in
   the ``gitlab.rb`` file above
-  You need to chose an asymetrical signature algorithm for the ID Token
   (RS256 or above)
-  You also need to set a key identifier on your LemonLDAP::NG server in
   ``OpenID Connect service`` » ``Security`` » ``Signing key ID`` (use
   something like ``default`` as the value).
-  Make sure the attribute containing the user email in the
   LemonLDAP::NG session is mapped to the ``email`` claim.


.. attention::

    You need to set a key identifier, or you will get a
    *JSON::JWK::Set::KidNotFound* error on Gitlab

.. |image0| image:: /applications/gitlab_logo.png
   :class: align-center

