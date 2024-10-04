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

You can find the database schema in ``/usr/share/lemonldap-ng/ressources/sessions.my.sql``.

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
