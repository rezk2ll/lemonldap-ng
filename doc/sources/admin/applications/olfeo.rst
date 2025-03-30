Olfeo
=====

|image0|

Presentation
------------

`Olfeo <https://www.olfeo.com/>`__ is a proprietary web filter component.

This documentation explains how to use LemonLDAP::NG as SAML IDP for Olfeo SaaS solutions.

Configuration
-------------

Olfeo
~~~~~

Follow the `official documentation <https://www.olfeo.com/en/kb-n17-configuration-de-lemonldapng-en-tant-que-fournisseur-didentite-idp-avec-olfeo-saas/>`__

Be sure to have LemonLDAP::NG SAML metadata to import them into Olfeo configuration.

LemonLDAP::NG
~~~~~~~~~~~~~

* Declare a new SAML Service Provider
* Import SP Metadata provided by Olfeo
* In Options > Authentication Response > Force NameID Key, set the attribute that was used by Olfeo as identifier when syncing accounts into Olfeao

.. |image0| image:: /applications/olfeo_logo.png
   :class: align-center
