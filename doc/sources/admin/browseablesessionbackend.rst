Browseable session backend
==========================

Presentation
------------

Browseable session backend
(`Apache::Session::Browseable <https://metacpan.org/pod/Apache::Session::Browseable>`__)
works exactly like Apache::Session::\* corresponding module but add
index that increase :ref:`session explorer<session-explorer>` and
:ref:`session restrictions<session-restrictions>` performances.

If you use features like SAML (authentication and issuer), CAS (issuer)
and password reset self-service, you also need to index some fields.


.. note::

    Without index, LL::NG will have to retrieve all sessions stored in
    backend and parse them to find the needed sessions. With index, LL::NG
    wil be able to get only wanted sessions from the backend.

The following table list fields to index depending on the feature you
want to increase performance:

====================================== ============= ===================================================================
Feature                                Session Type  Fields to index
====================================== ============= ===================================================================
Database cleanup *(cron)*              All           \_session_kind \_utime
Session explorer                       Global        \_session_kind ipAddr \_httpSessionType *WHATTOTRACE*
Session explorer                       Persistent    \_session_kind \_session_uid ipAddr \_httpSessionType *WHATTOTRACE*
Session restrictions                   Global        \_session_kind ipAddr *WHATTOTRACE*
Password reset by email                Global        user
SAML Session                           SAML          \_saml_id ProxyID \_nameID \_assert_id \_art_id
====================================== ============= ===================================================================

See Apache::Session::Browseable man page to see how use indexes.


.. attention::

    \ *WHATTOTRACE* must be replaced by the attribute or
    macro configured in the What To Trace parameter (REMOTE_USER). By
    default: **\_whatToTrace**\


.. tip::

    It is advised to use separate session backends for standard
    sessions, SAML sessions and CAS sessions, in order to manage index
    separately.


.. note::

    Documentation below explains how set index on ipAddr and
    \_whatToTrace. Adapt it to configure the index you need.

Browseable NoSQL
----------------

You can use Redis and set up the database like explained in
:doc:`Redis session backend<nosqlsessionbackend>`.

You then just have to add the ``Index`` parameter in
``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` :

=================== ============ ====================
Required parameters
=================== ============ ====================
Name                Comment      Example
**server**          Redis server 127.0.0.1:6379
**Index**           Index        \_whatToTrace ipAddr
=================== ============ ====================

Browseable SQL
--------------


.. note::

    This documentation concerns PostgreSQL. Some adaptations are
    needed with other databases. When using
    Apache::Session::Browseable::Postgres, it
    is strongly recommended to use version 1.3.1 at least. See `bug
    1732 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1732>`__.

Prepare database
~~~~~~~~~~~~~~~~

Database must be prepared exactly like in
:ref:`SQL session backend<sqlsessionbackend-prepare-the-database>`
except that a field must be added for each data to index.


.. attention::

    Data written to UNLOGGED tables is not written to the
    WAL, which makes them considerably faster than ordinary tables. However,
    they are not crash-safe: an unlogged table is automatically truncated
    after a crash or unclean shutdown. The contents of an unlogged table are
    also not replicated to standby servers. Any indexes created on an
    unlogged table are automatically unlogged as well.

Apache::Session::Browseable::Postgres
example:

::

   CREATE UNLOGGED TABLE sessions (
       id varchar(64) not null primary key,
       a_session text,
       _whatToTrace text,
       _session_kind text,
       _utime bigint,
       _httpSessionType text,
       ipAddr text
   );
   CREATE INDEX uid1 ON sessions USING BTREE (_whatToTrace text_pattern_ops);
   CREATE INDEX s1   ON sessions (_session_kind);
   CREATE INDEX u1   ON sessions (_utime);
   CREATE INDEX ip1  ON sessions USING BTREE (ipAddr);
   CREATE INDEX h1   ON sessions (_httpSessionType);


.. attention::

    For Session Explorer and one-off sessions, it is
    recommended to use BTREE or any index method that indexes partial
    content.

"id" fieds is set to ``varchar(64)`` (instead of char(32)) to use the
now recommended SHA256 hash algorithm. See
:doc:`Sessions<sessions>` for more details.


.. tip::

    With new
    Apache::Session::Browseable::PgHstore
    and **PgJSON**, you don't need to declare indexes in ``CREATE TABLE``
    since "json" and "hstore" type are browseable. You should anyway add
    some indexes *(see manpage)*.

Manager
~~~~~~~

Go in the Manager and set the session module
(`Apache::Session::Browseable::MySQL <https://metacpan.org/pod/Apache::Session::Browseable::MySQL>`__
for MySQL) in ``General parameters`` » ``Sessions`` »
``Session storage`` » ``Apache::Session module`` and add the following
parameters (case sensitive):

