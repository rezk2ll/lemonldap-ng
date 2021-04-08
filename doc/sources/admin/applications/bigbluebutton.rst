BigBlueButton
=============

|logo|

Presentation
------------

`BigBlueButton <https://bigbluebutton.org/>`__ is a web conferencing system
designed for online learning. It offers audio/video sharing, presentations with
extended whiteboard capabilities - such as a pointer, zooming and drawing -
public and private chat, breakout rooms, screen sharing, integrated VoIP using
FreeSWITCH, and support for presentation of PDF documents and Microsoft Office
documents.

Its user-facing interface, *Greenlight*, can be configured to authenticate users with :doc:`OpenID Connect <../idpopenidconnect>` since version 2.7.17.

Configuration
--------------

LL:NG
~~~~~

Make sure you have already
:doc:`enabled OpenID Connect<../idpopenidconnect>` on your LemonLDAP::NG
server

Make sure you have generated a set of signing keys in
``OpenID Connect Service`` » ``Security`` » ``Keys``

You also need to set a Signing key ID to a non-empty value of your choice.

Then, add a Relaying Party with the following configuration

- Options » Authentification » Client ID : choose a client ID, such as ``my_client_id``
- Options » Authentification » Client Secret : choose a client secret, such as ``my_client_secret``
- Options » Allowed redirection address : ``https://my_greenlight_server/b/auth/openid_connect/callback``
- Options » ID Token Signature Algorithm : ``RS256``
- Adjust your Exported Attributes to send the correct session variables in the ``email`` and ``name`` claims.

Greenlight
~~~~~~~~~~

Configure the following environment variables in your greenlight `.env` file ::

   OPENID_CONNECT_CLIENT_ID=my_client_id
   OPENID_CONNECT_CLIENT_SECRET=my_client_secret
   OPENID_CONNECT_ISSUER=https://auth.example.com
   OPENID_CONNECT_UID_FIELD=sub
   OAUTH2_REDIRECT=https://my_greenlight_server/b/


Notes
~~~~~

* Your ID Token Signature Algorithm has to be RSxxx, symmetric algorithms seem broken as of Greenlight 2.7.17
* ``OAUTH2_REDIRECT`` must match the URL you use to access Greenlight. the
  ``auth/openid_connect/callback`` suffix must be omitted
* Greenlight requires your LemonLDAP::NG server to be served over HTTPS using a publically recognized certificate authority (such as Let's Encrypt)

.. |logo| image:: /applications/bigbluebutton-logo.png
   :class: align-center


