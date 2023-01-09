SAML service configuration
==========================


.. note::

    SAML service configuration is a common step to configure LL::NG as
    :doc:`SAML SP<authsaml>` or :doc:`SAML IDP<idpsaml>`.

Presentation
------------

This documentation explains how configure SAML service in LL::NG, in
particular:

-  Install prerequisites
-  Import or generate security keys
-  Set SAML end points


.. attention::

    Service configuration will be used to generate LL::NG
    SAML metadata, that will be shared with other providers. It means that
    if you modify some settings here, you will have to share again the
    metadata with other providers. In other words, take the time to
    configure this part before sharing metadata.

Prerequisites
-------------

Lasso
~~~~~

|image0|

SAML2 implementation is based on
`Lasso <http://lasso.entrouvert.org>`__. You will need a very recent
version of Lasso (>= 2.6.0).

Debian/Ubuntu
^^^^^^^^^^^^^

You can use official Debian packages or those available here:
http://deb.entrouvert.org/.


.. tip::

    We recommend Lasso 2.6 for the SHA256 support, so use the
    stretch-testing repository of deb.entrouvert.org.

You will only need to install liblasso-perl package:

::

   sudo apt-get install liblasso-perl

RHEL/CentOS/Fedora
^^^^^^^^^^^^^^^^^^

RPMs are available in LL::NG RPM "extras" repository (see
:ref:`installrpm-yum-repository`)

Then install lasso and lasso-perl packages:

::

   yum install lasso lasso-perl


.. attention::

    Only 64bits package are available.

Other
^^^^^

`Download the Lasso tarball <http://lasso.entrouvert.org/download/>`__
and compile it on your system.

Service configuration
---------------------

Go in Manager and click on ``SAML 2 Service`` node.


.. tip::

    You can use #PORTAL# in values to replace the portal
    URL.

Entry Identifier
~~~~~~~~~~~~~~~~

Your EntityID, often use as metadata URL, by default
#PORTAL#/saml/metadata.


.. note::

    The value will be use in metadata main markup:

    .. code:: xml

       <EntityDescriptor entityID="http://auth.example.com/saml/metadata">
         ...
       </EntityDescriptor>



.. _samlservice-security-parameters:

Security parameters
~~~~~~~~~~~~~~~~~~~

You can define keys for SAML message signature and encryption. If no
encryption keys are defined, signature keys are used for signature and
encryption.

To define keys, you can:

-  import your own private and public keys (``Replace by file`` input)
-  generate new public and private keys (``New certificate`` button)

.. versionchanged:: 2.0.10

   A X.509 certificate is now generated instead of a plain public key. It has
   20 years of validity, and is self signed with the 2048bit RSA key.

.. tip::

    You can enter a password to protect private key with a
    password. It will be prompted if you generate keys, else you can set it
    in the ``Private key password``.

|image1|



-  **Use certificate in response**: Certificate will be sent inside SAML
   responses.
-  **Signature method**: set the signature algorithm

.. versionchanged:: 2.0.10

   The signature method can now be overridden for a SP or IDP. This will only work
   if you are using a certificate for signature instead of a public key.


.. attention::

   If you are running a version under 2.0.10, the choice of a signature
   algorithm will affect all SP and IDP.


.. _samlservice-convert-certificate:

Converting a RSA public key to a certificate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your application complains about the lack of certificate in SAML Metadata, and you generated a public RSA key instead of a certificate in a previous version of LemonLDAP::NG, you can convert the public key into a certificate without changing the private key.

Save the private key in a file, and use the ``openssl`` commands to
issue a self-signed certificate:

    ::

       $ openssl req -new -key private.key -out cert.pem -x509 -days 3650


NameID formats
~~~~~~~~~~~~~~

SAML can use different NameID formats. The NameID is the main user
identifier, carried in SAML messages. You can configure here which field
of LL::NG session will be associated to a NameID format.


.. note::

    This parameter is used by :doc:`SAML IDP<idpsaml>` to fill the
    NameID in authentication responses.

Customizable NameID formats are:

-  Email
-  X509
-  Windows
-  Kerberos


