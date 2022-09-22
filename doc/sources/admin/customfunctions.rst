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

LemonLDAP::NG Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Edit ``lemonldap-ng.ini`` to load the Perl module(s)

::

   [all]
   require = /path/to/SSOExtensions.pm
   ; Prevent Portal to crash if Perl module is not found
   ;requireDontDie = 1


Declare custom functions
~~~~~~~~~~~~~~~~~~~~~~~~

Go in Manager, ``General Parameters`` » ``Advanced Parameters`` »
``Custom functions`` and declare your function names, separated by a space:

::

   SSOExtensions::function1 SSOExtensions::function2


.. attention::

    If your function is not compliant with
    :doc:`Safe jail<safejail>`, you will need to disable the jail.

Usage
-----

You can now use your function in a macro, an header or an access rule,
for example:

::

   function1( $uid, $ENV{REMOTE_ADDR} )

