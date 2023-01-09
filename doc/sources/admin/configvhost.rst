Manage virtual hosts
====================

LemonLDAP::NG configuration is built around Apache or Nginx virtual
hosts. Each virtual host is a protected resource, with access rules,
headers, POST data and options.

Apache configuration
--------------------

To protect a virtual host in Apache, the LemonLDAP::NG Handler must be
activated (see
:ref:`Apache global configuration<configlocation-apache>`).

Then you can take any virtual host, and just add this line to protect it:

.. code-block:: apache

   PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

Hosted application
~~~~~~~~~~~~~~~~~~

Example of a protected virtual host for a local application:

.. code-block:: apache

   <VirtualHost *:80>
           ServerName localsite.example.com

           PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

           DocumentRoot /var/www/localsite

           ErrorLog /var/log/apache2/localsite_error.log
           CustomLog /var/log/apache2/localsite_access.log combined

   </VirtualHost>

Reverse-Proxy
~~~~~~~~~~~~~

Example of a protected virtual host with LemonLDAP::NG as reverse proxy:

.. code-block:: apache

   <VirtualHost *:80>
           ServerName application.example.com

           PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

           # Reverse-Proxy
           ProxyPass / http://private-name/
           # Change "Location" header in redirections
           ProxyPassReverse / http://private-name/
           # Change domain cookies
           ProxyPassReverseCookieDomain private-name application.example.com

           ErrorLog /var/log/apache2/proxysite_error.log
           CustomLog /var/log/apache2/proxysite_access.log combined
   </VirtualHost>

Same with remote server configured with the same host name:

.. code-block:: apache

   <VirtualHost *:80>
           ServerName application.example.com

           PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2

           # Reverse-Proxy
           ProxyPass / http://APPLICATION_IP/

           ProxyPreserveHost on

           ErrorLog /var/log/apache2/proxysite_error.log
           CustomLog /var/log/apache2/proxysite_access.log combined
   </VirtualHost>


.. note::

    The ``ProxyPreserveHost`` directive will forward the Host header
    to the protected application. To learn more about using Apache as
    reverse-proxy, see `Apache
    documentation <http://httpd.apache.org/docs/current/mod/mod_proxy.html>`__.



.. tip::

    Some applications need the ``REMOTE_USER`` environment
    variable to get the connected user, which is not set in reverse-proxy
    mode. In this case, see
    :doc:`how convert header into environment variable<header_remote_user_conversion>`.

Add a floating menu
~~~~~~~~~~~~~~~~~~~

A small floating menu can be added to application with this simple Apache configuration:

.. code-block:: apache

   PerlModule Lemonldap::NG::Handler::ApacheMP2::Menu
   PerlOutputFilterHandler Lemonldap::NG::Handler::ApacheMP2::Menu->run

Pages where this menu is displayed can be restricted, for example:

.. code-block:: apache

   <Location /var/www/html/index.php>
   PerlOutputFilterHandler Lemonldap::NG::Handler::ApacheMP2::Menu->run
   </Location>


.. attention::

    You need to disable mod_deflate to use the floating
    menu

Nginx configuration
-------------------

To protect a virtual host in Nginx, the LemonLDAP::NG FastCGI server
must be launched (see
:doc:`LemonLDAP::NG FastCGI server<fastcgiserver>`).

Then you can take any virtual host and modify it:

-  Declare the /lmauth endpoint

.. code-block:: nginx

     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;

       # Drop post data
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";

       # Keep original hostname
       fastcgi_param HOST $http_host;

       # Keep original request (LLNG server will receive /lmauth)
       fastcgi_param X_ORIGINAL_URI $original_uri;
     }

-  Protect the application (/ or /path/to/protect):

.. code-block:: nginx

     location /path/to/protect {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       auth_request_set $cookie_value $upstream_http_set_cookie;
       add_header Set-Cookie $cookie_value;
       error_page 401 $lmlocation;
       try_files $uri $uri/ =404;

       # ...
     }

-  Use LUA or set manually the headers:

