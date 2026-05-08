GLPI
====

|image0|

Presentation
------------

`GLPI <http://www.glpi-project.org>`__ is the Information
Resource-Manager with an additional Administration- Interface. You can
use it to build up a database with an inventory for your company
(computer, software, printers...). It has enhanced functions to make the
daily life for the administrators easier, like a job-tracking-system
with mail-notification and methods to build a database with basic
information about your network-topology.

Configuration
-------------

In Lemonldap you will need to create a new Virtual Host as follows:
`Virtual Hosts` -> `Add virtualhost`: `glpi.example.com`

On the virtual host the `Access rules` can be configured to `accept` as the
`Default rule`. This is for testing purposes but you can read the following
[documentation](https://lemonldap-ng.org/documentation/latest/writingrulesand_headers.html#rules).

In `Exported headers` the attributes picked sent to GLPI need to be configured:
.. code-block:: bash

   AUTH-GIVENNAME => $givenName
   AUTH-MAIL      => $mail
   AUTH-SN        => $sn

Next we will need to configure the reverse proxy to retrieve the headers from
lemonldap and send them to GLPI after authentication has been completed.
If you use Nginx, you need to create the following configuration:

.. code-block:: nginx

  server {
    listen 80;
    server_name glpi.example.com;
    location = /lmauth {
      internal;
      include /etc/nginx/fastcgi_params;
      fastcgi_pass unix:/var/run/llng-fastcgi-server/llng-fastcgi.sock;
      fastcgi_pass_request_body  off;
      fastcgi_param CONTENT_LENGTH "";
      fastcgi_param HTTP_HOST $host;
      fastcgi_param X_ORIGINAL_URI  $original_uri;
      auth_request_set $lmlocation $upstream_http_location;
    }

    location / {
      auth_request /lmauth;
      set $original_uri $uri$is_args$args;

      error_page 401 $lmlocation;

      proxy_pass http://glpi/;
      include /etc/nginx/proxy_params;

      auth_request_set $lmremote_user $upstream_http_lm_remote_user;
      proxy_set_header REMOTE-USER $lmremote_user;
      auth_request_set $authmail $upstream_http_auth_mail;
      proxy_set_header AUTH-MAIL $authmail;
      auth_request_set $authsn $upstream_http_auth_sn;
      proxy_set_header AUTH-SN $authsn;
      auth_request_set $authgivenname $upstream_http_auth_givenname;
      proxy_set_header AUTH-GIVENNAME $authgivenname;
    }
  }

The above example is a modified configuration that can be found here:
https://lemonldap-ng.org/documentation/latest/configvhost.html

Take note of the `proxy_set_header` and `auth_request_set` configurations at the
end the nginx configuration block. This follows a specific convention which is
described on this page for Apache2 and Nginx:
https://lemonldap-ng.org/documentation/latest/header_remote_user_conversion.html.

In addition you will need the below `proxy_params` configurations as defined in
the nginx configuration above:
.. code-block:: nginx

   proxy_set_header Host $host;
   proxy_set_header X-Forwarded-Host $host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

For GLPI >= 0.71, it is a simple configuration in GLPI: Setup → Authentication.
In “External authentications” click “Others authentication methods” and in the
section "Other authentication sent in the HTTP request" you will need to
configure the following:

.. code-block:: bash

   Field storage of the login in the HTTP request => HTTP_REMOTE_USER
   SSO logout url                                 => http://auth.example.com/?logout=1
   First name                                     => HTTP_AUTH_GIVENNAME
   Surname                                        => HTTP_AUTH_SN
   Email                                          => HTTP_AUTH_MAIL

It is important to note the naming convention of the HTTP headers being
configured between Lemonldap, Nginx and GLPI.

.. |image0| image:: /applications/glpi_logo.png
   :class: align-center

