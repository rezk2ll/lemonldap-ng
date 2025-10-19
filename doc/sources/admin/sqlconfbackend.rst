SQL configuration backends
==========================

There is 2 types of SQL configuration backends for LemonLDAP::NG:

-  **CDBI**: very simple storage (recommended)
-  **RDBI**: triple store storage (deprecated)


.. tip::

    You can use any database engine if it provides a Perl Driver.
    You will find here examples for MySQL and PostgreSQL, but other engines
    may also work.

See :doc:`how to change configuration backend<changeconfbackend>`.

MySQL
-----

Perl Driver
~~~~~~~~~~~

You need DBD::MySQL Perl module:

-  Debian:

::

   apt install libdbd-mysql-perl

-  Red Hat:

::

   yum install perl-DBD-MySQL

Database and table creation
~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. code-block:: sql

   CREATE DATABASE lemonldap-ng CHARACTER SET utf8;


Then execute ``/usr/share/lemonldap-ng/ressources/config.my.sql`` to create the table.

Grant access
~~~~~~~~~~~~

You have to grant read/write access for the manager component. Other
components needs just a read access. You can also use the same user for
all.


.. tip::

    You can use different dbiUser strings:

    -  one with read/write rights for servers hosting the manager
    -  one with just read rights for other servers



For example (suppose that our servers are in 10.0.0.0/24 network):

.. code-block:: sql

   GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES ON lemonldap-ng.lmConfig
     TO lemonldaprw@manager.host IDENTIFIED BY 'mypassword';
   GRANT SELECT ON lemonldap-ng.lmConfig
     TO lemonldapro@'10.0.0.%' IDENTIFIED BY 'myotherpassword';

Connection settings
-------------------

Change configuration settings in ``/etc/lemonldap-ng/lemonldap-ng.ini``
file (section configuration):

.. code-block:: ini

   [configuration]
   type = CDBI
   dbiChain    = DBI:mysql:database=lemonldap-ng;host=1.2.3.4
   dbiUser     = lemonldaprw
   dbiPassword = mypassword
   ; optional
   dbiTable    = mytablename

.. tip::

   We recommend adding the `mysql_connect_timeout`, `mysql_write_timeout`, and `mysql_read_timeout` options to the DBI string

PostGreSQL
----------

.. _perl-driver-1:

Perl Driver
~~~~~~~~~~~

You need DBD::Pg Perl module:

-  Debian:

::

   apt install libdbd-pg-perl

-  Red Hat:

::

   yum install perl-DBD-Pg

.. _database-and-table-creation-1:

Database and table creation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create database:

.. code-block:: sql

   CREATE DATABASE lemonldap-ng;

Then execute ``/usr/share/lemonldap-ng/ressources/config.pg.sql`` to create the table.

Connection settings
-------------------

Change configuration settings in ``/etc/lemonldap-ng/lemonldap-ng.ini``
file (section configuration):

.. code-block:: ini

   [configuration]
   type = CDBI
   dbiChain    = DBI:Pg:database=lemonldap-ng;host=1.2.3.4
   dbiUser     = lemonldaprw
   dbiPassword = mypassword
   ; optional
   dbiTable    = mytablename

.. tip::

   We recommend adding the `tcp_user_timeout` and `keepalives_idle` options to the DBI string

Patroni support
~~~~~~~~~~~~~~~

If you use a PostgreSQL cluster based on Patroni, you can add the list of
Patroni API urls to get a native high-availability without needing any
load-balancer. In case of error, LLNG will try to get the Patroni leader
and update its "dbiChain":

.. code-block:: ini

   [configuration]
   type = Patroni
   dbiChain    = DBI:Pg:database=lemonldap-ng;host=1.2.3.4
   patroniUrl  = http://1.2.3.2:8008/cluster, http://1.2.3.3:8008/cluster, http://1.2.3.4:8008/cluster
   dbiUser     = lemonldaprw
   dbiPassword = mypassword
   ; optional
   dbiTable                  = mytablename
   patroniTimeout            = 3
   patroniCacheTTL           = 60
   patroniCircuitBreakerDelay = 30

Optional Patroni parameters:

- **patroniTimeout**: Timeout in seconds for Patroni API requests (default: 3)
- **patroniCacheTTL**: Time-to-live in seconds for the cached leader information. If all Patroni APIs are temporarily unavailable, LLNG will use the last known leader if the cache is still valid (default: 60)
- **patroniCircuitBreakerDelay**: Circuit breaker delay in seconds. When Patroni API requests fail, LLNG will wait this amount of time before retrying, using the cached leader in the meantime (default: 30)

RDBI (deprecated)
------------------

In order to use the deprecated RDBI storage, use the following table schemas:


MySQL
~~~~~

.. code-block:: sql

   CREATE TABLE lmConfig (
       cfgNum int(11) NOT NULL,
       field varchar(255) NOT NULL DEFAULT '',
       value longtext,
       PRIMARY KEY (cfgNum,field)
       );

PostgreSQL
~~~~~~~~~~

.. code-block:: sql

   CREATE TABLE lmconfig (
       cfgnum integer NOT NULL,
       field text NOT NULL,
       value text,
       PRIMARY KEY (cfgNum,field)
       );