.. code-block:: nginx

     location /path/to/protect {

       # ...

       # IF LUA IS SUPPORTED
       #include /etc/lemonldap-ng/nginx-lua-headers.conf;

       # ELSE
       # Set manually your headers
       #auth_request_set $authuser $upstream_http_auth_user;
       #proxy_set_header Auth-User $authuser;
       # OR
       #fastcgi_param HTTP_AUTH_USER $authuser;

       # Then (if LUA not supported), change cookie header to hide LLNG cookie
       #auth_request_set $lmcookie $upstream_http_cookie;
       #proxy_set_header Cookie: $lmcookie;
       # OR in the corresponding block
       #fastcgi_param HTTP_COOKIE $lmcookie;

       # Set REMOTE_USER (for FastCGI apps only)
       #fastcgi_param REMOTE_USER $lmremote_user;
     }

.. _hosted-application-1:

Hosted application
~~~~~~~~~~~~~~~~~~

Example of a protected virtual host for a local application:

.. code-block:: nginx

   # Log format
   include /path/to/lemonldap-ng/nginx-lmlog.conf;
   server {
     listen 80;
     server_name myserver;
     root /var/www/html;
     # Internal authentication request
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass /path/to/llng-fastcgi-server.sock;
       # Drop post data
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LLNG server will receive /lmauth)
       fastcgi_param X_ORIGINAL_URI $original_uri;
     }

     # Client requests
     location ~ \.php$ {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;
       try_files $uri $uri/ =404;
       include fastcgi_params;
       try_files $fastcgi_script_name =404;
       fastcgi_pass /path/to/php-fpm/socket;
       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
       fastcgi_intercept_errors on;
       fastcgi_split_path_info ^(.+\.php)(/.+)$;
       fastcgi_hide_header X-Powered-By;

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################
       # IF LUA IS SUPPORTED
       #include /path/to/nginx-lua-headers.conf

       # ELSE
       # Set manually your headers
       #auth_request_set $authuser $upstream_http_auth_user;
       #fastcgi_param HTTP_AUTH_USER $authuser;
     }
     location / {
       try_files $uri $uri/ =404;
     }
   }

.. _reverse-proxy-1:

Reverse-Proxy
~~~~~~~~~~~~~

- Example of a protected reverse-proxy:

.. code-block:: nginx

   # Log format
   include /path/to/lemonldap-ng/nginx-lmlog.conf;
   server {
     listen 80;
     server_name myserver;
     root /var/www/html;
     # Internal authentication request
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass /path/to/llng-fastcgi-server.sock;
       # Drop post data
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LLNG server will receive /lmauth)
       fastcgi_param X_ORIGINAL_URI  $original_uri;
     }

     # Client requests
     location / {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;

       proxy_pass http://remote.server/;
       include /etc/nginx/proxy_params;

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################
       # IF LUA IS SUPPORTED
       #include /path/to/nginx-lua-headers.conf;

       # ELSE
       # Set manually your headers
       #auth_request_set $authuser $upstream_http_auth_user;
       #proxy_set_header HTTP_AUTH_USER $authuser;
     }
   }

If /etc/nginx/proxy_params file does not exist, you can create it with this content:

.. code-block:: nginx

    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

- Example of a Nginx Virtual Host using uWSGI with many URIs protected by different types of handler:

