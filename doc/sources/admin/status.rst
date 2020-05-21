Status pages
============

Portal Status (experimental)
----------------------------

The Portal displays in JSON format its activity. It can provide a view
of all returned codes.

Configuration
~~~~~~~~~~~~~

-  Ordered List ItemSet ``portalStatus = 1`` in lemonldap-ng.ini file
   (section ``[Portal]``)
-  Note that handler status must also been enabled
-  The URL http://portal/status must be protected by your webserver
   configuration

Handler Status
--------------

Presentation
~~~~~~~~~~~~

When status feature is enabled, Handlers and portal will collect
statistics and save them in their local cache. This means that if
several Handlers are deployed, each will manage its own statistics.


.. tip::

    This page can be browsed for example by
    `MRTG <http://oss.oetiker.ch/mrtg/>`__ using the
    :doc:`MRTG monitoring script<mrtg>`.

Statistics are collected through a daemon launched by the Handler. It
can be supervised in system processes.

The statistics are displayed when calling the status path on an Handler
(for example: http://reload.example.com/status).

Example of status page:

|image0|

.. _configuration-status-1:

Configuration
~~~~~~~~~~~~~

Nginx
^^^^^

You need to give access to status path in the Handler Nginx
configuration:

.. code-block:: nginx

   server {
     listen __PORT__;
     server_name reload.__DNSDOMAIN__;
     root /var/www/html;
     ...
     location = /status {
       allow 127.0.0.1;
       deny all;
       include /etc/nginx/fastcgi_params;
       fastcgi_pass unix:__FASTCGISOCKDIR__/llng-fastcgi.sock;
       fastcgi_param LLTYPE status;
     }
   }

Apache
^^^^^^

You need to give access to status path in the Handler Apache
configuration:

.. code-block:: apache

       # Uncomment this to activate status module
       <Location /status>
           Order deny,allow
           Allow from 127.0.0.0/8
           PerlHeaderParserHandler Lemonldap::NG::Handler->status
       </Location>

Then restart Apache.


.. tip::

    You should change the ``Allow`` directive to match
    administration IP, or use another Apache protection mean.

Portal data
'''''''''''

By default Apache handler status process listen to ``localhost:64321``
*(UDP)*. You can change this using ``LLNGSTATUSLISTEN`` environment
variable. If you want to collect portal data, you just have to set
``LLNGSTATUSHOST`` environment variable *(see comments in our
``portal-apache2.conf``)*.

.. code-block:: apache

     <Files *.fcgi>
       SetHandler fcgid-script
       # For Authorization header to be passed, please uncomment one of the following:
       # for Apache >= 2.4.13
       #CGIPassAuth On
       # for Apache < 2.4.13
       #RewriteCond %{HTTP:Authorization} ^(.*)
       #RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]
       Options +ExecCGI
       header unset Lm-Remote-User
     </Files>
     FcgidInitialEnv LLNGSTATUSHOST 127.0.0.1:64321

LemonLDAP::NG
^^^^^^^^^^^^^

Edit ``lemonldap-ng.ini``, and activate status in the ``handler``
section:

.. code-block:: ini

   [all]
   # Set status to 1 if you want to have the report of activity (used for
   # example to inform MRTG)
   status = 1

Then restart webserver.

Advanced
~~~~~~~~

#. You can also open the UDP port with Nginx if you set
   ``LLNGSTATUSLISTEN`` environment variable *(host:port)*
#. When querying status *(using portal or handler status)* and if UDP is
   used, query is given to ``LLNGSTATUSHOST`` *(host:port)* and response
   is waiting on a dynamic UDP port given in query *(between 64322 and
   64331)*. By default this dynamic UDP port is opened on loopback
   *(``localhost`` entry in ``/etc/hosts``)*. To change this, set an IP
   address or a host using ``LLNGSTATUSCLIENT`` environment variable.

.. |image0| image:: /documentation/status_standard.png
   :class: align-center

