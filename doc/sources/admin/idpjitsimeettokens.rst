Jitsi Meet Tokens
=================

|image0|

Presentation
------------

`Jitsi Meet <https://github.com/jitsi/jitsi-meet>`__ is a WEBRTC-based
video conferencing application, powering the
`meet.jit.si <http://meet.jit.si>`__ online service.

Users may install their own instance of Jitsi Meet for private use, in
which case, they may use authentication to control the creation of
conference rooms.

Jitsi Meet uses a custom JWT-based protocol to authenticate users. Some
technical details can be found  `in the documentation repo
<https://github.com/jitsi/lib-jitsi-meet/blob/master/doc/tokens.md>`__

LemonLDAP::NG can act as an JWT issuer for Jitsi Meet. 

As of 2.19.0, only a single Jitsi server per LemonLDAP::NG installation is supported.

Configuring LemonLDAP::NG
-------------------------

Jitsi Meet Tokens issuer
~~~~~~~~~~~~~~~~~~~~~~~~

Go in ``General Parameters`` » ``Issuer modules`` » ``Jitsi Meet Tokens`` and
configure:

-  **Activation**: set to ``On``.
-  **Path**: keep ``^/jitsi/`` unless you have change the prefix of endpoints
-  **Use rule**: a rule to select which users can use this module, set to ``1`` to allow all users

.. tip::

    For example, to allow only members of the jitsi-meet group:

    ::

       inGroup('jitsi-meet')


Options
~~~~~~~

- **Jitsi Meet server URL**: The base URL of your Jitsi Meet server
- **Application ID**: The application identifier
- **Shared secret**: The application shared secret, only needed if you use ``HS*`` signature algorithms
- **Signature algorithm**: The signature algorithm to use. By default ``HS256`` is used, which requires a shared secret.

Signature algorithms
~~~~~~~~~~~~~~~~~~~~

There are two ways for the Jitsi Meet server to validate the token authenticity:

* Using ``HS*`` signature algorithms, in that case, LemonLDAP::NG and the Jitsi Meet server will use a shared secret. This is simpler to setup, but less secure than public keys.
* When using a different signature algorithm. The Jitsi Meet server will use LemonLDAP::NG's public key to validate the token. ``RS256`` is recommended.

.. important::

    LemonLDAP::NG will attempt to use the *OpenID Connect* private key to emit
    JWTs, which means you need to create a key in *OpenID Connect Service* >
    *Security* > *Keys* if you intent to use public-key signature.


Attribute mapping
~~~~~~~~~~~~~~~~~

- **Identifier attribute**: Which LemonLDAP::NG session attribute should populate the ``context.user.id`` field of the token. By default, the main LemonLDAP::NG identifier is used.
- **Name attribute**: Which LemonLDAP::NG session attribute should populate the ``context.user.name`` field of the token.
- **Mail attribute**: Which LemonLDAP::NG session attribute should populate the ``context.user.email`` field of the token

Configuring Jitsi Meet
----------------------

If you are using the Docker based install, refer to the `Jitsi Meet documentation on token authentication <https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker/#authentication-using-jwt-tokens>`__

Here are the variables you need to adjust when using LemonLDAP::NG:


=========================== ================
Variable                    Value             
=========================== ================
JWT_APP_ID                  Same as *Application ID*
JWT_APP_SECRET              If ``HS*`` signature is used: same as *Shared secret*
JWT_ACCEPTED_ISSUERS        ``https://auth.example.com/``
JWT_ACCEPTED_AUDIENCES      Same as *Application ID*
JWT_ASAP_KEYSERVER          If public-key signature is used: ``https://auth.example.com/jitsi/asap``
=========================== ================


.. |image0| image:: /applications/logo-jitsimeet.png
   :class: align-center
