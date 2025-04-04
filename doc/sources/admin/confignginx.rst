Deploy Nginx configuration
==========================

FastCGI server
--------------

To use Nginx, you must install LemonLDAP::NG FastCGI server or use
``llngapp.psgi`` *(provided in examples)* with a PSGI server. See
:doc:`Advanced PSGI usage<psgi>`.

.. note::

    If installation has been done with packages, this should be already done.

Debian/Ubuntu
~~~~~~~~~~~~~

::

   apt install lemonldap-ng-fastcgi-server

Enable and start the service :

::

   systemctl enable lemonldap-ng-fastcgi-server
   systemctl start lemonldap-ng-fastcgi-server

Red Hat/CentOS
~~~~~~~~~~~~~~

::

   yum install lemonldap-ng-nginx lemonldap-ng-fastcgi-server

Enable and start the service :

::

   systemctl enable lemonldap-ng-fastcgi-server
   systemctl start lemonldap-ng-fastcgi-server

Files
-----

With tarball installation, Nginx configuration files will be installed
in ``/usr/local/lemonldap-ng/etc/``, else they are directly in web server
configuration.

.. _debianubuntu-1:

Debian/Ubuntu
~~~~~~~~~~~~~

-  Install snippet for vhost configuration files:

::

   ln -s /etc/lemonldap-ng/nginx-lua-headers.conf /etc/nginx/snippets/llng-lua-headers.conf

-  Enable portal, manager and handler/reload sites:

::

   ln -s /etc/nginx/sites-available/portal-nginx.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/manager-nginx.conf /etc/nginx/sites-enabled/
   ln -s /etc/nginx/sites-available/handler-nginx.conf /etc/nginx/sites-enabled/


-  Enable test sites (optional):

::

   ln -s /etc/nginx/sites-available/test-nginx.conf /etc/nginx/sites-enabled/
