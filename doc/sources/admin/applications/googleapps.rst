Google Apps
===========

|image0|

Presentation
------------

`Google Apps <http://www.google.com/apps/>`__ can use SAML to
authenticate users, behaving as an SAML service provider, as explained
`here <http://code.google.com/googleapps/domain/sso/saml_reference_implementation.html>`__.

To work with LL::NG it requires:

-  An `enterprise Google Apps
   account <http://www.google.com/apps/intl/en/business/index.html>`__
-  LL::NG configured as :doc:`SAML Identity Provider<../idpsaml>`
-  Registered users on Google Apps with the same email than those used
   by LL::NG (email will be the NameID exchanged between Google Apps and
   LL::NG)

Configuration
-------------

Google Apps control panel
~~~~~~~~~~~~~~~~~~~~~~~~~


.. attention::

    This part is based on `SimpleSAMLPHP
    documentation <http://simplesamlphp.org/docs/1.6/simplesamlphp-googleapps>`__.

As administrator, go in Google Apps control panel and click on Advanced
tools:

|image1|

Then select ``Set up single sign-on (SSO)``:

|image2|

Now configure all SAML parameters:

|image3|

-  **Enable Single Sign-On**: check the box. Uncheck it to disable SAML
   authentication (for example, if your Identity Provider is down).
-  **Sign-in page URL**: SSO access point (HTTP-Redirect binding).
   Example: http://auth.example.com/saml/singleSignOn
-  **Sign-out page URL**: this in not the SLO access point (Google Apps
   does not support SLO), but the main logout page. Example:
   http://auth.example.com/?logout=1
-  **Change password URL**: where users can change their password.
   Example: http://auth.example.com


.. attention::

    You must check the option
    ``Use a specific domain transmitter`` to force Google Apps to send the
    full entityId.

Certificate
~~~~~~~~~~~

For the certificate, you can build it from the signing private key
registered in Manager. Select the key, and export it (button
``Download``). This will download the public and the private key.

Keep the private key in a file, for example lemonldap-ng-priv.key, then
use openssl to generate an auto-signed certificate:

::

   openssl req -new -key lemonldap-ng-priv.key -out cert.csr
   openssl x509 -req -days 3650 -in cert.csr -signkey lemonldap-ng-priv.key -out cert.pem

You can now the upload the certificate (``cert.pem``) on Google Apps.


.. tip::

    You can also use the certificate instead of public key in SAML
    metadata, see :doc:`SAML service configuration<../samlservice>`\

New Service Provider
~~~~~~~~~~~~~~~~~~~~

You should have configured LL::NG as an
:doc:`SAML Identity Provider<../idpsaml>`,

Now we will add Google Apps as a new SAML Service Provider:

#. In Manager, click on SAML service providers and the button
   ``New service provider``.
#. Set GoogleApps as Service Provider name.
#. Set ``Email`` in ``Options`` » ``Authentication Response`` »
   ``Default NameID format``
#. Disable all signature flags in ``Options`` » ``Signature``, except
   ``Sign SSO message`` which should be to ``On``
#. Select ``Metadata``, and unprotect the field to paste the following
   value:

.. code-block:: xml

   <md:EntityDescriptor entityID="google.com" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">
     <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
       <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://www.google.com/a/mydomain.org/acs" index="1" />
       <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
     </SPSSODescriptor>
   </md:EntityDescriptor>


.. attention::

    Change **mydomain.org** (in ``AssertionConsumerService``
    markup, parameter ``Location``) into your Google Apps domain. Also adapt
    your entityID to match the Assertion issuer: google.com/a/mydomain.org


Application menu
~~~~~~~~~~~~~~~~

You can add a link in :doc:`application menu<../portalmenu>` to display
Google Apps to users.

You need to adapt some parameters:

-  **Address**: set one of Google Apps URL (all Google Apps product a
   distinct URL), for example
   http://www.google.com/calendar/hosted/mydomain.org/render
-  **Display**: As Google Apps is not a protected application, set to
   ``On`` to always display it


.. attention::

    Change **mydomain.org** into your Google Apps
    domain

Logout
~~~~~~

Google Apps does not support Single Logout (SLO).

Google Apps has a configuration parameter to redirect user on a specific
URL after Google Apps logout (see :doc:`Google Apps control panel<>`).

To manage the other way (LL::NG → Google Apps), you can add a dedicated
:doc:`logout forward rule<../logoutforward>`:

::

   GoogleApps => http://www.google.com/calendar/hosted/mydomain.org/logout


.. attention::

    Change **mydomain.org** into your Google Apps
    domain

.. |image0| image:: /applications/googleapps_logo.png
   :class: align-center
.. |image1| image:: /documentation/googleapps-menu.png
   :class: align-center
.. |image2| image:: /documentation/googleapps-sso.png
   :class: align-center
.. |image3| image:: /documentation/googleapps-ssoconfig.png
   :class: align-center