=================== ================================================= =============================================================
Required parameters
=================== ================================================= =============================================================
Name                Comment                                           Example
**DataSource**      The `DBI <https://metacpan.org/pod/DBI>`__ string dbi:Pg:database=lemonldap-ng
**UserName**        The database username                             lemonldapng
**Password**        The database password                             mysuperpassword
**Index**           Index                                             \_whatToTrace ipAddr \_session_kind \_utime \_httpSessionType
**TableName**       Table name (optional)                             sessions
=================== ================================================= =============================================================


.. tip::

    Apache::Session::Browseable::MySQL doesn't use locks so performances are
    keeped.

    For databases like PostgreSQL, don't forget to add "Commit" with a value
    of 1

Browseable LDAP
---------------

Go in the Manager and set the session module to
``Apache::Session::Browseable::LDAP``. Then configure the options like
in :doc:`LDAP session backend<ldapsessionbackend>`.

You need to add the ``Index`` field and can also configure the
``ldapAttributeIndex`` field to set the attribute name where index
values will be stored.

======================== ================================= ===============================
Required parameters
======================== ================================= ===============================
Name                     Comment                           Example
**ldapServer**           URI of the server                 ldap://localhost
**ldapConfBase**         DN of sessions branch             ou=sessions,dc=example,dc=com
**ldapBindDN**           Connection login                  cn=admin,dc=example,dc=password
**ldapBindPassword**     Connection password               secret
**Index**                Index list                        \_whatToTrace ipAddr
Optional parameters
Name                     Comment                           Default value
**ldapObjectClass**      Objectclass of the entry          applicationProcess
**ldapAttributeId**      Attribute storing session ID      cn
**ldapAttributeContent** Attribute storing session content description
**ldapAttributeIndex**   Attribute storing index           ou
**ldapVerify**           Perform certificate validation    require (use none to disable)
**ldapCAFile**           Path of CA file bundle            (system CA bundle)
**ldapCAPath**           Perform CA directory              (system CA bundle)
======================== ================================= ===============================

Security
--------

Restrict network access to the backend.

You can also use different user/password for your servers by overriding
parameters ``globalStorage`` and ``globalStorageOptions`` in
lemonldap-ng.ini file.

Performances
------------

Here are some recommended configurations:

**Browseable::Postgres**:

::

   CREATE UNLOGGED TABLE sessions (
       id varchar(64) not null primary key,
       a_session text,
       _whatToTrace text,
       _session_kind text,
       _utime bigint,
       _httpSessionType text,
       ipAddr text
   );
   CREATE INDEX uid1 ON sessions USING BTREE (_whatToTrace text_pattern_ops);
   CREATE INDEX s1   ON sessions (_session_kind);
   CREATE INDEX u1   ON sessions (_utime);
   CREATE INDEX ip1  ON sessions USING BTREE (ipAddr);
   CREATE INDEX h1   ON sessions (_httpSessionType);

**Browseable::MySQL**:

::

   CREATE TABLE sessions (
       id varchar(64) not null primary key,
       a_session text,
       _whatToTrace varchar(64),
       _session_kind varchar(15),
       user text,
       _utime bigint,
       ipAddr varchar(64)
   );
   CREATE INDEX uid1 ON sessions (_whatToTrace) USING BTREE;
   CREATE INDEX _s1 ON sessions (_session_kind);
   CREATE INDEX _u1 ON sessions (_utime);
   CREATE INDEX ip1 ON sessions (ipAddr) USING BTREE;

