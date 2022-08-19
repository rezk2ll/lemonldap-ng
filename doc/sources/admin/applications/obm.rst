OBM
===

|image0|

Presentation
------------

`OBM <http://obm.org>`__ is enterprise-class messaging and collaboration
platform for workgroup or enterprises with many thousands users. OBM
includes Groupware, messaging server, CRM, LDAP, Windows Domain,
smartphone and PDA synchronization…

OBM is shipped with a LL::NG plugin with these features:

-  SSO on OBM web interface
-  Logout
-  User provisioning (account auto creation at first connection)

Configuration
-------------

.. _obm-1:

OBM
~~~

To enable LL::NG authentication plugin, go in ``/etc/obm/obm_conf.inc``:

.. code-block:: php

   $auth_kind = 'LemonLDAP';

   $lemonldap_config = Array(
                   "auto_update"           => true,
                   "auto_update_force_user" => true,
                   "auto_update_force_group" => false,
                   "url_logout"            => "https://OBMURL/logout",
                   "server_ip_address"     => "localhost",
                   "server_ip_check"       => false,
                   "debug_level"           => "NONE",
   //                "debug_header_name"     => "HTTP_OBM_UID",
   //                "group_header_name"     => "HTTP_OBM_GROUPS",
                   "headers_map"           => Array(
                           //"userobm_gid"                   => "HTTP_OBM_GID",
                           //"userobm_domain_id"           => ,
                           "userobm_login"                 => "HTTP_OBM_UID",
                           "userobm_password"              => "HTTP_OBM_USERPASSWORD",
                           //"userobm_password_type"       => ,
                           "userobm_perms"                 => "HTTP_OBM_PERMS",
                           //"userobm_kind"                => ,
                           "userobm_lastname"              => "HTTP_OBM_SN",
                           "userobm_firstname"             => "HTTP_OBM_GIVENNAME",
   //                        "userobm_title"                 => "HTTP_OBM_TITLE",
                           "userobm_email"                 => "HTTP_OBM_MAIL",
                           "userobm_datebegin"             => "HTTP_OBM_DATEBEGIN",
                           //"userobm_account_dateexp"     => ,
                           //"userobm_delegation_target"   => ,
                           //"userobm_delegation"          => ,
                           "userobm_description"           => "HTTP_OBM_DESCRIPTION",
                           //"userobm_archive"             => ,
                           //"userobm_hidden"              => ,
                           //"userobm_status"              => ,
                           //"userobm_local"               => ,
                           //"userobm_photo_id"            => ,
                           "userobm_phone"                 => "HTTP_OBM_TELEPHONENUMBER",
                           //"userobom_phone2"             => ,
                           //"userobm_mobile"              => ,
                           "userobm_fax"                   => "HTTP_OBM_FACSIMILETELEPHONENUMBER",
                           //"userobm_fax2"                => ,
                           "userobm_company"               => "HTTP_OBM_O",
                           //"userobm_direction"           => ,
                           "userobm_service"               => "HTTP_OBM_OU",
                           "userobm_address1"              => "HTTP_OBM_POSTALADDRESS",
                           //"userobm_address2"            => ,
                           //"userobm_address3"            => ,
                           "userobm_zipcode"               => "HTTP_OBM_POSTALCODE",
                           "userobm_town"                  => "HTTP_OBM_L",
                           "userobm_zipcode"               => "HTTP_OBM_POSTALCODE",
                           "userobm_town"                  => "HTTP_OBM_L",
                           //"userobm_expresspostal"       => ,
                           //"userobm_host_id"             => ,
                           //"userobm_web_perms"           => ,
                           //"userobm_web_list"            => ,
                           //"userobm_web_all"             => ,
                           //"userobm_mail_perms"          => ,
                           //"userobm_mail_ext_perms"      => ,
                           //"userobm_mail_server_id"      => ,
                           //"userobm_mail_server_hostname" => ,
                           "userobm_mail_quota"            => "HTTP_OBM_MAILQUOTA",
                           //"userobm_nomade_perms"        => ,
                           //"userobm_nomade_enable"       => ,
                           //"userobm_nomade_local_copy"   => ,
                           //"userobm_email_nomade"        => ,
                           //"userobm_vacation_enable"     => ,
                           //"userobm_vacation_datebegin"  => ,
                           //"userobm_vacation_dateend"    => ,
                           //"userobm_vacation_message"    => ,
                           //"userobm_samba_perms"         => ,
                           //"userobm_samba_home"          => ,
                           //"userobm_samba_home_drive"    => ,
                           //"userobm_samba_logon_script"  => ,
                           // ---- Unused values ? ----
                           "userobm_ext_id"                => "HTTP_OBM_SERIALNUMBER",
                           //"userobm_system"              => ,
                           //"userobm_nomade_datebegin"    => ,
                           //"userobm_nomade_dateend"      => ,
                           //"userobm_location"            => ,
                           //"userobm_education"           => ,
                           ),
           );

Parameters:

-  **url_logout**: URL used by OBM to logout, will be caught by LL::NG
-  **headers_map**: map OBM internal field to LL::NG header

Edit also OBM configuration to enable LL::NG Handler:

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
       ServerName obm.example.com

       # SSO protection
       PerlHeaderParserHandler Lemonldap::NG::Handler

       DocumentRoot /usr/share/obm/php

       ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name obm.example.com;
     root /usr/share/obm/php;
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
     location ~ \.php$ {
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

LL::NG
~~~~~~

Attributes and macros
^^^^^^^^^^^^^^^^^^^^^

You will need to collect all attributes needed to create a user in OBM,
this includes:

-  First name
-  Last name
-  Login
-  Mail
-  ...

To add these attributes, go in Manager, ``Variables`` »
``Exported Variables``.


.. attention::

    If you plan to forward user's password to OBM, then you
    have to :doc:`keep the password in session<../passwordstore>`.

You may also create these macros to manage OBM administrator account
(``Variables`` » ``Macros``):

===== ============================================================================
field value
===== ============================================================================
uidR  ``($uid =~ /^admin0/i)[0] ? "admin0\@global.virt" : $uid``
mailR ``($uid =~ /admin0/i)[0] ? "" : ($mail =~ / ([ @]+)/)[0] . "\@example.com"``
===== ============================================================================

Virtual host
^^^^^^^^^^^^

Create OBM virtual host (for example obm.example.com) in LL::NG
configuration: ``Virtual Hosts`` » ``New virtual host``.

Then edit rules and headers.

Rules
'''''

Define at least:

-  **Default rule**: who can access to the application
-  **Logout rule**: catch OBM logout
-  **Exceptions**: allow anonymous access for specific URLs (connectors,
   etc.)

============================= =============================
field                         value
============================= =============================
^/logout                      logout_sso
^/obm-sync                    unprotect
^/minig                       unprotect
^/Microsoft-Server-ActiveSync unprotect
^/caldav                      unprotect
default                       accept (or whatever you want)
============================= =============================

Headers
'''''''

Define headers used in OBM mapping, for example:

================ ==========
field            valeur
================ ==========
OBM_GIVENNAME    $givenName
OBM_GROUPS       $groups
OBM_UID          $uidR
OBM_MAIL         $mailR
OBM_USERPASSWORD $_password
================ ==========

Other
^^^^^

Do not forget to add OBM in :doc:`applications menu<../portalmenu>`.

.. |image0| image:: /applications/obm_logo.png
   :class: align-center

