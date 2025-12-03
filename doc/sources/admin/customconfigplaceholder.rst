Custom configuration placeholder
================================

.. versionadded:: 2.23.0

LemonLDAP::NG optionally supports the ``%SERVERENV:VariableName%`` syntax to read configuration values from the environment.

You may also define additional placeholder syntaxes by creating your own Perl module

Enable and configure your module
--------------------------------

Edit the ``[configuration]`` section in ``lemonldap-ng.ini``

.. code:: ini

   [configuration]

   configPlaceHolderModules=SECRET=Lemonldap::NG::Common::Conf::SecretPlaceholder
   ; optionally configure the module here
   ; secretPlaceholderConfig=my_config


This configuration will call ``Lemonldap::NG::Common::Conf::SecretPlaceholder`` everytime
``%SECRET:MyVariable%`` is encountered in the configuration.

You can define multiple modules by separating them with a comma:

.. code:: ini

   [configuration]

   ; this will dispatch %SECRET:xx%, %DNS:yy% and %VAULT:zz% to each
   ; declared module
   configPlaceHolderModules=SECRET=My::Secret, DNS=My::DNS, VAULT=My::Vault

Write your custom module
------------------------

Here is an example of a Perl module that implements a configuration placeholder:

.. code:: perl

    # Must be stored in Lemonldap/NG/Common/Conf/SecretPlaceholder.pm
    package Lemonldap::NG::Common::Conf::SecretPlaceholder;

    use strict;

    # You must define a replace function
    sub replace {
        # The function takes:
        # * current module name
        # * current configuration hash
        # * variable name to look up
        my ( $class, $conf, $variable ) = @_;

        # You can read configuration options (vault server IP, etc)
        # from the ini-file configuration here
        my $placeholder_config = $conf->{secretPlaceholderConfig};

        # Obtain and return the value to be used in actual configuration
        my $value = implement_this($variable);

        return $value;
    }
    1;

