phpLDAPadmin
============

|image0|

Presentation
------------

`phpLDAPadmin <http://phpldapadmin.sourceforge.net>`__ is an LDAP
administration tool written in PHP.

phpLDAPadmin will connect to the directory with a static DN and
password, and so will not request authentication anymore. The access to
phpLDAPadmin will be protected by LemonLDAP::NG with specific access
rules.


.. danger::

    phpLDAPadmin will have no idea of the user connected to
    the WebSSO. So a simple user can have admin rights on the LDAP directory
    if your access rules are too lazy.

Configuration
-------------

phpLDAPadmin local configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just set the authentication type to ``config`` and indicate DN and
password inside the file ``config.php``:

.. code-block:: php

   $servers->SetValue('login','auth_type','config');
   $servers->SetValue('login','bind_id','cn=Manager,dc=example,dc=com');
   $servers->SetValue('login','bind_pass','secret');

phpLDAPadmin virtual host
~~~~~~~~~~~~~~~~~~~~~~~~~

Configure phpLDAPadmin virtual host like other
:doc:`protected virtual host<../configvhost>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName phpldapadmin.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name phpldapadmin.example.com;
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

phpLDAPadmin virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for phpLDAPadmin.

Just configure the :ref:`access rules<rules>`.

No :ref:`headers<headers>` are required.

.. |image0| image:: /applications/phpldapadmin_logo.png
   :class: align-center

