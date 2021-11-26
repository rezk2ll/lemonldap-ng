Custom functions
================

Custom functions allow one to extend LL::NG, they can be used in
:ref:`headers`,
:ref:`rules` or
:doc:`form replay data<formreplay>`. Two actions are needed:

-  declare them in LLNG configuration
-  load the relevant code

Implementation
--------------

Your perl custom functions must be declared on appropriate server when
separating:

**Portal type**: declare custom functions here when using it in rules,
macros or menu.

**Reverse-proxy type**: declare custom functions here when using it in
headers.

Write custom functions library
------------------------------

Create your Perl module with custom functions. You can name your module
as you want, for example ``SSOExtensions.pm``:

::

   vi /path/to/SSOExtensions.pm

.. code-block:: perl

   package SSOExtensions;

   sub function1 {
     my (@args) = @_;

     # Your nice code here
     return $result;
   }

   sub function2 {
     return $_[0];
   }

   1;

Import custom functions in LemonLDAP::NG
----------------------------------------

Load relevant code in handler server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

New method
^^^^^^^^^^

Just declare files or Perl module that must be loaded:

::

   [all]
   require = /path/to/functions.pl, /path/to/SSOExtensions.pm
   # OR
   require = SSOExtensions::function1, SSOExtensions::function2
   ; Prevent Portal to crash if Perl module is not found
   ;requireDontDie = 1

Old method
^^^^^^^^^^


.. danger::

    This method is available but unusable by Portal under
    Apache. So if your rule may be used by the menu, use the new
    method.

Apache
''''''

Your module has to be loaded by Apache (for example after Handler load):

.. code-block:: apache

   # Perl environment
   PerlRequire Lemonldap::NG::Handler
   PerlRequire /path/to/SSOExtensions.pm
   PerlOptions +GlobalRequest

FastCGI server (Nginx)
''''''''''''''''''''''

You've just to incicate to :doc:`LLNG FastCGI server<fastcgiserver>` the
file to read using either ``-f`` option or ``CUSTOM_FUNCTIONS_FILE``
environment variable. Using packages, you just have to modify your
``/etc/default/llng-fastcgi-server`` (or
``/etc/default/lemonldap-ng-fastcgi-server``) file:

.. code-block:: sh

   # Number of process (default: 7)
   #NPROC = 7

   # Unix socket to listen to
   SOCKET=/var/run/llng-fastcgi-server/llng-fastcgi.sock

   # Pid file
   PID=/var/run/llng-fastcgi-server/llng-fastcgi-server.pid

   # User and GROUP
   USER=www-data
   GROUP=www-data

   # Custom functions file
   CUSTOM_FUNCTIONS_FILE=/path/to/SSOExtensions.pm

Declare custom functions
~~~~~~~~~~~~~~~~~~~~~~~~

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Custom functions`` and set:

::

   SSOExtensions::function1, SSOExtensions::function2


.. attention::

    If your function is not compliant with
    :doc:`Safe jail<safejail>`, you will need to disable the jail.

Use it
------

You can now use your function in a macro, an header or an access rule,
for example:

::

   SSOExtensions::function1( $uid, $ENV{REMOTE_ADDR} )

