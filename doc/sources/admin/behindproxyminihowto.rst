Running LemonLDAP::NG behind a reverse proxy
============================================

Your network infrastructure might require that LemonLDAP::NG components
(Portal, Manager, Handler) run behind a reverse proxy.

|image0|

Transmitting the correct IP address to the portal
-------------------------------------------------

In this case, LemonLDAP::NG components will store the ip address of the
connection between the reverse proxy and the webserver in the session,
and in logs. This prevents features such as session restrictions and
rules based on \`ipAddr\` from working as expected.

A Content Delivery Network (CDN) would also have the same issue.

In order to make LemonLDAP::NG behave correctly behind a proxy, you need
to forward the original IP address all the way to LemonLDAP::NG.

In order to do this you have several options.

HTTP Header
~~~~~~~~~~~

This generic method is the most likely to work in your particular
environment.

First, configure your reverse proxy (or CDN) to send the origin IP
address in a HTTP header. Most reverse proxies do this by default,
generally in a header named ``X-Forwarded-For`` or ``X-Real-IP``.

Once the header is transmitted to LemonLDAP::NG's web server, you may
uncomment the relevant parts of the configuration file.

-  For Nginx:

.. code-block:: nginx

       set_real_ip_from  127.0.0.1;
       real_ip_header    X-Forwarded-For;


.. tip::

    Make sure Nginx was compiled with the `http_real_ip
    module <http://nginx.org/en/docs/http/ngx_http_realip_module.html>`__\

-  For Apache:

.. code-block:: apache

        RemoteIPHeader X-Forwarded-For
        RemoteIPInternalProxy 127.0.0.1


.. tip::

    Make sure the `mod_remoteip
    module <https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html>`__ is
    enabled in your Apache installation


.. danger::

    Both modules need you to specify the address of your
    reverse proxy. Using the ``http_real_ip`` or ``mod_remoteip`` module
    might let an attacker impersonate any IP address they want by setting
    the ``X-Forwarded-For`` header themselves. Please read the relevant
    module documentation carefully.

PROXY Protocol
~~~~~~~~~~~~~~

Alternatively, if your proxy supports the PROXY protocol (Nginx,
HAProxy, Amazon ELB), you may use it to carry over the information
almost transparently.

Refer to your reverse proxy's documentation to find out how to enable
the PROXY protocol on the reverse proxy side.

Then, on the LemonLDAP::NG side, in the NGINX configuration of your
Portal/Manager/Handler:

.. code-block:: nginx

    listen 80   proxy_protocol;
   # or
   # listen 443 ssl proxy_protocol;

   set_real_ip_from  127.0.0.1;
   real_ip_header    proxy_protocol;

.. |image0| image:: /documentation/reverseproxy.png
   :class: align-center


Fixing handler redirections
---------------------------

If your handler server runs behind a reverse proxy, it may have trouble figuring
out the right URL to redirect you to after logging in.

In this case, you can force a particular port and scheme in the Virtual Host's
Options.

But is instead you want this scheme to be auto-detected by LemonLDAP (in order to have a
same VHost domain available over multiple schemes), you can also use the following
declarations in the handler's virtual host to force LemonLDAP to use the correct port
and scheme

Nginx
~~~~~

::

   fastcgi_param SERVER_PORT 443
   fastcgi_param HTTPS On

Apache
~~~~~~

.. versionadded: 2.0.10

::

   PerlSetEnv SERVER_PORT 443
   PerlSetEnv HTTPS On
