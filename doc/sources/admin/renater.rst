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

.. versionchanged:: 2.0.15

   Since version 2.0.15 it is no longer necessary to copy the script, you can
   use the ``--configfile`` option to handle most customization use cases. See
   :ref:`importmetadataconfig` below for details.

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

The script provide the following options

* -i (--idpconfprefix): Prefix used to set IDP configuration key
* -h (--help): print this message
* -m (--metadata): URL of metadata document
* -s (--spconfprefix): Prefix used to set SP configuration key
* --ignore-sp: ignore SP matching this entityID (can be specified multiple times)
* --ignore-idp: ignore IdP matching this entityID (can be specified multiple times)
* -a (--nagios): output statistics in Nagios format
* -n (--dry-run): print statistics but do not apply changes
* -c (--configfile): use a configuration file
* -v (--verbose): increase verbosity of output
* -r (--remove): remove provider from LemonLDAP::NG if it does not appear in metadata


Example :
::

    /usr/libexec/lemonldap-ng/bin/importMetadata -m https://pub.federation.renater.fr/metadata/renater/main/main-sps-renater-metadata.xml -s "sp-fed-prd" -c https://pub.federation.renater.fr/metadata/certs/renater-metadata-signing-cert-2016.pem -bs https://test-sp.federation.renater.fr -r -v -d

This command will
  * fetch all SPs metadata from renater
  * set a prefix to entity stored inside LemonLdap::NG
  * disable local modification of SP https://test-sp.federation.renater.fr
  * remove local SPs wich didn't exist anymore in Federation metadata
  * show only all modifications to apply

The output is the following :
::

  ...
  Update SP https://www-iuem.univ-brest.fr/sp in configuration
  Attribute mail (urn:oid:0.9.2342.19200300.100.1.3) requested by SP https://gesper.ad.bnu.fr/shibboleth
  Attribute eduPersonPrimaryAffiliation (urn:oid:1.3.6.1.4.1.5923.1.1.1.5) requested by SP https://gesper.ad.bnu.fr/shibboleth
  Attribute eduPersonPrincipalName (urn:oid:1.3.6.1.4.1.5923.1.1.1.6) requested by SP https://gesper.ad.bnu.fr/shibboleth
  Attribute displayName (urn:oid:2.16.840.1.113730.3.1.241) requested by SP https://gesper.ad.bnu.fr/shibboleth
  Update SP https://gesper.ad.bnu.fr/shibboleth in configuration
  [INFO] Dry-run mod no EntityID inserted
  [IDP]	Found: 0	Updated: 0	Created: 0	Removed: 0	Rejected: 0	Ignored: 0
  [SP]	Found: 1248	Updated: 1240	Created: 0	Removed: 0	Rejected: 7	Ignored: 1


With "-n" options you could get a "nagios like" output with metrics :
::

  /usr/libexec/lemonldap-ng/bin/importMetadataFedRenater -m https://pub.federation.renater.fr/metadata/renater/main/main-sps-renater-metadata.xml -s "sp-fed-prd" -c https://pub.federation.renater.fr/metadata/certs/renater-metadata-signing-cert-2016.pem -bs https://test-sp.federation.renater.fr -r -d -n
  Metadata loaded inside Conf: [DRY-RUN]|idp_found=0, idp_updated=0, idp_created=0, idp_removed=0, idp_rejected=0, idp_ignored=0, sp_found=1248, sp_updated=1240, sp_created=0, sp_removed=0, sp_rejected=7, sp_ignored=1


.. attention::

    You need to add this in cron to refresh metadata into
    LL::NG configuration.


.. _importmetadataconfig:

Metadata import configuration file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: 2.0.15

You can now use a configuration file for the script in order to handle most custom cases.

Here is an example of a INI-formatted configuration file::

    # main script options, these will be overriden by the CLI options
    [main]
    dry-run=1
    verbose=1
    metadata=http://url/to/metadata.xml
    ; Multi-value options
    ignore-idp=entity-id-to-ignore-1
    ignore-idp=entity-id-to-ignore-2

    # Default exported attributes for IDPs
    [exportedAttributes]
    cn=0;cn
    eduPersonPrincipalName=0;eduPersonPrincipalName
    ...

    # options that apply to all providers
    [ALL]
    ; Disable signature requirement on requests
    samlSPMetaDataOptionsCheckSSOMessageSignature=0
    samlSPMetaDataOptionsCheckSLOMessageSignature=0
    ; Store SAML assertions in session
    samlIDPMetaDataOptionsStoreSAMLToken=1
    ; Mark ePPN as always required
    attribute_required_eduPersonPrincipalName=1
    ...

    # Specific provider configurations
    [https://test-sp.federation.renater.fr]
    ; All attributes are optional for this provider
    attribute_required=0
    ; Override some options
    samlSPMetaDataOptionsNameIDFormat=persistent

    [https://idp.renater.fr/idp/shibboleth]
    ; declare an extra attribute from this provider
    exported_attribute_eduPersonAffiliation=1;uid



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

