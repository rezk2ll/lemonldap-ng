Manager protection
==================

When installing LL::NG, the Manager can only be accessed with the demo
account ``dwho``. This How To explains how change this default behavior
to protect Manager with other rules.

Apache based protection
-----------------------


.. tip::

    Apache based protection allow one to be independent from
    WebSSO, so Manager will always be reachable even if WebSSO configuration
    is corrupted.

The configuration can be changed in ``etc/manager-apache2.conf``, for
example to restrict the IP allowed to access the Manager:

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


.. attention::

    You need to disable default Manager protection in
    lemonldap-ng.ini to rely only on Apache:

    .. code:: ini

       [manager]
       ;protection = manager



LL::NG based protection
-----------------------


.. danger::

    Before enabling Manager protection by LL::NG, you must
    have configured how users authenticate on Portal, and test that you can
    log in without difficulties. Else, you will lock access to Manager and
    will never access it anymore.

By default, you will have a manager virtual host define in
configuration. If not Go on Manager, and declare Manager as a new
:ref:`virtual host<configvhost-lemonldapng-configuration>`, for example
``manager.example.com``. You can then set the access rule. No headers
are needed.

The default rule is:

.. code-block:: perl

   $uid eq "dwho"

You have to change it to match your admin user (or use other conditions
like group membership, or any other rule based on a session variable).

Save the configuration and exit the Manager.


.. tip::

    The next time you will access Manager, it will be through
    LL::NG.

Enable protection on Manager, by editing ``lemonldap-ng.ini``:

.. code-block:: ini

   [manager]
   protection = manager

You can also adapt Apache access control:

.. code-block:: apache

       <Directory /usr/local/lemonldap-ng/htdocs/manager/>
           Order deny,allow
           Allow from all
           Options +ExecCGI
       </Directory>

Restart Apache and try to log on Manager. You should be redirected to
LL::NG Portal.

You can then add the Manager as
:ref:`an application in the menu<portalmenu-categories-and-applications>`.


.. tip::

    If for an obscure reason, the WebSSO is not working and you
    want to access the Manager, remove the protection in
    ``lemonldap-ng.ini``. Add an Apache access control to avoid other
    access.
