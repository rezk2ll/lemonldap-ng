SELinux
=======

To make LemonLDAP::NG work with SELinux, you may need to set up some
options.

SELinux policy package
----------------------

If you are using a RPM distribution and Apache as the web server, you need to
install the ``lemonldap-ng-selinux`` package to configure SELinux context correctly ::

   yum install lemonldap-ng-selinux

.. note::
   On CentOS 8 and Fedora, this is done automatically

This package will not configure SELinux booleans, please read the next sections to see which booleans you need to enable manually

Disk cache (sessions and configuration)
--------------------------------------

LDAP
----

::

   setsebool -P httpd_can_connect_ldap 1

Databases
---------

::

   setsebool -P httpd_can_network_connect_db 1

Memcache
--------

::

   setsebool -P httpd_can_network_memcache 1

Proxy HTTP
----------

::

   setsebool -P httpd_can_network_relay 1

If you use Nginx + LUA
----------------------

::

    setsebool -P httpd_execmem 1
