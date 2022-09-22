Bugzilla
========

|image0|

Presentation
------------

`Bugzilla <http://www.bugzilla.org>`__ is server software designed to
help you manage software development.

Bugzilla can authenticate a user with HTTP headers, and auto-create its
account with a few information:

-  User ID
-  Email
-  Real name

Configuration
-------------

Bugzilla administration
~~~~~~~~~~~~~~~~~~~~~~~

In Bugzilla administration interface, go in ``Parameters`` »
``User authentication``

Then set:

-  **auth_env_id**: HTTP_AUTH_USER
-  **auth_env_email**: HTTP_AUTH_MAIL
-  **auth_env_realname**: HTTP_AUTH_CN
-  **user_info_class**: Env or Env,CGI

Bugzilla virtual host
~~~~~~~~~~~~~~~~~~~~~

Configure Bugzilla virtual host like other
:doc:`protected virtual host<../configvhost>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName bugzilla.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name bugzilla.example.com;
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

Bugzilla virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Bugzilla.

Configure the :ref:`rules<rules>`.

Configure the following :ref:`header<headers>`.

-  **Auth-User**: $uid
-  **Auth-Mail**: $mail
-  **Auth-Cn**: $cn

.. |image0| image:: /applications/bugzilla_logo.png
   :class: align-center

