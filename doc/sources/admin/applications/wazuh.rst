Wazuh
=====

|image0|

Presentation
------------

`Wazuh <https://wazuh.com/>`__ is an Open Source Security Information and Event Management (SIEM) and Extended Detection and Response  (XDR)
solution that supports the :doc:`SAML <../idpsaml>` protocol.

Configuration
--------------

LL::NG
~~~~~~

This page assumes you already have configured the SAML Service in
LemonLDAP::NG, if not please follow :
:doc:`SAML service configuration<../samlservice>`


LL::NG SAML Key & Certificate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You'll need a private key and the corresponding certificate to setup
SAML in Wazuh, you can do it with your pki or with openssl on your machine
:

::

   openssl req -x509 -newkey rsa:4096 -keyout saml-awx.key -out saml-awx.crt -days 3650 -nodes


Generate Certificate from Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can find your private key in : SAML2 Service -> Security Parameters
-> Signature -> Private Key

Copy it somewhere secure as lemonldap.key, and then generate the
certificate with this command :

::

   openssl req -new -x509 -days 3650 -key lemonldap.key > lemonldap.crt

After that, if you want, you can replace your SAML public key with this
certificate in LL::NG configuration.

Make sure you have generated a set of private key and public certificate in
``SAML`` » ``Security`` » ``Keys``.

Use RSA-SHA256 for the IDP signature method.

Now go in "Exported attributes" and add the 'groups' variables and put the name 'Roles' for the attribute name. The attribute name must match the
'roles_key' configuration of the Wazuh indexer.

You can generate the Service Provider xml using `SAMLTool <https://www.samltool.com/sp_metadata.php>`__. Indicate "https://<WAZUH_DHASBOARD_DOMAIN>/_opendistro/_security/saml/acs" as the Attribute Consume Service Endpoint and "https://<WAZUH_DHASBOARD_DOMAIN>/" as the Logout Service Endpoint.

Wazuh
~~~~~

Refer to the `Wazuh documentation
<https://documentation.wazuh.com/current/user-manual/user-administration/single-sign-on/index.html>`__ to configure your Wazuh server and Wazuh
Dashboard.

Note that the SAML authentication requires the following JVM policy in the Wazuh indexer start command:

::

    grant {
        permission java.util.PropertyPermission "*","read,write";
    }

.. |image0| image:: /applications/wazuh-logo.png
   :class: align-center

