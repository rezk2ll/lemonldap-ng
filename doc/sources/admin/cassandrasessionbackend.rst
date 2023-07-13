Cassandra session backend
====================================

`Apache::Session::Browseable::Cassandra <https://metacpan.org/pod/Apache::Session::Browseable::Cassandra>`__
is a `Cassandra <https://cassandra.apache.org/>`__ session backend.

Setup
-----

Install and launch a `Cassandra <https://cassandra.apache.org/>`__ server.
Install
`Apache::Session::Browseable <http://search.cpan.org/perldoc?Apache::Session::Browseable>`__
Perl module (version ⩾ 1.3.12 required).

Prepare the database
~~~~~~~~~~~~~~~~~~~~

Your database must have a specific table to host sessions. Here are some
examples for main databases servers.

.. code-block::

   CREATE KEYSPACE IF NOT EXISTS llng
    WITH REPLICATION = {
     'class' : 'SimpleStrategy',
     'replication_factor' : 1
    };
    DROP TABLE IF EXISTS llng.sessions;
    CREATE TABLE llng.sessions (
      id text PRIMARY KEY,
      a_session text,
      # Indexed fields
      _whatToTrace text,
      _session_kind text,
      _utime text,
      ipAddr text
    );
    CREATE INDEX ON llng.sessions (_whatToTrace);
    CREATE INDEX ON llng.sessions (_session_kind);
    CREATE INDEX ON llng.sessions (_utime);
    CREATE INDEX ON llng.sessions (ipAddr);

Manager
~~~~~~~

In the manager: set
`Apache::Session::Browseable::Cassandra <http://search.cpan.org/perldoc?Apache::Session::Browseable::Cassandra>`__
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

=================== ================================================= =========================================
Name                Comment                                           Example
=================== ================================================= =========================================
**DataSource**      The `DBI <https://metacpan.org/pod/DBI>`__ string dbi:Cassandra:host=10.2.3.1;keyspace=llng
**UserName**        The database username                             lemonldap-ng
**Password**        The database password                             mysuperpassword
**TableName**       *(Optional)* Name of the table                    sessions
**Index**           Indexed fields                                    _whatToTrace _session_kind _utime ipAddr
=================== ================================================= =========================================

Security
--------

Restrict network access to the Cassandra server. For remote servers, you
can use :doc:`SOAP session backend<soapsessionbackend>` in cunjunction
to increase security for remote server that access through an unsecure
network.