.. tip::

    For example, if you are using
    :doc:`AD as authentication backend<authldap>`, you can use
    sAMAccountName for the Windows NameID format.

Other NameID formats are automatically managed:

-  **Transient**: NameID is generated
-  **Persistent**: NameID is restored from previous sessions
-  **Undefined**: Default NameID format is used

.. _samlservice-authentication-contexts:

Authentication contexts
~~~~~~~~~~~~~~~~~~~~~~~

Each LL::NG authentication module has an authentication level, which can
be associated to an `SAML authentication
context <http://docs.oasis-open.org/security/saml/v2.0/saml-authn-context-2.0-os.pdf>`__.


.. note::

    This parameter is used by :doc:`SAML IDP<idpsaml>` to fill the
    authentication context in authentication responses. It will use the
    authentication level registered in user session to match the SAML
    authentication context. It is also used by :doc:`SAML SP<authsaml>` to
    fill the authentication level in user session, based on authentication
    response authentication context.

Customizable NameID formats are:

-  Password
-  Password protected transport
-  TLS client
-  Kerberos

Organization
~~~~~~~~~~~~


.. note::

    This concerns all parameters for the Organization metadata
    section:

    .. code:: xml

       <Organization>
         <OrganizationName xml:lang="en">Example</OrganizationName>
         <OrganizationDisplayName xml:lang="en">Example</OrganizationDisplayName>
         <OrganizationURL xml:lang="en">http://www.example.com</OrganizationURL>
       </Organization>



-  **Display Name**: should be displayed on IDP, this is often your
   society name
-  **Name**: internal name
-  **URL**: URL of your society

Service Provider
~~~~~~~~~~~~~~~~


.. note::

    This concerns all parameters for the Service Provider metadata
    section:

    .. code:: xml

       <SPSSODescriptor>
         ...
       </SPSSODescriptor>


.. _samlservice-general-options:

General options
^^^^^^^^^^^^^^^

-  **Signed Authentication Request**: set to On to always sign
   authentication request.
-  **Want Assertions Signed**: set to On to require that received
   assertions are signed.


.. tip::

    These options can then be overridden for each Identity
    Provider.

Single Logout
^^^^^^^^^^^^^

For each binding you can set:

-  **Location**: Access Point for SLO request.
-  **Response Location**: Access Point for SLO response.

Available bindings are:

-  HTTP Redirect
-  HTTP POST
-  HTTP SOAP

Assertion Consumer
^^^^^^^^^^^^^^^^^^

For each binding you can set:

-  **Default**: will this binding be used by default for authentication
   response.
-  **Location**: Access Point for SSO request and response.

Available bindings are:

-  HTTP Artifact
-  HTTP POST

Artifact Resolution
^^^^^^^^^^^^^^^^^^^

The only authorized binding is SOAP. This should be set as Default.

Identity Provider
~~~~~~~~~~~~~~~~~


.. note::

    This concerns all parameters for the Service Provider metadata
    section:

    .. code:: xml

       <IDPSSODescriptor>
         ...
       </IDPSSODescriptor>



General parameters
^^^^^^^^^^^^^^^^^^

* **Want Authentication Request Signed**: By default, LemonLDAP::NG requires all SAML Requests to be signed. Set it to "Off" to let each Service Provider metadata decide if their requests should be verified by LemonLDAP::NG or not.

.. tip::

    The per-SP "Check SSO message signature" setting allows you to disable
    signature verification even if this option is set to "On" globally

This option will set the `WantAuthnRequestsSigned` attribute to `true` in LemonLDAP::NG's IDP Metadata.

.. warning::

   This setting requires Lasso 2.6.1 to be effective. Older versions behave as if this setting was set to "Off"

Single Sign On
^^^^^^^^^^^^^^

For each binding you can set:

-  **Location**: Access Point for SSO request.
-  **Response Location**: Access Point for SSO response.

Available bindings are:

-  HTTP Redirect
-  HTTP POST
-  HTTP Artifact

.. _single-logout-1:

Single Logout
^^^^^^^^^^^^^

For each binding you can set:

