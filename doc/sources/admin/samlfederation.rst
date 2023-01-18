Connect to SAML Federations
===========================

.. versionadded: 2.0.16

|beta| This feature is a new, experimental way to manage SAML federations. Regular users should read the :doc:`renater` doc instead.


Presentation
------------

In previous LemonLDAP::NG versions, the way to handle federations was to import the entire federation into the LemonLDAP::NG configuration. This caused several issues:

* The configuration JSON objects grows very large, sometimes beyond storage limitations
* The memory consumption is very high
* The manager interface becomes crowded with service definitions that are very rarely used

A new federation feature has been added in LemonLDAP::NG 2.0.16 to address
those issues. This is still a beta feature so feel free to experiment with it
and provide bug reports and fixes.

Configuration
-------------

Declare your SAML federation files
==================================

The new system does not (yet?) automatically handle retrieval of Federation
metadata. Therefore you need to write your own shell script to download the
federation metadata XML files on each server.

.. warning:: Be careful with possible race conditions when overwriting the
   current file. It is recommended to download the new files in a temporary
   location and then overwrite the original file with an atomic file move

Then, declare your federation metadata files in

SAML2 Service » Advanced » Federation » SAML Federation Metadata files

You should list local file paths, separated by spaces. For example ::

    /etc/saml/main-all-edugain-metadata.xml /etc/saml/main-sps-renater-metadata.xml

In case an EntityID is defined in multiple files, the first match wins.

Configure template IDP/SPs
==========================

SAML metadata does not contain all the information LemonLDAP::NG needs. It is
recommended that you create a generic configuration for all the providers found
in federation metadata.

In order to do this:

* Add a new SAML2 Service provider (or IDP)
* Leave the *Metadata* content empty
* Set *Options* » *Federation* » *Entity Identifier* to the Name= attribute of the federation. (eg: ``https://federation.renater.fr/``)

All options set on this *special* provider will be applied to SPs (or IDPs) defined in the Renater federation

In the case of Service Providers, Federation Metadata files contain a list of attributes that the SP wishes to receive. These attributes can be flagged as optional or mandatory (``isRequired="true"``).

LemonLDAP::NG lets you decide what to do with these attributes:

* *Keep*: The attribute definition from federation metadata will be handled by LemonLDAP::NG
* *Make optional*: The attribute will be handled by LemonLDAP::NG, but made optional if it was mandatory
* *Ignore*: The attribute will never be sent to this SP

You can also define additional attributes to be sent in the *Exported Attributes* section. In case of a conflict between an attribute definition in federation metadata and an explicit definition in LemonLDAP::NG configuration, the LemonLDAP::NG configuration wins.

Configure specific IDP/SPs
==========================

You may want to override the federation-wide defaults for some specific
SP/IDPs. A common example is the Renater test SP that defines all its
attributes as mandatory. Or you might want to disable AuthnRequest signature
validation for some SPs

To do this:

* Add a new SAML2 Service provider (or IDP)
* Leave the *Metadata* content empty
* Set *Options* » *Federation* » *Entity Identifier* to the entityID of the provider you want to override
* Set the desired configuration options on this provider

.. |beta| image:: /documentation/beta.png
