Rocket.Chat
=========

|image0|

Presentation
------------

`Rocket.Chat <https://www.rocket.chat//>`__ is an open source communications platform.

This documentation explains how to interconnect LemonLDAP::NG and
Rocket.Chat using SAML 2.0 protocol.

Pre-requisites
--------------

.. _rocketchat-1:

Rocket.Chat
~~~~~~~~~

You need to `install the
software <https://docs.rocket.chat/quick-start/deploying-rocket.chat>`__.


LL:NG
~~~~~

You need to enable SAML 2.0 issuer module in LL:NG:

::

   "General Parameters -> Issuer modules -> SAML -> Activation"

Create Certificate of Service provider for Rocket.Chat
____________________________________________________

You will need private key and public key within a certificate to
identify your SP in LL:NG Idp.

Select a host with a secure filesystem as a secure random source since private keys are generated.

To create a private key and self-sign a certificate for its public key

please adapt to your country/state

It is recommended to use rocketchat hostname for Common Name.

::

   certname=rocketchat_saml
   openssl req -new -newkey rsa:4096 -keyout $certname.key -nodes -out $certname.pem -x509 -days 3650

   Country Name (2 letter code) [AU]:BTN
   State or Province Name (full name) [Some-State]:North
   Locality Name (eg, city) []:Thimphou
   Organization Name (eg, company) [Internet Widgits Pty Ltd]:NGO
   Organizational Unit Name (eg, section) []:
   Common Name (e.g. server FQDN or YOUR name) []:rocketchat.example.com
   Email Address []:

Please note that once you have copied those in following process it is recommended to remove private
key file from your system.

Rocket.Chat, SAML 2.0 configuration
---------------------------------

Configuration of SAML 2.0 in Rocket.Chat is pretty straightforward.

SAML authentication that is documented here
<https://docs.rocket.chat/guides/administration/admin-panel/settings/saml/rocket.chat-server-settings>

Select a **Custom Provider** name that does not contain spaces. It will be
used as part of metadata url **Custom Issuer** and as name of SAML service
provider in further LL:NG configuration.

Unfold **Certification** and fill with rocketchat_saml.key rocketchat_saml.pem
content previously created.

LL:NG, SAML 2.0 Service Provider configuration
----------------------------------------------

We now have to define a service provider (e.g our rocketchat) in LL:NG.

Go to "SAML service providers", click on "Add SAML SP" and use very same name
than Custom Provider you used in previous Rocket.Chat configuration.

In the new subtree 'Rocket.Chat', open 'Metadata' and paste the content of
your previously downloaded file (or upload the file from Custom Issuer url)

Now go in "Exported attributes" and add the 'uid' and 'mail'

'mail' is needed for rocketchat initial mail enrollment.

Don't forget to save your configuration.

You are now good to go, and you can add the application in
:doc:`your menu<../portalmenu>` and
:doc:`your virtual hosts<../configvhost>`.

Your fields should look like this: |image6|

.. |image0| image:: /applications/rocketchat-logo.png
   :class: align-center
