REST session backend
====================

Session <type> can be 'global' for SSO sessions or 'persistent' for
persistent sessions.

LL::NG Portal provides REST end points for sessions management:

-  GET /sessions/<type>/<session-id> : get session data
-  GET /sessions/<type>/<session-id>/<key> : get a session key value
-  GET /sessions/<type>/<session-id>/[k1,k2] : get some keys value
-  POST /sessions/<type> : create a session
-  PUT /sessions/<type>/<session-id> : update some keys
-  DELETE /sessions/<type>/<session-id> : delete a session

Sessions for connected users (used by :doc:`LLNG Proxy<authproxy>`):

-  GET /session/my/<type> : get session data
-  GET /session/my/<type>/key : get session key
-  DELETE /session/my : ask for logout
-  DELETE /sessions/my : ask for global logout (if GlobalLogout plugin is on)

Services for connected users (always enabled):

-  GET /mysession/?authorizationfor=<base64-encoded-url> : ask if an url
   is authorized
-  GET /mysession/?whoami       : get "my" uid
-  PUT /mysession/<type>        : update some persistent data (restricted)
-  DELETE /mysession/<type>/key : delete key in data (restricted)
-  GET    /myapplications       : get "my" appplications list

This session backend can be used to share sessions stored in a
non-network backend (like
:doc:`file session backend<filesessionbackend>`) or in a network backend
protected with a firewall that only accepts HTTP flows.

Most of the time, REST session backend is used by Handlers deployed on
external servers.

To configure it, REST session backend will be set through Manager in
global configuration (used by all Handlers), and the real session
backend will be configured for local components in lemonldap-ng.ini.

Setup
-----

Manager
~~~~~~~

First, activate REST in ``General parameters`` » ``Plugins`` »
``Portal servers`` » ``REST session server``.

Then, set ``Lemonldap::NG::Common::Apache::Session::REST`` in
``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

=================== ======================================== ==================================================
Required parameters
---------------------------------------------------------------------------------------------------------------
Name                Comment                                  Example
=================== ======================================== ==================================================
**baseUrl**         URL of sessions REST end point           http://auth.example.com/index.fcgi/sessions/global
=================== ======================================== ==================================================

=================== ======================================== ==================================================
Optional parameters
---------------------------------------------------------------------------------------------------------------
Name                Comment                                  Example
=================== ======================================== ==================================================
**user**            Username to use for auth basic mechanism
**password**        Password to use for auth basic mechanism
=================== ======================================== ==================================================

`user` and `password` parameters are only used if the entry point `index.fcgi/sessions/global`
is protected by a basic authentication. Thus, handlers will make requests to the Portal
using these parameters.


.. attention::

    By default, user password and other secret keys are
    hidden by LL::NG REST server. You can force REST server to export their
    real values by selecting "Export secret attributes in REST" in the
    Manager. This less secure option is disabled by default.

Apache
~~~~~~

Sessions REST end points access must be allowed in Apache portal
configuration (for example, access by IP range):

.. code-block:: apache

   # REST/SOAP functions for sessions access (disabled by default)
   <Location /index.fcgi/sessions>
       Require ip 192.168.2.0/24
   </Location>

Nginx
~~~~~

Sessions REST end points access must be allowed in Nginx portal
configuration (for example, access by IP range):

.. code-block:: nginx

    # REST/SOAP functions for sessions access (disabled by default)
    location ~ ^/index.psgi/sessions {
      fastcgi_pass llng_portal_upstream;
      allow 192.168.2.0/24
      deny all;
    }

Real session backend
~~~~~~~~~~~~~~~~~~~~

Real session backend will be configured in ``lemonldap-ng.ini``, in
``portal`` section (the portal hosts the REST service for sessions, and
will do the link between REST requests and real sessions).

For example, if real sessions are stored in
:doc:`files<filesessionbackend>`:

.. code-block:: ini

   [portal]
   globalStorage = Apache::Session::File
   globalStorageOptions = { 'Directory' => '/var/lib/lemonldap-ng/sessions/', 'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/', }


.. tip::

    Session explorer and "single session" features can't be used
    using this backend. Session explorer and portal must be launched with
    real backend.

By default, only few sessions keys are shared by REST
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

   authenticationLevel groups ipAddr _startTime _utime _lastSeen _session_id uid cn mail

