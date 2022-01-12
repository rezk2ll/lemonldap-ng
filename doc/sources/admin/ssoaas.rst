SSO as a service (SSOaaS)
=========================

Our concept of SSOaaS
---------------------

Access management provides 3 services:

-  Global Authentication: Single Sign-On
-  Authorization: to grant authentication is not enough. User rights
   must be checked
-  Accounting: SSO logs (access) + application logs *(transactions and
   results)*

LL::NG affords all these services (except application logs of course,
but headers are provided to permit this).

Headers setting is an another LL::NG service. LL::NG can provide any
user attributes to an application (see
:doc:`Rules and headers<writingrulesand_headers>`)

``*aaS`` means that application can drive underlying layer (IaaS for
infrastructure, PaaS for platform,…). So for us, ``SSOaaS`` must provide
the ability for an app to manage authorizations and choose user
attributes to set. Authentication can not be really ``*aaS``: app must
just use it, not manage it.

LL::NG affords some features that can be used to provide SSO as a
service: a web application can manage its rules and headers. Docker or
VM images (Nginx only) includes LL::NG Nginx configuration that aims to
a global
:ref:`LL::NG authorization server<platformsoverview-external-servers-for-nginx>`.
By default, all authenticated users can access and one header is set:
``Auth-User``. If application gives a RULES_URL parameter that refers to
a JSON file, authorization server will read it, apply specified rules
and set required headers (see :doc:`DevOps Handler<devopshandler>`).

There are two different architectures to do this:

-  Using a :doc:`global FastCGI (or uWSGI) server<psgi>`
-  Using front reverse-proxies *(some cloud installations use
   reverse-proxies in front-end)*


.. note::

    Some requests can be droped by the fastCGI/uWSGI server.
    Example below with uWSGI server to avoid Load Balancer health check requests:

    ```route-remote-addr = ^127\.0\.0\.25[34]$ break: 403 Forbidden for IP ${REMOTE_ADDR}```

Example of a global FastCGI architecture:

|image0|

In both case, Handler type must be set to :doc:`DevOps<devopshandler>`.

Examples of webserver configuration for Docker/VM images
--------------------------------------------------------

Using a global FastCGI (or uWSGI) server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nginx
^^^^^

Examples below are web server templates (Nginx only) configured to
request authorization from a central FastCGI server.
With an uWSGI central server, use 'uwsgi_param' directive (Nginx only):

.. code::

   server {
     listen <port>;
     server_name myapp.domain.com;
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       # Pass authorization requests to Central FastCGI server:
       fastcgi_pass 10.1.2.3:9090;
       fastcgi_param VHOSTTYPE DevOps;
       # Drop post datas
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LLNG server will received /lmauth)
       fastcgi_param X_ORIGINAL_URI  $original_uri;

       # Set redirection params
       fastcgi_param HTTPS_REDIRECT "$https";
       fastcgi_param PORT_REDIRECT $server_port;

       # Set dynamically rules (LL::NG will poll it every 10 mn)
       fastcgi_param RULES_URL http://rulesserver/my.json;
     }
     location /rules.json {
       auth_request off;
       allow 10.1.2.3;
       deny all;
     }
     location ~ ^(.*\.php)$ {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;
       include /etc/nginx/nginx-lua-headers.conf;
       # ...
       # Example with php-fpm:
       include snippets/fastcgi-php.conf;
       fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
     }
     location / {
       try_files $uri $uri/ =404;
     }
   }

Apache
^^^^^^

There is an experimental FastCGI client in LL::NG. You just have to
install LemonLDAP::NG handler and FCGI::Client. Then, add this in
your apache2.conf, web applications or proxies.

The following configuration example assumes that you are in a "central
FastCGI" configuration.

