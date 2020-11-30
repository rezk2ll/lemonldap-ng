SELinux
=======

To make LemonLDAP::NG work with SELinux, you may need to set up some
options.

Disk cache (sessions an configuration)
--------------------------------------

You need to set the correct context on the cache directory

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
