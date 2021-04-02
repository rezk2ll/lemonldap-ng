simpleSAMLphp
=============

|image0|

Presentation
------------

`simpleSAMLphp <https://simplesamlphp.org/>`__ is an identity/service
provider written in PHP. It supports a lot of protocols like CAS, OpenID
and SAML.

This documentation explains how to interconnect LemonLDAP::NG and
simpleSAMLphp using SAML 2.0 protocol.

Pre-requisites
--------------

.. _simplesamlphp-1:

simpleSAMLphp
~~~~~~~~~~~~~

You need to `install the
software <https://simplesamlphp.org/docs/stable/simplesamlphp-install>`__.
If using Debian, just do:

::

   apt-get install simplesamlphp

We suppose that configuration is done in ``/etc/simplesamlphp`` and that
simpleSAMLphp is accessible at http://localhost/simplesamlphp.

To be able to sign SAML messages, you need to create a certificate.
First set where certificates are stored:

::

   vi /etc/simplesamlphp/config.php

.. code-block:: php

      'certdir' => '/etc/simplesamlphp/certs/',

Create directory and generate the certificate

::

   mkdir /etc/simplesamlphp/certs/
   cd /etc/simplesamlphp/certs/
   openssl req -newkey rsa:2048 -new -x509 -days 3652 -nodes -out saml.crt -keyout saml.pem

Then associate this certificate to the default SP:

::

   vi /etc/simplesamlphp/authsources.php

.. code-block:: php

       'default-sp' => array(
           'saml:SP',
           'privatekey' => 'saml.pem',
           'certificate' => 'saml.crt',

LemonLDAP::NG
~~~~~~~~~~~~~

You need to configure :doc:`SAML Service<../samlservice>`. Be sure to
convert public key in a certificate, as described in the
:doc:`security chapter<../samlservice>` as simpleSAMLphp can't use the
public key.

simpleSAMLphp as Service Provider
---------------------------------

We suppose you configured LemonLDAP::NG as
:doc:`SAML Identity Provider<../idpsaml>` and want to use simpleSAMLphp
as Service Provider.

In LL::NG Manager, create an new SP and load simpleSAMLphp metadata
through URL (by default:
http://localhost/simplesamlphp/module.php/saml/sp/metadata.php/default-sp):

|image1|

Then set some attributes that will be sent to simpleSAMLphp:

|image2|


.. tip::

    Set ``Mandatory`` to ``On`` to force attributes in
    authentication response.

You can also force all signatures:

|image3|

On simpleSAMLphp side, use the metadata converter (by default:
http://localhost/simplesamlphp/admin/metadata-converter.php) to convert
LL::NG metadata (by default: http://auth.example.com/saml/metadata) into
internal PHP representation. Copy the ``saml20-idp-remote`` content:

::

   vi /etc/simplesamlphp/metadata/saml20-idp-remote.php

.. code-block:: php

   <?php
   $metadata['http://auth.example.com/saml/metadata'] = array (
     'entityid' => 'http://auth.example.com/saml/metadata',
   ...
      // Add this option to force SLO requests signature
      'sign.logout' => true,
   );
   ?>


.. tip::

    Don't forget PHP start and end tag to have a valid PHP
    file.

All is ready, you can now test the authentication (by default:
http://localhost/simplesamlphp/module.php/core/authenticate.php). You
should see something like that:

|image4|

simpleSAMLphp as Identity Provider
----------------------------------

We suppose you configured LemonLDAP::NG as
:doc:`SAML Service Provider<../authsaml>` and want to use simpleSAMLphp
as Identity Provider.

First, you need to activate IDP feature in simpleSAMLphp:

::

   vi /etc/simplesamlphp/config.php

.. code-block:: php

       'enable.saml20-idp' => true,

And create a default IDP configuration:

::

   vi /etc/simplesamlphp/metadata/saml20-idp-hosted.php

.. code-block:: php

   <?php
   $metadata['__DYNAMIC:1__'] = array(
       /*
        * The hostname for this IdP. This makes it possible to run multiple
        * IdPs from the same configuration. '__DEFAULT__' means that this one
        * should be used by default.
        */
       'host' => '__DEFAULT__',

       /*
        * The private key and certificate to use when signing responses.
        * These are stored in the cert-directory.
        */
       'privatekey' => 'saml.pem',
       'certificate' => 'saml.crt',

       /*
        * The authentication source which should be used to authenticate the
        * user. This must match one of the entries in config/authsources.php.
        */
       'auth' => 'admin',
       // Sign SLO messages
       'sign.logout' => true,
   );
   ?>


.. attention::

    You need to configure your own certificates and
    authentication scheme

Now in LL::NG Manager, create a new IDP and import metadata with URL (by
default: http://localhost/simplesamlphp/saml2/idp/metadata.php):

|image5|

List attributes you want to collect:

|image6|


.. tip::

    You can keep ``Mandatory`` to ``Off`` to not fail if attribute
    is not sent by IDP

And activate all signatures:

|image7|

To finish, you need to declare LL::NG SP in simpleSAMLphp. Use the
metadata converter (by default:
http://localhost/simplesamlphp/admin/metadata-converter.php) to convert
LL::NG metadata (by default: http://auth.example.com/saml/metadata) into
internal PHP representation. Copy the ``saml20-sp-remote`` content:

::

   vi /etc/simplesamlphp/metadata/saml20-sp-remote.php

.. code-block:: php

   <?php
   $metadata['http://auth.example.com/saml/metadata'] = array (
     'entityid' => 'http://auth.example.com/saml/metadata',
   ...
   );
   ?>


.. tip::

    Don't forget PHP start and end tag to have a valid PHP
    file.

All is ready, you can now test the authentication from LL::NG portal.

.. |image0| image:: /applications/simplesamlphp_logo.png
   :class: align-center
.. |image1| image:: /applications/simplesamlphp_sp_metadata.png
   :class: align-center
.. |image2| image:: /applications/simplesamlphp_sp_attributes.png
   :class: align-center
.. |image3| image:: /applications/simplesamlphp_sp_signature.png
   :class: align-center
.. |image4| image:: /applications/simplesamlphp_sp_authentication.png
   :class: align-center
.. |image5| image:: /applications/simplesamlphp_idp_metadata.png
   :class: align-center
.. |image6| image:: /applications/simplesamlphp_idp_attributes.png
   :class: align-center
.. |image7| image:: /applications/simplesamlphp_idp_signature.png
   :class: align-center

