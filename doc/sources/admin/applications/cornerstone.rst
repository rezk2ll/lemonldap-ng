Cornerstone On Demand
=====================

|image0|

Presentation
------------

`CornerStone On Demand (CSOD) <http://www.cornerstoneondemand.com/>`__
allows one to use SAML to authenticate users. It works by default with
IDP intiated mechanism, but can works with the standard SP initiated
cinematic.

To work with LL::NG it requires:

-  An enterprise account
-  LL::NG configured as :doc:`SAML Identity Provider<../idpsaml>`
-  Registered users on CSOD with the same email than those used by
   LL::NG (email will be the NameID exchanged between CSOD and LL::NG)

Configuration
-------------

New Service Provider
~~~~~~~~~~~~~~~~~~~~

You should have configured LL::NG as an
:doc:`SAML Identity Provider<../idpsaml>`,

Now we will add CSOD as a new SAML Service Provider:

#. In Manager, click on SAML service providers and the button
   ``New service provider``.
#. Set csod as Service Provider name.
#. Set ``Email`` in ``Options`` » ``Authentication Response`` »
   ``Default NameID format``
#. Select ``Metadata``, and unprotect the field to paste the following
   value:

.. code-block:: xml

   <md:EntityDescriptor entityID="mycompanyid.csod.com" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">
     <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
       <KeyDescriptor use="signing">
         <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:X509Data>
         <ds:X509Certificate>
   Base64 encoded CSOD certificate
           </ds:X509Certificate>
         </ds:X509Data>
         </ds:KeyInfo>
       </KeyDescriptor>
       <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://mycompanyid.csod.com/samldefault.aspx" index="1" />
       <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
     </SPSSODescriptor>
   </md:EntityDescriptor>


.. attention::

    Change **mycompanyid** (in ``AssertionConsumerService``
    markup, parameter ``Location``) into your CSOD company ID and put the
    certificate value inside the ds:X509Certificate markup

CSOD control panel
~~~~~~~~~~~~~~~~~~

CSOD needs two things to configure LL::NG as an IDP:

-  Certificate
-  SAML assertion

Certificate
^^^^^^^^^^^

See :doc:`SAML security parameters<../samlservice>` to know how generate
a certificate from you SAML private key.

SAML assertion
^^^^^^^^^^^^^^

You need to use the IDP initiated feature of LL::NG. Just call this URL:

::

   https://auth.example.com/saml/singleSignOn?IDPInitiated=1&sp=mycompanyid.csod.com

.. |image0| image:: /applications/csod_logo.png
   :class: align-center

