LemonLDAP::NG FastCGI server
============================

Since 1.9, LL::NG provides a FastCGI server that can be used for protecting
applications with Nginx (See
:doc:`Manage virtual hosts<configvhost>` page to configure virtual hosts)
or the DevOps Handler (See :doc:`SSO as a Service<ssoaas>`).

This FastCGI server can be implemented for all LL::NG components.
It compiles enabled components just-in-time.

Start
-----

Using package
~~~~~~~~~~~~~

You just have to install lemonldap-ng-fastcgi-server package, it will be
started automatically.

Using "make install"
~~~~~~~~~~~~~~~~~~~~

To enable the FastCGI server at startup, copy the script
``llng-fastcgi-server`` installed in INITDIR (default
``/usr/local/lemonldap-ng/etc/init.d/``) in ``/etc/init.d`` and enable
it (links to ``/etc/rc<x>.d``).

Configuration
-------------

FastCGI server has few parameters. They can be set by environment
variables (read by startup script) or by command line options. A default
configuration file can be found in
``/usr/local/lemonldap-ng/etc/default/llng-fastcgi-server`` (or
``/etc/default/lemonldap-ng-fastcgi-server`` in Debian package).

The FastCGI server reads also ``LLTYPE`` parameter in FastCGI requests
(see portal-nginx.conf or manager-nginx.conf) to choose which module is
called:

-  ``cgi`` to run .cgi scripts in FastCGI compatibility mode
-  ``psgi`` ro run .psgi scripts under FastCGI
-  ``manager`` for the manager
-  ``handler`` for the handler
-  ``portal`` for the portal
-  ``status`` to see statistics (if enabled)

if ``LLTYPE`` is set to another value or not set, FastCGI server works
as handler.
