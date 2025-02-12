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

Follow the `official documentation <https://doc.saas.olfeo.eu/fr/guide-d-utilisation/configuration/configurer-et-g%C3%A9rer-des-annuaires.html>`__

LemonLDAP::NG
~~~~~~~~~~~~~

* Declare a new SAML Service Provider
* Import metadata provided by Olfeo
* Create a local macro named ``identifiantOlfeo`` with this value: ``$uid.'@domain.local'``
* Declare 3 attributes:

  * identitfiantOlfeo
  * mail
  * uid

* In Options > Authentication Response > Force NameID Key, set ``identifiantOlfeo``

.. |image0| image:: /applications/olfeo_logo.png
   :class: align-center
