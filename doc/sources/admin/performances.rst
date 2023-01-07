Performances
============

LemonLDAP::NG is designed for high performance, both in throughput and
response time. Indeed, it can use Apache2 threads capabilities **but**
since Apache version 2.4, mpm_worker seems to break mod_perl. So to
increase performances, prefer using Nginx.

Built-in
--------

Cache system
~~~~~~~~~~~~

LLNG uses different cache systems to avoid querying to many the
databases:

============= ======================== ========== ============================== ==================== ==
\             Lifetime in memory                  Lifetime in Local-Cache (file)                      DB
============= ======================== ========== ============================== ==================== ==
\             Parameter                Default    Parameter                      Default
Configuration ``checkTime``            1 second                                  Until "reload" order ✔
Session       ``handlerInternalCache`` 15 seconds ``default_expires_in`` [1]_    10 minutes           ✔
============= ======================== ========== ============================== ==================== ==

.. [1] Manager >> General parameters >> Sessions >> Sessions storage >> Cache module options


.. note::

    Configuration and sessions are first looked up in-memory, then in
    the cache file, and then in their backing store. This means that after a
    configuration reload (using Manager), you have to wait for
    ``checkTime`` before you can see your changes, or wait for configuration
    cache expiration in ``checkTime`` is disabled.

Global performance
------------------

By default, Linux does not use DNS cache and LemonLDAP::NG portal
request DNS for each connexions on LDAP or DB. Under heavy loads, that
can generated hundred of DNS queries and many errors on LDAP connexions
(timed out) from IO::Socket.

To bypass this, you can:

-  Use IP in configuration to avoid DNS resolution
-  Install a DNS cache like nscd, dnsmasq or unbound

Cron optimization (or systemd timers)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LLNG installs its cron files without knowing how many servers are
installed. You should optimize this to launch:

-  purgeCentralCache: only 1 time every 10 minutes for the whole system
   (or more)
-  purgeLocalCache: ~ 1 time per hour on each server

.. _performances-handler-performance:

Handler performance
-------------------

For Nginx, you can use another auth server instead of
llng-fastcgi-server. See: :doc:`Advanced PSGI usage<psgi>`.

To increase handler performance, you can disable "Sessions activity
timeout" to prevent it from writing to the session database.

Handlers check rights and calculate headers for each HTTP hit. So to
improve performances, avoid too complex rules by using macros, groups or
local macros.

Local macros
~~~~~~~~~~~~

Macros and groups are stored in session database. Local macros is a
special feature of handler that permit one to have macros useable localy
only. Those macros are calculated only at the first usage and stored in
the local session cache (only for this server) and only if the user
access to the related applications. This avoid to have to many data stored.

.. code-block:: perl

   # rule
   admin -> $admin ||= ($uid eq 'foo' or $uid eq 'bar')
   # header
   Display-Name -> $displayName ||= $givenName." ".$surName


.. tip::

    Note that this feature is interesting only for the
    Lemonldap::NG systems protecting a high number of applications

Portal performances
-------------------

General performances
~~~~~~~~~~~~~~~~~~~~

The portal is the biggest component of Lemonldap::NG. Since version 2.0,
portal runs under FastCGI and has been rewritten using plugins, so
performance is increased in comparison to earlier versions. You just
have to disable unused plugins:

-  disable unused issuer modules
-  disable notifications if not used
-  ...

By default it uses local storage to store its tokens. If you have more
than 1 portal and if your load-balancer doesn't keep state, you have to
disable this to use the global session storage *(General parameters »
portal Parameters » Advanced Parameters » Forms)*. Note that this will
decrease performances.


.. tip::

    In production environment for network performance, prefer
    using minified versions of javascript and css libs: use
    ``make install PROD=yes``. This is done by default in RPM/DEB
    packages.


.. _performances-apachesession-performances:

Apache::Session performances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lemonldap::NG handlers use a local cache to store sessions (for 10
minutes). So Apache::Session module is not a problem for handlers. But
it can be a bottleneck for the portal:

#. When you use the multiple sessions restriction parameters, sessions
   are parsed for each authentication unless you use an
   `Apache::Session::Browseable <https://metacpan.org/module/Apache::Session::Browseable>`__
   module.
#. Since MySQL does not have always transaction feature,
   Apache::Session::MySQL has been designed to
   use MySQL locks. Since MySQL performances are very bad using this, if
   you want to store sessions in a MySQL database, prefer one of the
   following


.. tip::

    Since 1.9.6, LLNG portal and handler check if session is valid
    at each access, so purgeCentralCache cron no longer needs to be launched
    every 10 minutes: one or two times per day is enough.

.. _replace-mysql-by-apachesessionflex:

Replace MySQL by Apache::Session::Flex
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In "Apache::Session module" field, set
"`Apache::Session::Flex <https://metacpan.org/module/Apache::Session::Flex>`"
and use the following parameters:

