Redmine
=======

|logo|

Presentation
------------

`Redmine <https://redmine.org/>`__ is is a flexible project management web application.
Written using the Ruby on Rails framework, it is cross-platform and cross-database.

It can be configured to authenticate users with :doc:`OpenID Connect <../idpopenidconnect>` with a plugin.

Configuration
--------------

LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server.

Make sure you have generated a set of signing keys in
``OpenID Connect Service`` » ``Security`` » ``Keys``

You also need to set a Signing key ID to a non-empty value of your choice.

Then, add a Relaying Party with the following configuration:

- Options » Basic » Client ID : choose a client ID, such as ``my_client_id``
- Options » Basic » Client Secret : choose a client secret, such as ``my_client_secret``
- Options » Basic » Allowed redirection address : ``https://my_redmine_server/oic/local_login``
- Options » Advanced » Force claims to be returned in ID Token : ``On``
- Options » Security » ID Token Signature Algorithm : ``RS512``
- Options » Logou( » Allowed redirection address for logout : ``https://my_redmine_server/oic/local_logout``

Define exported attributes:

- ``email``
- ``family_name``
- ``given_name``
- ``name``
- ``nickname``: the user login

To transfer groups:

- Declare ``member_of`` exported attribute as an array
- Declare a new scope named ``groups`` whith value ``member_of``
- Create a local macro ``member_of`` which will return ``["admin"]`` is user is administrator and ``["user"]`` else.

Redmine
~~~~~~~

Install `OpenID Connect plugin  <https://github.com/devopskube/redmine_openid_connect>`__.


Go in Redmine admin console and configure the OpenID Connect plugin:

- Enabled: check the box
- Client ID: ``my_client_id``
- OpenID Connect server url: ``https://auth.example.com/``
- Client Secret: ``my_client_secret``
- OpenID Connect scopes: ``openid profile email groups``
- Authorized group: leave blank
- Admins group: ``admin``
- How often to retrieve openid configuration: leave blank
- Disable Ssl Validation: uncheck the box
- Login Selector: uncheck the box
- Create user if not exists: check the box
- Users from the following auth sources will be required to login with SSO: do not select anythin

.. attention::

   A `bug <https://github.com/devopskube/redmine_openid_connect/issues/54>`__ has been reported, you must apply a patch
   if you transfer groups.

.. note::

   To bypass SSO, you can connect to `<https://my_redmine_server/login?local_login=true>`__

.. |logo| image:: /applications/redmine_logo.png
   :class: align-center


