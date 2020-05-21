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

Zimbra use a specific `preauthentication
protocol <http://wiki.zimbra.com/index.php?title=Preauth>`__ to provide
SSO on its application. This protocol is implemented in an LL::NG
specific Handler.


.. tip::

    Zimbra can also be connected to LL::NG via
    :doc:`SAML protocol<../idpsaml>` (see `Zimbra
    blog <http://blog.zimbra.com/blog/archives/2010/06/using-saml-assertions-to-access-zimbra.html>`__).

Configuration
-------------

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