::

   Store      -> MySQL
   Lock       -> Null
   Generate   -> MD5
   Serialize  -> Storable
   DataSource -> dbi:mysql:sessions;host=...
   UserName   -> ...
   Password   -> ...


.. tip::

    Since version 1.90 of Apache::Session, you can use
    Apache::Session::MySQL::NoLock instead

.. _use-apachesessionbrowseable:

Use Apache::Session::Browseable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

`Apache::Session::Browseable <https://metacpan.org/module/Apache::Session::Browseable>`__
is a wrapper for other Apache::Session modules that add the capability
to manage indexes. Prefer versions ≥ 1.2.5 for better performances in DB
cleaning. To use it (with PostgreSQL for example), choose
"Apachedoc:`Session::Browseable<session::browseable>`::Postgres" as
"Apache::Session module" and use the following parameters:

::

   DataSource -> dbi:Pg:database=sessions;host=...
   UserName   -> user
   Password   -> password
   Index      -> ipAddr uid

Note that
Apache::Session::Browseable::MySQL doesn't
use MySQL locks.

Look at :doc:`Browseable session backend<browseablesessionbackend>` to
known which index to choose.


.. attention::

    Some Apache::Session module are not fully usable by
    Lemonldap::NG such as Apache::Session::Memcached since these
    modules do not offer capability to browse sessions. They does not allow
    one to use sessions explorer neither manage one-off sessions.

.. _performance-test:

Performance test
^^^^^^^^^^^^^^^^


.. tip::

    A
    `Apache::Session::Browseable::Redis <https://metacpan.org/module/Apache::Session::Browseable::Redis>`__
    has been created, it is the fastest (except for session explorer,
    defeated by Apache::Session::Browseable:: `DBI <https://metacpan.org/module/Apache::Session::Browseable>`__ / `LDAP <https://metacpan.org/module/Apache::Session::Browseable::LDAP>`__)

This test isn't an "only-backend" test but embedded some LLNG methods,
so real differences between engines are mitigate here.

====================================================================== ============================ =================== ========== =================== ===================================== =================== =============
   Backend                                                                                             Portal and handlers                                Session explorer and one-off sessions
--------------------------------------------------------------------------------------------------- -------------------------------------------------- -----------------------------------------------------------------------
Name                                                                   Configuration                Insert 1000         Search 1   Purge 500           Parse all                             Search by substring Search by UID
====================================================================== ============================ =================== ========== =================== ===================================== =================== =============
Apache::Session::\ **Browseable::LDAP**                                mdb                          159.66              0.0120     49.22               0.1110                                0.0076              0.0050
Apache::Session::\ **MySQL**                                           No lock                      87.20               **0.0039** 23.14               0.0281                                0.0252              0.0235
Apache::Session::\ **Browseable::MySQL**                                                            91.79               **0.0039** **0.139** [2]_      0.0272                                **0.0036**          **0.0026**
Apache::Session::\ **Browseable::MySQLJSON**                                                        86.06               0.0145     \*\* 0.151*\* [3]_  **0.0104**                            0.0137              0.0038
Apache::Session::\ **Postgres**                                                                     18.31               0.0095     13.40               0.0323                                0.0277              0.0264
Apache::Session::\ **Postgres**                                        Unlogged table               9.16                0.0095     7.91                0.0318                                0.0270              0.0254
Apache::Session::\ **Browseable::Postgres**                            Unlogged table with indexes  9.24                0.0094     **0.103** [2]_      0.0301                                **0.0036**          **0.0028**
Apache::Session::\ **Browseable::PgJSON**                              Unlogged table, json field   9.25                0.0091     **0.108** [2]_      0.0247                                **0.0035**          **0.0029**
Apache::Session::\ **Browseable::PgJSON**                              Unlogged table, jsonb field  9.25                0.0091     **0.105** [2]_      **0.0126**                            **0.0034**          **0.0029**
Apache::Session::\ **Browseable::PgHstore**                            Unlogged table, hstore field 9.62                0.0111     **0.105** [2]_      **0.0125**                            **0.0033**          **0.0029**
Apache::Session::\ **Browseable::Redis**                                                            **2.36**            **0.0033** 1.154               0.0643                                0.1048              **0.0024**
====================================================================== ============================ =================== ========== =================== ===================================== =================== =============

*The source of this test is available in sources: e2e-tests/sbperf.pl*

.. [2]  "purge" test is done with Apache::Session::Browseable-1.2.5
   and LLG-2.0. Earlier results are not so good.
.. [3] "purge" test is done with Apache::Session::Browseable-1.2.6
   and LLG-2.0.

Analysis:

