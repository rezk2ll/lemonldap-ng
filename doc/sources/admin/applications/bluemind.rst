Bluemind
========

|logo|

Presentation
------------

`Bluemind <https://www.bluemind.net/>`__ is a groupware application that can use both the

:doc:`OpenID Connect <../idpopenidconnect>` or :doc:`CAS <../idpcas>` protocols.

It is recommended to use the more secure OpenID Connect protocol.

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

Then, add a Relying Party with the following configuration:

- Options » Basic » Client ID : choose a client ID, such as ``my_client_id``
- Options » Basic » Client Secret : choose a client secret, such as ``my_client_secret``
- Options » Basic » Allowed redirection address : ``https://bluemind.example.com/auth/openid``
- Options » Advanced » Force claims to be returned in ID Token : ``On``
- Options » Advanced » Use JWT format for Access Token: ``On``
- Options » Advanced » Release claims in Access Token: ``On``
- Options » Algorithms » ID Token Signature Algorithm : ``RS256``
- Options » Scope » Scope rules » email : ``1``

Define exported attributes:

- ``email``: The name of the LLNG variable containing the e-mail address, usually ``mail``.

Bluemind
~~~~~~~~~

Refer to the `Bluemind documentation
<https://doc.bluemind.net/release/en/5.6/guide_de_l_administrateur/authentification/mise_en_place_du_sso_openid>`__ to configure your Bluemind server.


- *third-party OpenID server URL*: ``https://auth.example.com/.well-known/openid-configuration``
- *OpenId customer identifier*: ``my_client_id`` from LemonLDAP configuration
- *OpenId customer secret*: ``my_client_secret`` from LemonLDAP configuration

.. |logo| image:: /applications/bluemind_logo.png
   :class: align-center

