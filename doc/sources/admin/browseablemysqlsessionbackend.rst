Browseable MySQL session backend
================================

Prerequisites
-------------

First, make sure you have installed the ``DBD::mysql`` perl module.

On Debian-based distributions ::

   apt install libdbd-mysql-perl

On Fedora-based distributions ::

   yum install 'perl(DBD::mysql)'

Create database schema
----------------------

Create the following tables. You may skip the session types you are not going to use, but you need at least ``sessions`` and ``psessions``

::

   CREATE TABLE sessions (
       id varchar(64) not null primary key,
       a_session text,
       _whatToTrace varchar(64),
       _session_kind varchar(15),
       ipAddr varchar(64),
       _utime bigint,
       _httpSessionType varchar(64),
       user varchar(64)
   ) DEFAULT CHARSET utf8;
   CREATE INDEX i_s__whatToTrace ON sessions (_whatToTrace);
   CREATE INDEX i_s__session_kind ON sessions (_session_kind);
   CREATE INDEX i_s__utime ON sessions (_utime);
   CREATE INDEX i_s_ipAddr ON sessions (ipAddr);
   CREATE INDEX i_s__httpSessionType ON sessions (_httpSessionType);
   CREATE INDEX i_s_user ON sessions (user);

   CREATE TABLE psessions (
       id varchar(64) not null primary key,
       a_session text,
       _session_kind varchar(15),
       _httpSessionType varchar(64),
       _whatToTrace varchar(64),
       ipAddr varchar(64),
       _session_uid varchar(64)
   )  DEFAULT CHARSET utf8;
   CREATE INDEX i_p__session_kind ON psessions (_session_kind);
   CREATE INDEX i_p__httpSessionType ON psessions (_httpSessionType);
   CREATE INDEX i_p__session_uid ON psessions (_session_uid);
   CREATE INDEX i_p_ipAddr ON psessions (ipAddr);
   CREATE INDEX i_p__whatToTrace ON psessions (_whatToTrace);

   CREATE TABLE samlsessions (
       id varchar(64) not null primary key,
       a_session text,
       _session_kind varchar(15),
       _utime bigint,
       ProxyID varchar(64),
       _nameID varchar(255),
       _assert_id varchar(64),
       _art_id varchar(64),
       _saml_id varchar(64)
   )  DEFAULT CHARSET utf8;
   CREATE INDEX i_a__session_kind ON samlsessions (_session_kind);
   CREATE INDEX i_a__utime ON samlsessions (_utime);
   CREATE INDEX i_a_ProxyID ON samlsessions (ProxyID);
   CREATE INDEX i_a__nameID ON samlsessions (_nameID);
   CREATE INDEX i_a__assert_id ON samlsessions (_assert_id);
   CREATE INDEX i_a__art_id ON samlsessions (_art_id);
   CREATE INDEX i_a__saml_id ON samlsessions (_saml_id);

   CREATE TABLE oidcsessions (
       id varchar(64) not null primary key,
       a_session text,
       _session_kind varchar(15),
       _utime bigint
   )  DEFAULT CHARSET utf8;
   CREATE INDEX i_o__session_kind ON oidcsessions (_session_kind);
   CREATE INDEX i_o__utime ON oidcsessions (_utime);


   CREATE TABLE cassessions (
       id varchar(64) not null primary key,
       a_session text,
       _session_kind varchar(15),
       _utime bigint,
       _cas_id varchar(128),
       pgtIou varchar(128)
   ) DEFAULT CHARSET utf8;
   CREATE INDEX i_c__session_kind ON cassessions (_session_kind);
   CREATE INDEX i_c__utime        ON cassessions (_utime);
   CREATE INDEX i_c__cas_id       ON cassessions (_cas_id);
   CREATE INDEX i_c_pgtIou        ON cassessions (pgtIou);

LemonLDAP::NG configuration
---------------------------

Go in the Manager and set the session module to ``Apache::Session::Browseable::MySQL`` for each session type you intend to use:

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
**DataSource**      The `DBI <https://metacpan.org/pod/DBI>`__ string dbi:mysql:database=lemonldap-ng
**UserName**        The database username                             lemonldapng
**Password**        The database password                             mysuperpassword
**TableName**       Table name (optional)                             sessions
**Index**           Fields to index                                   refer to :ref:`fieldstoindex`
=================== ================================================= =============================================================
