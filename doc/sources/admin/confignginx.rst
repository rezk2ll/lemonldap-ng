Deploy Nginx configuration
==========================

FastCGI server
--------------

To use Nginx, you must install LemonLDAP::NG FastCGI server or use
``llngapp.psgi`` *(provided in examples)* with a PSGI server. See
:doc:`Advanced PSGI usage<psgi>`.

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

   yum install lemonldap-ng-fastcgi-server

Enable and start the service :

::

   systemctl enable llng-fastcgi-server
   systemctl start llng-fastcgi-server

Files
-----

With tarball installation, Nginx configuration files will be installed
in ``/usr/local/lemonldap-ng/etc/``, else they are in
``/etc/lemonldap-ng``.

You have to include them in Nginx main configuration.

.. _debianubuntu-1:

Debian/Ubuntu
~~~~~~~~~~~~~

-  Install log format *(automatically loaded when linked in this place)*

::

   ln -s /etc/lemonldap-ng/nginx-lmlog.conf /etc/nginx/conf.d/llng-lmlog.conf

-  Install snippet for vhost configuration files:

::

   ln -s /etc/lemonldap-ng/nginx-lua-headers.conf /etc/nginx/snippets/llng-lua-headers.conf

-  Link LLNG components configuration file into ``sites-available``
   directory (should already have been done if you used packages):

::

   ln -s /etc/lemonldap-ng/handler-nginx.conf /etc/nginx/sites-available/
   ln -s /etc/lemonldap-ng/manager-nginx.conf /etc/nginx/sites-available/
   ln -s /etc/lemonldap-ng/portal-nginx.conf /etc/nginx/sites-available/
   ln -s /etc/lemonldap-ng/test-nginx.conf /etc/nginx/sites-available/

-  Enable sites:

::

   ln -s /etc/nginx/sites-available/handler-nginx.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/manager-nginx.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/portal-nginx.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/test-nginx.conf /etc/nginx/sites-enabled/

.. _red-hatcentos-1:

Red Hat/CentOS
~~~~~~~~~~~~~~

Link files directly in ``conf.d`` directory:

::

   ln -s /etc/lemonldap-ng/handler-nginx.conf /etc/nginx/conf.d/
   ln -s /etc/lemonldap-ng/manager-nginx.conf /etc/nginx/conf.d/
   ln -s /etc/lemonldap-ng/portal-nginx.conf /etc/nginx/conf.d/
   ln -s /etc/lemonldap-ng/test-nginx.conf /etc/nginx/conf.d/

