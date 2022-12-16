Databases
=========

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

Drivers
~~~~~~~

LL::NG can use a lot of databases as authentication, users and password
backend:

-  MariaDB/MySQL
-  PostGreSQL
-  Oracle
-  ...

Indeed, any `Perl DBD
driver <http://search.cpan.org/search?query=DBD%3A%3A&mode=module>`__
can be used.

Schema
~~~~~~

LL::NG can use two tables:

-  Authentication table: where login and password are stored
-  User table: where user data are stored (mail, name, etc.)


.. tip::

    Authentication table and user table can be the same.

The password can be in plain text, or encoded with a SQL method (for example
``SHA``, ``SHA1``, ``MD5`` or any method valid on database side).

Example 1: two tables
^^^^^^^^^^^^^^^^^^^^^

Authentication table
''''''''''''''''''''

== ========== ========================================
id login      password
== ========== ========================================
0  coudot     1f777a6581e478499f4284e54fe2d4a4e513dfff
1  xguimard   a15a18c8bb17e6f67886a9af1898c018b9f5a072
2  tchemineau 1f777a6581e478499f4284e54fe2d4a4e513dfff
== ========== ========================================

User table
''''''''''

== ========== ================ ======================
id user       name             mail
== ========== ================ ======================
0  coudot     Clément OUDOT    coudot@example.com
1  tchemineau Thomas CHEMINEAU tchemineau@example.com
2  xguimard   Xavier GUIMARD   xguimard@example.com
== ========== ================ ======================

Example 2: single table
^^^^^^^^^^^^^^^^^^^^^^^

== ========== ======================================== ================ ======================
id user       password                                 name             mail
== ========== ======================================== ================ ======================
0  coudot     1f777a6581e478499f4284e54fe2d4a4e513dfff Clément OUDOT    coudot@example.com
1  tchemineau 1f777a6581e478499f4284e54fe2d4a4e513dfff Thomas CHEMINEAU tchemineau@example.com
2  xguimard   a15a18c8bb17e6f67886a9af1898c018b9f5a072 Xavier GUIMARD   xguimard@example.com
== ========== ======================================== ================ ======================

SQL
~~~

LL::NG will operate some SQL queries:

-  Authentication: select row in authentication table matching user and
   password
-  Search user: select row in user table matching user
-  Change password: update password column in authentication table
   matching user

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Database (DBI) for authentication, users and/or password
modules.

Authentication level
~~~~~~~~~~~~~~~~~~~~

The authentication level given to users authenticated with this module.


.. attention::

    As DBI is a login/password based module, the
    authentication level can be:

    -  increased (+1) if portal is protected by SSL (HTTPS)
    -  decreased (-1) if the portal autocompletion is allowed (see
       :doc:`portal customization<portalcustom>`)



Exported variables
~~~~~~~~~~~~~~~~~~

List of columns to query to fill user session. See also
:doc:`exported variables configuration<exportedvars>`.

Connection
~~~~~~~~~~


.. tip::

    Connection settings can be configured differently for
    authentication process and user process. This allows one to use
    different databases for these process. By default, if user process
    connection settings are empty, authentication process connection
    settings will be used.

-  **Chain**: DBI chain, including database driver name and database
   name (for example: dbi:mysql:database=lemonldapng;host=localhost).
-  **User**: Connection user
-  **Password**: Connection password

.. _schema-1:

Schema
~~~~~~

-  **Authentication table**: authentication table name
-  **User table**: user table name
-  **Login field name**: name of authentication table column hosting
   login
-  **Password field name**: name of authentication table column hosting
   password
-  **Mail field name**: name of authentication table column hosting mail
   (for password reset)
-  **Login field name in user table**: name of user table column hosting
   login

Password
~~~~~~~~

-  **Hash schema**: SQL method for hashing password. Can be left blank
   for plain text passwords. The method will be forced to uppercase in
   SQL statement.
-  **Dynamic hash activation**: Activate dynamic hashing. With dynamic
   hashing, the hash scheme is recovered from the user password in the
   database during authentication.
-  **Supported non-salted schemes**: List of whitespace separated hash
   schemes. Every hash scheme MUST match a non-salted hash function in
   the database. LemonLDAP::NG relies on this hashing function for
   computing user password hashes. These hashes MUST NOT be salted (no
   random data used in conjunction with the password).
-  **Supported salted schemes**: List of whitespace separated salted
   hash schemes, of the form "**s**\ scheme", where scheme can match a
   non-salted hash function in the database. LemonLDAP::NG relies on
   this hashing function for computing user password hashes.
   Additional schemes for unix passwords are unixcrypt1 (MD5),
   unixcrypt5 (SHA256), unixcrypt6 (SHA512).
   For using unix passwords you need to create a database function function
   called `unixcrypth`. See example for details.
-  **Dynamic hash scheme for new passwords**: LemonLDAP::NG is able to
   store new passwords in the database (while modifying or
   reinitializing the password). You can choose a salted or non salted
   dynamic hashed password. The value must be an element of "Supported
   non-salted schemes" or "Supported salted schemes".


.. attention::

    The SQL function MUST have hexadecimal values as input
    AND output


.. tip::

    Here is an example for creating a postgreSQL SHA256 function.
    1. Install postgresql-contrib. 2. Activate extension:
    ``CREATE EXTENSION pgcrypto;`` 3. Create the hash function:

    ::

       CREATE OR REPLACE FUNCTION sha256(varchar) returns text AS $$
       SELECT encode(digest(decode($1, 'hex'), 'sha256'), 'hex')
       $$ LANGUAGE SQL STRICT IMMUTABLE;

    Another example to create an unix hash function in MariaDB.
    Caution: The `encrypt` function is only avaible if the database
    is running on a unix based OS.
    1. Use the lemonldapng database. 2. Create the unix hash function:
    
    ::
    
       CREATE FUNCTION `unixcrypth`(`pwd` VARCHAR(255), `unix_salt`
       VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4
       NOT DETERMINISTIC NO SQL SQL SECURITY INVOKER RETURN
       HEX( ENCRYPT( UNHEX(pwd), UNHEX(unix_salt) ) );


