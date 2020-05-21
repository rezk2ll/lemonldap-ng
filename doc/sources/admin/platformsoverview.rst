Platforms overview
==================

LLNG is able to use different web servers to provide its services. Here
is a resume of all possibilities. We recommend:

-  For installations subject to small/medium load: Nginx with our
   default FastCGI server, or Apache *(with mpm_prefork engine)*
-  For heavily loaded installation: Nginx. The choice for
   FastCGI server engine depends on the behavior of your users

Portal/Manager installation
---------------------------

Since 2.0, both portal and manager are native FastCGI / PSGI Plack based
applications. They can be powered by any FastCGI / PSGI compatible web
servers. Some examples:

=============================== ================================================================================================ ============================= ============================= =====================================================================================
\                               Apache                                                                                                                         Nginx                         Plack servers family
=============================== ================================================================================================ ============================= ============================= =====================================================================================
**Engines**                     `mod_fcgid <https://httpd.apache.org/mod_fcgid/>`__ or `mod_fastcgi <http://www.fastcgi.com/>`__                               FastCGI/uWSGI server          Any `Plack HTTP server <https://plackperl.org>`__ (*see* :doc:`our doc<configplack>` )
**Link with webserver process** External processes managed by webserver *(default)*                                              External LLNG serve           External LLNG server          :doc:`Inside<configplack>`
=============================== ================================================================================================ ============================= ============================= =====================================================================================

Application protection overview
-------------------------------

Applications can be protected:

-  by a LLNG handler
-  by themselves if they can dial with a supported protocol (SAML,
   OpenID-Connect,...)

To protect applications with handler, LLNG can be used in two mode:

-  Direct Application Mode : LLNG handler is an embedded application.
   Handler must be installed on application Web Server
-  ReverseProxy Mode : applications are hidden behind a ReverseProxy
   which provides the required LLNG handler

Handler integration
~~~~~~~~~~~~~~~~~~~

Direct Application Mode
^^^^^^^^^^^^^^^^^^^^^^^

LLNG handlers can be installed on the following web servers:

================================= ========================== =============================================================================== ==================== =================================================================================
\                                 Apache                     Nginx                                                                           Plack servers family Node.js
================================= ========================== =============================================================================== ==================== =================================================================================
**Addon needed**                  ModPerl                                                                                                                         Express
**LLNG integration in webserver** :doc:`Inside<configvhost>` Separate process: External LLNG FastCGI/uWSGI servers *(auth_request)*          :doc:`Inside<psgi>`  `Inside <https://github.com/LemonLDAPNG/node-lemonldap-ng-handler#express-app>`__
================================= ========================== =============================================================================== ==================== =================================================================================

ReverseProxy Mode
^^^^^^^^^^^^^^^^^

============================================== ========================== ==============================================================
\                                              Apache                     Nginx
============================================== ========================== ==============================================================
**LLNG integration in ReverseProxy webserver** :doc:`Inside<configvhost>` Separate process: External LLNG FastCGI/uWSGI servers
============================================== ========================== ==============================================================

.. _platformsoverview-external-servers-for-nginx:

External servers for Nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~

Nginx supportes natively FastCGI and uWSGI protocoles.

Therefore, LLNG services can be provided by compatible external servers.


.. tip::

    FastCGI or uWSGI server(s) can be installed on separate hosts.
    Also you can imagine a global cloud-FastCGI/uWSGI-service for all your
    Nginx servers. See more at
    :doc:`SSO as a service (SSOaaS)<ssoaas>`.

FastCGI
^^^^^^^

By default, LLNG provides a Plack based FastCGI server able to afford
all LLNG services using
`FCGI <https://metacpan.org/pod/Plack::Handler::FCGI>`__ engine.

However, you can use some other FastCGI server engines:

-  `AnyEvent::FCGI <https://metacpan.org/pod/Plack::Handler::AnyEvent::FCGI>`__
-  `FCGI::EV <https://metacpan.org/pod/Plack::Handler::FCGI::EV>`__
-  `FCGI::Engine <https://metacpan.org/pod/Plack::Handler::FCGI::Engine>`__
-  `FCGI::Engine::ProcManager <https://metacpan.org/pod/Plack::Handler::FCGI::Engine::ProcManager>`__
-  `FCGI::Async <https://metacpan.org/pod/Plack::Handler::FCGI::Async>`__
-  `LLNG FastCGI server for
   Node.js <https://github.com/LemonLDAPNG/node-lemonldap-ng-handler#nginx-authorization-server>`__\ (*)


.. danger::

    (*) LLNG Node.js handler can only be used as Nginx
    \`auth_request\` server, not to serve Portal or Manager

uWSGI
^^^^^

-  uWSGI server (with uwsgi PSGI plugin, see
   :doc:`Advanced PSGI usage<psgi>`)
