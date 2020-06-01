Protect your application
========================

Presentation
------------

Your application can know the connected user using:

-  REMOTE_USER environment variable (with local Handler or SetEnvIf
   trick)
-  HTTP header (in all cases)

To get more information on user (name, mail, etc.), you have to read
:ref:`HTTP headers<headers>`.


.. tip::

    If your application is based on `Perl CGI package
    <http://search.cpan.org/perldoc?CGI>`__, you can simply replace CGI by
    :ref:`Lemonldap::NG::Handler::CGI<selfmadeapplication-perl-auto-protected-cgi>`

Code snippet
------------

Examples with a :ref:`configured header<headers>` named
'Auth-User':

Perl
~~~~

.. code-block:: perl

   print "Connected user: ".$ENV{HTTP_AUTH_USER};

PHP
~~~

.. code-block:: php

   print "Connected user: ".$_SERVER["HTTP_AUTH_USER"];

.. _selfmadeapplication-perl-auto-protected-cgi:

Perl auto-protected CGI
-----------------------

LL::NG now uses FastCGI instead of CGI, but you still can write your own
protected CGI.

First create a PSGI module based on Lemonldap::NG::Handler:

.. code-block:: perl

   package My::PSGI;

   use base "Lemonldap::NG::Handler::PSGI"; # or Lemonldap::NG::Handler::PSGI::OAuth2, etc…

   sub init {
       my ($self,$args) = @_;
       $self->protection('manager');
       $self->SUPER::init($args) or return 0;
       $self->staticPrefix("/static");
       $self->templateDir("/usr/share/lemonldap-ng/portal/templates");
       # See Lemonldap::NG::Common::PSGI for more
       #...
       # Return a boolean. If false, then error message has to be stored in
       # $self->error
       return 1;
   }

   sub handler {
       my ( $self, $req ) = @_;

       # Will be called only if authorisated
       my $userId = $self->userId($req);
       #...

       # Return JSON
       # $self->sendJSONresponse(...);

       # or Return HTML
       $self->sendHtml($req, "myskin/mytemplate", ( params => { 'userId' => $userId }) );
   }

They create a FCGI script like this:

.. code-block:: perl

   #!/usr/bin/env perl

   use My::PSGI;
   use Plack::Handler::FCGI;

   Plack::Handler::FCGI->new->run( My::PSGI->run() );

See our LLNG Nginx/Apache configurations to see how to launch it or read
`PSGI/Plack documentation <https://plackperl.org/>`__.

The protection parameter must be set when calling the init() method:

-  ``none``: no protection
-  ``authenticate``: check authentication but do not manage
   authorization
-  ``manager``: rely on virtual host configuration in Manager
-  ``rule: xxx``: apply a specific rule
