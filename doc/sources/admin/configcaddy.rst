Deploy Caddy configuration
==========================

Caddy is a modern web server written in Go with automatic HTTPS capabilities.
It supports integration with authentication services via its ``forward_auth``
directive, which works similarly to Traefik's ``forwardAuth``.

.. versionadded:: 2.19.0

Since Caddy's ``forward_auth`` behavior is identical to Traefik's ``forwardAuth``,
LemonLDAP::NG uses the same handler for both servers: ``SOURCE_SERVER=traefik``.

PSGI server
-----------

Caddy does not support FastCGI for authentication (it doesn't implement
``FCGI_ROLE=AUTHORIZER``), so it must work with a PSGI server exposing an
HTTP socket. See :doc:`Advanced PSGI usage<psgi>`.

For example, to use the handler with uWSGI, exposing an HTTP socket
binding on 127.0.0.1:8183:

::

   cd /usr/share/lemonldap-ng/llng-server && SOURCE_SERVER=traefik /sbin/uwsgi \
     --plugin psgi \
     --psgi llng-server.psgi \
     --master \
     --workers 2 \
     --max-worker-lifetime 86400 \
     --max-requests 10000 \
     --disable-logging \
     --harakiri 30 \
     --buffer-size 65535 \
     --limit-post 0 \
     --die-on-term \
     --http-socket 127.0.0.1:8183

.. note::
   Use ``SOURCE_SERVER=traefik`` - this handler works for both Traefik and Caddy
   since they have identical ``forward_auth`` / ``forwardAuth`` behavior.

Handler behavior
----------------

The Traefik handler (used for both Traefik and Caddy):

- Reads ``X-Forwarded-*`` headers sent by Caddy
- Returns 302/303 redirects directly (unlike Nginx which requires
  conversion to 401)
- Passes headers through directly using Caddy's ``copy_headers`` directive

Caddy configuration
-------------------

Basic Caddyfile
~~~~~~~~~~~~~~~

Here is a basic configuration example:

::

   # Portal LemonLDAP::NG
   auth.example.com {
       reverse_proxy llng-portal:9090
   }

   # Manager LemonLDAP::NG
   manager.example.com {
       reverse_proxy llng-manager:9090
   }

   # Protected application
   app.example.com {
       # Security: remove headers that could be forged by malicious users
       request_header -Auth-User
       request_header -Auth-Mail
       request_header -Auth-Groups
       request_header -Lm-Remote-User

       forward_auth llng-handler:8184 {
           uri /
           copy_headers {
               Auth-User
               Auth-Mail
               Auth-Groups
               Lm-Remote-User
           }
       }

       reverse_proxy backend:8080
   }

The ``forward_auth`` directive:

- Sends the original request information via ``X-Forwarded-*`` headers
- On 2xx response: copies specified headers to the original request
- On non-2xx response: returns the response to the client (including redirects
  to the login portal)

Headers configuration
~~~~~~~~~~~~~~~~~~~~~

Use ``copy_headers`` to specify which headers should be copied from the
authentication response to the original request:

::

   forward_auth llng-handler:8184 {
       uri /
       copy_headers {
           Auth-User
           Auth-Mail
           Auth-Groups
           Lm-Remote-User
           Lm-Remote-Custom
       }
   }

.. warning::

   It is **highly recommended** to prefix your exported headers with ``Auth-``
   to make it easier to prevent header injection attacks. Always remove these
   headers before the ``forward_auth`` directive using ``request_header -HeaderName``.

Passing headers to backend
~~~~~~~~~~~~~~~~~~~~~~~~~~

After authentication, you can pass headers to the backend using
``header_up`` in the ``reverse_proxy`` directive:

::

   reverse_proxy backend:8080 {
       header_up X-Remote-User {http.request.header.Auth-User}
       header_up X-Remote-Mail {http.request.header.Auth-Mail}
   }

Docker/Kubernetes example
~~~~~~~~~~~~~~~~~~~~~~~~~

In a containerized environment, your Caddyfile might look like:

::

   :80 {
       handle /health {
           respond "OK" 200
       }

       handle {
           request_header -Auth-User
           request_header -Auth-Mail

           forward_auth llng-handler:8184 {
               uri /
               copy_headers Auth-User Auth-Mail Lm-Remote-User
           }

           reverse_proxy {$BACKEND_URL}
       }
   }

Security considerations
-----------------------

Header injection prevention
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Always remove headers that could be forged by malicious users before
authentication:

::

   # Remove all headers that LLNG might set
   request_header -Auth-*
   request_header -Lm-Remote-User
   request_header -Lm-Remote-Custom

   forward_auth llng-handler:8184 {
       # ...
   }

See also
--------

- :doc:`Deploy Traefik configuration<configtraefik>`
- :doc:`Deploy Nginx configuration<confignginx>`
- :doc:`Advanced PSGI usage<psgi>`
- :doc:`Handler architecture<handlerarch>`
