Keys |beta|
===========

*General parameters* » *Keys*

.. versionadded:: 2.22.0

This section allows you to define cryptographic key pairs (*public* and *private* keys) that can be used by LemonLDAP::NG features such as
:doc:`idpsaml`, :doc:`idpopenidconnect` and :doc:`idpjitsimeettokens`.

Key material
------------

- **Private key**: The PEM-encoded private key. It can be optionally encrypted using PKCS#8
- **Private key password**: Password for PKCS#8 encrypted keys
- **Public key**: Can either be a PEM-encoded public key or a PEM-encoded certificate.
  Certificates are usually more compatible with client applications, so it is
  recommended to input a full X.509 certificate here.


Options
-------

- **External key identifier**: Some protocols, such as OpenID Connect, associate
  an identifier (``kid``) with the key. By default, LemonDLAP::NG will use the
  name you gave while creating the key. Use this option to use a different name
  instead.
- **Comment**: set a comment to describe this key to your future self or fellow admins

Exposing keys to applications
-----------------------------

LemonLDAP::NG uses *SAML Metadata* or *OpenID Connect JWKS* to expose its
public keys to applications without having to manually configure the
application.

By default, the keys you manually add are not exposed. There are two ways to
expose them:

* Use a per-application metadata URL, such as:

  * `/saml/metadata/idp?sp=<entityid>`
  * `/oauth2/jwks?client_id=<clientid>`

* Or set multiple values in each protocol's *Signing key name* option. The
  first value will by used to sign protocol responses when no explicit key is
  defined at the SP/RP level, and all other values will be exposed in global
  metadata.


Using placeholders
------------------

You can use :ref:`configuration placeholders <configuration-placeholders>` as
the value of any field in this section, which is a convenient way to store
private keys externally.


.. |beta| image:: /documentation/beta.png
   :width: 35px
   :alt: beta
