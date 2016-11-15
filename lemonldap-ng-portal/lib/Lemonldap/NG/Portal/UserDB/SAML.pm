package Lemonldap::NG::Portal::UserDB::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

use Lemonldap::NG::Common::Conf::SAML::Metadata;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Portal::Lib::SAML';

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Load SAML service and SAML SP list
    return ( $self->SUPER::init and $self->loadSPs );
}

1;
