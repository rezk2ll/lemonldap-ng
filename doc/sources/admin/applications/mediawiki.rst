MediaWiki
=========

|image0|

Presentation
------------

`MediaWiki <http://www.mediawiki.org>`__ is a wiki software, used by the
well known `Wikipedia <http://www.wikipedia.org>`__.

Several extensions allows one to configure SSO on MediaWiki:

-  `Automatic
   REMOTE_USER <http://www.mediawiki.org/wiki/Extension:AutomaticREMOTE_USER>`__
-  `Siteminder
   Authentication <http://www.mediawiki.org/wiki/Extension:Siteminder_Authentication>`__

We will explain how to use `Automatic
REMOTE_USER <http://www.mediawiki.org/wiki/Extension:AutomaticREMOTE_USER>`__
extension.

Installation
------------

The extension is presented here:
http://www.mediawiki.org/wiki/Extension:AutomaticREMOTE_USER

You can download the code here:
https://www.mediawiki.org/wiki/Special:ExtensionDistributor/Auth_remoteuser

You have to install '' Auth_remoteuser'' in the ``extensions/``
directory of your MediaWiki installation:

::

   cp -a Auth_remoteuser/ extensions/

Configuration
-------------

MediWiki local configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then edit MediaWiki local settings

::

   vi LocalSettings.php

.. code-block:: php

   require_once "$IP/extensions/Auth_remoteuser/Auth_remoteuser.php";
   $wgAuth = new Auth_remoteuser();

Add then extension configuration, for example:

.. code-block:: php

   $wgAuthRemoteuserAuthz = true; /* Your own authorization test */
   $wgAuthRemoteuserName = $_SERVER["HTTP_AUTH_CN"]; /* User's name */
   $wgAuthRemoteuserMail = $_SERVER["HTTP_AUTH_MAIL"]; /* User's Mail */
   $wgAuthRemoteuserNotify = false; /* Do not send mail notifications */
   //$wgAuthRemoteuserDomain = "NETBIOSDOMAIN"; /* Remove NETBIOSDOMAIN\ from the beginning or @NETBIOSDOMAIN at the end of a IWA username */
   /* User's mail domain to append to the user name to make their email address */
   //$wgAuthRemoteuserMailDomain = "example.com";

   // see http://www.mediawiki.org/wiki/Manual:Hooks/SpecialPage_initList
   // and http://www.mediawiki.org/w/Manual:Special_pages
   // and http://lists.wikimedia.org/pipermail/mediawiki-l/2009-June/031231.html
   // disable login and logout functions for all users
   function LessSpecialPages(&$list) {
       unset( $list['Userlogout'] );
       unset( $list['Userlogin'] );
       return true;
   }
   $wgHooks['SpecialPage_initList'][]='LessSpecialPages';

   // http://www.mediawiki.org/wiki/Extension:Windows_NTLM_LDAP_Auto_Auth
   // remove login and logout buttons for all users
   function StripLogin(&$personal_urls, &$wgTitle) {
       unset( $personal_urls["login"] );
       unset( $personal_urls["logout"] );
       unset( $personal_urls['anonlogin'] );
       return true;
   }
   $wgHooks['PersonalUrls'][] = 'StripLogin';


.. danger::

    In last version of Auth_remoteuser and Mediawiki, empty
    passwords are not authorized, so you may need to patch the extension
    code if you get the error: "Unexpected REMOTE_USER authentication
    failure. Login Error was:EmptyPass". If necessary, use the code
    below to patch the extension:

::

   sed -i "s/'wpPassword' => ''/'wpPassword' => 'none'/" extensions/Auth_remoteuser/Auth_remoteuser.body.php


.. danger::

    In last version of Auth_remoteuser and Mediawiki,
    auto-provisioning requires REMOTE_USER to match the normalized mediawiki
    username (for example: john_doe -> john doe), so you may need to patch
    the extension code if you get the error: "Unexpected REMOTE_USER
    authentication failure. Login Error was:WrongPluginPass" You can
    use the code below for normalizing logins containing "_" in the
    extension:

::

   sed -i '/$usertest = $this->getRemoteUsername();/a\                $usertest = str_replace( "_"," ", $usertest );' extensions/Auth_remoteuser/Auth_remoteuser.body.php

MediaWiki virtual host
~~~~~~~~~~~~~~~~~~~~~~

Configure MediaWiki virtual host like other
:doc:`protected virtual host<../configvhost>`.


.. attention::

    If you are protecting MediaWiki with LL::NG as reverse
    proxy,
    :doc:`convert header into REMOTE_USER environment variable<../header_remote_user_conversion>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName mediawiki.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name mediawiki.example.com;
     root /path/to/application;
     # Internal authentication request
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
       # Drop post data
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LL::NG server will receive /lmauth)
       fastcgi_param X_ORIGINAL_URI  $original_uri;
     }

     # Client requests
     location / {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;
       try_files $uri $uri/ =404;

       ...

       include /etc/lemonldap-ng/nginx-lua-headers.conf;
     }
     location / {
       try_files $uri $uri/ =404;
     }
   }

MediaWiki virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for MediaWiki.

Just configure the :ref:`access rules<rules>`. You
can also add a rule for logout:

::

   Userlogout => logout_sso

You can create these two headers to fill user name and mail (see
extension configuration):

::

   Auth-Cn => $cn
   Auth-Mail => $mail

If using LL::NG as reverse proxy, configure also the ``Auth-User``
:ref:`header<headers>`,

.. |image0| image:: /applications/mediawiki_logo.png
   :class: align-center

