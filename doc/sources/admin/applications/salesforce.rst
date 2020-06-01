SalesForce
==========

|image0|

Presentation
------------

Salesforce Inc. is a cloud computing company. It is best known for their
CRM products and social networking applications.

It allows one to use SAML to authenticate users. It can deal with both
SP and IdP initiated modes.

This page presents the SP initiated mode.

To work with LL::NG it requires:

-  LL::NG configured as :doc:`SAML Identity Provider<../idpsaml>`

Configuration
-------------

You should have configured LL::NG as a
:doc:`SAML Identity Provider<../idpsaml>`.

Create Salesforce domain
~~~~~~~~~~~~~~~~~~~~~~~~

|image1|

For using SP-initiated mode, you must create your salesforce domain.
Creation can take up to 1 hour. (if it is superior to 1h, then there is
a problem. Problems are generally resolved in up to 72 hours)

Then you must **deploy** this domain in order to go on with the
configuration.

Finally, just ensure that at least:

-  Login policy
-  Redirect policy
-  domain name
-  authentication service

match with the correct values. (adapt the domain if necessary)


.. attention::

    For now, the authentication service parameter has no
    domain available. You must come back later to fill this parameter. Once
    SAML cinematics are working, you can then put your domain, and delete
    the login form, and you'll have an automatic redirection to your
    Identity Provider (no need for the user to click). Note that you can
    always access Salesforce by the general login page:
    https://login.salesforce.com\

SAML settings
~~~~~~~~~~~~~

Salesforce is not able to read metadata, you must fill the information
into a form.

|image2|

Go to the SAML Single Sign On settings, and fill these information:

-  Name: should be filled automatically with your organization or domain
-  SAML Version: check that version 2.0 is used
-  Issuer: this is the LemonLDAP::NG (our IdP) Entity Id, which is by
   default #PORTAL#/saml/metadata
-  Identity Provider Certificate: whereas it is mentioned that this is
   the authentication certificate, you must give your LemonLDAP::NG
   (IdP) signing certificate. If you don't have one, create it with the
   signing key pair already generated (you could do this with openssl).
   SSL authentication (https) does not seem to be checked anyway.
-  Signing Certificate: choose a certificate for SP signature. (create
   one if none is present)
-  Assertion decryption Certificate: choose a certificate only if you
   want to cipher your assertion. (default is not to cipher)
-  SAML Identity Type: choose Federation ID. This means that the user
   Name ID will be mapped to the Federation ID field. (see next section)
-  SAML Identity Location: choose if the user Name ID is held in the
   subject or in some attribute
-  Identity Provider Login URL: the user/password SAML portal location
   on the IdP
-  Identity Provider Logout URL: the logout location on the IdP
-  Custom Error URL: you can redirect the user to a special page when an
   error is happening
-  SP Initiated Binding: chose any of the supported binding (every one
   listed there is currently supported on LemonLDAP::NG) HTTP POST is a
   good choice
-  Salesforce Login URL: generated automatically. This is the entry
   point of our login cinematic.
-  OAuth 2.0 Token Endpoint: not used here
-  API Name: filled automatically
-  User Provisioning Enabled: should create automatically the user in
   Salesforce (not functionnal right now)
-  EntityId: Salesforce (the SP) Entity ID. Fill this field accordingly.
   It should be the same value as the organization domain url, displayed
   on the previous section

Configure Federation ID
~~~~~~~~~~~~~~~~~~~~~~~

Finally, configure for each user his Federation ID value. It will be the
link between the SAML assertion coming from LemonLDAP::NG (the IdP) and
a given user in Salesforce. Here, the mail has been chosen as the user
Name ID.

|image3|

Once this is completed, click to export the Salesforce metadata and
import them into LemonLDAP::NG, into the declaration of the Salesforce
Service Provider.

See
:doc:`Register partner Service Provider on LemonLDAP::NG<../idpsaml>`
configuration chapter.

.. |image0| image:: /applications/salesforce-logo.jpg
   :class: align-center
.. |image1| image:: /applications/my_domain_salesforce-resize-web.png
   :class: align-center
.. |image2| image:: /applications/saml_sso_settings-resize-web.png
   :class: align-center
.. |image3| image:: /applications/user_federation_id-resize-web.png
   :class: align-center

