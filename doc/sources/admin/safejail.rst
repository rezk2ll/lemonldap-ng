Safe jail
=========

Presentation
------------

LemonLDAP::NG uses Safe jail to evaluate all expressions:

-  Access rules
-  Headers
-  Form replay parameters
-  Macros
-  Groups
-  Conditions:

   -  Menu modules display
   -  Multi modules display
   -  IssuerDB use
   -  Session opening

More information about Safe on
`CPAN <http://search.cpan.org/search?query=Safe&mode=module>`__

Disable Safe jail
-----------------

Safe can be very annoying when using
:doc:`extended functions<extendedfunctions>` or
:doc:`custom functions<customfunctions>`. In this case, you might want
to disable it.

To do this, go into Manager > General Parameters > Advanced Parameters >
Security > Use Safe Jail and disable it.


Assignment test
===============

Presentation
------------

Perl comparaisons are done by using ``eq`` for strings or ``==`` for integers.
To avoid an unwanted assignment like ``$authLevel = 5`` (BAD EXPRESSION!),
you can enable ``Avoid assignment in expressions`` option.

To do this, go into Manager > General Parameters > Advanced Parameters >
Security > Avoid assignment in expressions and enable it.

DISABLE by default.