Radius
======

============== ===== ========
Authentication Users Password
============== ===== ========
✔
============== ===== ========

Presentation
------------

LL::NG uses `Perl
Authen::Radius <http://search.cpan.org/~manowar/RadiusPerl-0.12/Radius.pm>`__
as a simple authentication backend.

Currently, the module is simply handling a Radius Authentication request
and has been tested only against a FreeRadius server.

Configuration
-------------

Install Authen::Radius
~~~~~~~~~~~~~~~~~~~~~~

You have to install the corresponding Perl module.

For CentOS/RHEL:

.. code-block:: shell

   yum install perl-Authen-Radius

In Debian/Ubuntu, install the library through apt-get command

.. code-block:: shell

   apt-get install libauthen-radius-perl

Configuration of LL::NG
~~~~~~~~~~~~~~~~~~~~~~~

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Radius for authentication.


.. tip::

    You can then choose any other module for users and
    password.

Then, go in ``Radius parameters``:

-  **Authentication level**: authentication level for Radius module
-  **Shared secret**: this is the passphrase to use to connect to the
   Radius server
-  **Server hostname**: this is the hostname or IP address of the Radius
   server
-  **Exported variables**: radius attributes stored in user session at
   authentication time. key is name in user session and value is
   attribute name in radius dictionary.
-  **Dictionary**: radius dictionary file ex: /etc/freeradius/3.0/dictionary.
   This is mandatory to handle attributes as names.

