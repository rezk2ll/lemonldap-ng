Odoo
====

|image0|

Presentation
------------

Odoo is a suite of business management software tools including, for example, CRM, e-commerce, billing, accounting, manufacturing, warehouse, project management, and inventory management. 

Requirements
------------

This guide explains how to authenticate your Odoo users using LemonLDAP::NG 's SAML provider.

Make sure you have :doc:`set up LemonLDAP::NG a SAML IDP <../samlservice>` 

.. warning::
   Odoo requires your public SAML Signature key to be in `BEGIN CERTIFICATE`
   format, if this is not the case, you need to :ref:`convert your SAML key to
   a certificate<samlservice-convert-certificate>`)

.. warning::
   Odoo requires LL::NG 2.0.14 in order to handle RelayState correctly

Configuring Odoo
----------------

Pre-requisites
~~~~~~~~~~~~~~

On the Odoo side, you need to install the ``auth_saml`` module from OCA:

* https://github.com/OCA/server-auth/tree/14.0/auth_saml 
* https://odoo-community.org/shop/product/saml2-authentication-3211

This module requires the ``pysaml2`` and ``xmlsec1`` python dependencies.

Configuration
~~~~~~~~~~~~~

After installing the module, you will see two new menus in the Odoo admin:


* Settings » Users & Companies » SAML Providers
* And a new *SAML* tab in Settings » Users & Companies » Users


Creating a new SAML Provider
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a new SAML provider in Settings » Users & Companies » SAML Providers

* Choose a name
* Copy the metadata from https://auth.example.com/saml/metadata/idp in the *Identity Provider Metadata* field
* Import a certificate and a private key in the *Odoo Public Certificate* and *Odoo Private Key* fields

To generate a key/certificate pair, you can run the following command::

    openssl req -x509 -newkey rsa:4096 -keyout odoo-key.pem -out odoo-cert.pem -sha256 -days 3650 -nodes

* Select a signature method in the *Signature Algorithm*, such as *SIG_RSA_SHA256*
* If you do not want to use the email address to match between LL::NG and Odoo accounts, set the *Identity Provider matching attribute* to a different value
* All other fields may be left to default values

Configuring users
~~~~~~~~~~~~~~~~~

For each user you want to enable SAML on, you need to edit them in Settings » Users & Companies » Users

In the *SAML* tab, set the SAML provider you just created, and their email address as the identifier.

Configuring LemonLDAP
---------------------

Add a new :ref:`new SAML Service Provider to the LemonLDAP::NG configuration<samlidp-register-sp>`
with the following parameters:

* **Metadata**
  * Copy the Metadata found at the URL referenced in Odoo's Settings » Users & Companies » SAML Providers menu » Your provider » Metadata URL
* **Exported Attributes**
   * Declare the attribute that you set in Odoo's *Identity Provider matching attribute*
   * If you are using the email, you don't need to declare anything


.. |image0| image:: /applications/odoo_logo.png
   :class: align-center

