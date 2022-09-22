Advanced PSGI usage
===================

LL::NG is built on `Plack <http://plackperl.org/>`__, so it can be used
with any compatible server:

-  `Starman <https://metacpan.org/pod/starman>`__
-  `Twiggy <https://metacpan.org/pod/twiggy>`__
-  `Twiggy::Prefork <https://metacpan.org/pod/Twiggy::Prefork>`__
-  `Feersum <https://metacpan.org/pod/feersum>`__
-  uWSGI using `uWSGI PSGI
   plugin <http://uwsgi-docs.readthedocs.io/en/latest/Perl.html>`__
-  **Alternative**: :doc:`Node.js handler<nodehandler>` can be used as
   FastCGI server, only for application protection

uWSGI or :doc:`Node.js FastCGI server<nodehandler>` may provide the
highest performance.

FastCGI server replacement
--------------------------

A ``llng-server.psgi`` is provided in example directory. It is designed
to replace exactly FastCGI server. You can use it :

-  with a FCGI Plack server, but you just have to change
   llng-fastcgi-server engine *(in
   /etc/default/lemonldap-ng-fastcgi-server)* to have the same result.
   Available engines:

   -  `FCGI <https://metacpan.org/pod/Plack::Handler::FCGI>`__
      **(default)**. It can use the following managers:

      -  `FCGI::ProcManager <https://metacpan.org/pod/FCGI::ProcManager>`__
         (default)
      -  `FCGI::ProcManager::Constrained <https://metacpan.org/pod/FCGI::ProcManager::Constrained>`__
      -  `FCGI::ProcManager::Dynamic <https://metacpan.org/pod/FCGI::ProcManager::Dynamic>`__

   -  `AnyEvent::FCGI <https://metacpan.org/pod/Plack::Handler::AnyEvent::FCGI>`__
   -  `FCGI::EV <https://metacpan.org/pod/Plack::Handler::FCGI::EV>`__
   -  `FCGI::Engine <https://metacpan.org/pod/Plack::Handler::FCGI::Engine>`__
   -  `FCGI::Engine::ProcManager <https://metacpan.org/pod/Plack::Handler::FCGI::Engine::ProcManager>`__
   -  `FCGI::Async <https://metacpan.org/pod/Plack::Handler::FCGI::Async>`__

-  with uWSGI **(see below)**


.. attention::

    Starman, Twiggy,... are HTTP servers, not FastCGI ones!

You can also replace only a part of it to create a specialized FastCGI
server (portal,...). Look at ``llng-server.psgi`` example and take the
part you want to use.

There are also some other PSGI files in examples directory.

LL::NG FastCGI Server
~~~~~~~~~~~~~~~~~~~~~

``llng-fastcgi-server`` can be started with the following options:

==================== ===================== ===================== ==========================================================================================
Command-line options                       Environment variable  Explanation
------------------------------------------ --------------------- ------------------------------------------------------------------------------------------
Short                Long
==================== ===================== ===================== ==========================================================================================
-p                   --pid                 PID                   Process PID
-u                   --user                USER                  Unix uid
-g                   --group               GROUP                 Unix gid
-n                   --proc                NPROC                 Number of process to launch *(FCGI::ProcManager)*
-s                   --socket              SOCKET                Socket to listen to
-l                   --listen              LISTEN                Listening address. Examples: ``host:port``, ``:port``, ``/socket/path``
-f                   --customFunctionsFile CUSTOM_FUNCTIONS_FILE File to load for custom functions
-e                   --engine              ENGINE                Plack::Handler engine, default to FCGI *(see below)*
\                    --plackOptions                              Other options to path to Plack. Can bu multi-valued. Values must look like ``--key=value``
==================== ===================== ===================== ==========================================================================================

See ``llng-fastcgi-server(1)`` manpage.

Some examples
^^^^^^^^^^^^^

FCGI with FCGI::ProcManager::Constrained

.. code-block:: shell

   llng-fastcgi-server -u nobody -g nobody -s /run/llng.sock -n 10 -e FCGI \
                       --plackOptions=--manager=FCGI::ProcManager::Constrained

FCGI::Engine::ProcManager

.. code-block:: shell

   llng-fastcgi-server -u nobody -g nobody -s /run/llng.sock -n 10 \
                       -e FCGI::Engine::ProcManager

Using uWSGI
~~~~~~~~~~~

You have to install uWSGI PSGI plugin. Then for example, start
llng-server.psgi *(simple example)*:

.. code-block:: shell

   /usr/bin/uwsgi --plugins psgi --socket :5000 --uid www-data --gid www-data --psgi /usr/share/lemonldap-ng/llng-server/llng-server.psgi

You will find in LL::NG Nginx configuration files some comments that
explain how to configure Nginx to use uWSGI instead of LL::NG FastCGI server.

Using Debian lemonldap-ng-uwsgi-app package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

lemonldap-ng-uwsgi-app installs a uWSGI application:
``/etc/uwsgi/apps-available/llng-server.yaml``. To enable it, link it in
``apps-enabled`` and restart your uWSGI daemon:

.. code-block:: shell

   apt-get install uwsgi uwsgi-plugin-psgi
   cd /etc/uwsgi/apps-enabled
   ln -s ../apps-available/llng-server.yaml
   service uwsgi restart

Then adapt your Nginx configuration to use this uWSGI app.

Configuration
^^^^^^^^^^^^^

To serve large requests with uWSGI, you could have to modify in uWSGI
and/or Nginx init files several options. Example:

.. code-block:: ini

   workers = 4
   buffer-size = 65535
   limit-post = 0

.. code-block:: nginx

   client_max_body_size 300M;
   proxy_send_timeout 600;
   proxy_read_timeout 600;
   proxy_connect_timeout 600;
   uwsgi_read_timeout 120;
   uwsgi_send_timeout 120;

.. note::
    Nginx natively includes support for upstream servers speaking the uwsgi protocol since version 0.8.40.
    To improve performances, you can switch from a TCP socket to an UDS socket by editing
    ``llng-server.yaml``:

    .. code-block:: ini

      uwsgi:
              plugins: psgi
              socket: /tmp/uwsgi.sock

    and adapting Nignx configuration files:

    .. code-block:: nginx

      # With uWSGI
      include /etc/nginx/uwsgi_params;
      uwsgi_pass unix:///tmp/uwsgi.sock;
      uwsgi_param LLTYPE psgi;
      uwsgi_param SCRIPT_FILENAME $document_root$sc;
      uwsgi_param SCRIPT_NAME $sc;
      # Uncomment this if you use Auth SSL:
      #uwsgi_param  SSL_CLIENT_S_DN_CN $ssl_client_s_dn_cn;


Protect a PSGI application
--------------------------

LL::NG provides ``Plack::Middleware::Auth::LemonldapNG`` that can be used
to protect any PSGI application: it works exactly like a LL::NG handler.
Simple example:

.. code-block:: perl

   use Plack::Builder;

   my $app   = sub { ... };
   builder {
       enable "Auth::LemonldapNG";
       $app;
   };

More advanced example:

.. code-block:: perl

   use Plack::Builder;

   my $app   = sub { ... };

   # Optionally ($proposedResponse is the PSGI response of Lemonldap::NG handler)
   sub on_reject {
       my($self,$env,$proposedResponse) = @_;
       # ...
   }

   builder {
       enable "Auth::LemonldapNG",
         llparams => {
           # ...
         },
         on_reject => \&on_reject;
       $app;
   };