.. code-block:: nginx

   # Log format
   include /path/to/lemonldap-ng/nginx-lmlog.conf;
   server {
     listen 80;
     server_name myserver;
     root /var/www/html;

    # Internal MAIN handler authentication request
     location = /lmauth {
       internal;
       # uWSGI Configuration
       include /etc/nginx/uwsgi_params;
       uwsgi_pass 127.0.0.1:5000;
       uwsgi_pass_request_body  off;
       uwsgi_param CONTENT_LENGTH "";
       uwsgi_param HOST $http_host;
       uwsgi_param X_ORIGINAL_URI  $original_uri;
       # Improve performances
       uwsgi_buffer_size 32k;
       uwsgi_buffers 32 32k;
     }

     # Internal AUTH_BASIC handler authentication request
     location = /lmauth-basic {
       internal;
       # uWSGI Configuration
       include /etc/nginx/uwsgi_params;
       uwsgi_pass 127.0.0.1:5000;
       uwsgi_pass_request_body  off;
       uwsgi_param CONTENT_LENGTH "";
       uwsgi_param HOST $http_host;
       uwsgi_param X_ORIGINAL_URI  $original_uri;
       uwsgi_param VHOSTTYPE AuthBasic;
       # Improve performances
       uwsgi_buffer_size 32k;
       uwsgi_buffers 32 32k;
     }

     # Internal SERVICE_TOKEN handler authentication request
     location = /lmauth-service {
       internal;
       # uWSGI Configuration
       include /etc/nginx/uwsgi_params;
       uwsgi_pass 127.0.0.1:5000;
       uwsgi_pass_request_body  off;
       uwsgi_param CONTENT_LENGTH "";
       uwsgi_param HOST $http_host;
       uwsgi_param X_ORIGINAL_URI  $original_uri;
       uwsgi_param VHOSTTYPE ServiceToken;
       # Improve performances
       uwsgi_buffer_size 32k;
       uwsgi_buffers 32 32k;
     }

     # Client requests
     location / {
       ##################################
       # CALLING AUTHENTICATION         #
       ##################################
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmremote_custom $upstream_http_lm_remote_custom;
       auth_request_set $lmlocation $upstream_http_location;
       # Remove this for AuthBasic handler
       error_page 401 $lmlocation;

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################
       # IF LUA IS SUPPORTED
       include /etc/nginx/nginx-lua-headers.conf;
     }

     location /AuthBasic/ {
       ##################################
       # CALLING AUTHENTICATION         #
       ##################################
       auth_request /lmauth-basic;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmremote_custom $upstream_http_lm_remote_custom;
       auth_request_set $lmlocation $upstream_http_location;
       # Remove this for AuthBasic handler
       #error_page 401 $lmlocation;

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################
       # IF LUA IS SUPPORTED
       include /etc/nginx/nginx-lua-headers.conf;
     }

     location /web-service/ {
       ##################################
       # CALLING AUTHENTICATION         #
       ##################################
       auth_request /lmauth-service;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       # Remove this for AuthBasic handler
       error_page 401 $lmlocation;

       ##################################
       # PASSING HEADERS TO APPLICATION #
       ##################################
       # IF LUA IS SUPPORTED
       include /etc/nginx/nginx-lua-headers.conf;
     }
   }

.. _configvhost-lemonldapng-configuration:

LemonLDAP::NG configuration
---------------------------

A virtual host protected by LemonLDAP::NG Handler must be registered in
LemonLDAP::NG configuration.

To do this, use the Manager, and go in ``Virtual Hosts`` branch. You can
add, delete or modify a virtual host here. Enter the exact virtual host
name (for example ``test.example.com``) or use a wildcard (for example
``*.example.com``).

A virtual host contains:

-  Access rules: check user's right on URL patterns
-  HTTP headers: forge information sent to protected applications
-  POST data: use form replay
-  Options: redirection port, protocol, Handler type, aliases,required authentication level,...

Wildcards in hostnames
----------------------

A wildcard can be used in virtualhost name (not in aliases !):
``*.example.com`` matches all hostnames that belong to ``example.com`` domain.

.. versionchanged:: 2.0.9
   You can now use wildcards of the form ``test-*.example.com`` or
   ``test-%.example.com``. The ``%`` wilcard doesn't match subdomains.

Even if a wildcard exists, if a VirtualHost is explicitly declared, this
rule will be applied. Example with precedence order for test.sub.example.com:

#. test.sub.example.com
#. test%.sub.example.com
#. test*.sub.example.com
#. %.sub.example.com
#. \*.sub.example.com
#. \*.example.com (``%.example.com`` does not match
   test.sub.example.com)

