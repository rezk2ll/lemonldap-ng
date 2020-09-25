Jitsi Meet
==========

|image0|

Presentation
------------

`Jitsi Meet <https://github.com/jitsi/jitsi-meet>`__ is a WEBRTC-based
video conferencing application, powering the
`meet.jit.si <http://meet.jit.si>`__ online service.

Users may install their own instance of Jitsi Meet for private use, in
which case, they may use authentication to control the creation of
conference rooms.

The official documentation provides instructions on `how to configure
Jitsi Meet to use
Shibboleth <https://github.com/jitsi/jicofo/blob/master/doc/shibboleth.md>`__,
but with a little adaptation, it can work just as fine with
LemonLDAP::NG.

Configuration
-------------

Pre-requisites
~~~~~~~~~~~~~~

This documentation assumes that you have already installed a :doc:`Nginx-based <../confignginx>`
LemonLDAP::NG Handler on your Jitsi server.

You need to install Nginx before Jitsi Meet. If you install Jitsi Meet first,
the Jitsi Meet installer will not generate a Nginx configuration file.

We assume that you have followed the `Jitsi Meet
quick
start <https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md>`__

Jitsi Meet configuration
~~~~~~~~~~~~~~~~~~~~~~~~

As with the Shibboleth guide, you need to configure
``/etc/jitsi/jicofo/sip-communicator.properties``

::

   org.jitsi.jicofo.auth.URL=shibboleth:default
   org.jitsi.jicofo.auth.LOGOUT_URL=/logout/

This defines the login servlet as ``/login/`` and the logout URL as
``/logout/``

Jitsi Meet Nginx configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the Nginx configuration that the Jitsi Meet quickstart generated, you
must add the following blocks, just like you would in a typical handler
configuration file:

::


   # This block lets Nginx know how to contact the local LLNG handler
   # for authentication
   location = /lmauth {
      internal;
      include /etc/nginx/fastcgi_params;
      fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
      fastcgi_pass_request_body  off;
      fastcgi_param CONTENT_LENGTH "";
      fastcgi_param HOST $http_host;
      fastcgi_param X_ORIGINAL_URI  $original_uri;
   }

   # Protect only the /login/ URL
   # You may want to change this is your goal is to make the whole Jitsi Meet instance private
   location /login/ {

       # Protect the current path with LLNG
       auth_request /lmauth;
       set $original_uri $uri$is_args$args;
       auth_request_set $lmremote_user $upstream_http_lm_remote_user;
       auth_request_set $lmlocation $upstream_http_location;
       error_page 401 $lmlocation;

       # Transmis user information to Jitsi through HTTP headers
       auth_request_set $mail $upstream_http_mail;
       proxy_set_header mail $mail;
       auth_request_set $displayname $upstream_http_displayName;
       proxy_set_header displayName $displayname;
       auth_request_set $lmcookie $upstream_http_cookie;
       proxy_set_header Cookie: $lmcookie;

       # Proxy requests to Jitsi Meet
       proxy_pass http://127.0.0.1:8888/login;
   }


