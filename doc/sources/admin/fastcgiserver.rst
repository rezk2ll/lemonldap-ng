LemonLDAP::NG FastCGI server
============================

Since 1.9, Lemonldap::NG provides a FastCGI server usable to protect
applications with Nginx (See
:doc:`Manage virtual hosts<configvhost>` page to
configure virtual hosts).

This FastCGI server can be used for all LLNG components. It compiles
enabled components on-the-fly.

Start
-----

Using packages
~~~~~~~~~~~~~~

You just have to install lemonldap-ng-fastcgi-server package, it will be
started automatically.

Using "make install"
~~~~~~~~~~~~~~~~~~~~

To enable the FastCGI server at startup, copy the script
``llng-fastcgi-server`` installed in INITDIR (default
``/usr/local/lemonldap-ng/etc/init.d/``) in ``/etc/init.d`` and enable
it (links to ``/etc/rc//x//.d``).

Configuration
-------------

FastCGI server has few parameters. They can be set by environment
variables (read by startup script) or by command line options. A default
configuration file can be found in
``/usr/local/lemonlda-ng/etc/default/llng-fastcgi-server`` (or
``/etc/default/lemonldap-ng-fastcgi-server`` in Debian package).

The FastCGI server reads also ``LLTYPE`` parameter in FastCGI requests
(see portal-nginx.conf or manager-nginx.conf) to choose which module is
called:

-  ``cgi`` for the portal (or any CGI: it works like PHP-FPM for Perl !)
-  ``manager`` for the manager
-  ``status`` to see statistics (if enabled)

if ``LLTYPE`` is set to another value or not set, FastCGI server works
as handler.