.. code-block:: apache

   <VirtualHost ...>
       ServerName app.tls
       PerlHeaderParserHandler Lemonldap::NG::Handler::ApacheMP2::FCGIClient

       # This must point to the central FastCGI server
       PerlSetVar LLNG_SERVER 192.0.2.1:9090

       # Declare this vhost as a DevOps vhost, so that we do not have
       # to declare it in the LemonLDAP::NG Manager
       PerlSetVar VHOSTTYPE DevOps

       # This URL will be fetched by the central FastCGI server and
       # used to make the authentication decision about this virtualhost
       # Make sure the central FastCGI server can reach it
       PerlSetVar RULES_URL http://app.tld/rules.json
       PerlSetVar HTTPS_REDIRECT HTTPS
       PerlSetVar PORT_REDIRECT SERVER_PORT
       ...
   </VirtualHost>

Node.js
^^^^^^^

Using `express <https://github.com/expressjs/express#readme>`__ and
`fastcgi-authz-client <https://github.com/LemonLDAPNG/node-fastcgi-authz-client>`__,
you can protect also an Express server. Example:

.. code-block:: javascript

   var express = require('express');
   var app = express();
   var FcgiAuthz = require('fastcgi-authz-client');
   var handler = FcgiAuthz({
     host: '127.0.0.1',
     port: 9090,
     PARAMS: {
       RULES_URL: 'http://my-server/rules.json'
       HTTPS_REDIRECT: 'ON',
       PORT_REDIRECT: '443'
     }
   });

   app.use(handler);

   // Simple express application
   app.get('/', function(req, res) {
     return res.send('Hello ' + req.upstreamHeaders['auth-user'] + ' !');
   });

   // Launch server
   app.listen(3000, function() {
     return console.log('Example app listening on port 3000!');
   });

Plack application
^^^^^^^^^^^^^^^^^

You just have to enable
`Plack::Middleware::Auth::FCGI <https://metacpan.org/pod/Plack::Middleware::Auth::FCGI>`__.
Simple example:

.. code-block:: perl

   use Plack::Builder;

   my $app   = sub {
     my $env = shift;
     my $user = $env->{fcgiauth-auth-user};
     return [ 200, [ 'Content-Type' => 'text/plain' ], [ "Hello $user" ] ];
   };

   # Optionally ($fcgiResponse is the PSGI response of remote FCGI auth server)
   #sub on_reject {
   #    my($self,$env,$fcgiResponse) = @_;
   #    my $statusCode = $fcgiResponse->{status};
   #    ...
   #}

   builder
   {
     enable "Auth::FCGI",
       host => '127.0.0.1',
       port => '9090',
       fcgi_auth_params => {
         RULES_URL => 'https://my-server/my.json',
         HTTPS_REDIRECT => 'ON',
         PORT_REDIRECT  => 443
       },
       # Optional rejection subroutine
       #on_reject => \&on_reject;
       ;
     $app;
   };

Using front reverse-proxies
~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a simple Nginx configuration file. It looks like a standard
LL::NG nginx configuration file except for:

-  VHOSTTYPE parameter forced to use DevOps handler
-  /rules.json must not be protected by LL::NG but by the web server
   itself

This configuration handles ``*.dev.sso.my.domain`` URL and forwards
authenticated requests to ``<vhost>.internal.domain``. Rules can be
defined in ``/rules.json`` which is located at the website root
directory.

.. code-block:: nginx

   server {
     listen <port>;
     server_name "~^(?<vhost>.+?)\.dev\.sso\.my\.domain$";
     location = /lmauth {
       internal;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
       # Force handler type:
       fastcgi_param VHOSTTYPE DevOps;
       # Drop post datas
       fastcgi_pass_request_body  off;
       fastcgi_param CONTENT_LENGTH "";
       # Keep original hostname
       fastcgi_param HOST $http_host;
       # Keep original request (LL::NG server will received /lmauth)
       fastcgi_param X_ORIGINAL_URI  $original_uri;
       # Set redirection params
       fastcgi_param HTTPS_REDIRECT "$https";
       fastcgi_param PORT_REDIRECT $server_port;
     }
     location /rules.json {
       auth_request off;
       allow 127.0.0.0/8;
       deny all;
     }
     location / {
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;
       include /etc/nginx/nginx-lua-headers.conf;
       proxy_pass https://$vhost.internal.domain;
     }
   }

.. |image0| image:: /documentation/devops.png

