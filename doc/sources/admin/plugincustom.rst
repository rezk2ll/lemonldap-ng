Write a custom plugin
=====================

Presentation
------------

Portal plugins let you customize LemonLDAP::NG's behavior.

Common use cases for plugins are:

* Looking up session information in an additional backend
* Implementing additional controls or steps during login
* Adjusting the behavior of SAML, OIDC or CAS protocols to work around application bugs

Creating a plugin can be as simple as writing a short Perl module file and
declaring it in your configuration. See below for an example.

Plugin API
----------

Authentication entry points
~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Generic entry points
~~~~~~~~~~~~~~~~~~~~

If you need to call a method just after any standard method in
authentication process, then use ``afterSub``, for example:

.. code-block:: perl

     use constant afterSub => {
         getUser => 'mysub',
     };
     sub mysub {
         my ( $self ,$req ) = @_;
         # Do something
         return PE_OK;
     }

If you need to call a method instead any standard method in
authentication process, then use ``aroundSub``, for example:

.. code-block:: perl

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


Hooks
~~~~~

.. versionadded:: 2.0.10

Your plugin can also register itself to be called at some points of interest
within the main LemonLDAP::NG code.

Check the :doc:`list of available plugin hooks <hooks>` for details

Routes
~~~~~~

The plugin can also define new routes and call actions on them.

See also ``Lemonldap::NG::Portal::Main::Plugin`` man page.

Configuration
~~~~~~~~~~~~~

The current LemonLDAP::NG configuration can be accessed in the ``$self->conf`` hash. This variable is only meant to be read. Don't try changing its content, or *Bad Things* may happen.

You can set your own parameters in ``General Parameters`` » ``Plugins`` » ``Custom plugins`` » ``Additional parameters``
and reach them through ``customPluginsParams``

.. code-block:: perl

    sub my_function {
        my ($self, $req) = @_;

        # Get a standard LLNG option
        my $llng_logo = $self->conf->{portalMainLogo};

        # Get your custom LLNG option
        my $myvar = $self->conf->{customPluginsParams}->{myvar};
        }

Logs
~~~~

You can use the ``$self->logger`` and ``$self->userLogger`` objects to log information during your plugin execution. Use ``logger`` for technical logs and ``userLogger`` for accounting and tracability events.

.. code-block:: perl

    sub my_function {
        my ($self, $req) = @_;

        $self->logger->debug("Debug message");
        if (my_custom_test($req->user)) {
            $self->userLogger->debug("User ". $req->user .
                " is not allowed because XXX");

            return PE_ERROR;
        }
        return PE_OK;
    }


Remembering data
~~~~~~~~~~~~~~~~

In order to remember data between different steps, you can use the ``$req->data`` hash.

Data will not be remembered in between requests, only in between methods that process the same HTTP request.

History management
~~~~~~~~~~~~~~~~~~

Plugins may declare additional session fields to be stored in the :doc:`loginhistory`.

.. code:: perl

    sub init {
        my ($self) = @_;

        $self->addSessionDataToRemember({
            # This field will be hidden from the user
            _language => '__hidden__',

            # This field will be displayed on the portal. The column name
            # is treated like a message and can be internationalized
            authenticationLevel => "Human friendly column name",
        });
        return 1;
    }

Column names can be translated by :ref:`overriding the corresponding message <intlmessages>`

.. _pluginppolicy:

Password policies
~~~~~~~~~~~~~~~~~

You can implement custom password policies in your plugins.

In order to do this, implement the :ref:`passwordBeforeChange hook <passwordBeforeChange>`.

If you want to display user feedback, you need to do two additional things

* In you plugin's ``init`` method, declare a HTML control for your policy ::

    $self->p->addPasswordPolicyDisplay(
        'ppolicy-custom1',
        {
            # Activation condition
            condition => $self->conf->{customPluginsParams}->{myPpolicyEnabled},
            # Label to show the user
            label     => "myppolicy",
            # What value to display in front of the label
            value     => 1,
            # Optional key-value HTML data-* elements
            data => { },
            # Custom HTML code to inject before the element
            customHtml => qq'<script type="text/javascript" src="$self->{p}->{staticPrefix}/common/js/myppolicy.min.js"></script>',
            # Custom HTML code to inject after the element
            customHtmlAfter => qq'<div id="advanced_feedback"></div>',
            # Optional display order, higher goes last
            order => 100,
        }
    );

* Implement a JS check and trigger it on the :ref:`checkpassword event <checkpassword>`

Creating a second factor module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Adding a new type of second factor requires one or two modules:

* A module for using the second factor during authentication

This module must inherit from ``Lemonldap::NG::Portal::Main::SecondFactor``.

.. code:: perl

    package My::SFA;

    use strict;
    use Mouse;

    extends 'Lemonldap::NG::Portal::Main::SecondFactor';

* (optional) A module for registering the second factor

This module must inherit from ``Lemonldap::NG::Portal::2F::Register::Base``.

