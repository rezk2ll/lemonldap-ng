Custom handlers
===============

LLNG provides Perl libraries that can be easily used by inheritance. So
you can write your own handlers but you need first to understand
:doc:`Handler architecture<handlerarch>`

Add a new handler type
----------------------

#. Write your new Module (in Lemonldap/NG/Handler/Lib for example) that
   overload some Lemonldap::NG::Handler::Main methods
#. Write a wrapper in each platform directory *(see
   Lemonldap::NG::Handler::Apache2::AuthBasic or
   Lemonldap::NG::Handler::Server::AuthBasic for examples)*

Wrapper usually look at this:

.. code-block:: perl

   package Lemonldap::NG::Handler::ApacheMP2::MyType;

   use base 'Lemonldap::NG::Handler::ApacheMP2::Main', 'Lemonldap::NG::Handler::Lib::MyType';

   1;

Enable it
~~~~~~~~~

Your wrappers must be named "Lemonldap::NG::Handler::<platform>::<type>"
where <platform> is the target (ApacheMP2 or Server) and <type> is the
name you've chosen.

You can enable it either:

-  by setting a ``PerlSetVar VHOSTTYPE <type>`` in the Apache
   configuration file
-  by setting a ``fastcgi_param VHOSTTYPE <type>`` in the Nginx
   configuration file
-  by adding it to the menu: add its name in ``vhostType`` "select"
   declaration (file
   ``lemonldap-ng-manager/lib/Lemonldap/NG/Build/Attributes``) and
   rebuild LLNG

Note that configuration parameter can be set only in lemonldap-ng.ini
configuration file *(section Handler)*.

Add a new platform
------------------

LLNG provides 3 platforms:

-  ApacheMP2
-  FastCGI server *(Nginx is build from there)*
-  Auto-protected PSGI

If you want to add another, you must write:

-  the platform launcher file that launch the required type (see
   ``lemonldap-ng-handler/lib/Lemonldap/NG/Handler/ApacheMP2`` file for
   example)
-  write the main platform file
   (``Lemonldap::NG::Handler::MyPlatform::Main``) that provides required
   method (see ``lemonldap-ng-handler/lib/Lemonldap/NG/Handler/*/Main``
   for examples) and inherits from ``Lemonldap::NG::Handler::Main``
-  write the "type" wrapper files (AuthBasic,...).

Wrapper usually look at this:

.. code-block:: perl

   package Lemonldap::NG::Handler::MyPlatform::AuthBasic;

   use base 'Lemonldap::NG::Handler::MyPlatform::Main', 'Lemonldap::NG::Handler::Lib::AuthBasic';

   1;

Old fashion Nginx handlers
--------------------------


.. attention::

    There is no need to use this feature now. It is kept for
    compatibility.

Three actions are needed:

-  declare your own module in the manager "General Parameters >>
   Advanced Parameters >> Custom handlers (Nginx)". Key is the name that
   will be used below and value is the name of the custom package,
-  in your Nginx configuration file, add ``LLTYPE=<name>;`` in the
   ``location = /lmauth {...}`` paragraph
-  restart FastCGI server(s) *(reload is not enough here)*