-  LDAP servers are "write-once-read-many", so write performances are
   very bad. Don't use this on heavy load if "Session activity timeout"
   is enabled *(if set, handler "write" sessions)*
-  MySQL/MariaDB is better to read than to write. Prefer PostgreSQL if
   you use "Session activity timeout"
-  Logged tables decrease a lot insert performances with PostgreSQL, so
   use unlogged tables for sessions except for persistent sessions
-  Redis is the best for main usage
-  Browseable::Postgres/PgHstore/PgJSON are the best SQL solutions on
   average

.. _performances-ldap-performances:

LDAP performances
~~~~~~~~~~~~~~~~~

LDAP server can slow you down when you use LDAP groups retrieval. You
can avoid this by setting "memberOf" fields in your LDAP scheme:

.. code::

   dn: uid=foo,dmdName=people,dc=example,dc=com
   ...
   memberOf: cn=admin,dmdName=groups,dc=example,dc=com
   memberOf: cn=su,dmdName=groups,dc=example,dc=com

So instead of using LDAP groups retrieval, you just have to store
"memberOf" field in your exported variables. With OpenLDAP, you can use
the `memberof
overlay <http://www.openldap.org/doc/admin24/overlays.html#Reverse%20Group%20Membership%20Maintenance>`__
to do it automatically.


.. attention::

    Don't forget to create an index on the field used to
    find users (uid by default)


.. tip::

    To avoid storing the full group DNs in session data, you can
    use a macro to rewrite ``memberOf``:

    -  In \*Exported variables*, export the ``memberOf`` LDAP attribute as a
       ``ldapGroups`` session variable

       -  key: ``ldapGroups``
       -  value: ``memberOf``

    -  Next, add a ``ldapGroups`` macro that will overwrite the exported
       attribute

       -  key: ``ldapGroups``
       -  value:

    ::

       join("; ",($ldapGroups =~ /cn=(.*?),/g))

    ``ldapGroups`` should now contain something like ``admin; su`` just like
    it would if you had used the regular, slower group resolution mechanism.

    You can use
    :ref:`listMatch($ldapGroups, "some_group")<listMatch>` in your
    access rules.

NGINX performances
~~~~~~~~~~~~~~~~~~

To increase launch by web browser, for example to load js, css, or
fonts, Gzip compression can be activated.

Edit file /etc/nginx/mime.types Check those lines or add :

.. code-block:: perl

   application/vnd.ms-fontobject    eot;
   application/x-font-ttf           ttf;
   application/font-woff            woff;
   font/opentype                    ott;

Edit file /etc/nginx/nginx.conf

.. code-block:: perl

   gzip on; # active la compression Gzip
   gzip_disable "msie6";

   gzip_vary on;
   gzip_proxied any;
   gzip_comp_level 6;
   gzip_buffers 16 8k;
   gzip_http_version 1.1;
   gzip_min_length 128;
   gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/rss+xml text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/jpeg image/png image/svg+xml image/x-icon;

Restart NGINX and watch web-browser console.

Manager performances
--------------------

Disable unused modules
~~~~~~~~~~~~~~~~~~~~~~

In lemonldap-ng.ini, set only modules that you will use. By default,
configuration, sessions explorer, notifications explorer and second
factor are enabled. Example:

.. code-block:: ini

   [manager]
   enabledModules = conf, sessions

Enable compactConf parameter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By enabling compactConf option, all unused configuration parameters are
removed. Could be usefull to shrink lemonldap-ng configuration file and
save space.

Go in Manager, ``General Parameters`` » ``Configuration reload`` »
''Compact configuration file '' and set to ``On``.

Use static HTML files
~~~~~~~~~~~~~~~~~~~~~

Once Manager is installed, browse enabled modules (configuration,
sessions, notifications) and save the web pages respectively under
``manager.html``, ``sessions.html`` and ``notifications.html`` in the
``DocumentRoot`` directory. Then replace this in Manager file of Apache
configuration:

.. code-block:: apache

   RewriteRule "^/$" "/psgi/manager-server.fcgi" [PT]
   # DirectoryIndex manager.html
   # RewriteCond "%{REQUEST_FILENAME}" "!\.html$"
   RewriteCond "%{REQUEST_FILENAME}" "!^/(?:static|doc|lib).*"
   RewriteRule "^/(.+)$" "/psgi/manager-server.fcgi/$1" [PT]

by:

.. code-block:: apache

   # RewriteRule "^/$" "/psgi/manager-server.fcgi" [PT]
   DirectoryIndex manager.html
   RewriteCond "%{REQUEST_FILENAME}" "!\.html$"
   RewriteCond "%{REQUEST_FILENAME}" "!^/(?:static|doc|lib).*"
   RewriteRule "^/(.+)$" "/psgi/manager-server.fcgi/$1" [PT]

So manager HTML templates will be no more generated by Perl but directly
given by the web server.
