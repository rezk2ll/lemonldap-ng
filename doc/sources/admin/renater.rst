Connect to Renater Federation
=============================

|image0|

Presentation
------------

`Renater <https://www.renater.fr/>`__ provides an SAML federation for
higher education in France.

It is based on SAMLv2 but add some specific items like a WAYF service
and a metadata bundle to list all SP and IDP from the federation.

Register as Service Provider
----------------------------

If you want to give access to applications protected with LL::NG to users of the federation then you will act as a Service Provider.

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

Configure LL::NG as SAML Service Provider with this
:doc:`documentation<authsaml>`. You don't need to declare any IDP for
the moment.

Configure :ref:`SAML Discovery Protocol<samlservice-discovery-protocol>`
to redirect users on WAYF Service. The endpoint URL is
https://discovery.renater.fr/renater/WAYF.

With configuration CLI:

.. code-block:: shell

   /usr/*/lemonldap-ng/bin/lemonldap-ng-cli set \
        samlDiscoveryProtocolActivation 1 \
        samlDiscoveryProtocolURL https://discovery.renater.fr/renater/WAYF.

SAML Federation
~~~~~~~~~~~~~~~

Follow :doc:`SAML Federation documentation<samlfederation>` to enable `IDP metadata file bundle <https://services.renater.fr/federation/en/documentation/generale/metadata/fichiers>`__ download. For example :

.. code-block:: shell

   /usr/share/lemonldap-ng/bin/downloadSamlMetadata -m https://pub.federation.renater.fr/metadata/renater/main/main-idps-renater-metadata.xml -o /etc/lemonldap-ng/metadata/main-idps-renater-metadata.xml

Then declare this file in SAML2 Service > Advanced > Federation > SAML Federation Metadata files.

With configuration CLI:

.. code-block:: shell

   /usr/*/lemonldap-ng/bin/lemonldap-ng-cli set \
     samlFederationFiles /etc/lemonldap-ng/metadata/main-idps-renater-metadata.xml


Add your SP into the federation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to `Renater registration portal <https://federation.renater.fr/registry>`__ and register your SP on the Renater federation.

.. attention::

    Be sure to check all attributes as mandatory to be able
    to get them in SAML assertions. Remember OID and name
    ti configure them in LL::NG.


Create the IDP template
~~~~~~~~~~~~~~~~~~~~~~~

Declare a template Identity Provider in LL::NG configuration that will hold the default settings for all IDP of the Renater Federation :

* Keep metadata empty
* Associate it by setting Options > Federation > Entity identifier to https://federation.renater.fr/
* Declare the attributes in Exported Attributes and put ``urn:oid:OID`` in Attribute name and name in Friendly name.
* Set NameID format to ``Unspecified`` in Options > NameID format

With configuration CLI:

.. code-block:: shell

   /usr/*/lemonldap-ng/bin/lemonldap-ng-cli addKey \
     samlIDPMetaDataExportedAttributes/idp-renater mail '0;urn:oid:0.9.2342.19200300.100.1.3;urn:oasis:names:tc:SAML:2.0:attrname-format:uri;mail' \
     samlIDPMetaDataExportedAttributes/idp-renater uid '0;urn:oid:1.3.6.1.4.1.5923.1.1.1.6;urn:oasis:names:tc:SAML:2.0:attrname-format:uri;eduPersonPrincipalName' \
     samlIDPMetaDataOptions/idp-renater samlIDPMetaDataOptionsFederationEntityID 'https://federation.renater.fr/' \
     samlIDPMetaDataOptions/idp-renater samlIDPMetaDataOptionsNameIDFormat 'unspecified'

.. tip::

   You can override these settings for a specific IDP by creating a new IDP in configuration and configuring the Federation EntityID with the value of the IDP EntityID.

Register as Identity Provider
-----------------------------

If you want to give access to Renater applications (SP) to users authenticated with your LL::NG server, then you will act as an Identity Provider.

.. _llng-configuration-renater-1:

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

Configure LL::NG as SAML Identity Provider with this
:doc:`documentation<idpsaml>`. You don't need to declare any SP for the
moment.


.. attention::

    If your LL::NG server will act as SP and IDP inside
    Renater federation, you need to set the advanced parameter "Override
    Entity ID for IDP". Indeed, Renater do not allow to register a SP and an
    IDP with the same entityID.

.. _metadata-import-1:

SAML Federation
~~~~~~~~~~~~~~~

Follow :doc:`SAML Federation documentation<samlfederation>` to enable `SP metadata file bundle <https://services.renater.fr/federation/en/documentation/generale/metadata/fichiers>`_ download. For Example:

.. code-block:: shell

   /usr/share/lemonldap-ng/bin/downloadSamlMetadata -m https://pub.federation.renater.fr/metadata/renater/main/main-sps-renater-metadata.xml -o /etc/lemonldap-ng/metadata/main-sps-renater-metadata.xml

Then declare this file in SAML2 Service > Advanced > Federation > SAML Federation Metadata files.

With configuration CLI:

.. code-block:: shell

   /usr/*/lemonldap-ng/bin/lemonldap-ng-cli set \
     samlFederationFiles /etc/lemonldap-ng/metadata/main-sps-renater-metadata.xml

Add your IDP into the federation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to `Renater registration portal <https://federation.renater.fr/registry>`__ and register your IDP on the Renater federation.

Create the SP template
~~~~~~~~~~~~~~~~~~~~~~

Declare a template Service Provider in LL::NG configuration that will hold the default settings for all SP of the Renater Federation :

* Keep metadata empty
* Associate it by setting Options > Federation > Entity identifier to https://federation.renater.fr/

With configuration CLI:

.. code-block:: shell

   /usr/*/lemonldap-ng/bin/lemonldap-ng-cli addKey \
     samlSPMetaDataOptions/idp-renater samlSPMetaDataOptionsFederationEntityID 'https://federation.renater.fr/'

.. tip::

   You can override these settings for a specific SP by creating a new SP in configuration and configuring the Federation EntityID with the value of the SP EntityID.


.. |image0| image:: /logos/1renater.png
   :class: align-center

