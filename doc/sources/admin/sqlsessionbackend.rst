SQL session backend
===================

SQL session backend can be used with many SQL databases such as:

-  `MariaDB / MySQL <https://metacpan.org/pod/Apache::Session::MySQL>`__
-  `PostgreSQL <https://metacpan.org/pod/Apache::Session::Postgres>`__
-  `Oracle <https://metacpan.org/pod/Apache::Session::Oracle>`__
-  `Informix <https://metacpan.org/pod/Apache::Session::Informix>`__
-  `Sybase <https://metacpan.org/pod/Apache::Session::Sybase>`__
-  ...

Setup
-----

.. _sqlsessionbackend-prepare-the-database:

Prepare the database
~~~~~~~~~~~~~~~~~~~~

Your database must have a specific table to host sessions. Here are some
examples for main databases servers.


.. attention::

    If your database doesn't accept UTF-8 characters in
    'text' field, use 'blob' instead of 'text'.

MySQL
^^^^^

Create a database if necessary:

::

   mysqladmin create lemonldap-ng

Create sessions table:

.. code-block:: sql

   CREATE TABLE sessions (
       id char(32) not null primary key,
       a_session text
       );


.. attention::

    Change ``char(32)`` by ``varchar(64)`` if you use the
    now recommended SHA256 hash algorithm. See
    :doc:`Sessions<sessions>` for more details


.. tip::

    You can change table name ``sessions`` to whatever you want,
    just adapt the parameter ``TableName`` in module options.


.. attention::

    For a better UTF-8 support, use
    `DBD::MariaDB <https://metacpan.org/pod/DBD::MariaDB>`__ with
    Apache::Session*::MySQL instead of DBD::mysql

PostgreSQL
^^^^^^^^^^

Create user and role:

::

   su - postgres
   createuser lemonldap-ng -P

::

   Entrez le mot de passe pour le nouveau rôle : <PASSWORD>
   Entrez-le de nouveau : <PASSWORD>
   Le nouveau rôle est-il un super-utilisateur ? (o/n) n
   Le nouveau rôle doit-il être autorisé à créer des bases de données ? (o/n) n
   Le nouveau rôle doit-il être autorisé à créer de nouveaux rôles ? (o/n) n

Create database:

::

   createdb -O lemonldap-ng lemonldap-ng

Create table:

::

   psql -h 127.0.0.1 -U lemonldap-ng -W lemonldap-ng

::

   Mot de passe pour l'utilisateur lemonldap-ng :
   [...]
   lemonldap-ng=> create unlogged table sessions ( id char(32) not null primary key, a_session text );
   lemonldap-ng=> q


.. attention::

    Change ``char(32)`` by ``varchar(64)`` if you use the
    now recommended SHA256 hash algorithm. See
    :doc:`Sessions<sessions>` for more details

Manager
~~~~~~~

Go in the Manager and set the session module (for example
`Apache::Session::Postgres <https://metacpan.org/pod/Apache::Session::Postgres>`__
for PostgreSQL) in ``General parameters`` » ``Sessions`` »
``Session storage`` » ``Apache::Session module`` and add the following
parameters (case sensitive):

=================== ================================================= ====================================
Required parameters
----------------------------------------------------------------------------------------------------------
Name                Comment                                           Example
=================== ================================================= ====================================
**DataSource**      The `DBI <https://metacpan.org/pod/DBI>`__ string dbi:Pg:dbname=sessions;host=10.2.3.1
**UserName**        The database username                             lemonldap-ng
**Password**        The database password                             mysuperpassword
**Commit**          Required for PostgreSQL                           1
**TableName**       *(Optional)* Name of the table                    sessions
=================== ================================================= ====================================

You must read the man page corresponding to your database
(`Apache::Session::MySQL <https://metacpan.org/pod/Apache::Session::MySQL>`__,
...) to learn more about parameters. You must also install the database
connector (https://metacpan.org/pod/DBD::Oracle,
`DBD::Pg <https://metacpan.org/pod/DBD::Pg>`__,...)


.. attention::

    For MySQL, you need to set additional parameters:

    -  LockDataSource
    -  LockUserName
    -  LockPassword




.. tip::

    For better performances, you can use specific
    :doc:`browseable session backend<browseablesessionbackend>`.

    Learn more at
    :ref:`how to increase Data Base performances<performances-apachesession-performances>`.


UTF8 support
^^^^^^^^^^^^

If you may store some non-ASCII characters, you must add the parameter
corresponding to your database.

========== ================= =====
Database   Parameter name    Value
========== ================= =====
MySQL      mysql_enable_utf8 1
PostgreSQL pg_enable_utf8    1
SQLite     sqlite_unicode    1
========== ================= =====

Security
--------

Restrict network access to the database.

You can also use different user/password for your servers by overriding
parameters ``globalStorage`` and ``globalStorageOptions`` in
lemonldap-ng.ini file.
