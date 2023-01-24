Zimbra
======

|image0|

Presentation
------------

`Zimbra <http://www.zimbra.com/>`__ is open source server software for
email and collaboration - email, group calendar, contacts, instant
messaging, file storage and web document management. The Zimbra email
and calendar server is available for Linux, Mac OS X and virtualization
platforms. Zimbra syncs to smartphones (iPhone, BlackBerry) and desktop
clients like Outlook and Thunderbird. Zimbra also features archiving and
discovery for compliance. Zimbra can be deployed on-premises or as a
hosted email solution.

Zimbra can be connected with `SAML protocol <../idpsaml>`__ which is the
recommended way, but this requires Zimbra Network Edition.

Zimbra can also use a specific `preauthentication
protocol <http://wiki.zimbra.com/index.php?title=Preauth>`__ to provide
SSO on its application. This protocol is implemented in an LL::NG
specific Handler and is available in Zimbra Open Source Edition.

SAML
----

On LemonLDAP::NG side
~~~~~~~~~~~~~~~~~~~~~

Create a new SAML SP and use this metadata content:

.. code-block:: xml

    <?xml version="1.0"?>
        <md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            validUntil="2020-02-28T09:33:56Z"
            cacheDuration="PT604800S"
            entityID="https://zimbrasaml.example.com/service/extension/samlreceiver">
        <md:SPSSODescriptor AuthnRequestsSigned="true" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://zimbrasaml.example.com/service/extension/samlreceiver"
            index="1" />
        </md:SPSSODescriptor>
    </md:EntityDescriptor>

Replace ``zimbrasaml.example.com`` by your ZimbraPublicHostname.

Enable IDP SSO Initiated option.

Create ``Email`` exported attribute, which must return the user email.

Export the SAML signature certificate in a file, for example ``lemonsaml.cert`` that must be copied on Zimbra server.

On Zimbra side
~~~~~~~~~~~~~~

Copy the SAML plugin (available only with Zimbra NE):

.. code-block:: console

   mkdir /opt/zimbra/lib/ext/saml
   cp /opt/zimbra/extensions-network-extra/saml/samlextn.jar /opt/zimbra/lib/ext/saml/samlextn.jar

Import certificate:

.. code-block:: console

   su - zimbra
   cat /tmp/lemonsaml.crt |xargs -0 zmprov md exampledomain.com zimbraMyoneloginSamlSigningCert

Configure SAML properties:

.. code-block:: console

   zmprov mcf zimbraCsrfRefererCheckEnabled FALSE
   zmprov md exampledomain.com zimbraWebClientLoginURL "https://auth.example.com/saml/singleSignOn?IDPInitiated=1&sp=https://zimbrasaml.example.com/service/extension/samlreceiver"
   zmprov md exampledomain.com zimbraWebClientLogoutURL "https://auth.example.com/saml/singleLogout"
   zmmailboxdctl restar

To check for errors:

.. code-block:: console

   tail -f /opt/zimbra/log/zmmailboxd.ou

Zimbra PreAuth Handler
----------------------

.. note::

    This method is no more recommended.

The integration with LL::NG is the following:

-  A special URL is declared in application menu (like
   http://zimbra.example.com/zimbrasso)
-  A Zimbra Handler is called
-  Handler build the preauth request and redirect user on Zimbra preauth
   URL
-  Then Zimbra do the SSO by setting a cookie in user's browser

Zimbra preauth key
~~~~~~~~~~~~~~~~~~

You need to get a preauth key from Zimbra server.

See `how to do
this <http://wiki.zimbra.com/index.php?title=Preauth#Preparing_a_domain_for_preauth>`__
on Zimbra wiki.

Zimbra application in menu
~~~~~~~~~~~~~~~~~~~~~~~~~~

Choose for example http://zimbra.example.com/zimbrasso as SSO URL and
:doc:`set it in application menu<../portalmenu>`.

Zimbra virtual host
~~~~~~~~~~~~~~~~~~~

You just have to set "Type: ZimbraPreAuth" in virtualhost options and
reload configuration in this handler.

Zimbra Handler parameters
~~~~~~~~~~~~~~~~~~~~~~~~~

Zimbra parameters are the following:

-  **Preauthentication key**: the one you grab from zmprov command
-  **Account session key**: session field used as Zimbra user account
   (by default: uid)
-  **Account type**: for Zimbra this can be name, id or foreignKey (by
   default: id)
-  **Preauthentication URL**: Zimbra preauthentication URL, either with
   full URL (ex: http://zimbra.lan/service/preauth), either only with
   path (ex: /service/preauth) (by default: /service/preauth)
-  **Local SSO URL pattern**: regular expression to match the SSO URL
   (by default: ^/zimbrasso$)


.. attention::

    Due to Handler API change in 1.9, you need to set these
    attributes in ``lemonldap-ng.ini`` and not in Manager, for example:

    .. code:: ini

       [handler]
       zimbraPreAuthKey = XXXX
       zimbraAccountKey = uid
       zimbraBy =id
       zimbraUrl = /service/preauth
       zimbraSsoUrl = ^/zimbrasso$



Multi-domain issues
~~~~~~~~~~~~~~~~~~~

Some organizations have multiple zimbra domains:

#. foo@domain1.com
#. bar@domain2.com

However, the zimbra preauth key is:

-  generated for one zimbra domain only
-  declared globally for every LemonLDAP::NG virtual hosts.

Thus, if domain1 has been registered on LemonLDAP::NG, user bar won't be
able to connect to zimbra because preauth key is different. If you
accept to have the same preauth key for all zimbra domains, you can set
the same preauth key using this procedure:

We are going to use the first key (the domain1 one) for every domain. On
Zimbra machine, generate the keys:

::

    zmprov generateDomainPreAuthKey domain1.com
    preAuthKey: 4e2816f16c44fab20ecdee39fb850c3b0bb54d03f1d8e073aaea376a4f407f0c

    zmprov generateDomainPreAuthKey domain2.com
    preAuthKey: 6b7ead4bd425836e8cf0079cd6c1a05acc127acd07c8ee4b61023e19250e929c

Then, connect to your zimbra LDAP server with your favourite tool
(Apache Directory Studio can do the job). Take care to connect with the
super admin and password account.

-  Expand the branch "dc=com", then click the "dc=domain1" branch
-  Get the value of zimbraPreAuthKey
-  Expand the branch "dc=com", then click the "dc=domain2" branch
-  Replace the value of zimbraPreAuthKey you have previously copied
-  Wait for all Zimbra servers to update, or restart the zcs server

That's it, all zimbra servers will be able to decipher the hmac because
they share the same key!

.. |image0| image:: /applications/zimbra_logo.png
   :class: align-center

