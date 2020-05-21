Active Directory Federation Services
====================================

|image0|

Presentation
------------

Microsoft ADFS (Active Directory Federation Services) is an
Identity/Service Provider, compatible with several protocols, including
SAML 2.0.


.. attention::

    This documentation does not explains how to setup ADFS,
    but give only tricks to make it works with LL::NG

ADFS as Identity Provider
-------------------------

When ADFS is declared as an Identity Provider in LemonLDAP::NG, you need
to take care of the following items:

-  HTTPS is mandatory on LL::NG portal
-  You need to use a certificate in LL::NG SAML metadata instead of a
   raw public key
-  Activate option ``Use specific query_string method`` in SAML Service
-  Use SHA1 instead of SHA256 as signature algorithm on ADFS if using a
   Lasso version < 2.5.0
-  Force SAML response to be sent by POST and not Artifact (signature
   verification fails with Artifact)
-  Enable ``Allow proxy authentication`` in IDP options on LL::NG side

.. |image0| image:: /applications/microsoft-adfs.png
   :class: align-center

