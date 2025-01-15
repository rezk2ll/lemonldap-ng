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

LL::NG configuration
~~~~~~~~~~~~~~~~~~~~

Configure LL::NG as SAML Service Provider with this
:doc:`documentation<authsaml>`. You don't need to declare any IDP for
the moment.

Configure :ref:`SAML Discovery Protocol<samlservice-discovery-protocol>`
to redirect users on WAYF Service. The endpoint URL is
https://discovery.renater.fr/renater/WAYF.

SAML Federation
~~~~~~~~~~~~~~~

Follow :doc:`SAML Federation documentation<samlfederation>` to enable `IDP metadata file bundle <https://services.renater.fr/federation/documentation/generale/metadata/versions-metadata.>`_ download.

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

SAML Federation
~~~~~~~~~~~~~~~

Follow :doc:`SAML Federation documentation<samlfederation>` to enable `SP metadata file bundle <https://services.renater.fr/federation/documentation/generale/metadata/versions-metadata.>`_ download.

Add your IDP into the federation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to https://federation.renater.fr/registry and register your IDP.

.. |image0| image:: /logos/1renater.png
   :class: align-center

