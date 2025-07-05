Deploy Traefik configuration
============================

FastCGI server
--------------

For now, Traefik does not support FastCGI, so it can't be used with the
default provided llng-fastcgi-server. It can work with the PSGI server,
if it exposes an HTTP socket. See :doc:`Advanced PSGI usage<psgi>`.

For example, to use the Traefik handler with uWSGI, exposing an HTTP socket
binding on 127.0.0.1:8183

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
   you can create a systemd unit, but as Traefik is mainly used in a
   containers context, you can use a command similar to the previous one as
   an entrypoint.

Then, to configure Traefik's middleware to use it, you can use this
configuration fragment:

::

   http:
     middlewares:
       lemonldap:
         forwardAuth:
           address: http://127.0.0.1:8183
           authResponseHeaders:
             - Cookie
           authResponseHeadersRegex: '^Auth-'

.. danger::
   With this configuration, only HTTP headers starting with ``Auth-`` will be
   protected from injection by malicious users. When you use Traefik, it is
   highly recommended to only export headers that start with this prefix, unless
   you have a very good understanding of how the ``authResponseHeaders`` and
   ``authResponseHeadersRegex`` options in Traefik work.

Then to protect an app with Lemonldap::NG:

::

   tags = [
     "traefik.enable=true",
     "traefik.http.routers.whoami.rule=Path(`/whoami`)",
     "traefik.http.routers.whoami.entrypoints=https",
     "traefik.http.routers.whoami.middlewares=lemonldap@file"
   ]

Install LLNG FastCGI server
---------------------------

Debian/Ubuntu
~~~~~~~~~~~~~

::

   apt install lemonldap-ng-fastcgi-server

Enable and start the service :

::

   systemctl enable llng-fastcgi-server
   systemctl start llng-fastcgi-server

Red Hat/CentOS
~~~~~~~~~~~~~~

::

   yum install lemonldap-ng-nginx lemonldap-ng-fastcgi-server

Enable and start the service :

::

   systemctl enable llng-fastcgi-server
   systemctl start llng-fastcgi-server
