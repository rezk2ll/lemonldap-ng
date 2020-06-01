Deploy LemonLDAP::NG on a Plack server
======================================

`Plack <https://metacpan.org/release/Plack>`__ is a powerful engine that
powers many very fast `servers <http://plackperl.org/#servers>`__. LLNG
uses some Plack libraries to run as FastCGI server. So, It can be easily
run on these servers. See also :doc:`Advanced PSGI usage<psgi>` if you
want to replace LLNG FastCGI server.

Complete example
----------------

.. code-block:: perl

   #!/usr/bin/perl

   use Data::Dumper;
   use Plack::Builder;

   # Basic test app
   my $testApp = sub {
       my ($env) = @_;
       return [
           200,
           [ 'Content-Type' => 'text/plain' ],
           [ "Hello LLNG world\n\n" . Dumper($env) ],
       ];
   };

   # Build protected app
   my $test = builder {
       enable "Auth::LemonldapNG";
       $testApp;
   };

   # Build portal app
   use Lemonldap::NG::Portal::Main;
   my $portal = builder {
       enable "Plack::Middleware::Static",
         path => '^/static/',
         root => '/path/to/portal/htdocs/';
       Lemonldap::NG::Portal::Main->run( {} );
   };

   # Build manager app
   use Lemonldap::NG::Manager;
   my $manager = builder {
       enable "Plack::Middleware::Static",
         path => '^/static/',
         root => '/path/to/manager/htdocs/';
       enable "Plack::Middleware::Static",
         path => '^/doc/',
         root => '/path/to/dir/that/contains/"doc"';
       enable "Plack::Middleware::Static",
         path => '^/lib/',
         root => '/path/to/doc/pages/documentation/current/';
       Lemonldap::NG::Manager->run( {} );
   };

   # Global app
   builder {
       mount 'http://test1.example.com/'   => $test;
       mount 'http://auth.example.com/'    => $portal;
       mount 'http://manager.example.com/' => $manager;
   };

Launch it with `Starman <https://github.com/miyagawa/Starman>`__ for
example:

::

   $ starman --port 80 --workers 32 llapp.psgi