.. warning::

    Thoses 2 blocks should be append before the "location ~ ^/([^/?&:'"]+)/(.*)$ {"

A complete nginx configuration would look like this :

   server {
      listen 80;
      server_name jitsi.demo;

      location ^~ /.well-known/acme-challenge/ {
         default_type "text/plain";
         root         /usr/share/jitsi-meet;
      }
      location = /.well-known/acme-challenge/ {
         return 404;
      }
      location / {
         return 301 https://$host$request_uri;
      }
   }
   server {
      listen 443 ssl http2;
      server_name jitsi.demo;

      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_prefer_server_ciphers on;
      ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED";

      add_header Strict-Transport-Security "max-age=31536000";

      ssl_certificate /etc/jitsi/meet/jitsi.demo.crt;
      ssl_certificate_key /etc/jitsi/meet/jitsi.demo.key;

      root /usr/share/jitsi-meet;

      # ssi on with javascript for multidomain variables in config.js
      ssi on;
      ssi_types application/x-javascript application/javascript;

      index index.html index.htm;
      error_page 404 /static/404.html;


      location = /config.js {
         alias /etc/jitsi/meet/jitsi.demo-config.js;
      }

      location = /external_api.js {
         alias /usr/share/jitsi-meet/libs/external_api.min.js;
      }

      #ensure all static content can always be found first
      location ~ ^/(libs|css|static|images|fonts|lang|sounds|connection_optimization|.well-known)/(.*)$
      {
         add_header 'Access-Control-Allow-Origin' '*';
         alias /usr/share/jitsi-meet/$1/$2;
      }

      # BOSH
      location = /http-bind {
         proxy_pass      http://127.0.0.1:5280/http-bind;
            proxy_http_version 1.0;
         proxy_set_header X-Forwarded-For $remote_addr;
         proxy_set_header Host $http_host;
      }

      # xmpp websockets
      location = /xmpp-websocket {
         proxy_pass http://localhost:5280/xmpp-websocket?prefix=$prefix&$args;
         proxy_http_version 1.1;
         proxy_set_header Upgrade $http_upgrade;
         proxy_set_header Connection "upgrade";
         proxy_set_header Host $http_host;
         tcp_nodelay on;
      }

      location ~ ^/([^/?&:'"]+)$ {
         try_files $uri @root_path;
      }

      location @root_path {
         rewrite ^/(.*)$ / break;
      }

      location ~ ^/([^/?&:'"]+)/config.js$
      {
         set $subdomain "$1.";
         set $subdir "$1/";

         alias /etc/jitsi/meet/jitsi.demo-config.js;
      }

      # BOSH for subdomains
      location ~ ^/([^/?&:'"]+)/http-bind {
         set $subdomain "$1.";
         set $subdir "$1/";
         set $prefix "$1";

         rewrite ^/(.*)$ /http-bind;
      }

      # websockets for subdomains
      location ~ ^/([^/?&:'"]+)/xmpp-websocket {
         set $subdomain "$1.";
         set $subdir "$1/";
         set $prefix "$1";

         rewrite ^/(.*)$ /xmpp-websocket;
      }

      location = /lmauth {
         internal;
         include /etc/nginx/fastcgi_params;
         fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
         fastcgi_pass_request_body off;
         fastcgi_param CONTENT_LENGTH "";
         fastcgi_param HOST $http_host;
         fastcgi_param X_ORIGINAL_URI $request_uri;
      }

      location = /login/ {

      auth_request /lmauth;
         auth_request_set $lmremote_user $upstream_http_lm_remote_user;
         auth_request_set $lmlocation $upstream_http_location;
         error_page 401 $lmlocation;

         auth_request_set $mail $upstream_http_mail;
         proxy_set_header mail $mail;
         auth_request_set $displayname $upstream_http_displayName;
         proxy_set_header displayName $displayname;
         auth_request_set $lmcookie $upstream_http_cookie;
         proxy_set_header Cookie: $lmcookie;

         proxy_pass http://127.0.0.1:8888/login;
      }

      #Anything that didn't match above, and isn't a real file, assume it's a room name and redirect to /
      location ~ ^/([^/?&:'"]+)/(.*)$ {
         set $subdomain "$1.";
         set $subdir "$1/";
         rewrite ^/([^/?&:'"]+)/(.*)$ /$2;
      }

   }

Jitsi Meet Virtual host in Manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>`
for Jitsi Meet.

Configure the :ref:`access rules<rules>`.

* Don't forget to configure the /logout/ URL

Configure the following :ref:`headers<headers>`.

-  **mail**: $mail
-  **displayName**: $cn


.. danger::

    Jitsi meet expects to find a ``mail`` HTTP header, it
    will ignore REMOTE_USER and only use the mail value to identify the
    user.

.. |image0| image:: /applications/logo-jitsimeet.png
   :class: align-center

