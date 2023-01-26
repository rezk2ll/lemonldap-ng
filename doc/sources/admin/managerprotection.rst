Manager protection
==================

When installing LL::NG, the Manager can only be accessed with the demo
account ``dwho``. This 'How To' describes how change this default behavior
to protect Manager with other rules.

Web server based protection
---------------------------


.. tip::

    Web server based protection allows one to be independent from WebSSO,
    so Manager will be always reachable even if WebSSO configuration is corrupted.

The configuration can be changed in ``etc/manager-apache2.conf`` or
``etc/manager-nginx.conf``. For example to restrict the IP allowed to access the Manager:

.. code-block:: apache

       <Directory /usr/local/lemonldap-ng/htdocs/manager/>
           Order deny,allow
           Deny from all
           Allow from 127.0.0.0/8 192.168.100.0/32
           Options +ExecCGI
       </Directory>


But you will rather prefer to use an Apache authentication module, like
for example `LDAP authentication
module <http://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html>`__:

.. code-block:: apache

       <Directory /usr/local/lemonldap-ng/htdocs/manager/>
           AuthzLDAPAuthoritative On
           AuthName "LL::NG Manager"
           AuthType Basic
           AuthBasicProvider ldap
           AuthLDAPBindDN "ou=websso,ou=applications,dc=example,dc=com"
           AuthLDAPBindPassword "secret"
           AuthLDAPURL ldap://localhost:389/ou=users,dc=example,dc=com???(objectClass=inetOrgPerson) TLS
           Require ldap-user coudot xguimard tchemineau
           Options +ExecCGI
       </Directory>


.. code-block:: nginx

       location /usr/local/lemonldap-ng/htdocs/manager/ {
           allow 127.0.0.0/8;
           allow 192.168.100.0/32;
           deny all;
       }

.. attention::

    You have to disable default Manager protection in ``lemonldap-ng.ini `` file
    to rely only on web server by commenting relative line:

    .. code:: ini

       [manager]
       ;protection = manager



LL::NG based protection
-----------------------


.. danger::

    Before enabling Manager protection by LL::NG, you must have configured
    how users authenticate on Portal, and test that you can log in.
    Else, you will lock access to Manager and will not be able to access it anymore.
    In that case, you have to set protection to ``none`` in ``lemonldap-ng.ini `` file.

By default, you will have a manager virtual host define in configuration.
If not Go to Manager, and declare Manager as a new
:ref:`virtual host<configvhost-lemonldapng-configuration>`,
for example ``manager.example.com``. Then you can then set an access rule.
No headers are required.

Default rule is:

.. code-block:: perl

   $uid eq "dwho"

You have to change it to match your admin user (or use other conditions
like group membership, or any other rule based on session variables).
Save the configuration and exit the Manager.
Further accesses to the Manager will be protected by LL::NG.

Manager protection mode can be modified by editing ``lemonldap-ng.ini``:

.. code-block:: ini

   [manager]
   protection = manager


You also have to adapt your web server access control:

.. code-block:: apache

       <Directory /usr/local/lemonldap-ng/htdocs/manager/>
           Order deny,allow
           Allow from all
           Options +ExecCGI
       </Directory>

.. code-block:: nginx

       location /usr/local/lemonldap-ng/htdocs/manager/ {
           allow all;
       }

Restart your web server and try to log in to the Manager. You should be redirected to
LL::NG Portal.

You can then add the Manager as
:ref:`an application in the menu<portalmenu-categories-and-applications>`.


.. tip::

    If for an obscure reason, the WebSSO is not working and you
    want to access the Manager, remove the protection in ``lemonldap-ng.ini`` file.
    and set an access control to avoid other accesses.


Override Portal links in Manager drop-down menu
-----------------------------------------------

In some particular use cases, for example if an external Manager is protected by
an another internal LL::NG instance, you should have to override the 'Go to Portal'
or 'Logout' links proposed in the external Manager drop-down menu.
To do this, you can override external configuration by editing ``lemonldap-ng.ini`` file.

.. code-block:: ini

   [manager]
   customPortalUrl = http://external-portal.internal.com