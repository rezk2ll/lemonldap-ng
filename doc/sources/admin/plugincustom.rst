Write a custom plugin
=====================

Presentation
------------

You can now write a custom portal plugin that will hook in the
authentication process:

-  ``beforeAuth``: method called before authentication process
-  ``betweenAuthAndData``: method called after authentication and before
   setting "sessionInfo" provisionning
-  ``afterData``: method called after "sessionInfo" provisionning
-  ``endAuth``: method called when session is validated (after cookie
   build)
-  ``authCancel``: method called when user click on "cancel" during auth
   process
-  ``forAuthUser``: method called for already authenticated users
-  ``beforeLogout``: method called before logout

If you need to call a method just after any standard method in
authentication process, then use ``afterSub``, for example:

.. code:: perl

     use constant afterSub => {
         getUser => 'mysub',
     }
     sub mysub {
         my ( $self ,$req ) = @_;
         # Do something
         return PE_OK;
     }

If you need to call a method instead any standard method in
authentication process, then use ``aroundSub``, for example:

.. code:: perl

     use constant aroundSub => {
         getUser => 'mysub',
     };
     sub mysub {
         my ( $self, $sub, $req ) = @_;
         # Do something before
         my $ret = $sub->($req);
         # Do something after
         return $ret;
     }

The plugin can also define new routes and call actions on them.

See also ``Lemonldap::NG::Portal::Main::Plugin`` man page.

Example
-------

Plugin Perl module
~~~~~~~~~~~~~~~~~~

Create for example the MyPlugin module:

::

   vi /usr/share/perl5/Lemonldap/NG/Portal/MyPlugin.pm


.. tip::

    If you do not want to mix files from the distribution with
    your own work, put your own code in
    ``/usr/local/lib/site_perl/Lemonldap/NG/Portal/MyPlugin.pm``\

.. code:: perl

   package Lemonldap::NG::Portal::MyPlugin;

   use Mouse;
   use Lemonldap::NG::Portal::Main::Constants;
   extends 'Lemonldap::NG::Portal::Main::Plugin';

   use constant beforeAuth => 'verifyIP';

   sub init {
             my ($self) = @_;
             $self->addUnauthRoute( mypath => 'hello', [ 'GET', 'PUT' ] );
             $self->addAuthRoute( mypath => 'welcome', [ 'GET', 'PUT' ] );
             return 1;
   }
   sub verifyIP {
             my ($self, $req) = @_;
             return PE_ERROR if($req->address !~ /^10/);
             return PE_OK;
   }
   sub hello {
             my ($self, $req) = @_;
             ...
             return $self->p->sendJSONresponse($req, { hello => 1 });
   }
   sub welcome {
             my ($self, $req) = @_;

             my $userid = $req->user;
             $self->p->logger->debug("Call welcome for $userid");

             ...
             return $self->p->sendHtml($req, 'template', params => { WELCOME => 1 });
   }
   1;

Configuration
~~~~~~~~~~~~~

Declare the plugin in lemonldap-ng.ini:

::

   vi /etc/lemonldap-ng/lemonldap-ng.ini

.. code:: perl

   [portal]
   customPlugins = Lemonldap::NG::Portal::MyPlugin
   ;customPlugins = Lemonldap::NG::Portal::MyPlugin1, Lemonldap::NG::Portal::MyPlugin2, ...

Since 2.0.7, it can also be configured in Manager, in General Parameters
> Plugins > Custom Plugins.
