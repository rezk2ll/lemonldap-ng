PgJSON session backend
======================

This backend is the recommended one for production installations of LemonLDAP::NG.

Prerequisites
-------------

First, make sure you have installed the ``DBD::Pg`` perl module.

On Debian-based distributions ::

   apt install libdbd-pg-perl libapache-session-browseable-perl

On Fedora-based distributions ::

   yum install 'perl(DBD::Pg)' 'perl(Apache::Session::Browseable)'


The minimum required version of PostgreSQL is 9.3 with `support for JSON column types <https://www.postgresql.org/docs/9.3/functions-json.html>`__

Make sure you are using at least version 1.2.9 of ``Apache::Session::Browseable``, this might require installing it from Debian Backports or CPAN.

Create database schema
----------------------

You can find the database schema in ``/usr/share/lemonldap-ng/ressources/sessions.pg.sql``.

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
