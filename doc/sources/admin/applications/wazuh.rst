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

Wazuh requires a certificate in the published Identity Provider metadata (i.e. not a public key). Make sure you have generated a set of private key and public certificate in
``SAML`` » ``Security`` » ``Keys``.

LL::NG SAML Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~

Use RSA-SHA256 for the IDP signature method.

Now go in "Exported attributes" and add the 'groups' variables and put the name 'Roles' for the attribute name. The attribute name must match the
'roles_key' configuration of the Wazuh indexer.

You can generate the Service Provider xml using `SAMLTool <https://www.samltool.com/sp_metadata.php>`__. Indicate ``https://<WAZUH_DHASBOARD_DOMAIN>/_opendistro/_security/saml/acs`` as the Attribute Consume Service Endpoint and ``https://<WAZUH_DHASBOARD_DOMAIN>/`` as the Logout Service Endpoint.

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

