SQL configuration backends
==========================

There is 2 types of SQL configuration backends for LemonLDAP::NG:

-  **CDBI**: very simple storage (recommended)
-  **RDBI**: triple store storage (not recommended)


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

Create database:

.. code-block:: sql

   CREATE DATABASE lemonldap-ng CHARACTER SET utf8;

Use database to create table:

.. code-block:: sql

   use lemonldap-ng

CDBI
^^^^

.. code-block:: sql

   CREATE TABLE lmConfig (
       cfgNum int not null primary key,
       data longtext
   );

RDBI
^^^^

.. code-block:: sql

   CREATE TABLE lmConfig (
       cfgNum int(11) NOT NULL,
       field varchar(255) NOT NULL DEFAULT '',
       value longtext,
       PRIMARY KEY (cfgNum,field)
       );

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

Use database to create table:

.. code-block:: sql

   use lemonldap-ng

.. _rdbi-1:

CDBI
^^^^

.. code-block:: sql

   CREATE TABLE lmConfig (
       cfgnum integer not null primary key,
       data text
   );

.. _connection-settings-1:

RDBI
^^^^

.. code-block:: sql

   CREATE TABLE lmconfig (
       cfgnum integer NOT NULL,
       field text NOT NULL,
       value text,
       PRIMARY KEY (cfgNum,field)
       );

.. _cdbi-1:

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

