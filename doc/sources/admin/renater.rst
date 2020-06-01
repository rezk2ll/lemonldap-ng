Connect to Renater Federation
=============================

|image0|

Presentation
------------

`Renater <https://www.renater.fr/>`__ provides an SAML federation for
higher education in France.

It is based on SAMLv2 but add some specific items like a WAYF service
and a metadata bundle to list all SP and IDP from the federation.

Since LL::NG 2.0, you can register into Renater federation.

Register as Service Provider
----------------------------

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

Configure LL::NG as SAML Service Provider with this
:doc:`documentation<authsaml>`. You don't need to declare any IDP for
the moment.

Configure :ref:`SAML Discovery Protocol<samlservice-discovery-protocol>`
to redirect users on WAYF Service. The endpoint URL is
https://discovery.renater.fr/renater/WAYF.

Metadata import
~~~~~~~~~~~~~~~

You now need to import IDP metadata in LL::NG configuration. Use the
``importMetadata`` script that should be installed in
/usr/share/lemonldap-ng/bin. You need to select the correct metadata
bundle proposed by Renater:
https://services.renater.fr/federation/technique/metadata.

For Renater, you need to customize some settings of the script, copy it
and edit configuration:

::

   cp /usr/share/lemonldap-ng/bin/importMetadata /usr/share/lemonldap-ng/bin/importMetadataRenater
   vi /usr/share/lemonldap-ng/bin/importMetadataRenater

Set attributes (use the SAML Name, not FriendlyName) that are provided
by IDPs, for example:

.. code-block:: perl

   my $exportedAttributes = {
       'cn'                          => '0;urn:oid:2.5.4.3',
       'eduPersonPrincipalName'      => '1;urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
       'givenName'                   => '0;urn:oid:2.5.4.42',
       'sn'                          => '0;urn:oid:2.5.4.4',
       'eduPersonAffiliation'        => '0;urn:oid:1.3.6.1.4.1.5923.1.1.1.1',
       'eduPersonPrimaryAffiliation' => '0;urn:oid:1.3.6.1.4.1.5923.1.1.1.5',
       'mail'                        => '0;urn:oid:0.9.2342.19200300.100.1.3',
       'supannListeRouge'            => '0;urn:oid:1.3.6.1.4.1.7135.1.2.1.1',
       'supannEtuCursusAnnee'        => '0;rn:oid:1.3.6.1.4.1.5923.1.1.1.10',
   };

Adapt IDP options, for example:

.. code-block:: perl

   my $idpOptions = {
       'samlIDPMetaDataOptionsAdaptSessionUtime'        => 0,
       'samlIDPMetaDataOptionsAllowLoginFromIDP'        => 0,
       'samlIDPMetaDataOptionsAllowProxiedAuthn'        => 0,
       'samlIDPMetaDataOptionsCheckAudience'            => 1,
       'samlIDPMetaDataOptionsCheckSLOMessageSignature' => 1,
       'samlIDPMetaDataOptionsCheckSSOMessageSignature' => 1,
       'samlIDPMetaDataOptionsCheckTime'                => 1,
       'samlIDPMetaDataOptionsEncryptionMode'           => 'none',
       'samlIDPMetaDataOptionsForceAuthn'               => 0,
       'samlIDPMetaDataOptionsForceUTF8'                => 1,
       'samlIDPMetaDataOptionsIsPassive'                => 0,
       'samlIDPMetaDataOptionsNameIDFormat'             => 'transient',
       'samlIDPMetaDataOptionsRelayStateURL'            => 0,
       'samlIDPMetaDataOptionsSignSLOMessage'           => -1,
       'samlIDPMetaDataOptionsSignSSOMessage'           => -1,
       'samlIDPMetaDataOptionsStoreSAMLToken'           => 0,
       'samlIDPMetaDataOptionsUserAttribute' => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
   };

Then run the script:

::

   /usr/share/lemonldap-ng/bin/importMetadataRenater -m https://metadata.federation.renater.fr/renater/main/main-idps-renater-metadata.xml -r -i "idp-renater-" -s "sp-renater-"


.. attention::

    You need to add this in cron to refresh metadata into
    LL::NG configuration.

Add your SP into the federation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to https://federation.renater.fr/registry and register your SP.


.. attention::

    Be sure to check all attributes as mandatory to be able
    to get them in SAML assertions.

Register as Identity Provider
-----------------------------

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

Metadata import
~~~~~~~~~~~~~~~

You now need to import SP metadata in LL::NG configuration. Use the
``importMetadata`` script that should be installed in
/usr/share/lemonldap-ng/bin. You need to select the correct metadata
bundle proposed by Renater:
https://services.renater.fr/federation/technique/metadata.

For Renater, you may need to customize some settings of the script, copy
it and edit configuration:

::

   cp /usr/share/lemonldap-ng/bin/importMetadata /usr/share/lemonldap-ng/bin/importMetadataRenater
   vi /usr/share/lemonldap-ng/bin/importMetadataRenater

Adapt IDP options, for example:

.. code-block:: perl

   my $spOptions = {
       'samlSPMetaDataOptionsCheckSLOMessageSignature'   => 1,
       'samlSPMetaDataOptionsCheckSSOMessageSignature'   => 1,
       'samlSPMetaDataOptionsEnableIDPInitiatedURL'      => 0,
       'samlSPMetaDataOptionsEncryptionMode'             => 'none',
       'samlSPMetaDataOptionsForceUTF8'                  => 1,
       'samlSPMetaDataOptionsNameIDFormat'               => '',
       'samlSPMetaDataOptionsNotOnOrAfterTimeout'        => 72000,
       'samlSPMetaDataOptionsOneTimeUse'                 => 0,
       'samlSPMetaDataOptionsSessionNotOnOrAfterTimeout' => 72000,
       'samlSPMetaDataOptionsSignSLOMessage'             => 1,
       'samlSPMetaDataOptionsSignSSOMessage'             => 1
   };

Then run the script:

::

   /usr/share/lemonldap-ng/bin/importMetadataRenater -m https://metadata.federation.renater.fr/renater/main/main-sps-renater-metadata.xml -r -i "idp-renater" -s "sp-renater"


.. attention::

    You need to add this in cron to refresh metadata into
    LL::NG configuration.

Add your IDP into the federation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to https://federation.renater.fr/registry and register your IDP.

.. |image0| image:: /logos/1renater.png
   :class: align-center

