How to change session backend
=============================

LemonLDAP::NG provides a script to change session backend. This script
will help you transfer existing persistent sessions (or offline
sessions) when migrating from one backend to another, or when adding
indexes to a
:doc:`browseable session backend</browseablesessionbackend>`. It is
available in LemonLDAP::NG utilities directory (``convertSessions``).

How it works
------------

The ``convertSessions`` utility requires you to create a job
configuration file with the following content:

::

   # This example migrates psessions from the default File backend to a PostgreSQL database
   [sessions_from]
   storageModule = Apache::Session::File
   storageModuleOptions = {    \
         'Directory' => '/var/lib/lemonldap-ng/psessions',     \
         'LockDirectory' => '/var/lib/lemonldap-ng/psessions/lock', \
   }
   # Only convert some session types
   # sessionKind = Persistent, SSO

   [sessions_to]
   storageModule = Apache::Session::Browseable::Postgres
   storageModuleOptions = {    \
       'DataSource' => 'DBI:Pg:database=lemonldapdb;host=pg.example.com', \
       'UserName' => 'lemonldaplogin', \
       'Password' => 'lemonldappw', \
       'Commit' => 1, \
       'Index' => 'ipAddr _whatToTrace user', \
       'TableName' => 'psessions', \
   }

Invocation
----------

``convertSessions -c job.ini``

Options:

-  ``-c``: job configuration file (mandatory)
-  ``-r oldkey=newkey``: rename session keys during conversion (optional, can be given multiple times)
-  ``-x key``: remove session keys during conversion (optional, can be given multiple times)
-  ``-i``: ignore errors. By default errors will stop the script
   execution
-  ``-d``: print debugging output
