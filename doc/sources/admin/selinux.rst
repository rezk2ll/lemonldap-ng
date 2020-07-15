SELinux
=======

To make LemonLDAP::NG work with SELinux, you may need to set up some
options.

Disk cache (sessions an configuration)
--------------------------------------

::

   chcon -R -t httpd_sys_rw_content_t /var/cache/lemonldap-ng

To persist the rule:

::

   semanage fcontext -a -t http_sys_content_t /var/cache/lemonldap-ng

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
