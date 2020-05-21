Convert HTTP header into environment variable
=============================================

Apache
------

Using LL::NG in reverse proxy mode, you will not have the
``REMOTE_USER`` environment variable set. Indeed, this variable is set
by the Handler on the physical server hosting the Handler, and not on
other servers where the Handler is not installed.

Apache `SetEnvIf
module <http://httpd.apache.org/docs/current/mod/mod_setenvif.html>`__
will let you transform the Auth-User HTTP header in ``REMOTE_USER``
environment variable:

.. code-block:: apache

   SetEnvIfNoCase Auth-User "(.*)" REMOTE_USER=$1

This can be used to protect applications relying on ``REMOTE_USER``
environment variable in reverse proxy mode. In this case you will have
two Apache configuration files:

-  Apache configuration file on LL::NG reverse proxy (hosting LL::NG
   Handler):

.. code-block:: apache

   <VirtualHost *:80>
           ServerName application.example.com

           PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

           ProxyPreserveHost on
           ProxyPass / http://APPLICATION_IP/
           ProxyPassReverse / http://APPLICATION_IP/

   </VirtualHost>

-  Apache configuration file on application server (hosting the
   application):

.. code-block:: apache

   <VirtualHost *:80>
           ServerName application.example.com

           SetEnvIfNoCase Auth-User "(.*)" REMOTE_USER=$1

           DocumentRoot /var/www/application

   </VirtualHost>


.. tip::

    Sometimes, PHP applications also check the PHP_AUTH_USER and
    PHP_AUHT_PW environment variables. You can set them the same way:

    .. code:: apache

       SetEnvIfNoCase Auth-User "(.*)" PHP_AUTH_USER=$1
       SetEnvIfNoCase Auth-Password "(.*)" PHP_AUTH_PW=$1

    Of course, you need to :doc:`store password in session<passwordstore>`
    to fill PHP_AUTH_PW.

Nginx
-----

Nginx doesn't launch directly PHP pages (or other languages): it dials
with FastCGI servers (like php-fpm). As you can see in examples, it's
easy to map a LLNG header to a fastcgi param. Example:

.. code-block:: nginx

   auth_request_set $authuser $upstream_http_auth_user;
   fastcgi_param HTTP_MYVAR $authuser;

