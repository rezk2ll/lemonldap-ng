SOAP session backend
====================

LL::NG portal provides SOAP end points for sessions management:

-  **sessions/**: read only access to sessions (enough for distant
   Handlers)
-  **adminSessions/**: read/write access to sessions (required for
   distant Portal, distant Manager or distant Handlers which modify
   sessions)

This session backend can be used to share sessions stored in a
non-network backend (like
:doc:`file session backend<filesessionbackend>`) or in a network backend
protected with a firewall that only accepts HTTP flows.

Most of the time, SOAP session backend is used by Handlers installed on
external servers.

To configure it, SOAP session backend will be set through Manager in
global configuration (used by all Hanlders), and the real session
backend will be configured for local components in lemonldap-ng.ini.

Setup
-----

Manager
~~~~~~~

First, active SOAP in ``General parameters`` » ``Advanced parameters`` »
``SOAP``.

Then, set ``Lemonldap::NG::Common::Apache::Session::SOAP`` in
``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

=================== ============================== ===========================================
Required parameters
----------------------------------------------------------------------------------------------
Name                Comment                        Example
=================== ============================== ===========================================
**proxy**           URL of sessions SOAP end point http://auth.example.com/index.fcgi/sessions
=================== ============================== ===========================================


.. tip::

    Use /adminSessions if the Handler need to modify the session,
    for example if you configured an idle timeout.

By default, only few sessions keys are shared by SOAP
(authenticationLevel, groups, ipAddr, \_startTime, \_utime, \_lastSeen,
\_session_id), you need to define which other keys you want to share in
``General parameters`` » ``Plugins`` » ``Portal servers`` »
``SOAP/REST exported attributes``.

You must start with ``+`` to keep default keys, else they will not be
shared. For example:

::

   + uid cn mail

To share only the listed attributes:

::

   _utime _session_id uid cn mail

Apache
~~~~~~

Sessions SOAP end points access must be allowed in Apache portal
configuration (for example, access by IP range):

.. code-block:: apache

   # SOAP functions for sessions management (disabled by default)
   <Location /index.fcgi/adminSessions>
       Require ip 192.168.2.0/24
   </Location>

   # SOAP functions for sessions access (disabled by default)
   <Location /index.fcgi/sessions>
       Require ip 192.168.2.0/24
   </Location>

Real session backend
~~~~~~~~~~~~~~~~~~~~

Real session backend will be configured in ``lemonldap-ng.ini``, in
``portal`` section (the portal hosts the SOAP service for sessions, and
will do the link between SOAP requests and real sessions).

For example, if real sessions are stored in
:doc:`files<filesessionbackend>`:

.. code-block:: ini

   [portal]
   globalStorage = Apache::Session::File
   globalStorageOptions = { 'Directory' => '/var/lib/lemonldap-ng/sessions/', 'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/', }


.. tip::

    If your sessions explorer is on the same server that the
    portal, either use the **adminSessions** end point in Manager
    configuration, or override the ``globalStorage`` and
    ``globalStorageOptions`` parameters in section all (and not portal) of
    ``lemonldap-ng.ini``.