Access rules and HTTP headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`Writing rules and headers<writingrulesand_headers>` to
learn how to configure access control and HTTP headers sent to
application by LL::NG.


.. attention::

    With **Nginx**-based Reverse-Proxy, header directives can
    be appended by a LUA script.

    To send more than **15** headers to protected applications,
    you have to edit and modify :

    ``/etc/nginx/nginx-lua-headers.conf``


.. danger::

    \* **Nginx** gets rid of any empty headers. There is no
    point of passing along empty values to another server; it would only
    serve to bloat the request. In other words, headers with **empty values
    are completely removed** from the passed request.

    \* **Nginx**, by default, will consider any header that **contains
    underscores as invalid**. It will remove these from the proxied request.
    If you wish to have Nginx interpret these as valid, you can set the
    ``underscores_in_headers`` directive to “on”, otherwise your headers
    will never make it to the backend server.

POST data
~~~~~~~~~

See :doc:`Form replay<formreplay>` to learn how to configure form
replay to POST data on protected applications.

Options
~~~~~~~

Some options are available:

-  **Port**: used to build redirection URL *(when user is not logged, or for
   CDA requests)*, -1 means the handler builds the URL with the incoming port, as seen by the webserver
-  **HTTPS**: used to build redirection URL
-  **Maintenance mode**: reject all requests with a maintenance message
-  **Aliases**: list of aliases for this virtual host *(avoid to rewrite
   rules,...)*
-  **Access to trace**: can be used for overwriting REMOTE_CUSTOM with a custom function.
   Provide a comma separated parameters list with custom function path and args.
   Args can be vars or session attributes, macros, ...
   By example: My::accessToTrace, Doctor, Who, _whatToTrace
-  **Required authentication level**: this option avoids to reject user with
   a rule based on ``$authenticationLevel``. When user has not got the
   required level, he is redirected to an upgrade page in the portal.
   This default level is required for ALL locations relative to this virtual host.
   It can be overrided for each locations.
-  **Type**: handler type (:ref:`Main<presentation-kinematics>`,
   :doc:`AuthBasic<authbasichandler>`,
   :doc:`ServiceToken<servertoserver>`,
   :doc:`DevOps<devopshandler>`,
   :doc:`DevOpsST<devopssthandler>`,
   :doc:`OAuth2<oauth2handler>`,...)
-  **DevOps rules file URL**: option to define URL to retreive DevOps rules file.
   This option can be overridden with ``uwsgi_param/fastcgi_param RULES_URL`` parameter.
-  **ServiceToken timeout**: by default, ServiceToken is just valid during 30
   seconds. This TTL can be customized for each virtual host.
-  **Comment**: can be used for setting comment.


.. attention::

    A hash reference containing $req, $session, $vhost, $custom and an array reference
    with provided parameters is passed to the custom function.

    ::

      package My;

      sub accessToTrace {
          my $hash    = shift;
          my $custom  = $hash->{custom};
          my $req     = $hash->{req};
          my $vhost   = $hash->{vhost};
          my $custom  = $hash->{custom};
          my $params  = $hash->{params};
          my $session = $hash->{session};

          return "$custom alias $params->[0]_$params->[1]:$session->{groups}:$session->{$params->[2]}";
      }

      1;


.. danger::

    A same virtual host can serve many locations. Each
    location can be protected by a different type of handler :

    ::

       server test1.example.com 80
         location ^/AuthBasic  => AuthBasic handler
         location ^/AuthCookie => Main handler

    Keep in mind that AuthBasic handler use "Login/Password" to authenticate
    users. If you set "Authentication level required" option to "5" by
    example, AuthBasic requests will be ALWAYS rejected because AuthBasic
    authentication level is lower than required level.


.. attention::

    A negative or null ServiceToken timeout value will be
    overloaded by ``handlerServiceTokenTTL`` (30 seconds by default).


"Port" and "HTTPS" options are used to build redirection URL *(when user
is not logged, or for CDA requests)*. By default, default values are
used. These options are for overriding default values.

.. |image0| image:: /documentation/new.png
   :width: 35px
