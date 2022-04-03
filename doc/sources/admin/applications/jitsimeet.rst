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
but with a little adaptation, it can work just as fine with LemonLDAP::NG.

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


   # This block lets Nginx know how to contact the local LL::NG handler
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

       # Protect the current path with LL::NG
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

    Thoses 2 blocks should be append BEFORE the following block::

      #Anything that didn't match above, and isn't a real file,
      #assume it's a room name and redirect to /
      location ~ ^/([^/?&:'"]+)/(.*)$ {
         set $subdomain "$1.";
         set $subdir "$1/";
         rewrite ^/([^/?&:'"]+)/(.*)$ /$2;
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

