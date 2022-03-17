OpenCTI
=========

.. image:: /applications/opencti.png
   :class: align-center

Presentation
------------

`OpenCTI <https://www.opencti.io/en/>`__ is an open source platform allowing organizations to manage their cyber threat intelligence knowledge and observables.

OpenCTI allows SSO via the SAML or OIDC protocols, this page explains how to setup the SAML protocol.


Configuring OpenCTI
-------------------

Prerequisites
~~~~~~~~~~~~~

First, generate a key/certificate pair for OpenCTI ::

    openssl req -x509 -newkey rsa:4096 -keyout octi-saml-key.pem -out octi-saml-cert.pem -sha256 -days 3650 -nodes


Then, download the LemonLDAP::NG SAML metadata at https://auth.example.com/saml/metadata/idp

In this certificate, extract the ``ds:X509Certificate`` element inside the ``KeyDescriptor use="signing"`` element, and remove all spaces, you will get a long Base64 string that looks like ::

    # On a single line, with no spaces
    MIIFazCCA1OgAwIBAgIUDuUn+nT550rK0Qsej28PlQpZoFkwDQYJKoZIhvcN....

Do the same with ``octi-saml-key.pem`` in order to get a long Base64 string representing the OpenCTI signing key.

Regular installation
~~~~~~~~~~~~~~~~~~~~

In your OpenCTI configuration ::

    "saml": {
    "identifier": "saml",
    "strategy": "SamlStrategy",
    "config": {
        "issuer": "opencti",
        "entry_point": "https://auth.example.com/saml/singleSignOn",
        "saml_callback_url": "https://opencti.example.com/auth/saml/callback",
        "private_key": "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwg...",
        "cert": "MIICmzCCAYMCBgF2Qt3X1zANBgkqhkiG9w0BAQsFADARMQ8w...",
        "roles_management": {
          "role_attributes": ["groups"],
          "roles_mapping": ["my_lemonldap_group:Administrator"]
        }
    }

* ``private_key`` must contain the concatenated content of ``octi-saml-key.pem``
* ``cert`` must contain the concatenated content of the LemonLDAP::NG signing certificate, from SAML metadata
* The ``roles_management`` element is only useful if you want to automatically affect roles to your LemonLDAP::NG users depending on their groups.

Docker
~~~~~~

In a docker setup, add the following environment variables ::

      - PROVIDERS__SAML__STRATEGY=SamlStrategy
      - "PROVIDERS__SAML__CONFIG__LABEL=Login with SAML"
      - PROVIDERS__SAML__CONFIG__ISSUER=opencti
      - PROVIDERS__SAML__CONFIG__ENTRY_POINT=https://auth.example.com/saml/singleSignOn
      - PROVIDERS__SAML__CONFIG__SAML_CALLBACK_URL=https://opencti.example.com/auth/saml/callback
      - PROVIDERS__SAML__CONFIG__CERT=MIICmzCCAYMCBgF2Qt3X1zANBgkqhkiG9w0BAQsFADARMQ8w...
      - PROVIDERS__SAML__CONFIG__PRIVATE_KEY=MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwg...
      - "PROVIDERS__SAML__CONFIG__ROLES_MANAGEMENT__ROLE_ATTRIBUTES=[\"groups\"]"
      - "PROVIDERS__SAML__CONFIG__ROLES_MANAGEMENT__ROLES_MAPPING=[\"my_lemonldap_group:Administrator\"]"

* ``PRIVATE_KEY`` must contain the concatenated content of ``octi-saml-key.pem``
* ``CERT`` must contain the concatenated content of the LemonLDAP::NG signing certificate, from SAML metadata
* The ``ROLES_MANAGEMENT`` variables are only useful if you want to automatically affect roles to your LemonLDAP::NG users depending on their groups.


Configuring LemonLDAP
---------------------

Generating OpenCTI metadata
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Edit the following template to create the metadata for OpenCTI ::

    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <EntityDescriptor
     entityID="opencti"
     xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
     <SPSSODescriptor
       AuthnRequestsSigned="true"
       WantAssertionsSigned="true"
       protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
       <KeyDescriptor use="signing"><ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:X509Data><ds:X509Certificate>
       ###paste the content of octi-saml-cert.pem here, without the BEGIN and END line###
       </ds:X509Certificate></ds:X509Data></ds:KeyInfo></KeyDescriptor>
       <AssertionConsumerService
         index="0"
         isDefault="true"
         Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
         Location="https://opencti.example.com/auth/saml/callback" />
     </SPSSODescriptor>

    </EntityDescriptor>

Don't forget to replace the ``Location=`` attribute and the content of ``X509Certificate``.

Adding OpenCTI::NG to LemonLDAP configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add a new :ref:`new SAML Service Provider to the LemonLDAP::NG configuration<samlidp-register-sp>`
with the following parameters:

* **Metadata**
   * Copy the Metadata generated at the previous step
* **Exported Attributes**
   * variable name: ``groups``
   * attribute name: ``groups``


