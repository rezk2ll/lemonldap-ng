File session backend
====================

File session backend is the more simple session database. Sessions are
stored as files in a single directory. Lock files are stored in another
directory. It can not be used to share sessions between different
servers except if you share directories (with NFS,...) or if you use
:doc:`SOAP proxy<soapsessionbackend>`.

Setup
-----

In the manager: set
"`Apache::Session::File <http://search.cpan.org/perldoc?Apache::Session::File>`__"
in "General parameters » Sessions » Session storage » Apache::Session
module" and add the following parameters (case sensitive):

=================== ============================== ===================================
Required parameters
=================== ============================== ===================================
Name                Comment                        Example
**Directory**       The path to the main directory /var/lib/lemonldap-ng/sessions
**LockDirectory**   The path to the lock directory /var/lib/lemonldap-ng/sessions/lock
=================== ============================== ===================================

Security
--------

Restrict access to the directories only to the Apache server. Example:

.. code-block:: shell

   chmod 750 /var/lib/lemonldap-ng/sessions /var/lib/lemonldap-ng/sessions/lock
   chown www-data:www-data /var/lib/lemonldap-ng/sessions /var/lib/lemonldap-ng/sessions/lock

