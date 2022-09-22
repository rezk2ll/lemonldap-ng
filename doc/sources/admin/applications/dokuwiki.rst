Dokuwiki
========

|image0|

Presentation
------------

`DokuWiki <http://www.dokuwiki.org/>`__ is a standards compliant, simple
to use Wiki, mainly aimed at creating documentation of any kind. It is
targeted at developer teams, workgroups and small companies. It has a
simple but powerful syntax which makes sure the data files remain
readable outside the Wiki and eases the creation of structured texts.
All data is stored in plain text files – no database is required.


HTTP headers
------------

You need to install a Dokuwiki plugin, available on `Dokuwiki plugins
registry <https://www.dokuwiki.org/plugins>`__:
https://www.dokuwiki.org/plugin:authlemonldap

Plugin installation
~~~~~~~~~~~~~~~~~~~

Install the plugin using the `Plugin
Manager <https://www.dokuwiki.org/plugin:plugin>`__.

Dokuwiki configuration
~~~~~~~~~~~~~~~~~~~~~~

As administrator, go in Dokuwiki parameters and set:

-  Authentication backend: authlemonldap
-  Manager: set which users and/or groups will be admin

|image1|

Dokuwiki virtual host
~~~~~~~~~~~~~~~~~~~~~

Configure Dokuwiki virtual host like other
:doc:`protected virtual host<../configvhost>`.

-  For Apache:

.. code-block:: apache

   <VirtualHost *:80>
          ServerName dokuwiki.example.com

          PerlHeaderParserHandler Lemonldap::NG::Handler

          ...

   </VirtualHost>

-  For Nginx:

.. code-block:: nginx

   server {
     listen 80;
     server_name dokuwiki.example.com;
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

Dokuwiki virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Dokuwiki.

Configure the :ref:`access rules<rules>`.

Configure the :ref:`headers<headers>`:

-  Auth-User $uid
-  Auth-Cn: $cn
-  Auth-Mail: $mail
-  Auth-Groups: encode_base64($groups,"")


.. attention::

    To allow execution of encode_base64() method, you must
    deactivate the :doc:`Safe jail<../safejail>`.

.. |image0| image:: /applications/dokuwiki_logo.png
   :class: align-center
.. |image1| image:: /applications/screenshot_dokuwiki_configuration.png
   :class: align-center

