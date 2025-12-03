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


Using placeholders
------------------

You can use :ref:`configuration placeholders <configuration-placeholders>` as
the value of any field in this section, which is a convenient way to store
private keys externally.


.. |beta| image:: /documentation/beta.png
   :width: 35px
   :alt: beta