* **Location**: Access Point for SLO request.
* **Response Location**: Access Point for SLO response.

Available bindings are:

-  HTTP Redirect
-  HTTP POST
-  HTTP SOAP

.. _artifact-resolution-1:

Artifact Resolution
^^^^^^^^^^^^^^^^^^^

The only authorized binding is SOAP. This should be set as Default.

Attribute Authority
~~~~~~~~~~~~~~~~~~~


.. note::

    This concerns all parameters for the Attribute Authority metadata
    section

    .. code:: xml

       <AttributeAuthorityDescriptor>
         ...
       </AttributeAuthorityDescriptor>



Attribute Service
^^^^^^^^^^^^^^^^^

This is the only service to configure, and it accept only the SOAP
binding.

Response Location should be empty, as SOAP responses are directly
returned (synchronous binding).

Advanced
~~~~~~~~

These parameters are not mandatory to run SAML service, but can help to
customize it:

-  **IDP resolution cookie name**: by default, it's the LL::NG cookie
   name suffixed by ``idp``, for example: ``lemonldapidp``.
-  **UTF8 metadata conversion**: set to On to force partner's metadata
   conversion.
-  **RelayState session timeout**: timeout for RelayState sessions. By
   default, the RelayState session is deleted when it is read. This
   timeout allows one to purge sessions of lost RelayState.
-  **Use specific query_string method**: the CGI query_string method may
   break invalid URL encoded signatures (issued for example by ADFS).
   This option allows one to use a specific method to extract query
   string, that should be compliant with non standard URL encoded
   parameters.
-  **Override Entity ID when acting as IDP**: By default, SAML entityID
   is the same for SP and IDP roles. Some federations (like
   :doc:`Renater<renater>`) can require a different entityID for IDP. In
   this case, you can fill here the IDP entityID, for example:
   ``https://auth.example.com/saml/metadata/idp``.

.. _samlservice-saml-sessions-module-name-and-options:

SAML sessions module name and options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default, the main session module is used to store SAML temporary data
(like relay-states), but SAML sessions need to use a session module
compatible with the
:ref:`sessions restrictions feature<session-restrictions>`.


.. tip::

    You can also choose a different session module to split SSO
    sessions and SAML sessions.

Common Domain Cookie
^^^^^^^^^^^^^^^^^^^^

The common domain is used by :doc:`SAML SP<authsaml>` to find an
Identity Provider for the user, and by :doc:`SAML IDP<idpsaml>` to
register itself in user's IDP list.

Configuration parameters are:

-  **Activation**: Set to On to enable Common Domain Cookie support.
-  **Common domain**: Name of the common domain (where common cookie is
   available).
-  **Reader URL**: URL used by SAML SP to read the cookie. Leave blank
   to deactivate the feature.
-  **Writer URL**: URL used by SAML IDP to write the cookie. Leave blank
   to deactivate the feature.

.. _samlservice-discovery-protocol:

Discovery Protocol
^^^^^^^^^^^^^^^^^^


.. note::

    Discovery Protocol is also know as `WAYF
    Service <http://www.switch.ch/aai/support/tools/wayf.html>`__. More
    information can be found in the specification:
    `sstc-saml-idp-discovery-cs-01.pdf <https://www.oasis-open.org/committees/download.php/28049/sstc-saml-idp-discovery-cs-01.pdf>`__.

When Discovery Protocol is enabled, the LL::NG IDP list is no more used.
Instead user is redirected on the discovery service and is redirected
back to LL::NG with the chosen IDP.


.. attention::

    If the chosen IDP is not registered in LL::NG, user will
    be redirected to discovery service again.

Configuration parameters are:

-  **Activation**: Set to On to enable Discovery Protocol support.
-  **EndPoint URL**: Discovery service page
-  **Policy**: Set a value here if you don't want to use the default
   policy
   (``urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol:single``)
-  **Is passive**: Enable this option to avoid user interaction on
   discovery service page

.. |image0| image:: /documentation/lasso.png
   :class: align-center
.. |image1| image:: /documentation/manager-saml-signature.png
   :class: align-center

