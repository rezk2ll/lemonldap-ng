Cassandra configuration backend
==========================================

`Cassandra <https://cassandra.apache.org/>`__ is a NoSQL database that can be
used both for storing configuration and
:doc:`sessions<cassandrasessionbackend>`. You need to install Perl DBD::Cassandra
module to be able to use this backend. This driver emulates a SQL connector.

See :doc:`how to change configuration backend<changeconfbackend>` to
change your configuration database.

Configuration
-------------

Prepare the database
~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   CREATE KEYSPACE IF NOT EXISTS llng
    WITH REPLICATION = {
     'class' : 'SimpleStrategy',
     'replication_factor' : 1
    };
   DROP TABLE IF EXISTS llng.lmconfig;
   CREATE TABLE llng.lmconfig (
     cfgnum int PRIMARY KEY,
     conf text
   );

Connection settings
~~~~~~~~~~~~~~~~~~~

Change configuration settings in ``/etc/lemonldap-ng/lemonldap-ng.ini``
file (section configuration):

.. code-block:: ini

   [configuration]
   type = CDBI
   dbiChain    = DBI:Cassandra:host=localhost;keyspace=llng
   dbiUser     = lemonldaprw
   dbiPassword = mypassword
   ; optional
   dbiTable    = mytablename

