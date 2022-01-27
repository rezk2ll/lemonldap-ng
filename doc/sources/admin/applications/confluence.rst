Confluence
==========

Presentation
------------

Confluence is a web-based corporate wiki developed by Atlassian.

It is compatible with SAML and OpenID Connect. This tutorial will focus on SAML.

Configuration
-------------

You must first configure LemonLDAP::NG as a :doc:`SAML Identity Provider<../idpsaml>`.

Configure SAML in Confluence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the SSO configuration page, choose SAML as the authentication method. And set the following parameters.

Don't forget to replace ``auth.example.com`` with your actual domain.

* Single sign on issuer: ``https://auth.example.com/saml/metadata``
* Identity provider single sign on URL: ``https://auth.example.com/saml/singleSignOn``
* X.509 certificate: You can find this certificate in the manager: SAML2 Service » Security » Signature » Public key
* Username mapping attribute: ``${uid}``

.. danger:: Make sure the certificate you copy into Confluence starts with BEGIN CERTIFICATE and not with BEGIN PRIVATE KEY

Write down the *Assertion Consumer Service URL* and the *Audience URL*, that Confluence is showing you, you will need it to configure LemonLDAP::NG

Configure LemonLDAP::NG
~~~~~~~~~~~~~~~~~~~~~~~

In the LemonLDAP::NG Manager, create a new *SAML Service Provider*

In *Metadata*, copy the following XML document, and don't forget to change ``AUDIENCE_URL`` and ``CONSUMER_SERVICE_URL`` the URLs with the values given by Confluence.

::

	<?xml version="1.0"?>
	<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
		entityID="AUDIENCE_URL">
	  <md:SPSSODescriptor
		AuthnRequestsSigned="false"
		WantAssertionsSigned="false"
		protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
		  <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>
		  <md:AssertionConsumerService
			Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
			Location="CONSUMER_SERVICE_URL"
			index="1"/>
	  </md:SPSSODescriptor>
	</md:EntityDescriptor>

In *Exported Attributes*, add a new attribute:

* Variable name: the session variable containing user logins
* Attribute name: ``uid``
* Mandatory: ``On``

Finally, in *Options* » *Signature*, set

* Check SSO message signature: Off
* Check SLO message signature: Off
