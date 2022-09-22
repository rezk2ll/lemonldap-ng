Sessions
========

LL::NG rely on a session mechanism with the session ID as a shared
secret between the user (in :doc:`SSO cookie<ssocookie>`) and the
:ref:`session database<start-sessions-database>`.

To configure sessions, go in Manager, ``General Parameters`` »
``Sessions``:

-  **Store user password in session data**: see
   :doc:`password store documentation<passwordstore>`
-  **Display session identifier**: should the session ID be displayed in the manager's session explorer. The session ID is a sensitive information that should only be shown to highly trusted administrators
-  **Sessions timeout**: maximum lifetime of a session. Old sessions are
   deleted by a cron script
-  **Sessions activity timeout**: maximum inactivity duration
-  **Sessions update interval**: minimum interval used to update session
   when activity timeout is set


.. danger::

    Session activity timeout requires Handlers to have a write
    access to sessions database.

-  **Opening conditions**: rules which are evaluated before granting
   session, see :doc:`Grant Session plugin documentation<grantsession>`
-  **Sessions Storage**: you can define here which session backend to
   use, with the backend options. See
   :ref:`sessions database configuration<start-sessions-database>` to
   know which modules you can use. Here are some global options that you
   can use with all sessions backends:

   -  **generateModule**: allows one to override the default module that
      generates sessions identifiers. For security reasons, we recommend
      to use
      Lemonldap::NG::Common::Apache::Session::Generate::SHA256
   -  **IDLength**: length of sessions identifiers. Max is 32 for MD5
      and 64 for SHA256

-  **Multiple sessions**, you can restrict the number of open sessions:

   -  **One session per user**: when a user logs in, all their previous
      sessions are removed
   -  **One IP address per user**: when a user logs in, all their
      previous sessions on a different IP address are removed
   -  **One user per IP address**: when a user logs in, all sessions
      that belong to a different user on that IP address are removed
   -  **Display deleted sessions**: display deleted sessions on
      authentication phase.
   -  **Display other sessions**: display other sessions on
      authentication phase, with a link to delete them.

-  **Persistent sessions**: are used for storing users log in history,
   2F devices, OIDCConsents and so on. Heavy organizations may have to
   disable persistent sessions storage to avoid too many database
   tuples.

   -  **Disable storage**: do not store user persitent sessions


.. attention::

    Note that since HTTP protocol is not connected,
    restrictions are not applied to the new session. The oldest are
    destroyed.

Command-line tools
==================

.. versionadded:: 2.0.9

You can use the ``lemonldap-ng-sessions`` tool to search, update or delete sessions. See a few examples in :ref:`the examples page <cli-sessions>`

.. deprecated:: 2.0.10

-  LLNG Portal provides a simple tool to delete a session:
   ``llngDeleteSession``. To use it, simply give it the user identifier
   *(wildcard are authorizated)*:

.. code-block:: shell

   # Delete all sessions opened by user "dwho"
   $ llngDeleteSession dwho
   # Delete all sessions opened by user starting with "dh"
   $ llngDeleteSession dh*
   # Delete all sessions:
   $ llngDeleteSession *

