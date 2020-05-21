Office 365
==========

|image0|

Presentation
------------

`Office 365 <https://en.wikipedia.org/wiki/Office_365>`__ provides
online access to Microsoft products like Office, Outlook or Yammer.
Authentication is done on https://login.microsoftonline.com/ and can be
forwarded to an SAML Identity Provider.

Configuration
-------------

.. _office-365-1:

Office 365
~~~~~~~~~~

You first need to install AzureAD PowerShell to be able to run
administrative commands.

Then run this script:

.. code-block:: bash

   $dom = "mycompany.com"
   $brand = "My Company"
   $url = "https://auth.example.com/saml/singleSignOn"
   $uri = "https://auth.example.com/saml/metadata"
   $logouturl = "https://auth.example.com/?logout=1"
   $cert = "xxxxxxxxxxxxxxxxxxx"

   Set-MsolDomainAuthentication –DomainName $dom -FederationBrandName $brand -Authentication Federated  -PassiveLogOnUri $url -SigningCertificate $cert -IssuerUri $uri  -LogOffUri $logouturl -PreferredAuthenticationProtocol SAMLP

Where parameters are:

-  dom: Your Office 365 domain
-  brand: Simple label
-  url: The SAML SSO endpoint
-  uri: The SAML metadata endpoint
-  logouturl: Logout URL
-  cert: The SAML certificate containing the signature public key

If you have several Office365 domains, you can't use the same URLs for
each domains. To be able to have a single SAML IDP for several domains,
you must add the 'domain' GET parameters at the end of SSO endpoint and
metadata URLs, for example:

-  domain 'mycompany.com':

   -  url: https://auth.example.com/saml/singleSignOn?domain=mycompany
   -  uri: https://auth.example.com/saml/metadata?domain=mycompany

-  domain 'myfirm.com':

   -  url: https://auth.example.com/saml/singleSignOn?domain=myfirm
   -  uri: https://auth.example.com/saml/metadata?domain=myfirm

LemonLDAP::NG
~~~~~~~~~~~~~

Create a new SAML Service Provider and import Microsoft metadata from
https://nexus.microsoftonline-p.com/federationmetadata/saml20/federationmetadata.xml

Set the NameID value to persistent, or any immutable value for the user.

Create a SAML attribute named IDPEmail which contains the user principal
name (UPN).

.. |image0| image:: /applications/logo_office_365.png
   :class: align-center

