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

Disk cache (sessions an configuration)
--------------------------------------

You need to set the correct context on the cache directory

.. deprecated:: 2.0.10
   this is now done by the ``lemonldap-ng-selinux`` package

::

   semanage fcontext --add -t httpd_cache_t -f a '/var/cache/lemonldap-ng(/.*)?'
   restorecon -R /var/cache/lemonldap-ng/

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
