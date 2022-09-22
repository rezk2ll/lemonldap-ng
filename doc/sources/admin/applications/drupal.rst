Drupal
======

|image0|

Presentation
------------

`Drupal <http://drupal.org>`__ is a CMS written in PHP. It can works
with external modules to extends its functionalities. One of this module
can be used to delegate authentication server to the web server:
`Webserver Auth <http://drupal.org/project/Webserver_auth>`__.

Installation
------------

Install `Webserver Auth <http://drupal.org/project/Webserver_auth>`__
module, by downloading it, and unarchive it in the drupal modules/
directory.

Configuration
-------------

Drupal module activation
~~~~~~~~~~~~~~~~~~~~~~~~

Go on Drupal administration interface and enable the Webserver Auth
module.

Drupal virtual host
~~~~~~~~~~~~~~~~~~~

Configure Drupal virtual host like other
:doc:`protected virtual host<../configvhost>`.


.. attention::

    If you are protecting Drupal with LL::NG as reverse
    proxy,
    :doc:`convert header into REMOTE_USER environment variable<../header_remote_user_conversion>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName drupal.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name drupal.example.com;
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

Drupal virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Drupal.

Just configure the :ref:`access rules<rules>`.

If using LL::NG as reverse proxy, configure the ``Auth-User``
:ref:`header<headers>`, else no headers are needed.

Protect only the administration pages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With the above solution, all the Drupal site will be protected, so no
anonymous access will be allowed.


.. attention::

    You cannot use the ``unprotect`` rule because Drupal
    navigation is based on query strings (?q=admin, ?q=user, etc.), and
    unprotect rule only works on URL patterns.

You can create a special virtual host and use `Apache rewrite
module <http://httpd.apache.org/docs/current/mod/mod_rewrite.html>`__ to
switch between open and protected hosts:

.. code-block:: apache

   <VirtualHost *:80>
       ServerName drupal.example.com

       # DocumentRoot
       DocumentRoot /var/www/html/drupal/
       DirectoryIndex index.php

       # Redirect admin pages
       RewriteEngine On
       RewriteCond  %{QUERY_STRING} q=(admin|user)
       RewriteRule ^/(.*)$ http://admindrupal.example.com/$1 [R]

       LogLevel warn
       ErrorLog /var/log/httpd/drupal-error.log
       CustomLog /var/log/httpd/drupal-access.log combined
   </VirtualHost>
   <VirtualHost *:80>
       ServerName admindrupal.example.com

       # SSO protection
       PerlHeaderParserHandler Lemonldap::NG::Handler

       # DocumentRoot
       DocumentRoot /var/www/html/drupal/
       DirectoryIndex index.php

       LogLevel warn
       ErrorLog /var/log/httpd/admindrupal-error.log
       CustomLog /var/log/httpd/admindrupal-access.log combined
   </VirtualHost>

.. |image0| image:: /applications/drupal_logo.png
   :class: align-center

