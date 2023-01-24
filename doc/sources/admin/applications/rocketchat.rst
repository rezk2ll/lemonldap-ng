Rocket.Chat
===========

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
~~~~~~~~~~~

Assuming you already have a rocketchat setup.

Installing rocketchat chat software is documented on the `official Rocket.Chat documentation <https://docs.rocket.chat/quick-start/deploying-rocket.chat>`__.


Rocket.Chat, SAML 2.0 configuration
-----------------------------------

Configuration of SAML 2.0 in Rocket.Chat is pretty straightforward once certificate are created.


Create Certificate of Service provider for Rocket.Chat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Configure SAML within RocketChat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SAML authentication that is documented on the `official Rocket.Chat SAML documentation
<https://docs.rocket.chat/guides/administration/admin-panel/settings/saml/rocket.chat-server-settings>`__

Select a **Custom Provider** name that does not contain spaces. It will be
used as part of metadata url **Custom Issuer** and as name of SAML service
provider in further LL:NG configuration.

Unfold **Certification** and fill with rocketchat_saml.key rocketchat_saml.pem
content created previously.


LL:NG, SAML 2.0 Service Provider configuration
----------------------------------------------

You should have configured LL::NG as an :doc:`SAML Identity Provider<../idpsaml>`.

We now have to define a service provider (e.g our rocketchat) in LL:NG.

Go to "SAML service providers", click on "Add SAML SP".

In the new subtree 'Rocket.Chat', open 'Metadata' and paste the content of
your previously downloaded file (or upload the file from Custom Issuer url)

Now go in "Exported attributes" and add the 'uid' and 'mail'

'mail' is needed for rocketchat initial mail enrollment.

Don't forget to save your configuration.

You are now good to go, and you can add the application in
:doc:`your menu<../portalmenu>` and
:doc:`your virtual hosts<../configvhost>`.

.. |image0| image:: /applications/rocketchat-logo.png
   :class: align-center
