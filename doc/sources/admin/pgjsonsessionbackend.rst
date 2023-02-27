PgJSON session backend
======================

This backend is the recommended one for production installations of LemonLDAP::NG.

Prerequisites
-------------

First, make sure you have installed the ``DBD::Pg`` perl module.

On Debian-based distributions ::

   apt install libdbd-pg-perl

On Fedora-based distributions ::

   yum install 'perl(DBD::Pg)'


The minimum required version of PostgreSQL is 9.3 with `support for JSON column types <https://www.postgresql.org/docs/9.3/functions-json.html>`__

Make sure you are using at least version 1.2.9 of ``Apache::Session::Browseable``, this might require installing it from Debian Backports or CPAN.

Create database schema
----------------------

Create the following tables. You may skip the session types you are not going to use, but you need at least ``sessions`` and ``psessions``

::

   CREATE TABLE sessions (
       id varchar(64) not null primary key,
       a_session jsonb
   );

   CREATE INDEX i_s__whatToTrace     ON sessions ((a_session ->> '_whatToTrace'));
   CREATE INDEX i_s__session_kind    ON sessions ((a_session ->> '_session_kind'));
   CREATE INDEX i_s__utime           ON sessions ((cast (a_session ->> '_utime' as bigint)));
   CREATE INDEX i_s_ipAddr           ON sessions ((a_session ->> 'ipAddr'));
   CREATE INDEX i_s__httpSessionType ON sessions ((a_session ->> '_httpSessionType'));
   CREATE INDEX i_s_user             ON sessions ((a_session ->> 'user'));


   CREATE TABLE psessions (
       id varchar(64) not null primary key,
       a_session jsonb
   );
   CREATE INDEX i_p__session_kind    ON psessions ((a_session ->> '_session_kind'));
   CREATE INDEX i_p__httpSessionType ON psessions ((a_session ->> '_httpSessionType'));
   CREATE INDEX i_p__session_uid     ON psessions ((a_session ->> '_session_uid'));
   CREATE INDEX i_p_ipAddr           ON psessions ((a_session ->> 'ipAddr'));
   CREATE INDEX i_p__whatToTrace     ON psessions ((a_session ->> '_whatToTrace'));


   CREATE TABLE samlsessions (
       id varchar(64) not null primary key,
       a_session jsonb
   );
   CREATE INDEX i_a__session_kind ON samlsessions ((a_session ->> '_session_kind'));
   CREATE INDEX i_a__utime        ON samlsessions ((cast(a_session ->> '_utime' as bigint)));
   CREATE INDEX i_a_ProxyID       ON samlsessions ((a_session ->> 'ProxyID'));
   CREATE INDEX i_a__nameID       ON samlsessions ((a_session ->> '_nameID'));
   CREATE INDEX i_a__assert_id    ON samlsessions ((a_session ->> '_assert_id'));
   CREATE INDEX i_a__art_id       ON samlsessions ((a_session ->> '_art_id'));
   CREATE INDEX i_a__saml_id      ON samlsessions ((a_session ->> '_saml_id'));

   CREATE TABLE oidcsessions (
       id varchar(64) not null primary key,
       a_session jsonb
   );
   CREATE INDEX i_o__session_kind ON oidcsessions ((a_session ->> '_session_kind'));
   CREATE INDEX i_o__utime        ON oidcsessions ((cast(a_session ->> '_utime' as bigint )));

   CREATE TABLE cassessions (
       id varchar(64) not null primary key,
       a_session jsonb
   );
   CREATE INDEX i_c__session_kind ON cassessions ((a_session ->> '_session_kind'));
   CREATE INDEX i_c__utime        ON cassessions ((cast(a_session ->> '_utime' as bigint)));
   CREATE INDEX i_c__cas_id       ON cassessions ((a_session ->> '_cas_id'));
   CREATE INDEX i_c_pgtIou        ON cassessions ((a_session ->> 'pgtIou'));

LemonLDAP::NG configuration
---------------------------

Go in the Manager and set the session module to ``Apache::Session::Browseable::PgJSON`` for each session type you intend to use:

* ``General parameters`` » ``Sessions`` » ``Session storage`` » ``Apache::Session module``
* ``General parameters`` » ``Sessions`` » ``Persistent sessions`` » ``Apache::Session module``
* ``CAS Service`` » ``CAS sessions module name``
* ``OpenID Connect Service`` » ``Sessions`` » ``Sessions module name``
* ``SAML2 Service`` » ``Advanced`` » ``SAML sessions module name``

Then, set the following module options:

=================== ================================================= =============================================================
Required parameters
=================== ================================================= =============================================================
Name                Comment                                           Example
**DataSource**      The `DBI <https://metacpan.org/pod/DBI>`__ string dbi:Pg:database=lemonldap-ng
**UserName**        The database username                             lemonldapng
**Password**        The database password                             mysuperpassword
**TableName**       Table name (optional)                             sessions
**Commit**          1                                                 This setting is mandatory for PostgreSQL to work
=================== ================================================= =============================================================


.. tip::

    Unlike other browseable modules, Pg::JSON does not require an ``Index`` parameter
