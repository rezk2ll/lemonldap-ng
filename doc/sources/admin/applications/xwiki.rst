X-Wiki
======

|image0|

Presentation
------------

XWiki is a free wiki software platform written in Java with a design
emphasis on extensibility. XWiki is an enterprise wiki. It includes
WYSIWYG editing, OpenDocument based document import/export, semantic
annotations and tagging, and advanced permissions management.

Configuration
-------------

The integration with LL::NG is the following:

-  LemonLDAP::NG is configured as a reverse-proxy for xwiki
-  Xwiki is configured to accept HTTP Headers

Xwiki virtual host
~~~~~~~~~~~~~~~~~~

Apache
^^^^^^

You will configure Xwiki virtual host like other
:doc:`protected virtual host<../configvhost>`.

This is an example, with https and speaking to xwiki via AJP.

.. code-block:: apache

   <VirtualHost *:80>
       ServerName wiki.acme.fr
       Redirect / https://wiki.acme.fr/
   </VirtualHost>

   <VirtualHost *:443>
       ServerName wiki.acme.fr

       SSLEngine On
       SSLCertificateFile /etc/pki/tls/certs/wildcard.acme.fr.crt
       SSLCertificateKeyFile /etc/pki/tls/certs/wildcard.acme.fr.key
       SSLCertificateChainFile /etc/pki/tls/certs/CLASS_2_ACME_CA.crt
       SSLOptions +StdEnvVars
       SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
       SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
       SSLHonorCipherOrder     on
       SSLCompression          off

       PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

       RewriteEngine on
       RewriteRule ^/$ /xwiki/ [R]

       ProxyPreserveHost On
       ProxyRequests On

       ProxyPass / ajp://192.168.11.130:8009/
       ProxyPassReverse / ajp://192.168.11.130:8009/

       ErrorLog /var/log/httpd/wiki_error.log
       CustomLog /var/log/httpd/wiki_access.log combined
   </VirtualHost>

Xwiki virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Xwiki.

Configure the :ref:`access rules<rules>`.

Configure the :ref:`headers<headers>`:

-  remote_user: ``$uid``
-  remote_groups: ``join('|', keys(%{$hGroups}))``
-  secret: ``choose_a_secret_key``

Xwiki Configuration
~~~~~~~~~~~~~~~~~~~

First, you need to install the `Headers Trusted Authentication Adapter <https://extensions.xwiki.org/xwiki/bin/view/Extension/Trusted%20Headers%20Authentication%20Adapter>`__

Then, configure in `xwiki.cfg`

::


   xwiki.authentication.authclass=org.xwiki.contrib.authentication.XWikiTrustedAuthenticator
   xwiki.authentication.trusted.adapterHint=headers
   xwiki.authentication.trusted.auth_field=remote_user
   xwiki.authentication.trusted.group_field=remote_groups
   xwiki.authentication.trusted.logout_url=https://auth.example.com/?logout=1
   xwiki.authentication.trusted.secret_field=secret
   xwiki.authentication.trusted.secret_value=choose_a_secret_key

   # Adjust the XWiki=>LemonLDAP group map to your liking
   xwiki.authentication.trusted.groupsMapping=XWiki.XWikiAdminGroup=xwiki-admins|XWiki.XWikiAdminGroup=timelords

.. |image0| image:: /applications/xwiki.png
   :class: align-center