.. code:: perl

    package My::SFARegister;

    use strict;
    use Mouse;

    extends 'Lemonldap::NG::Portal::2F::Register::Base';

Custrom entry points
~~~~~~~~~~~~~~~~~~~~

Entrypoints allow plugins to register custom actions when they are loaded.
LemonLDAP::NG comes with many pre-defined entrypoints already. But you may want
to add your own, especially if you are creating a plugin that can itself have
plugins.

You can call the ``addEntryPoint`` method in your plugin's ``init`` to
create your custom entrypoints.

.. note::

   Only plugins loaded *after* registering the entry point will trigger it. Be
   careful with the ordering of your ``customPlugins`` variable.

Here are a few examples:

.. code:: perl

    sub init {
        my ($self) = @_;

        # ...

        # From now on, when loading a new plugin that inherits from
        # My::Base::Class, run the provided code reference, with an
        # instance of the plugin being loaded as first argument
        $self->addEntryPoint(
            isa      => "My::Base::Class",
            callback => sub {
                my ($plugin) = @_;
                $self->do_domething_with($plugin);
            }
        );

        # From now on, when loading a new plugin that uses My::Role
        # Call a particular method of a particular service, passing the new
        # plugins instance and optional extra arguments.
        # This will effectively run:
        #  $portal->getService('myservice')
        #         ->mymethod($plugin, "role_entry_point")
        $self->addEntryPoint(
            does    => "My::Role",
            service => "myservice",
            method  => "mymethod",
            args    => ["role_entry_point"],
        );

        # ...
        return 1;
    }

See also ``Lemonldap::NG::Portal::Main::Plugin`` man page for full details.

Example
-------

Plugin Perl module
~~~~~~~~~~~~~~~~~~

This example creates a ``Lemonldap::NG::Portal::Plugins::MyPlugin`` plugin that
showcases some features of the plugin system.

First, create a file to contain the plugin code ::

   vi /usr/share/perl5/Lemonldap/NG/Portal/Plugins/MyPlugin.pm

.. tip::

    If you do not want to mix files from the distribution with
    your own work, put your own code in
    ``/usr/local/lib/site_perl/Lemonldap/NG/Portal/Plugins/MyPlugin.pm``.
    Or you can use your own namespace such as ``ACME::Corp::MyPlugin``.

.. code-block:: perl

   # The package name must match the file path
   # This file must be in Lemonldap/NG/Portal/Plugins/MyPlugin.pm
   package Lemonldap::NG::Portal::Plugins::MyPlugin;

   use Mouse;
   use Lemonldap::NG::Portal::Main::Constants;
   extends 'Lemonldap::NG::Portal::Main::Plugin';

   # Declare when LemonLDAP::NG must call your functions
   use constant beforeAuth => 'verifyIP';
   use constant hook => { passwordAfterChange  => 'logPasswordChange' };

   # This function will be called at the "beforeAuth" login step
   sub verifyIP {
             my ($self, $req) = @_;
             return PE_ERROR if($req->address !~ /^10/);
             return PE_OK;
   }

   # This function will be called when changing passwords
   sub logPasswordChange {
       my ( $self, $req, $user, $password, $old ) = @_;
       $self->userLogger->info("Password changed for $user");
       return PE_OK;
   }

   # You can define your custom initialization in the
   # init method.
   # Before LemonLDAP::NG 2.0.14, this function was mandatory
   sub init {
             my ($self) = @_;

             # This is how you declare HTTP routes
             $self->addUnauthRoute( mypath => 'hello', [ 'GET', 'PUT' ] );
             $self->addAuthRoute( mypath => 'welcome', [ 'GET', 'PUT' ] );

             # The function can return 0 to indicate failure
             return 1;
   }

   # This method will be called to handle unauthenticated requests to /mypath
   sub hello {
             my ($self, $req) = @_;
             ...
             return $self->p->sendJSONresponse($req, { hello => 1 });
   }

   # This method will be called to handle authenticated requests to /mypath
   sub welcome {
             my ($self, $req) = @_;

             my $userid = $req->user;
             $self->p->logger->debug("Call welcome for $userid");

             ...
             return $self->p->sendHtml($req, 'template', params => { WELCOME => 1 });
   }

   # Your file must return 1, or Perl will complain.
   1;


Enabling your plugin
~~~~~~~~~~~~~~~~~~~~

Declare the plugin in lemonldap-ng.ini:

::

   vi /etc/lemonldap-ng/lemonldap-ng.ini

.. code-block:: perl

   [portal]
   customPlugins = Lemonldap::NG::Portal::Plugins::MyPlugin
   ;customPlugins = Lemonldap::NG::Portal::Plugins::MyPlugin1, Lemonldap::NG::Portal::Plugins::MyPlugin2, ...

Since 2.0.7, it can also be configured in Manager, in General Parameters
> Plugins > Custom Plugins.
